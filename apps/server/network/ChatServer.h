#pragma once

#include <QByteArray>
#include <QHash>
#include <QJsonObject>
#include <QObject>
#include <QStringList>
#include <QTcpServer>
#include <QTimer>
#include <QVariantList>

#include <memory>

class MongoChatStore;
class QTcpSocket;

class ChatServer final : public QObject
{
	Q_OBJECT
	Q_PROPERTY(bool running READ running NOTIFY statusChanged)
	Q_PROPERTY(QString statusText READ statusText NOTIFY statusChanged)
	Q_PROPERTY(QString lastError READ lastError NOTIFY statusChanged)
	Q_PROPERTY(bool publicMode READ publicMode CONSTANT)
	Q_PROPERTY(bool tlsEnabled READ tlsEnabled CONSTANT)
	Q_PROPERTY(bool registrationEnabled READ registrationEnabled CONSTANT)
	Q_PROPERTY(int listenPort READ listenPort CONSTANT)
	Q_PROPERTY(QString databaseTarget READ databaseTarget CONSTANT)
	Q_PROPERTY(int activeConnections READ activeConnections NOTIFY metricsChanged)
	Q_PROPERTY(int authenticatedConnections READ authenticatedConnections
		NOTIFY metricsChanged)
	Q_PROPERTY(qulonglong totalRequests READ totalRequests NOTIFY metricsChanged)
	Q_PROPERTY(qulonglong rejectedRequests READ rejectedRequests NOTIFY metricsChanged)
	Q_PROPERTY(QVariantList recentLogs READ recentLogs NOTIFY logsChanged)

public:
	explicit ChatServer(QObject* parent = nullptr);
	~ChatServer() override;

	bool start(QString* error = nullptr);
	Q_INVOKABLE bool startServer();
	Q_INVOKABLE void stopServer();

	bool running() const { return m_running; }
	QString statusText() const;
	QString lastError() const { return m_lastError; }
	bool publicMode() const { return m_publicMode; }
	bool tlsEnabled() const { return m_tlsEnabled; }
	bool registrationEnabled() const { return m_registrationEnabled; }
	int listenPort() const { return m_port; }
	QString databaseTarget() const;
	int activeConnections() const { return m_clients.size(); }
	int authenticatedConnections() const;
	qulonglong totalRequests() const { return m_totalRequests; }
	qulonglong rejectedRequests() const { return m_rejectedRequests; }
	QVariantList recentLogs() const { return m_recentLogs; }

signals:
	void statusChanged();
	void metricsChanged();
	void logsChanged();

private:
	struct ClientState {
		QByteArray buffer;
		QString account;
		QString token;
		qint64 lastSeen = 0;
		qint64 rateWindowStart = 0;
		int requestsInWindow = 0;
	};

	struct RateBucket {
		qint64 windowStart = 0;
		int count = 0;
	};

	void acceptConnections();
	void readClient(QTcpSocket* socket);
	void disconnectClient(QTcpSocket* socket);
	void handlePacket(QTcpSocket* socket, const QJsonObject& packet);
	void sendResponse(QTcpSocket* socket, const QJsonObject& request,
		const QJsonObject& data = {});
	void sendError(QTcpSocket* socket, const QJsonObject& request,
		const QString& message);
	void sendEvent(QTcpSocket* socket, const QString& event,
		const QJsonObject& data = {});
	void notifyAccount(const QString& account, const QString& event,
		const QJsonObject& data = {});
	void notifyStateChanged(const QStringList& accounts);
	void overlayPresence(QJsonObject& snapshot) const;
	bool allowRequest(ClientState& state);
	bool allowRate(const QString& key, int limit, qint64 windowMs);
	QString peerKey(const QTcpSocket* socket) const;
	int connectionsForPeer(const QString& peer) const;
	void pruneRateBuckets();
	void heartbeatSweep();
	void appendLog(const QString& level, const QString& message);
	void reject(const QString& message);

	std::unique_ptr<QTcpServer> m_tcpServer;
	QHash<QTcpSocket*, ClientState> m_clients;
	QHash<QString, RateBucket> m_rateBuckets;
	std::unique_ptr<MongoChatStore> m_store;
	QTimer m_heartbeatTimer;
	QString m_mongoUri;
	QString m_databaseName;
	QString m_certificateFile;
	QString m_privateKeyFile;
	QString m_lastError;
	QVariantList m_recentLogs;
	bool m_tlsEnabled = false;
	bool m_publicMode = false;
	bool m_seedDemoAccounts = false;
	bool m_registrationEnabled = true;
	bool m_running = false;
	int m_maxConnections = 500;
	int m_maxConnectionsPerIp = 12;
	quint16 m_port = 7502;
	qulonglong m_totalRequests = 0;
	qulonglong m_rejectedRequests = 0;
};
