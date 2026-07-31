#include "ChatController.h"

#include "../../../libs/protocol/ChatProtocol.h"

#include <QCoreApplication>
#include <QClipboard>
#include <QCryptographicHash>
#include <QDateTime>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QGuiApplication>
#include <QJsonArray>
#include <QJsonDocument>
#include <QMap>
#include <QMimeDatabase>
#include <QRandomGenerator>
#include <QRegularExpression>
#include <QStandardPaths>
#include <QStyleHints>
#include <QUuid>

#include <utility>

namespace
{
QString normalizedTheme(const QString& value)
{
	return value == "dark" || value == "light" || value == "system"
		? value : "system";
}

QVariantList variantList(const QJsonArray& array)
{
	return array.toVariantList();
}
}

ChatController::ChatController(QObject* parent)
	: QObject(parent)
	, m_settings("RubbageChat", "RubbageChat")
{
	QSettings runtimeConfig(QCoreApplication::applicationDirPath() + "/rubbagechat.ini",
		QSettings::IniFormat);
	m_bootstrapUrl = QUrl(qEnvironmentVariable("RUBBAGECHAT_BOOTSTRAP_URL",
		runtimeConfig.value("network/bootstrapUrl").toString()).trimmed());
	m_serverHost = qEnvironmentVariable("RUBBAGECHAT_SERVER_HOST",
		runtimeConfig.value("network/host", "127.0.0.1").toString()).trimmed();
	bool chatPortOk = false;
	const int chatPort = qEnvironmentVariable("RUBBAGECHAT_CHAT_PORT",
		runtimeConfig.value("network/chatPort", 7502).toString()).toInt(&chatPortOk);
	m_chatPort = chatPortOk && chatPort > 0 && chatPort <= 65535 ? chatPort : 7502;
	if (m_serverHost.isEmpty())
		m_serverHost = "127.0.0.1";
	m_tlsEnabled = qEnvironmentVariable("RUBBAGECHAT_TLS",
		runtimeConfig.value("security/tls", false).toString())
		.trimmed().toLower() == "true";

	m_theme = normalizedTheme(m_settings.value("appearance/theme", "system").toString());
	m_notificationsEnabled = m_settings.value("notifications/enabled", true).toBool();
	m_enterToSend = m_settings.value("chat/enterToSend", true).toBool();
	m_showOnlineStatus = m_settings.value("privacy/showOnlineStatus", true).toBool();
	m_compactMode = m_settings.value("appearance/compactMode", false).toBool();
	m_deviceId = m_settings.value("identity/deviceId").toString();
	if (m_deviceId.isEmpty()) {
		m_deviceId = QUuid::createUuid().toString(QUuid::WithoutBraces);
		saveSetting("identity/deviceId", m_deviceId);
	}

	m_reconnectTimer.setSingleShot(true);
	connect(&m_reconnectTimer, &QTimer::timeout,
		this, &ChatController::connectToServer);
	connect(&m_socket, &QTcpSocket::connected, this, [this]() {
		if (m_tlsEnabled)
			return;
		setConnected(true);
		flushOutbox();
		if (m_authenticated && !m_token.isEmpty())
			refreshAll();
	});
	connect(&m_socket, &QSslSocket::encrypted, this, [this]() {
		setConnected(true);
		flushOutbox();
		if (m_authenticated && !m_token.isEmpty())
			refreshAll();
	});
	connect(&m_socket, &QSslSocket::sslErrors, this,
		[this](const QList<QSslError>& errors) {
			m_tlsBlocked = true;
			m_reconnectTimer.stop();
			QStringList messages;
			for (const QSslError& error : errors)
				messages.append(error.errorString());
			showToast(QStringLiteral("TLS 证书校验失败：%1")
				.arg(messages.join("; ")), true);
			m_socket.disconnectFromHost();
		});
	connect(&m_socket, &QTcpSocket::readyRead,
		this, &ChatController::processIncomingData);
	connect(&m_socket, &QTcpSocket::disconnected, this, [this]() {
		setConnected(false);
		scheduleReconnect();
	});
	connect(&m_socket, &QTcpSocket::errorOccurred, this,
		[this](QAbstractSocket::SocketError) {
			setConnected(false);
			scheduleReconnect();
		});

	m_pingTimer.setInterval(25000);
	connect(&m_pingTimer, &QTimer::timeout, this, [this]() {
		if (m_connected)
			sendRequest("ping", {}, false);
	});
	m_pingTimer.start();
	connect(QGuiApplication::styleHints(), &QStyleHints::colorSchemeChanged,
		this, &ChatController::settingsChanged);
	connect(&m_endpointDiscovery, &EndpointDiscovery::resolved,
		this, [this](const QString& host, int port, bool tls) {
			m_serverHost = host;
			m_chatPort = port;
			m_tlsEnabled = tls;
			m_tlsBlocked = false;
			connectToServer();
		});
	m_endpointDiscovery.resolve(m_bootstrapUrl,
		{m_serverHost, quint16(m_chatPort), m_tlsEnabled});
}

