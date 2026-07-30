#include "ChatServer.h"

#include "../storage/MongoChatStore.h"
#include "../../../libs/protocol/ChatProtocol.h"

#include <QCoreApplication>
#include <QDateTime>
#include <QFile>
#include <QHostAddress>
#include <QJsonArray>
#include <QSet>
#include <QSettings>
#include <QSslCertificate>
#include <QSslConfiguration>
#include <QSslKey>
#include <QSslServer>
#include <QTcpSocket>
#include <QUrl>

namespace
{
qint64 nowMs()
{
	return QDateTime::currentMSecsSinceEpoch();
}

QString exceptionMessage(const std::exception& exception)
{
	const QString message = QString::fromUtf8(exception.what()).trimmed();
	return message.isEmpty() ? QStringLiteral("服务器处理失败") : message;
}
}

ChatServer::ChatServer(QObject* parent)
	: QObject(parent)
{
	QSettings config(QCoreApplication::applicationDirPath() + "/rubbagechat.ini",
		QSettings::IniFormat);
	m_mongoUri = qEnvironmentVariable("RUBBAGECHAT_MONGO_URI",
		config.value("database/mongoUri",
			"mongodb://127.0.0.1:27017/?serverSelectionTimeoutMS=3000").toString());
	m_databaseName = qEnvironmentVariable("RUBBAGECHAT_MONGO_DATABASE",
		config.value("database/name", "rubbagechat").toString());
	m_tlsEnabled = qEnvironmentVariable("RUBBAGECHAT_TLS",
		config.value("security/tls", false).toString()).trimmed().toLower()
		== "true";
	m_certificateFile = qEnvironmentVariable("RUBBAGECHAT_TLS_CERT",
		config.value("security/certificateFile").toString());
	m_privateKeyFile = qEnvironmentVariable("RUBBAGECHAT_TLS_KEY",
		config.value("security/privateKeyFile").toString());
	m_publicMode = qEnvironmentVariable("RUBBAGECHAT_PUBLIC_MODE",
		config.value("security/publicMode", false).toString())
		.trimmed().toLower() == "true";
	m_seedDemoAccounts = qEnvironmentVariable("RUBBAGECHAT_SEED_DEMO_ACCOUNTS",
		config.value("development/seedDemoAccounts", false).toString())
		.trimmed().toLower() == "true";
	m_registrationEnabled = qEnvironmentVariable("RUBBAGECHAT_REGISTRATION_ENABLED",
		config.value("security/registrationEnabled", true).toString())
		.trimmed().toLower() == "true";
	m_maxConnections = qBound(20,
		config.value("security/maxConnections", 500).toInt(), 10000);
	m_maxConnectionsPerIp = qBound(2,
		config.value("security/maxConnectionsPerIp", 12).toInt(), 200);
	bool portOk = false;
	const int port = qEnvironmentVariable("RUBBAGECHAT_CHAT_PORT",
		config.value("network/chatPort", 7502).toString()).toInt(&portOk);
	if (portOk && port > 0 && port <= 65535)
		m_port = quint16(port);

	m_heartbeatTimer.setInterval(15000);
	connect(&m_heartbeatTimer, &QTimer::timeout,
		this, &ChatServer::heartbeatSweep);
}

ChatServer::~ChatServer() = default;

