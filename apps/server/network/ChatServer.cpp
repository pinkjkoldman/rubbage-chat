#include "ChatServer.h"

#include "../application/ChatCommandService.h"
#include "../storage/MongoChatStore.h"
#include "../../../libs/protocol/ChatProtocol.h"

#include <QCoreApplication>
#include <QDateTime>
#include <QFile>
#include <QHostAddress>
#include <QJsonArray>
#include <QPointer>
#include <QSet>
#include <QSettings>
#include <QSslCertificate>
#include <QSslConfiguration>
#include <QSslKey>
#include <QSslServer>
#include <QTcpSocket>
#include <QThread>
#include <QUrl>
#include <QVariantMap>

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
	m_businessWorkers = qBound(2,
		config.value("performance/businessWorkers",
			qMax(4, QThread::idealThreadCount())).toInt(), 64);
	m_maxPendingCommands = qBound(100,
		config.value("performance/maxPendingCommands", 2000).toInt(), 50000);
	bool portOk = false;
	const int port = qEnvironmentVariable("RUBBAGECHAT_CHAT_PORT",
		config.value("network/chatPort", 7502).toString()).toInt(&portOk);
	if (portOk && port > 0 && port <= 65535)
		m_port = quint16(port);

	m_heartbeatTimer.setInterval(15000);
	connect(&m_heartbeatTimer, &QTimer::timeout,
		this, &ChatServer::heartbeatSweep);
}

ChatServer::~ChatServer()
{
	stopServer();
}

QString ChatServer::statusText() const
{
	return m_running ? QStringLiteral("Running") : QStringLiteral("Stopped");
}

QString ChatServer::databaseTarget() const
{
	const QUrl url(m_mongoUri);
	const QString host = url.host().isEmpty()
		? QStringLiteral("configured host") : url.host();
	const int port = url.port(27017);
	QString database = m_databaseName;
	const QString pathDatabase = url.path().mid(1).section('/', 0, 0);
	if (!pathDatabase.isEmpty())
		database = pathDatabase;
	return QStringLiteral("%1:%2/%3").arg(host).arg(port).arg(database);
}

int ChatServer::pendingCommands() const
{
	return m_commandService ? m_commandService->pending() : 0;
}

int ChatServer::authenticatedConnections() const
{
	int count = 0;
	for (const ClientState& client : m_clients) {
		if (!client.account.isEmpty())
			++count;
	}
	return count;
}

void ChatServer::appendLog(const QString& level, const QString& message)
{
	QVariantMap entry;
	entry.insert(QStringLiteral("time"),
		QDateTime::currentDateTime().toString(QStringLiteral("HH:mm:ss")));
	entry.insert(QStringLiteral("level"), level);
	entry.insert(QStringLiteral("message"), message);
	m_recentLogs.prepend(entry);
	while (m_recentLogs.size() > 100)
		m_recentLogs.removeLast();
	emit logsChanged();
}

void ChatServer::reject(const QString& message)
{
	++m_rejectedRequests;
	appendLog(QStringLiteral("warning"), message);
	emit metricsChanged();
}

bool ChatServer::startServer()
{
	if (m_running)
		return true;

	m_lastError.clear();
	QString error;
	if (!start(&error)) {
		m_lastError = error.isEmpty()
			? QStringLiteral("The server could not be started.") : error;
		m_tcpServer.reset();
		m_store.reset();
		appendLog(QStringLiteral("error"), m_lastError);
		emit statusChanged();
		return false;
	}
	return true;
}

void ChatServer::stopServer()
{
	const bool wasRunning = m_running;
	m_heartbeatTimer.stop();
	if (m_tcpServer)
		m_tcpServer->close();
	for (QTcpSocket* socket : m_clients.keys()) {
		socket->disconnect(this);
		socket->abort();
		socket->deleteLater();
	}
	m_clients.clear();
	m_rateBuckets.clear();
	m_commandService.reset();
	m_store.reset();
	m_tcpServer.reset();
	m_running = false;
	if (wasRunning) {
		appendLog(QStringLiteral("info"), QStringLiteral("Server stopped."));
		emit statusChanged();
		emit metricsChanged();
	}
}

bool ChatServer::start(QString* error)
{
	if (m_running)
		return true;
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
	m_commandService = std::make_unique<ChatCommandService>(
		m_mongoUri, m_databaseName, m_registrationEnabled,
		m_businessWorkers, m_maxPendingCommands, this);

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
	m_running = true;
	appendLog(QStringLiteral("success"),
		QStringLiteral("Listening on port %1%2.")
			.arg(m_port)
			.arg(m_tlsEnabled ? QStringLiteral(" with TLS") : QString()));
	emit statusChanged();
	emit metricsChanged();
	return true;
}