ChatController::~ChatController()
{
	m_reconnectTimer.stop();
	m_pingTimer.stop();
	m_socket.abort();
}

void ChatController::connectToServer()
{
	if (m_tlsBlocked)
		return;
	if (m_socket.state() == QAbstractSocket::ConnectedState
		|| m_socket.state() == QAbstractSocket::ConnectingState)
		return;
	m_socket.abort();
	if (m_tlsEnabled)
		m_socket.connectToHostEncrypted(m_serverHost, quint16(m_chatPort));
	else
		m_socket.connectToHost(m_serverHost, quint16(m_chatPort));
}

void ChatController::scheduleReconnect()
{
	if (m_tlsBlocked || m_reconnectTimer.isActive())
		return;
	const int exponent = qMin(m_reconnectAttempts, 5);
	const int baseDelay = qMin(30000, 1000 * (1 << exponent));
	const int jitter = QRandomGenerator::global()->bounded(501);
	m_reconnectTimer.setInterval(baseDelay + jitter);
	++m_reconnectAttempts;
	m_reconnectTimer.start();
}

void ChatController::setConnected(bool value)
{
	if (value) {
		m_reconnectAttempts = 0;
		m_reconnectTimer.stop();
	}
	if (m_connected == value)
		return;
	m_connected = value;
	emit connectedChanged();
}

QString ChatController::sendRequest(const QString& action,
	const QJsonObject& data, bool authenticated)
{
	if (authenticated && (!m_authenticated || m_token.isEmpty())) {
		showToast(QStringLiteral("请先登录"), true);
		return {};
	}
	QJsonObject packet = ChatProtocol::request(
		action, data, authenticated ? m_token : QString(), {}, m_deviceId);
	const QString requestId = packet.value("requestId").toString();
	m_pendingActions.insert(requestId, action);
	if (authenticated && action == "send_message")
		m_reliableOutbox.enqueue(m_currentUserAccount, packet);
	if (m_socket.state() == QAbstractSocket::ConnectedState)
		m_socket.write(ChatProtocol::encode(packet));
	else {
		if (action != "send_message")
			m_outbox.append(packet);
		connectToServer();
	}
	return requestId;
}

void ChatController::flushOutbox()
{
	const QList<QJsonObject> queued = std::exchange(m_outbox, {});
	for (QJsonObject packet : queued) {
		if (!packet.value("token").toString().isEmpty() && !m_token.isEmpty())
			packet.insert("token", m_token);
		packet.insert("deviceId", m_deviceId);
		m_socket.write(ChatProtocol::encode(packet));
	}
	if (!m_authenticated || m_token.isEmpty())
		return;
	for (QJsonObject packet : m_reliableOutbox.pending(m_currentUserAccount)) {
		packet.insert("token", m_token);
		packet.insert("deviceId", m_deviceId);
		const QString requestId = packet.value("requestId").toString();
		m_pendingActions.insert(requestId, packet.value("action").toString());
		m_socket.write(ChatProtocol::encode(packet));
	}
}

void ChatController::login(const QString& account, const QString& password)
{
	const QString cleanAccount = account.trimmed();
	if (!QRegularExpression("^\\d{9}$").match(cleanAccount).hasMatch()) {
		showToast(QStringLiteral("账号必须是 9 位数字"), true);
		return;
	}
	if (password.isEmpty()) {
		showToast(QStringLiteral("请输入密码"), true);
		return;
	}
	sendRequest("login", {{"account", cleanAccount}, {"password", password}}, false);
}