bool ChatServer::start(QString* error)
{
	if (m_publicMode && !m_tlsEnabled) {
		if (error)
			*error = QStringLiteral("公网模式必须启用 TLS");
		return false;
	}
	if (m_publicMode && m_seedDemoAccounts) {
		if (error)
			*error = QStringLiteral("公网模式禁止创建演示账号");
		return false;
	}
	const QUrl mongoUrl(m_mongoUri);
	if (m_publicMode && mongoUrl.userName().isEmpty()) {
		if (error)
			*error = QStringLiteral("公网模式必须使用带身份认证的 MongoDB URI");
		return false;
	}

	try {
		m_store = std::make_unique<MongoChatStore>(m_mongoUri, m_databaseName);
	}
	catch (const std::exception& exception) {
		if (error)
			*error = exceptionMessage(exception);
		return false;
	}
	if (!m_store->initialize(m_seedDemoAccounts, m_publicMode, error))
		return false;

	if (m_tlsEnabled) {
		QFile certificateFile(m_certificateFile);
		QFile keyFile(m_privateKeyFile);
		if (!certificateFile.open(QIODevice::ReadOnly)
			|| !keyFile.open(QIODevice::ReadOnly)) {
			if (error)
				*error = QStringLiteral("TLS 证书或私钥无法读取");
			return false;
		}
		const QList<QSslCertificate> certificateChain =
			QSslCertificate::fromData(certificateFile.readAll(), QSsl::Pem);
		const QByteArray privateKeyData = keyFile.readAll();
		QSslKey privateKey(privateKeyData, QSsl::Rsa, QSsl::Pem);
		if (privateKey.isNull())
			privateKey = QSslKey(privateKeyData, QSsl::Ec, QSsl::Pem);
		if (certificateChain.isEmpty() || privateKey.isNull()) {
			if (error)
				*error = QStringLiteral("TLS 证书链或 RSA/ECDSA 私钥格式无效");
			return false;
		}
		QSslConfiguration ssl = QSslConfiguration::defaultConfiguration();
		ssl.setLocalCertificateChain(certificateChain);
		ssl.setPrivateKey(privateKey);
		ssl.setProtocol(QSsl::TlsV1_2OrLater);
		auto server = std::make_unique<QSslServer>();
		server->setSslConfiguration(ssl);
		server->setHandshakeTimeout(10000);
		m_tcpServer = std::move(server);
	}
	else {
		m_tcpServer = std::make_unique<QTcpServer>();
	}
	connect(m_tcpServer.get(), &QTcpServer::newConnection,
		this, &ChatServer::acceptConnections);
	if (!m_tcpServer->listen(QHostAddress::Any, m_port)) {
		if (error)
			*error = m_tcpServer->errorString();
		return false;
	}
	m_heartbeatTimer.start();
	return true;
}

void ChatServer::acceptConnections()
{
	while (QTcpSocket* socket = m_tcpServer->nextPendingConnection()) {
		const QString peer = peerKey(socket);
		if (m_clients.size() >= m_maxConnections
			|| connectionsForPeer(peer) >= m_maxConnectionsPerIp
			|| !allowRate("connect:" + peer, 30, 60000)) {
			socket->disconnectFromHost();
			socket->deleteLater();
			continue;
		}
		ClientState state;
		state.lastSeen = nowMs();
		state.rateWindowStart = state.lastSeen;
		m_clients.insert(socket, state);
		connect(socket, &QTcpSocket::readyRead, this,
			[this, socket]() { readClient(socket); });
		connect(socket, &QTcpSocket::disconnected, this,
			[this, socket]() { disconnectClient(socket); });
		connect(socket, &QTcpSocket::errorOccurred, this,
			[this, socket](QAbstractSocket::SocketError) {
				if (socket->state() == QAbstractSocket::UnconnectedState)
					disconnectClient(socket);
			});
	}
}

void ChatServer::readClient(QTcpSocket* socket)
{
	auto iterator = m_clients.find(socket);
	if (iterator == m_clients.end())
		return;
	iterator->lastSeen = nowMs();
	iterator->buffer.append(socket->readAll());
	QList<QJsonObject> packets;
	QString error;
	if (!ChatProtocol::takeFrames(iterator->buffer, packets, &error)) {
		sendEvent(socket, "protocol_error", {{"message", error}});
		socket->disconnectFromHost();
		return;
	}
	for (const QJsonObject& packet : packets)
		handlePacket(socket, packet);
}

