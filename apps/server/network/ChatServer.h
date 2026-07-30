#pragma once

#include <QByteArray>
#include <QHash>
#include <QJsonObject>
#include <QObject>
#include <QTcpServer>
#include <QTimer>

#include <memory>

class MongoChatStore;
class QTcpSocket;

class ChatServer final : public QObject
{
	Q_OBJECT

public:
	explicit ChatServer(QObject* parent = nullptr);
	~ChatServer() override;
	bool start(QString* error = nullptr);

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

	std::unique_ptr<QTcpServer> m_tcpServer;
	QHash<QTcpSocket*, ClientState> m_clients;
	QHash<QString, RateBucket> m_rateBuckets;
	std::unique_ptr<MongoChatStore> m_store;
	QTimer m_heartbeatTimer;
	QString m_mongoUri;
	QString m_databaseName;
	QString m_certificateFile;
	QString m_privateKeyFile;
	bool m_tlsEnabled = false;
	bool m_publicMode = false;
	bool m_seedDemoAccounts = false;
	bool m_registrationEnabled = true;
	int m_maxConnections = 500;
	int m_maxConnectionsPerIp = 12;
	quint16 m_port = 7502;
};