void ChatController::registerAccount(const QString& name,
	const QString& password, const QString& confirmation)
{
	if (name.trimmed().size() < 2 || name.trimmed().size() > 20) {
		showToast(QStringLiteral("昵称需要 2-20 个字符"), true);
		return;
	}
	if (password.size() < 8 || password.size() > 72) {
		showToast(QStringLiteral("密码需要 8-72 个字符"), true);
		return;
	}
	if (password != confirmation) {
		showToast(QStringLiteral("两次输入的密码不一致"), true);
		return;
	}
	sendRequest("register", {{"name", name.trimmed()}, {"password", password}}, false);
}

void ChatController::logout()
{
	if (!m_token.isEmpty())
		sendRequest("logout");
	resetIdentity();
	showToast(QStringLiteral("已退出当前账号"));
}

void ChatController::resetIdentity()
{
	m_token.clear();
	m_authenticated = false;
	m_currentUserAccount.clear();
	m_currentUserName.clear();
	m_currentUserSignature.clear();
	m_selectedPeerAccount.clear();
	m_selectedPeerName.clear();
	m_selectedPeerOnline = false;
	m_contacts.clear();
	m_conversations.clear();
	m_messages.clear();
	m_requests.clear();
	m_searchResult.clear();
	emit authenticatedChanged();
	emit currentUserChanged();
	emit selectedPeerChanged();
	emit contactsChanged();
	emit conversationsChanged();
	emit messagesChanged();
	emit requestsChanged();
	emit searchResultChanged();
}

void ChatController::refreshAll()
{
	if (m_authenticated)
		sendRequest("snapshot");
}

void ChatController::selectPeer(const QString& account)
{
	const QVariantMap peer = peerMap(account);
	if (peer.isEmpty()) {
		showToast(QStringLiteral("联系人不存在"), true);
		return;
	}
	m_selectedPeerAccount = account;
	m_selectedPeerName = peer.value("name").toString();
	m_selectedPeerOnline = peer.value("online").toBool();
	m_messages.clear();
	emit selectedPeerChanged();
	emit messagesChanged();
	sendRequest("history", {{"account", account}, {"limit", 200}});
}

bool ChatController::sendMessage(const QString& text)
{
	const QString body = text.trimmed();
	if (m_selectedPeerAccount.isEmpty()) {
		showToast(QStringLiteral("请先选择联系人"), true);
		return false;
	}
	if (body.isEmpty() || body.size() > 4000) {
		showToast(QStringLiteral("消息长度需要在 1-4000 个字符之间"), true);
		return false;
	}
	const QString clientMessageId =
		QUuid::createUuid().toString(QUuid::WithoutBraces);
	QJsonObject data{
		{"account", m_selectedPeerAccount},
		{"body", body},
		{"clientMessageId", clientMessageId}
	};
	if (!m_replyToId.isEmpty())
		data.insert("replyToId", m_replyToId);
	m_messages.append(QVariantMap{
		{"id", QString()},
		{"clientMessageId", clientMessageId},
		{"body", body},
		{"mine", true},
		{"type", "text"},
		{"status", m_connected ? "sending" : "queued"},
		{"replyToId", m_replyToId},
		{"replyPreview", m_replyPreview},
		{"reactionSummary", QString()},
		{"dayLabel", QStringLiteral("今天")},
		{"time", QDateTime::currentDateTime().toString("HH:mm")}
	});
	emit messagesChanged();
	clearReply();
	sendRequest("send_message", data);
	return true;
}

void ChatController::replyToMessage(
	const QString& messageId, const QString& preview)
{
	m_replyToId = messageId;
	m_replyPreview = preview.left(120);
	showToast(QStringLiteral("已引用该消息，发送下一条消息即可回复"));
}

void ChatController::clearReply()
{
	m_replyToId.clear();
	m_replyPreview.clear();
}

void ChatController::editMessage(const QString& messageId, const QString& body)
{
	if (messageId.isEmpty())
		return;
	sendRequest("edit_message", {{"messageId", messageId}, {"body", body}});
}