void ChatServer::disconnectClient(QTcpSocket* socket)
{
	auto iterator = m_clients.find(socket);
	if (iterator == m_clients.end())
		return;
	const QString account = iterator->account;
	m_clients.erase(iterator);
	socket->deleteLater();
	if (account.isEmpty())
		return;
	bool stillOnline = false;
	for (const ClientState& client : std::as_const(m_clients))
		stillOnline = stillOnline || client.account == account;
	if (!stillOnline) {
		for (QTcpSocket* peer : m_clients.keys())
			sendEvent(peer, "presence", {{"account", account}, {"online", false}});
	}
}

bool ChatServer::allowRequest(ClientState& state)
{
	const qint64 now = nowMs();
	if (now - state.rateWindowStart >= 10000) {
		state.rateWindowStart = now;
		state.requestsInWindow = 0;
	}
	return ++state.requestsInWindow <= 80;
}

bool ChatServer::allowRate(
	const QString& key, int limit, qint64 windowMs)
{
	const qint64 now = nowMs();
	RateBucket& bucket = m_rateBuckets[key];
	if (bucket.windowStart == 0 || now - bucket.windowStart >= windowMs) {
		bucket.windowStart = now;
		bucket.count = 0;
	}
	return ++bucket.count <= limit;
}

QString ChatServer::peerKey(const QTcpSocket* socket) const
{
	if (!socket)
		return QStringLiteral("unknown");
	bool ipv4Ok = false;
	const quint32 ipv4 = socket->peerAddress().toIPv4Address(&ipv4Ok);
	return ipv4Ok ? QHostAddress(ipv4).toString()
		: socket->peerAddress().toString();
}

int ChatServer::connectionsForPeer(const QString& peer) const
{
	int count = 0;
	for (QTcpSocket* socket : m_clients.keys()) {
		if (peerKey(socket) == peer)
			++count;
	}
	return count;
}

void ChatServer::pruneRateBuckets()
{
	const qint64 staleBefore = nowMs() - 60LL * 60 * 1000;
	for (auto iterator = m_rateBuckets.begin();
		iterator != m_rateBuckets.end();) {
		if (iterator->windowStart < staleBefore)
			iterator = m_rateBuckets.erase(iterator);
		else
			++iterator;
	}
}

