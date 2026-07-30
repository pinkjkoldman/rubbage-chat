#pragma once

#include <QByteArray>
#include <QJsonObject>
#include <QList>

namespace ChatProtocol
{
constexpr quint32 MaxFrameSize = 12 * 1024 * 1024;
constexpr int Version = 2;

QByteArray encode(const QJsonObject& packet);
bool takeFrames(QByteArray& buffer, QList<QJsonObject>& packets, QString* error = nullptr);
QJsonObject request(const QString& action, const QJsonObject& data = {},
	const QString& token = {}, const QString& requestId = {},
	const QString& deviceId = {});
}