void ChatController::recallMessage(const QString& messageId)
{
	if (!messageId.isEmpty())
		sendRequest("recall_message", {{"messageId", messageId}});
}

void ChatController::reactToMessage(
	const QString& messageId, const QString& emoji)
{
	if (!messageId.isEmpty() && !emoji.trimmed().isEmpty())
		sendRequest("react_message",
			{{"messageId", messageId}, {"emoji", emoji.trimmed()}});
}

void ChatController::sendFile(const QUrl& fileUrl)
{
	if (m_selectedPeerAccount.isEmpty()) {
		showToast(QStringLiteral("请先选择联系人"), true);
		return;
	}
	QFile file(fileUrl.toLocalFile());
	if (!file.open(QIODevice::ReadOnly)) {
		showToast(QStringLiteral("无法读取所选文件"), true);
		return;
	}
	if (file.size() <= 0 || file.size() > 6 * 1024 * 1024) {
		showToast(QStringLiteral("文件大小需要在 1 字节到 6 MB 之间"), true);
		return;
	}
	const QByteArray bytes = file.readAll();
	const QFileInfo info(file);
	m_fileTransferActive = true;
	m_fileTransferProgress = 0.5;
	m_fileTransferLabel = QStringLiteral("正在上传 %1").arg(info.fileName());
	emit fileTransferChanged();
	sendRequest("send_file", {
		{"account", m_selectedPeerAccount},
		{"fileName", info.fileName()},
		{"mimeType", QMimeDatabase().mimeTypeForFile(info).name()},
		{"base64", QString::fromLatin1(bytes.toBase64())},
		{"clientMessageId", QUuid::createUuid().toString(QUuid::WithoutBraces)}
	});
}

void ChatController::downloadAttachment(const QString& attachmentId)
{
	if (attachmentId.isEmpty())
		return;
	m_fileTransferActive = true;
	m_fileTransferProgress = 0.5;
	m_fileTransferLabel = QStringLiteral("正在下载附件");
	emit fileTransferChanged();
	sendRequest("download_attachment", {{"attachmentId", attachmentId}});
}

void ChatController::copyText(const QString& text)
{
	if (text.isEmpty())
		return;
	QGuiApplication::clipboard()->setText(text);
	showToast(QStringLiteral("消息已复制"));
}

void ChatController::searchUser(const QString& account)
{
	if (!QRegularExpression("^\\d{9}$").match(account.trimmed()).hasMatch()) {
		showToast(QStringLiteral("请输入 9 位数字账号"), true);
		return;
	}
	sendRequest("search_user", {{"account", account.trimmed()}});
}

void ChatController::sendFriendRequest(const QString& account)
{
	sendRequest("send_friend_request", {{"account", account}});
}

void ChatController::acceptFriendRequest(const QString& account)
{
	sendRequest("accept_friend_request", {{"account", account}});
}

void ChatController::rejectFriendRequest(const QString& account)
{
	sendRequest("reject_friend_request", {{"account", account}});
}

void ChatController::removeFriend(const QString& account)
{
	sendRequest("remove_friend", {{"account", account}});
	if (account == m_selectedPeerAccount) {
		m_selectedPeerAccount.clear();
		m_selectedPeerName.clear();
		m_messages.clear();
		emit selectedPeerChanged();
		emit messagesChanged();
	}
}

QVariantMap ChatController::conversationOptions(const QString& account) const
{
	for (const QVariant& value : m_conversations) {
		const QVariantMap row = value.toMap();
		if (row.value("account").toString() == account)
			return {{"pinned", row.value("pinned", false)},
				{"muted", row.value("muted", false)}};
	}
	return {{"pinned", false}, {"muted", false}};
}

void ChatController::togglePinned(const QString& account)
{
	const bool next = !conversationOptions(account).value("pinned").toBool();
	sendRequest("set_conversation_option",
		{{"account", account}, {"option", "pinned"}, {"value", next}});
}

void ChatController::toggleMuted(const QString& account)
{
	const bool next = !conversationOptions(account).value("muted").toBool();
	sendRequest("set_conversation_option",
		{{"account", account}, {"option", "muted"}, {"value", next}});
}

