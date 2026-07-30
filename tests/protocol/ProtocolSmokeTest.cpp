#include "../../libs/protocol/ChatProtocol.h"

#include <QCoreApplication>
#include <QElapsedTimer>
#include <QJsonArray>
#include <QJsonObject>
#include <QTcpSocket>
#include <QUuid>

#include <cstdio>

namespace
{
class TestClient
{
public:
	bool connect()
	{
		socket.connectToHost("127.0.0.1", 7502);
		return socket.waitForConnected(5000);
	}

	QJsonObject request(const QString& action, const QJsonObject& data = {},
		const QString& requestToken = {}, int timeout = 15000)
	{
		const QJsonObject packet = ChatProtocol::request(
			action, data, requestToken, {}, deviceId);
		const QString id = packet.value("requestId").toString();
		socket.write(ChatProtocol::encode(packet));
		socket.waitForBytesWritten(5000);

		QElapsedTimer timer;
		timer.start();
		while (timer.elapsed() < timeout) {
			for (qsizetype i = 0; i < events.size(); ++i) {
				if (events.at(i).value("kind").toString() == "response"
					&& events.at(i).value("requestId").toString() == id)
					return events.takeAt(i);
			}
			QJsonObject incoming;
			if (!nextPacket(incoming, timeout - int(timer.elapsed())))
				break;
			if (incoming.value("kind").toString() == "response"
				&& incoming.value("requestId").toString() == id)
				return incoming;
			events.append(incoming);
		}
		return {};
	}

	QJsonObject waitForEvent(const QString& event, int timeout = 10000)
	{
		QElapsedTimer timer;
		timer.start();
		while (timer.elapsed() < timeout) {
			for (qsizetype i = 0; i < events.size(); ++i) {
				if (events.at(i).value("kind").toString() == "event"
					&& events.at(i).value("event").toString() == event)
					return events.takeAt(i);
			}
			QJsonObject packet;
			if (!nextPacket(packet, timeout - int(timer.elapsed())))
				break;
			if (packet.value("kind").toString() == "event"
				&& packet.value("event").toString() == event)
				return packet;
			events.append(packet);
		}
		return {};
	}

	QTcpSocket socket;
	QByteArray buffer;
	QList<QJsonObject> events;
	QString deviceId =
		QUuid::createUuid().toString(QUuid::WithoutBraces);

private:
	bool nextPacket(QJsonObject& result, int timeout)
	{
		QElapsedTimer timer;
		timer.start();
		while (timer.elapsed() < timeout) {
			QList<QJsonObject> packets;
			QString error;
			if (!ChatProtocol::takeFrames(buffer, packets, &error))
				return false;
			if (!packets.isEmpty()) {
				result = packets.takeFirst();
				for (const QJsonObject& packet : packets)
					events.append(packet);
				return true;
			}
			if (!socket.waitForReadyRead(qMin(500, timeout - int(timer.elapsed()))))
				continue;
			buffer.append(socket.readAll());
		}
		return false;
	}
};

bool ok(const QJsonObject& response)
{
	return !response.isEmpty() && response.value("ok").toBool();
}

void dump(const char* label, const QJsonObject& value)
{
	const QByteArray json = QJsonDocument(value).toJson(QJsonDocument::Compact);
	std::fprintf(stderr, "%s: %s\n", label, json.constData());
	std::fflush(stderr);
}
}

