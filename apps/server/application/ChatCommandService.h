#pragma once

#include <QAtomicInteger>
#include <QJsonObject>
#include <QList>
#include <QObject>
#include <QStringList>
#include <QThreadPool>

#include <functional>

class ChatCommandService final : public QObject
{
public:
	struct Notification {
		QString account;
		QString event;
		QJsonObject data;
	};

	struct Result {
		bool ok = false;
		QString error;
		QString action;
		QJsonObject data;
		QString account;
		QString token;
		QString deviceId;
		bool login = false;
		bool logout = false;
		bool reauthenticate = false;
		QString revokeDeviceId;
		QList<Notification> notifications;
		QStringList stateAccounts;
	};

	using Completion = std::function<void(Result)>;

	ChatCommandService(const QString& mongoUri, const QString& databaseName,
		bool registrationEnabled, int maxWorkers, int maxPending,
		QObject* parent = nullptr);
	~ChatCommandService() override;

	bool execute(const QJsonObject& packet, Completion completion);
	int pending() const { return m_pending.loadRelaxed(); }

private:
	Result run(const QJsonObject& packet) const;

	QString m_mongoUri;
	QString m_databaseName;
	bool m_registrationEnabled = true;
	int m_maxPending = 1000;
	QAtomicInteger<int> m_pending = 0;
	QThreadPool m_pool;
};