void ChatController::clearCurrentConversation()
{
	if (m_selectedPeerAccount.isEmpty())
		return;
	sendRequest("clear_conversation", {{"account", m_selectedPeerAccount}});
	m_messages.clear();
	emit messagesChanged();
}

void ChatController::updateProfile(const QString& name, const QString& signature)
{
	sendRequest("update_profile", {{"name", name.trimmed()},
		{"signature", signature.trimmed()}});
}

void ChatController::changePassword(const QString& currentPassword,
	const QString& newPassword, const QString& confirmation)
{
	if (newPassword != confirmation) {
		showToast(QStringLiteral("两次输入的新密码不一致"), true);
		return;
	}
	if (newPassword.size() < 8 || newPassword.size() > 72) {
		showToast(QStringLiteral("新密码需要 8-72 个字符"), true);
		return;
	}
	sendRequest("change_password", {
		{"currentPassword", currentPassword}, {"newPassword", newPassword}});
}

void ChatController::processIncomingData()
{
	m_incomingBuffer.append(m_socket.readAll());
	QList<QJsonObject> packets;
	QString error;
	if (!ChatProtocol::takeFrames(m_incomingBuffer, packets, &error)) {
		showToast(error, true);
		m_socket.disconnectFromHost();
		return;
	}
	for (const QJsonObject& packet : packets)
		processPacket(packet);
}

void ChatController::processPacket(const QJsonObject& packet)
{
	const QString kind = packet.value("kind").toString();
	if (kind == "event") {
		processEvent(packet.value("event").toString(), packet.value("data").toObject());
		return;
	}
	if (kind != "response")
		return;
	const QString requestId = packet.value("requestId").toString();
	const QString action = m_pendingActions.take(requestId);
	m_reliableOutbox.acknowledge(requestId);
	if (!packet.value("ok").toBool()) {
		if (action == "send_file" || action == "download_attachment") {
			m_fileTransferActive = false;
			m_fileTransferProgress = 0;
			m_fileTransferLabel.clear();
			emit fileTransferChanged();
		}
		const QString error = packet.value("error").toString(
			QStringLiteral("服务器请求失败"));
		if (error.contains(QStringLiteral("会话已失效")))
			resetIdentity();
		showToast(error, true);
		return;
	}
	processResponse(action, packet.value("data").toObject());
}

