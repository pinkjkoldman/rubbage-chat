#include "EndpointDiscovery.h"

#include <QDateTime>
#include <QHostAddress>
#include <QJsonArray>
#include <QJsonDocument>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QSettings>
#include <QSslConfiguration>

namespace
{
constexpr int MaxBootstrapBytes = 64 * 1024;
constexpr qint64 MaxCacheLifetimeMs = 7LL * 24 * 60 * 60 * 1000;

bool isLocalDevelopmentHost(const QString& host)
{
	QHostAddress address;
	return host.compare(QStringLiteral("localhost"), Qt::CaseInsensitive) == 0
		|| (address.setAddress(host)
			&& (address.isLoopback()
				|| (address.protocol() == QAbstractSocket::IPv4Protocol
					&& address.toIPv4Address() >> 24 == 10)));
}
}

bool EndpointDiscovery::Endpoint::isValid() const
{
	return !host.trimmed().isEmpty() && port > 0;
}

EndpointDiscovery::EndpointDiscovery(QObject* parent)
	: QObject(parent)
{
	m_timeout.setSingleShot(true);
	m_timeout.setInterval(5000);
	connect(&m_timeout, &QTimer::timeout, this, [this]() {
		if (m_reply) {
			QNetworkReply* reply = m_reply;
			m_reply = nullptr;
			reply->abort();
			reply->deleteLater();
		}
		finishWithFallback(QStringLiteral("Bootstrap request timed out"));
	});
}

void EndpointDiscovery::resolve(
	const QUrl& bootstrapUrl, const Endpoint& fallback)
{
	if (m_reply) {
		m_reply->abort();
		m_reply->deleteLater();
		m_reply = nullptr;
	}
	m_finished = false;
	m_bootstrapUrl = bootstrapUrl;
	m_fallback = fallback;

	if (!bootstrapUrl.isValid() || bootstrapUrl.isEmpty()) {
		finishWith(fallback, QStringLiteral("Using packaged endpoint"));
		return;
	}
	const bool allowInsecure =
		qEnvironmentVariable("RUBBAGECHAT_ALLOW_INSECURE_BOOTSTRAP")
			.trimmed().compare(QStringLiteral("true"), Qt::CaseInsensitive) == 0;
	if (bootstrapUrl.scheme() != QStringLiteral("https")
		&& !(allowInsecure && bootstrapUrl.scheme() == QStringLiteral("http"))) {
		finishWithFallback(QStringLiteral("Bootstrap URL must use HTTPS"));
		return;
	}

	emit statusChanged(QStringLiteral("Discovering the nearest endpoint"));
	QNetworkRequest request(bootstrapUrl);
	request.setHeader(QNetworkRequest::UserAgentHeader,
		QStringLiteral("RubbageChat/2.5"));
	request.setRawHeader("Accept", "application/json");
	request.setTransferTimeout(5000);
	request.setMaximumRedirectsAllowed(2);
	request.setAttribute(
		QNetworkRequest::RedirectPolicyAttribute,
		QNetworkRequest::NoLessSafeRedirectPolicy);
	QSslConfiguration ssl = QSslConfiguration::defaultConfiguration();
	ssl.setProtocol(QSsl::TlsV1_2OrLater);
	request.setSslConfiguration(ssl);
	m_reply = m_network.get(request);
	m_timeout.start();

	connect(m_reply, &QNetworkReply::readyRead, this, [this]() {
		if (m_reply && m_reply->bytesAvailable() > MaxBootstrapBytes)
			m_reply->abort();
	});
	connect(m_reply, &QNetworkReply::finished, this, [this]() {
		if (m_finished || !m_reply)
			return;
		m_timeout.stop();
		QNetworkReply* reply = m_reply;
		m_reply = nullptr;
		const QByteArray payload = reply->readAll();
		const QNetworkReply::NetworkError networkError = reply->error();
		const int status = reply->attribute(
			QNetworkRequest::HttpStatusCodeAttribute).toInt();
		const QString networkMessage = reply->errorString();
		reply->deleteLater();

		Endpoint endpoint;
		qint64 expiresAt = 0;
		QString parseError;
		if (networkError == QNetworkReply::NoError && status == 200
			&& payload.size() <= MaxBootstrapBytes
			&& acceptDocument(payload, endpoint, expiresAt, &parseError)) {
			saveCached(payload, expiresAt);
			finishWith(endpoint, QStringLiteral("Endpoint discovered"));
			return;
		}
		finishWithFallback(parseError.isEmpty()
			? networkMessage : parseError);
	});
}

