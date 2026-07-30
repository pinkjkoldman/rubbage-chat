#pragma once

#include <QJsonObject>
#include <QList>
#include <QString>

class ReliableOutbox final
{
public:
	ReliableOutbox();

	bool enqueue(const QString& owner, const QJsonObject& packet);
	QList<QJsonObject> pending(const QString& owner) const;
	void acknowledge(const QString& requestId);

private:
	QList<QJsonObject> readAll() const;
	bool writeAll(const QList<QJsonObject>& entries) const;

	QString m_filePath;
};