void ChatController::processResponse(const QString& action, const QJsonObject& data)
{
	if (action == "register") {
		m_lastRegisteredAccount = data.value("account").toString();
		emit lastRegisteredAccountChanged();
		showToast(QStringLiteral("注册成功，请使用新账号登录"));
	}
	else if (action == "login") {
		m_token = data.value("token").toString();
		m_currentUserAccount = data.value("account").toString();
		m_currentUserName = data.value("name").toString();
		m_currentUserSignature = data.value("signature").toString();
		m_authenticated = true;
		applySnapshot(data.value("snapshot").toObject());
		emit currentUserChanged();
		emit authenticatedChanged();
		flushOutbox();
		showToast(QStringLiteral("欢迎回来，%1").arg(m_currentUserName));
	}
	else if (action == "snapshot") {
		applySnapshot(data);
	}
	else if (action == "search_user") {
		m_searchResult = data.value("user").toObject().toVariantMap();
		emit searchResultChanged();
		if (m_searchResult.isEmpty())
			showToast(QStringLiteral("未找到该用户"), true);
	}
	else if (action == "history" || action == "sync_messages") {
		applyHistory(data.value("messages").toArray());
		const qint64 cursor = qint64(data.value("nextCursor").toDouble());
		if (cursor > 0 && !m_selectedPeerAccount.isEmpty())
			sendRequest("ack_message", {
				{"account", m_selectedPeerAccount},
				{"seq", double(cursor)},
				{"kind", "read"}
			});
		refreshAll();
	}
	else if (action == "send_message") {
		const QJsonObject message = data.value("message").toObject();
		if (message.value("receiver").toString() == m_selectedPeerAccount)
			mergeMessage(message);
		refreshAll();
	}
	else if (action == "send_file") {
		m_fileTransferActive = false;
		m_fileTransferProgress = 1;
		m_fileTransferLabel = QStringLiteral("文件已发送并保存到服务器");
		emit fileTransferChanged();
		const QJsonObject message = data.value("message").toObject();
		mergeMessage(message);
		refreshAll();
		QTimer::singleShot(1500, this, [this]() {
			m_fileTransferProgress = 0;
			m_fileTransferLabel.clear();
			emit fileTransferChanged();
		});
	}
	else if (action == "download_attachment") {
		const QJsonObject attachment = data.value("attachment").toObject();
		const QByteArray bytes = QByteArray::fromBase64(
			attachment.value("base64").toString().toLatin1());
		const QString expectedHash = attachment.value("sha256").toString();
		const QString actualHash = QString::fromLatin1(
			QCryptographicHash::hash(bytes, QCryptographicHash::Sha256).toHex());
		if (bytes.isEmpty() || actualHash != expectedHash) {
			m_fileTransferActive = false;
			m_fileTransferProgress = 0;
			m_fileTransferLabel.clear();
			emit fileTransferChanged();
			showToast(QStringLiteral("附件校验失败"), true);
			return;
		}
		const QString configured = qEnvironmentVariable("RUBBAGECHAT_DOWNLOAD_PATH");
		const QString directory = configured.isEmpty()
			? QStandardPaths::writableLocation(QStandardPaths::DownloadLocation)
				+ "/RubbageChat" : configured;
		QDir().mkpath(directory);
		const QString safeName = QFileInfo(
			attachment.value("fileName").toString()).fileName();
		QString target = QDir(directory).filePath(safeName);
		if (QFileInfo::exists(target)) {
			target = QDir(directory).filePath(
				QFileInfo(safeName).completeBaseName() + "-"
				+ QDateTime::currentDateTime().toString("yyyyMMdd-HHmmss")
				+ (QFileInfo(safeName).suffix().isEmpty() ? QString()
					: "." + QFileInfo(safeName).suffix()));
		}
		QFile output(target);
		if (!output.open(QIODevice::WriteOnly) || output.write(bytes) != bytes.size()) {
			m_fileTransferActive = false;
			m_fileTransferProgress = 0;
			m_fileTransferLabel.clear();
			emit fileTransferChanged();
			showToast(QStringLiteral("无法保存附件"), true);
			return;
		}
		output.close();
		m_fileTransferActive = false;
		m_fileTransferProgress = 1;
		m_fileTransferLabel = QStringLiteral("附件已保存");
		emit fileTransferChanged();
		showToast(QStringLiteral("附件已保存到 %1").arg(target));
		QTimer::singleShot(1500, this, [this]() {
			m_fileTransferProgress = 0;
			m_fileTransferLabel.clear();
			emit fileTransferChanged();
		});
	}
	else if (action == "send_friend_request") {
		showToast(QStringLiteral("好友申请已发送"));
		refreshAll();
	}
	else if (action == "accept_friend_request"
		|| action == "reject_friend_request"
		|| action == "remove_friend"
		|| action == "set_conversation_option"
		|| action == "clear_conversation"
		|| action == "update_profile") {
		showToast(QStringLiteral("操作成功"));
		refreshAll();
	}
	else if (action == "edit_message"
		|| action == "recall_message"
		|| action == "react_message") {
		mergeMessage(data.value("message").toObject());
	}
	else if (action == "change_password") {
		resetIdentity();
		showToast(QStringLiteral("密码已修改，请重新登录"));
	}
}