void ChatServer::acceptConnections()
{
	while (QTcpSocket* socket = m_tcpServer->nextPendingConnection()) {
		const QString peer = peerKey(socket);
		if (m_clients.size() >= m_maxConnections
			|| connectionsForPeer(peer) >= m_maxConnectionsPerIp
			|| !allowRate("connect:" + peer, 30, 60000)) {
			reject(QStringLiteral("Connection rejected from %1.").arg(peer));
			socket->disconnectFromHost();
			socket->deleteLater();
			continue;
		}
		ClientState state;
		state.lastSeen = nowMs();
		state.rateWindowStart = state.lastSeen;
		m_clients.insert(socket, state);
		appendLog(QStringLiteral("info"),
			QStringLiteral("Client connected from %1.").arg(peer));
		emit metricsChanged();
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
	const QString peer = peerKey(socket);
	m_clients.erase(iterator);
	socket->deleteLater();
	appendLog(QStringLiteral("info"),
		QStringLiteral("Client disconnected from %1.").arg(peer));
	emit metricsChanged();
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
	++m_totalRequests;
	emit metricsChanged();
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
	if (action == "ping") {
		sendResponse(socket, packet, {{"serverTime", double(nowMs())}});
		return;
	}
	if (action == "register"
		&& !allowRate("register:" + peer, 5, 60LL * 60 * 1000)) {
		sendError(socket, packet, QStringLiteral("注册尝试过于频繁，请稍后重试"));
		return;
	}
	if (action == "login") {
		const QString requestedAccount = data.value("account").toString().trimmed();
		if (!allowRate("login-ip:" + peer, 12, 60000)
			|| !allowRate("login-account:" + requestedAccount,
				8, 5LL * 60 * 1000)) {
			sendError(socket, packet, QStringLiteral("登录尝试过于频繁，请稍后重试"));
			return;
		}
	}
	if (!m_commandService) {
		sendError(socket, packet, QStringLiteral("业务服务尚未就绪"));
		return;
	}
	const QPointer<QTcpSocket> guardedSocket(socket);
	const bool accepted = m_commandService->execute(packet,
		[this, guardedSocket, packet](ChatCommandService::Result result) {
			emit metricsChanged();
			if (!guardedSocket || !m_clients.contains(guardedSocket))
				return;
			QTcpSocket* client = guardedSocket;
			if (!result.ok) {
				sendError(client, packet, result.error);
				return;
			}
			ClientState& state = m_clients[client];
			if (!result.account.isEmpty())
				state.account = result.account;
			if (!result.token.isEmpty())
				state.token = result.token;
			if (!result.deviceId.isEmpty())
				state.deviceId = result.deviceId;

			QJsonObject responseData = result.data;
			if (result.action == "snapshot") {
				overlayPresence(responseData);
			}
			else if (result.action == "login") {
				QJsonObject snapshot = responseData.value("snapshot").toObject();
				overlayPresence(snapshot);
				responseData.insert("snapshot", snapshot);
			}
			else if (result.action == "search_user") {
				QJsonObject user = responseData.value("user").toObject();
				bool online = false;
				const QString searched = user.value("account").toString();
				for (const ClientState& connected : std::as_const(m_clients))
					online = online || connected.account == searched;
				user.insert("online", online);
				responseData.insert("user", user);
			}
			sendResponse(client, packet, responseData);

			for (const ChatCommandService::Notification& notification
				: std::as_const(result.notifications)) {
				notifyAccount(notification.account,
					notification.event, notification.data);
			}
			if (!result.stateAccounts.isEmpty())
				notifyStateChanged(result.stateAccounts);
			if (result.login) {
				appendLog(QStringLiteral("success"),
					QStringLiteral("Account %1 authenticated.")
						.arg(result.account));
				for (QTcpSocket* connected : m_clients.keys())
					sendEvent(connected, "presence",
						{{"account", result.account}, {"online", true}});
			}
			if (result.logout || result.reauthenticate) {
				state.account.clear();
				state.token.clear();
				state.deviceId.clear();
			}
			if (!result.revokeDeviceId.isEmpty()) {
				for (QTcpSocket* connected : m_clients.keys()) {
					const ClientState connectedState = m_clients.value(connected);
					if (connectedState.account == result.account
						&& connectedState.deviceId == result.revokeDeviceId) {
						sendEvent(connected, "session_revoked");
						connected->disconnectFromHost();
					}
				}
			}
		});
	if (!accepted)
		sendError(socket, packet,
			QStringLiteral("服务器繁忙，请稍后重试"));
	else
		emit metricsChanged();
	return;

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
	reject(message);
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