bool EndpointDiscovery::acceptDocument(const QByteArray& payload,
	Endpoint& endpoint, qint64& expiresAt, QString* error) const
{
	QJsonParseError parseError;
	const QJsonDocument document = QJsonDocument::fromJson(payload, &parseError);
	if (parseError.error != QJsonParseError::NoError || !document.isObject()) {
		if (error)
			*error = QStringLiteral("Bootstrap returned invalid JSON");
		return false;
	}
	const QJsonObject root = document.object();
	if (root.value(QStringLiteral("schemaVersion")).toInt() != 1) {
		if (error)
			*error = QStringLiteral("Unsupported bootstrap schema");
		return false;
	}
	expiresAt = QDateTime::fromString(
		root.value(QStringLiteral("expiresAt")).toString(), Qt::ISODate)
		.toMSecsSinceEpoch();
	const qint64 now = QDateTime::currentMSecsSinceEpoch();
	if (expiresAt <= now || expiresAt > now + MaxCacheLifetimeMs) {
		if (error)
			*error = QStringLiteral("Bootstrap document has an invalid expiry");
		return false;
	}
	const QJsonArray endpoints = root.value(QStringLiteral("endpoints")).toArray();
	for (const QJsonValue& value : endpoints) {
		const QJsonObject candidate = value.toObject();
		const QString transport =
			candidate.value(QStringLiteral("transport")).toString();
		const QString host =
			candidate.value(QStringLiteral("host")).toString().trimmed();
		const int port = candidate.value(QStringLiteral("port")).toInt();
		QHostAddress literalAddress;
		const bool literalIp = literalAddress.setAddress(host);
		if (transport != QStringLiteral("tls-tcp") || host.isEmpty()
			|| port <= 0 || port > 65535
			|| (literalIp && !isLocalDevelopmentHost(host)))
			continue;
		endpoint = {host, quint16(port), true};
		return true;
	}
	if (error)
		*error = QStringLiteral("Bootstrap contains no supported endpoint");
	return false;
}

bool EndpointDiscovery::readCached(Endpoint& endpoint) const
{
	QSettings cache(QStringLiteral("RubbageChat"),
		QStringLiteral("EndpointDiscovery"));
	const qint64 expiresAt = cache.value(QStringLiteral("expiresAt")).toLongLong();
	const QByteArray payload =
		cache.value(QStringLiteral("document")).toByteArray();
	if (payload.isEmpty()
		|| expiresAt <= QDateTime::currentMSecsSinceEpoch())
		return false;
	qint64 verifiedExpiry = 0;
	return acceptDocument(payload, endpoint, verifiedExpiry, nullptr)
		&& verifiedExpiry == expiresAt;
}

void EndpointDiscovery::saveCached(
	const QByteArray& payload, qint64 expiresAt)
{
	QSettings cache(QStringLiteral("RubbageChat"),
		QStringLiteral("EndpointDiscovery"));
	cache.setValue(QStringLiteral("document"), payload);
	cache.setValue(QStringLiteral("expiresAt"), expiresAt);
	cache.sync();
}

void EndpointDiscovery::finishWith(
	const Endpoint& endpoint, const QString& status)
{
	if (m_finished || !endpoint.isValid())
		return;
	m_finished = true;
	m_timeout.stop();
	emit statusChanged(status);
	emit resolved(endpoint.host, endpoint.port, endpoint.tls);
}

void EndpointDiscovery::finishWithFallback(const QString& reason)
{
	if (m_finished)
		return;
	Endpoint cached;
	if (readCached(cached)) {
		finishWith(cached, QStringLiteral("Using cached endpoint"));
		return;
	}
	finishWith(m_fallback, reason.isEmpty()
		? QStringLiteral("Using packaged fallback")
		: QStringLiteral("%1; using packaged fallback").arg(reason));
}