void ChatController::processEvent(const QString& event, const QJsonObject& data)
{
	if (event == "state_changed") {
		refreshAll();
	}
	else if (event == "presence") {
		applyPresence(data.value("account").toString(), data.value("online").toBool());
	}
	else if (event == "message") {
		const QString sender = data.value("sender").toString();
		if (sender == m_selectedPeerAccount) {
			mergeMessage(data);
			const qint64 seq = qint64(data.value("seq").toDouble());
			if (seq > 0)
				sendRequest("ack_message", {
					{"account", sender}, {"seq", double(seq)}, {"kind", "read"}});
		}
		if (m_notificationsEnabled && sender != m_selectedPeerAccount)
			showToast(QStringLiteral("收到一条新消息"));
		refreshAll();
	}
	else if (event == "message_committed" || event == "message_updated") {
		const QString sender = data.value("sender").toString();
		const QString receiver = data.value("receiver").toString();
		if (sender == m_selectedPeerAccount || receiver == m_selectedPeerAccount)
			mergeMessage(data);
	}
	else if (event == "message_receipt") {
		const qint64 seq = qint64(data.value("seq").toDouble());
		const QString status = data.value("kind").toString();
		bool changed = false;
		for (qsizetype i = 0; i < m_messages.size(); ++i) {
			QVariantMap message = m_messages.at(i).toMap();
			if (message.value("mine").toBool()
				&& message.value("seq").toLongLong() <= seq) {
				message.insert("status", status);
				m_messages[i] = message;
				changed = true;
			}
		}
		if (changed)
			emit messagesChanged();
	}
	else if (event == "session_revoked") {
		resetIdentity();
		showToast(QStringLiteral("当前设备会话已被撤销"), true);
	}
	else if (event == "heartbeat") {
		sendRequest("ping", {}, false);
	}
	else if (event == "protocol_error") {
		showToast(data.value("message").toString(), true);
	}
}

void ChatController::applySnapshot(const QJsonObject& snapshot)
{
	const QJsonObject profile = snapshot.value("profile").toObject();
	if (!profile.isEmpty()) {
		m_currentUserName = profile.value("name").toString();
		m_currentUserSignature = profile.value("signature").toString();
		emit currentUserChanged();
	}
	m_contacts = variantList(snapshot.value("contacts").toArray());
	m_conversations = variantList(snapshot.value("conversations").toArray());
	m_requests = variantList(snapshot.value("requests").toArray());
	if (!m_selectedPeerAccount.isEmpty()) {
		const QVariantMap peer = peerMap(m_selectedPeerAccount);
		if (peer.isEmpty()) {
			m_selectedPeerAccount.clear();
			m_selectedPeerName.clear();
			m_selectedPeerOnline = false;
			m_messages.clear();
			emit messagesChanged();
		}
		else {
			m_selectedPeerName = peer.value("name").toString();
			m_selectedPeerOnline = peer.value("online").toBool();
		}
		emit selectedPeerChanged();
	}
	emit contactsChanged();
	emit conversationsChanged();
	emit requestsChanged();
}

void ChatController::applyHistory(const QJsonArray& messages)
{
	m_messages.clear();
	for (const QJsonValue& value : messages)
		m_messages.append(messageMap(value.toObject()));
	emit messagesChanged();
}

QVariantMap ChatController::messageMap(const QJsonObject& message) const
{
	const bool recalled = message.value("recalledAt").toDouble() > 0
		|| message.value("status").toString() == "recalled";
	const QDateTime createdAt = QDateTime::fromMSecsSinceEpoch(
		qint64(message.value("createdAt").toDouble()));
	const QDate today = QDate::currentDate();
	QString dayLabel;
	if (createdAt.date() == today)
		dayLabel = QStringLiteral("今天");
	else if (createdAt.date() == today.addDays(-1))
		dayLabel = QStringLiteral("昨天");
	else if (createdAt.date().year() == today.year())
		dayLabel = createdAt.date().toString(QStringLiteral("M月d日"));
	else
		dayLabel = createdAt.date().toString(QStringLiteral("yyyy年M月d日"));

	QMap<QString, int> reactionCounts;
	QStringList reactionOrder;
	for (const QJsonValue& value : message.value("reactions").toArray()) {
		const QString emoji = value.toObject().value("emoji").toString();
		if (emoji.isEmpty())
			continue;
		if (!reactionCounts.contains(emoji))
			reactionOrder.append(emoji);
		++reactionCounts[emoji];
	}
	QStringList reactionSummary;
	for (const QString& emoji : std::as_const(reactionOrder)) {
		const int count = reactionCounts.value(emoji);
		reactionSummary.append(count > 1
			? QStringLiteral("%1 %2").arg(emoji).arg(count) : emoji);
	}
	return {
		{"id", message.value("id").toString()},
		{"clientMessageId", message.value("clientMessageId").toString()},
		{"seq", qint64(message.value("seq").toDouble())},
		{"body", recalled ? QStringLiteral("该消息已撤回")
			: message.value("body").toString()},
		{"mine", message.value("sender").toString() == m_currentUserAccount},
		{"type", message.value("type").toString("text")},
		{"attachmentId", message.value("attachmentId").toString()},
		{"status", message.value("status").toString("accepted")},
		{"edited", message.value("editedAt").toDouble() > 0},
		{"recalled", recalled},
		{"replyToId", message.value("replyToId").toString()},
		{"replyPreview", message.value("replyPreview").toString()},
		{"reactions", message.value("reactions").toArray().toVariantList()},
		{"reactionSummary", reactionSummary.join(QStringLiteral("   "))},
		{"dayLabel", dayLabel},
		{"time", createdAt.toString("HH:mm")}
	};
}

