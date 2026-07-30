#include "ChatProtocol.h"

#include <QDataStream>
#include <QIODevice>
#include <QJsonDocument>
#include <QUuid>

QByteArray ChatProtocol::encode(const QJsonObject& packet)
{
	const QByteArray payload = QJsonDocument(packet).toJson(QJsonDocument::Compact);
	QByteArray frame;
	QDataStream stream(&frame, QIODevice::WriteOnly);
	stream.setByteOrder(QDataStream::BigEndian);
	stream << quint32(payload.size());
	frame.append(payload);
	return frame;
}

bool ChatProtocol::takeFrames(
	QByteArray& buffer, QList<QJsonObject>& packets, QString* error)
{
	while (buffer.size() >= int(sizeof(quint32))) {
		QByteArray sizeBytes = buffer.left(sizeof(quint32));
		QDataStream sizeStream(&sizeBytes, QIODevice::ReadOnly);
		sizeStream.setByteOrder(QDataStream::BigEndian);
		quint32 size = 0;
		sizeStream >> size;
		if (size == 0 || size > MaxFrameSize) {
			if (error)
				*error = QStringLiteral("非法数据帧长度");
			return false;
		}
		const qsizetype frameSize = sizeof(quint32) + size;
		if (buffer.size() < frameSize)
			return true;
		QJsonParseError parseError;
		const QJsonDocument document = QJsonDocument::fromJson(
			buffer.mid(sizeof(quint32), size), &parseError);
		buffer.remove(0, frameSize);
		if (parseError.error != QJsonParseError::NoError || !document.isObject()) {
			if (error)
				*error = QStringLiteral("数据帧不是有效 JSON");
			return false;
		}
		packets.append(document.object());
	}
	return true;
}

QJsonObject ChatProtocol::request(const QString& action,
	const QJsonObject& data, const QString& token, const QString& requestId)
{
	QJsonObject packet{
		{"version", Version},
		{"kind", "request"},
		{"action", action},
		{"requestId", requestId.isEmpty()
			? QUuid::createUuid().toString(QUuid::WithoutBraces) : requestId},
		{"data", data}
	};
	if (!token.isEmpty())
		packet.insert("token", token);
	return packet;
}