void ChatServer::handlePacket(QTcpSocket* socket, const QJsonObject& packet)
{
	auto iterator = m_clients.find(socket);
	if (iterator == m_clients.end())
		return;
	const QString peer = peerKey(socket);
	if (!allowRequest(*iterator)
		|| !allowRate("request:" + peer, 120, 10000)) {
		sendError(socket, packet, QStringLiteral("请求过于频繁，请稍后重试"));
		return;
	}
	if (packet.value("version").toInt() != ChatProtocol::Version
		|| packet.value("kind").toString() != "request") {
		sendError(socket, packet, QStringLiteral("协议版本不受支持"));
		return;
	}

	const QString action = packet.value("action").toString();
	const QJsonObject data = packet.value("data").toObject();
	try {
		if (action == "register") {
			if (!m_registrationEnabled) {
				sendError(socket, packet, QStringLiteral("当前未开放新账号注册"));
				return;
			}
			if (!allowRate("register:" + peer, 5, 60LL * 60 * 1000)) {
				sendError(socket, packet, QStringLiteral("注册尝试过于频繁，请稍后重试"));
				return;
			}
			sendResponse(socket, packet, m_store->registerUser(
				data.value("name").toString(), data.value("password").toString()));
			return;
		}
		if (action == "login") {
			const QString requestedAccount =
				data.value("account").toString().trimmed();
			if (!allowRate("login-ip:" + peer, 12, 60000)
				|| !allowRate("login-account:" + requestedAccount,
					8, 5LL * 60 * 1000)) {
				sendError(socket, packet, QStringLiteral("登录尝试过于频繁，请稍后重试"));
				return;
			}
			QJsonObject result = m_store->login(
				requestedAccount,
				data.value("password").toString());
			iterator->account = result.value("account").toString();
			iterator->token = result.value("token").toString();
			QJsonObject snapshot = result.value("snapshot").toObject();
			overlayPresence(snapshot);
			result.insert("snapshot", snapshot);
			sendResponse(socket, packet, result);
			for (QTcpSocket* peer : m_clients.keys())
				sendEvent(peer, "presence",
					{{"account", iterator->account}, {"online", true}});
			return;
		}
		if (action == "ping") {
			sendResponse(socket, packet, {{"serverTime", double(nowMs())}});
			return;
		}

		const QString token = packet.value("token").toString();
		const QString account = m_store->authenticate(token);
		if (account.isEmpty()) {
			sendError(socket, packet, QStringLiteral("会话已失效，请重新登录"));
			return;
		}
		iterator->account = account;
		iterator->token = token;

		if (action == "logout") {
			m_store->logout(token);
			iterator->account.clear();
			iterator->token.clear();
			sendResponse(socket, packet);
		}
		else if (action == "snapshot") {
			QJsonObject snapshot = m_store->snapshot(account);
			overlayPresence(snapshot);
			sendResponse(socket, packet, snapshot);
		}
		else if (action == "search_user") {
			QJsonObject user = m_store->searchUser(
				account, data.value("account").toString());
			bool online = false;
			const QString searched = user.value("account").toString();
			for (const ClientState& client : std::as_const(m_clients))
				online = online || client.account == searched;
			user.insert("online", online);
			sendResponse(socket, packet, {{"user", user}});
		}
		else if (action == "send_friend_request") {
			const QString peer = data.value("account").toString();
			m_store->sendFriendRequest(account, peer);
			sendResponse(socket, packet);
			notifyStateChanged({account, peer});
		}
		else if (action == "accept_friend_request") {
			const QString peer = data.value("account").toString();
			m_store->acceptFriendRequest(account, peer);
			sendResponse(socket, packet);
			notifyStateChanged({account, peer});
		}
		else if (action == "reject_friend_request") {
			const QString peer = data.value("account").toString();
			m_store->rejectFriendRequest(account, peer);
			sendResponse(socket, packet);
			notifyStateChanged({account, peer});
		}
		else if (action == "remove_friend") {
			const QString peer = data.value("account").toString();
			m_store->removeFriend(account, peer);
			sendResponse(socket, packet);
			notifyStateChanged({account, peer});
		}
		else if (action == "history") {
			sendResponse(socket, packet, {{"messages", m_store->history(
				account, data.value("account").toString(),
				data.value("limit").toInt(200))}});
		}
		else if (action == "send_message") {
			const QString peer = data.value("account").toString();
			const QJsonObject message = m_store->sendMessage(account, peer,
				data.value("body").toString(),
				data.value("clientMessageId").toString());
			sendResponse(socket, packet, {{"message", message}});
			notifyAccount(peer, "message", message);
			notifyStateChanged({account, peer});
		}
		else if (action == "send_file") {
			const QString peer = data.value("account").toString();
			const QByteArray bytes = QByteArray::fromBase64(
				data.value("base64").toString().toLatin1());
			const QJsonObject attachment = m_store->storeAttachment(account, peer,
				data.value("fileName").toString(), data.value("mimeType").toString(),
				bytes);
			const QJsonObject message = m_store->sendMessage(account, peer,
				QStringLiteral("[文件] %1").arg(attachment.value("fileName").toString()),
				data.value("clientMessageId").toString(), "file",
				attachment.value("id").toString());
			sendResponse(socket, packet,
				{{"attachment", attachment}, {"message", message}});
			notifyAccount(peer, "message", message);
			notifyStateChanged({account, peer});
		}
		else if (action == "download_attachment") {
			sendResponse(socket, packet, {{"attachment", m_store->loadAttachment(
				account, data.value("attachmentId").toString())}});
		}
		else if (action == "set_conversation_option") {
			m_store->setConversationOption(account,
				data.value("account").toString(), data.value("option").toString(),
				data.value("value").toBool());
			sendResponse(socket, packet);
			notifyStateChanged({account});
		}
		else if (action == "conversation_option") {
			sendResponse(socket, packet, m_store->conversationOption(
				account, data.value("account").toString()));
		}
		else if (action == "clear_conversation") {
			m_store->clearConversation(account, data.value("account").toString());
			sendResponse(socket, packet);
			notifyStateChanged({account});
		}
		else if (action == "update_profile") {
			m_store->updateProfile(account, data.value("name").toString(),
				data.value("signature").toString());
			sendResponse(socket, packet);
			notifyStateChanged({account});
		}
		else if (action == "change_password") {
			m_store->changePassword(account,
				data.value("currentPassword").toString(),
				data.value("newPassword").toString());
			iterator->account.clear();
			iterator->token.clear();
			sendResponse(socket, packet, {{"reauthenticate", true}});
		}
		else {
			sendError(socket, packet, QStringLiteral("未知操作"));
		}
	}
	catch (const std::exception& exception) {
		sendError(socket, packet, exceptionMessage(exception));
	}
}