void ChatController::mergeMessage(const QJsonObject& message)
{
	const QVariantMap mapped = messageMap(message);
	const QString id = mapped.value("id").toString();
	const QString clientId = mapped.value("clientMessageId").toString();
	for (qsizetype i = 0; i < m_messages.size(); ++i) {
		const QVariantMap current = m_messages.at(i).toMap();
		if ((!id.isEmpty() && current.value("id").toString() == id)
			|| (!clientId.isEmpty()
				&& current.value("clientMessageId").toString() == clientId)) {
			m_messages[i] = mapped;
			emit messagesChanged();
			return;
		}
	}
	m_messages.append(mapped);
	emit messagesChanged();
}

void ChatController::applyPresence(const QString& account, bool online)
{
	auto update = [&](QVariantList& list) {
		bool changed = false;
		for (qsizetype i = 0; i < list.size(); ++i) {
			QVariantMap row = list.at(i).toMap();
			if (row.value("account").toString() == account) {
				row.insert("online", online);
				list[i] = row;
				changed = true;
			}
		}
		return changed;
	};
	if (update(m_contacts))
		emit contactsChanged();
	if (update(m_conversations))
		emit conversationsChanged();
	if (m_selectedPeerAccount == account) {
		m_selectedPeerOnline = online;
		emit selectedPeerChanged();
	}
}

QVariantMap ChatController::peerMap(const QString& account) const
{
	for (const QVariant& value : m_contacts) {
		const QVariantMap row = value.toMap();
		if (row.value("account").toString() == account)
			return row;
	}
	return {};
}

void ChatController::showToast(const QString& message, bool error)
{
	m_toastMessage = message;
	m_toastError = error;
	emit toastChanged();
}

void ChatController::clearToast()
{
	if (m_toastMessage.isEmpty())
		return;
	m_toastMessage.clear();
	m_toastError = false;
	emit toastChanged();
}

bool ChatController::effectiveDark() const
{
	if (m_theme == "dark")
		return true;
	if (m_theme == "light")
		return false;
	return QGuiApplication::styleHints()->colorScheme() == Qt::ColorScheme::Dark;
}

void ChatController::saveSetting(const QString& key, const QVariant& value)
{
	m_settings.setValue(key, value);
	m_settings.sync();
}

void ChatController::setTheme(const QString& value)
{
	const QString normalized = normalizedTheme(value);
	if (m_theme == normalized)
		return;
	m_theme = normalized;
	saveSetting("appearance/theme", m_theme);
	emit settingsChanged();
}

void ChatController::setNotificationsEnabled(bool value)
{
	if (m_notificationsEnabled == value)
		return;
	m_notificationsEnabled = value;
	saveSetting("notifications/enabled", value);
	emit settingsChanged();
}

void ChatController::setEnterToSend(bool value)
{
	if (m_enterToSend == value)
		return;
	m_enterToSend = value;
	saveSetting("chat/enterToSend", value);
	emit settingsChanged();
}

void ChatController::setShowOnlineStatus(bool value)
{
	if (m_showOnlineStatus == value)
		return;
	m_showOnlineStatus = value;
	saveSetting("privacy/showOnlineStatus", value);
	emit settingsChanged();
}

void ChatController::setCompactMode(bool value)
{
	if (m_compactMode == value)
		return;
	m_compactMode = value;
	saveSetting("appearance/compactMode", value);
	emit settingsChanged();
}