int main(int argc, char* argv[])
{
	QCoreApplication application(argc, argv);
	TestClient alpha;
	TestClient beta;
	if (!alpha.connect() || !beta.connect()) {
		qCritical("无法连接 RubbageChatServer");
		return 1;
	}

	const QString suffix = QUuid::createUuid().toString(QUuid::WithoutBraces).left(6);
	const QJsonObject registerAlpha = alpha.request("register",
		{{"name", "Test Alpha " + suffix}, {"password", "secret123"}}, {}, 30000);
	const QJsonObject registerBeta = beta.request("register",
		{{"name", "Test Beta " + suffix}, {"password", "secret123"}}, {}, 30000);
	if (!ok(registerAlpha) || !ok(registerBeta)) {
		qCritical() << "注册失败" << registerAlpha << registerBeta;
		return 2;
	}
	const QString alphaAccount =
		registerAlpha.value("data").toObject().value("account").toString();
	const QString betaAccount =
		registerBeta.value("data").toObject().value("account").toString();

	const QJsonObject loginAlpha = alpha.request("login",
		{{"account", alphaAccount}, {"password", "secret123"}}, {}, 30000);
	const QJsonObject loginBeta = beta.request("login",
		{{"account", betaAccount}, {"password", "secret123"}}, {}, 30000);
	if (!ok(loginAlpha) || !ok(loginBeta)) {
		dump("loginAlpha", loginAlpha);
		dump("loginBeta", loginBeta);
		return 3;
	}
	const QString alphaToken =
		loginAlpha.value("data").toObject().value("token").toString();
	const QString betaToken =
		loginBeta.value("data").toObject().value("token").toString();

	if (!ok(alpha.request("send_friend_request",
		{{"account", betaAccount}}, alphaToken))
		|| !ok(beta.request("accept_friend_request",
			{{"account", alphaAccount}}, betaToken))) {
		qCritical("好友申请流程失败");
		return 4;
	}

	const QString body = "Mongo persisted " + suffix;
	const QString clientMessageId =
		QUuid::createUuid().toString(QUuid::WithoutBraces);
	const QJsonObject send = alpha.request("send_message", {
		{"account", betaAccount},
		{"body", body},
		{"sender", betaAccount},
		{"clientMessageId", clientMessageId}
	}, alphaToken);
	if (!ok(send)) {
		qCritical() << "消息发送失败" << send;
		return 5;
	}
	const QJsonObject stored = send.value("data").toObject().value("message").toObject();
	if (stored.value("sender").toString() != alphaAccount) {
		qCritical("服务端错误地信任了客户端 sender 字段");
		return 6;
	}
	const qint64 textSeq = qint64(stored.value("seq").toDouble());
	const QString textMessageId = stored.value("id").toString();
	if (textSeq <= 0 || textMessageId.isEmpty()
		|| stored.value("conversationId").toString().isEmpty()) {
		qCritical() << "消息序列或服务端消息 ID 缺失" << stored;
		return 12;
	}
	const QJsonObject duplicate = alpha.request("send_message", {
		{"account", betaAccount}, {"body", body},
		{"clientMessageId", clientMessageId}
	}, alphaToken);
	const QJsonObject duplicateMessage =
		duplicate.value("data").toObject().value("message").toObject();
	if (!ok(duplicate) || duplicateMessage.value("id") != stored.value("id")
		|| duplicateMessage.value("seq") != stored.value("seq")) {
		qCritical() << "消息幂等重放失败" << duplicate;
		return 13;
	}
	const QJsonObject event = beta.waitForEvent("message");
	if (event.value("data").toObject().value("body").toString() != body) {
		qCritical() << "实时消息事件缺失" << event;
		return 7;
	}
	const QJsonObject ack = beta.request("ack_message", {
		{"account", alphaAccount}, {"seq", double(textSeq)}, {"kind", "read"}
	}, betaToken);
	const QJsonObject receipt = alpha.waitForEvent("message_receipt");
	if (!ok(ack) || receipt.value("data").toObject().value("kind") != "read"
		|| qint64(receipt.value("data").toObject().value("seq").toDouble())
			!= textSeq) {
		qCritical() << "消息已读回执失败" << ack << receipt;
		return 14;
	}

	const QString editedBody = body + " edited";
	const QJsonObject edited = alpha.request("edit_message", {
		{"messageId", textMessageId}, {"body", editedBody}
	}, alphaToken);
	const QJsonObject editedEvent = beta.waitForEvent("message_updated");
	alpha.waitForEvent("message_updated");
	if (!ok(edited)
		|| editedEvent.value("data").toObject().value("body") != editedBody) {
		qCritical() << "消息编辑同步失败" << edited << editedEvent;
		return 15;
	}
	const QJsonObject reaction = beta.request("react_message", {
		{"messageId", textMessageId}, {"emoji", "👍"}
	}, betaToken);
	const QJsonObject reactionEvent = alpha.waitForEvent("message_updated");
	beta.waitForEvent("message_updated");
	if (!ok(reaction)
		|| reactionEvent.value("data").toObject()
			.value("reactions").toArray().isEmpty()) {
		qCritical() << "消息回应同步失败" << reaction << reactionEvent;
		return 16;
	}

	const QJsonObject file = alpha.request("send_file", {
		{"account", betaAccount},
		{"fileName", "smoke.txt"},
		{"mimeType", "text/plain"},
		{"base64", QString::fromLatin1(QByteArray("file-data").toBase64())},
		{"clientMessageId", QUuid::createUuid().toString(QUuid::WithoutBraces)}
	}, alphaToken);
	if (!ok(file)
		|| file.value("data").toObject().value("attachment").toObject()
			.value("sha256").toString().isEmpty()) {
		qCritical() << "附件持久化失败" << file;
		return 8;
	}
	const QString attachmentId = file.value("data").toObject()
		.value("attachment").toObject().value("id").toString();
	const QJsonObject download = beta.request("download_attachment",
		{{"attachmentId", attachmentId}}, betaToken);
	if (!ok(download)
		|| QByteArray::fromBase64(download.value("data").toObject()
			.value("attachment").toObject().value("base64").toString().toLatin1())
			!= QByteArray("file-data")) {
		qCritical() << "附件下载或权限校验失败" << download;
		return 9;
	}

	const QJsonObject history = beta.request("history",
		{{"account", alphaAccount}, {"limit", 50}}, betaToken);
	const QJsonArray messages =
		history.value("data").toObject().value("messages").toArray();
	bool foundText = false;
	bool foundFile = false;
	for (const QJsonValue& value : messages) {
		const QJsonObject message = value.toObject();
		foundText = foundText || message.value("body").toString() == editedBody;
		foundFile = foundFile || message.value("type").toString() == "file";
	}
	if (!ok(history) || !foundText || !foundFile) {
		qCritical() << "MongoDB 历史消息读取失败" << history;
		return 10;
	}
	const QJsonObject sync = beta.request("sync_messages", {
		{"account", alphaAccount}, {"afterSeq", double(textSeq)}, {"limit", 50}
	}, betaToken);
	if (!ok(sync)
		|| sync.value("data").toObject().value("messages").toArray().isEmpty()
		|| qint64(sync.value("data").toObject().value("nextCursor").toDouble())
			<= textSeq) {
		qCritical() << "游标增量同步失败" << sync;
		return 17;
	}

	const QJsonObject devices = alpha.request("list_devices", {}, alphaToken);
	if (!ok(devices)
		|| devices.value("data").toObject().value("devices").toArray().isEmpty()) {
		qCritical() << "设备会话列表失败" << devices;
		return 18;
	}

	const QJsonObject recalled = alpha.request("recall_message",
		{{"messageId", textMessageId}}, alphaToken);
	const QJsonObject recalledEvent = beta.waitForEvent("message_updated");
	if (!ok(recalled)
		|| recalledEvent.value("data").toObject().value("status") != "recalled") {
		qCritical() << "消息撤回同步失败" << recalled << recalledEvent;
		return 19;
	}

	const QJsonObject forged = alpha.request("snapshot", {}, "invalid-token");
	if (forged.value("ok").toBool()
		|| !forged.value("error").toString().contains("会话")) {
		qCritical() << "无效令牌未被拒绝" << forged;
		return 11;
	}

	qInfo() << "MongoDB 注册、会话、好友、消息、附件和鉴权回归通过"
		<< alphaAccount << betaAccount;
	return 0;
}
