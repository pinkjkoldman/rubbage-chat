#include "ReliableOutbox.h"

#include <QDir>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QSaveFile>
#include <QStandardPaths>

#include <utility>

ReliableOutbox::ReliableOutbox()
{
	const QString directory = QStandardPaths::writableLocation(
		QStandardPaths::AppLocalDataLocation);
	QDir().mkpath(directory);
	m_filePath = QDir(directory).filePath(QStringLiteral("reliable-outbox.json"));
}

bool ReliableOutbox::enqueue(const QString& owner, const QJsonObject& packet)
{
	if (owner.isEmpty() || packet.value("requestId").toString().isEmpty())
		return false;
	QList<QJsonObject> entries = readAll();
	for (const QJsonObject& entry : std::as_const(entries)) {
		if (entry.value("requestId") == packet.value("requestId"))
			return true;
	}
	QJsonObject sanitized = packet;
	sanitized.remove("token");
	sanitized.insert("_owner", owner);
	entries.append(sanitized);
	while (entries.size() > 1000)
		entries.removeFirst();
	return writeAll(entries);
}

QList<QJsonObject> ReliableOutbox::pending(const QString& owner) const
{
	QList<QJsonObject> result;
	for (QJsonObject entry : readAll()) {
		if (entry.value("_owner").toString() != owner)
			continue;
		entry.remove("_owner");
		result.append(entry);
	}
	return result;
}

void ReliableOutbox::acknowledge(const QString& requestId)
{
	if (requestId.isEmpty())
		return;
	QList<QJsonObject> entries = readAll();
	for (qsizetype i = entries.size(); i > 0; --i) {
		if (entries.at(i - 1).value("requestId").toString() == requestId)
			entries.removeAt(i - 1);
	}
	writeAll(entries);
}

QList<QJsonObject> ReliableOutbox::readAll() const
{
	QFile file(m_filePath);
	if (!file.open(QIODevice::ReadOnly))
		return {};
	const QJsonDocument document = QJsonDocument::fromJson(file.readAll());
	if (!document.isArray())
		return {};
	QList<QJsonObject> result;
	for (const QJsonValue& value : document.array()) {
		if (value.isObject())
			result.append(value.toObject());
	}
	return result;
}

bool ReliableOutbox::writeAll(const QList<QJsonObject>& entries) const
{
	QJsonArray array;
	for (const QJsonObject& entry : entries)
		array.append(entry);
	QSaveFile file(m_filePath);
	if (!file.open(QIODevice::WriteOnly))
		return false;
	if (file.write(QJsonDocument(array).toJson(QJsonDocument::Compact)) < 0)
		return false;
	return file.commit();
}
