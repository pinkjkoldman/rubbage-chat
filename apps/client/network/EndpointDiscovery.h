#pragma once

#include <QJsonObject>
#include <QNetworkAccessManager>
#include <QObject>
#include <QTimer>
#include <QUrl>

class QNetworkReply;

class EndpointDiscovery final : public QObject
{
	Q_OBJECT

public:
	struct Endpoint {
		QString host;
		quint16 port = 443;
		bool tls = true;

		bool isValid() const;
	};

	explicit EndpointDiscovery(QObject* parent = nullptr);

	void resolve(const QUrl& bootstrapUrl, const Endpoint& fallback);

signals:
	void resolved(const QString& host, int port, bool tls);

private:
	bool acceptDocument(const QByteArray& payload, Endpoint& endpoint,
		qint64& expiresAt, QString* error) const;
	bool readCached(Endpoint& endpoint) const;
	void saveCached(const QByteArray& payload, qint64 expiresAt);
	void finishWith(const Endpoint& endpoint);
	void finishWithFallback(const QString& reason);

	QNetworkAccessManager m_network;
	QTimer m_timeout;
	QNetworkReply* m_reply = nullptr;
	QUrl m_bootstrapUrl;
	Endpoint m_fallback;
	bool m_finished = false;
};