void ChatServer::sendResponse(QTcpSocket* socket,
	const QJsonObject& request, const QJsonObject& data)
{
	socket->write(ChatProtocol::encode({
		{"version", ChatProtocol::Version},
		{"kind", "response"},
		{"action", request.value("action").toString()},
		{"requestId", request.value("requestId").toString()},
		{"ok", true},
		{"data", data}
	}));
}

void ChatServer::sendError(QTcpSocket* socket,
	const QJsonObject& request, const QString& message)
{
	socket->write(ChatProtocol::encode({
		{"version", ChatProtocol::Version},
		{"kind", "response"},
		{"action", request.value("action").toString()},
		{"requestId", request.value("requestId").toString()},
		{"ok", false},
		{"error", message.left(500)}
	}));
}

void ChatServer::sendEvent(QTcpSocket* socket,
	const QString& event, const QJsonObject& data)
{
	if (socket && socket->state() == QAbstractSocket::ConnectedState)
		socket->write(ChatProtocol::encode({
			{"version", ChatProtocol::Version},
			{"kind", "event"},
			{"event", event},
			{"data", data}
		}));
}

void ChatServer::notifyAccount(const QString& account,
	const QString& event, const QJsonObject& data)
{
	for (QTcpSocket* socket : m_clients.keys()) {
		if (m_clients.value(socket).account == account)
			sendEvent(socket, event, data);
	}
}

void ChatServer::notifyStateChanged(const QStringList& accounts)
{
	for (const QString& account : accounts)
		notifyAccount(account, "state_changed");
}

void ChatServer::overlayPresence(QJsonObject& snapshot) const
{
	QSet<QString> onlineAccounts;
	for (const ClientState& state : std::as_const(m_clients)) {
		if (!state.account.isEmpty())
			onlineAccounts.insert(state.account);
	}
	for (const QString& key : {QString("contacts"), QString("conversations")}) {
		QJsonArray array = snapshot.value(key).toArray();
		for (qsizetype i = 0; i < array.size(); ++i) {
			QJsonObject item = array.at(i).toObject();
			item.insert("online", onlineAccounts.contains(
				item.value("account").toString()));
			array[i] = item;
		}
		snapshot.insert(key, array);
	}
}

void ChatServer::heartbeatSweep()
{
	pruneRateBuckets();
	const qint64 staleBefore = nowMs() - 90000;
	for (QTcpSocket* socket : m_clients.keys()) {
		if (m_clients.value(socket).lastSeen < staleBefore)
			socket->disconnectFromHost();
		else
			sendEvent(socket, "heartbeat", {{"serverTime", double(nowMs())}});
	}
}
