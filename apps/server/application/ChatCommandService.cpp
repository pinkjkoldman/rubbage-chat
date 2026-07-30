#include "ChatCommandService.h"

#include "../storage/MongoChatStore.h"

#include <QMetaObject>
#include <QRunnable>

#include <memory>
#include <stdexcept>

namespace
{
QString errorText(const std::exception& exception)
{
	const QString message = QString::fromUtf8(exception.what()).trimmed();
	return message.isEmpty() ? QStringLiteral("服务器处理失败") : message;
}
}

ChatCommandService::ChatCommandService(const QString& mongoUri,
	const QString& databaseName, bool registrationEnabled, int maxWorkers,
	int maxPending, QObject* parent)
	: QObject(parent)
	, m_mongoUri(mongoUri)
	, m_databaseName(databaseName)
	, m_registrationEnabled(registrationEnabled)
	, m_maxPending(qBound(100, maxPending, 50000))
{
	m_pool.setMaxThreadCount(qBound(2, maxWorkers, 64));
	m_pool.setExpiryTimeout(60000);
}

ChatCommandService::~ChatCommandService()
{
	m_pool.waitForDone();
}

bool ChatCommandService::execute(
	const QJsonObject& packet, Completion completion)
{
	if (m_pending.fetchAndAddRelaxed(1) >= m_maxPending) {
		m_pending.fetchAndSubRelaxed(1);
		return false;
	}
	m_pool.start(QRunnable::create(
		[this, packet, completion = std::move(completion)]() mutable {
			Result result;
			try {
				result = run(packet);
			}
			catch (const std::exception& exception) {
				result.action = packet.value("action").toString();
				result.error = errorText(exception);
			}
			m_pending.fetchAndSubRelaxed(1);
			QMetaObject::invokeMethod(this,
				[completion = std::move(completion), result = std::move(result)]() mutable {
					completion(std::move(result));
				},
				Qt::QueuedConnection);
		}));
	return true;
}

ChatCommandService::Result ChatCommandService::run(
	const QJsonObject& packet) const
{
	thread_local std::unique_ptr<MongoChatStore> store;
	thread_local QString storeKey;
	const QString requestedKey = m_mongoUri + QChar('\n') + m_databaseName;
	if (!store || storeKey != requestedKey) {
		store = std::make_unique<MongoChatStore>(m_mongoUri, m_databaseName);
		storeKey = requestedKey;
	}

	Result result;
	result.action = packet.value("action").toString();
	const QJsonObject data = packet.value("data").toObject();
	const QString action = result.action;
	if (action == "register") {
		if (!m_registrationEnabled)
			throw std::runtime_error("当前未开放新账号注册");
		result.data = store->registerUser(
			data.value("name").toString(), data.value("password").toString());
		result.ok = true;
		return result;
	}
	if (action == "login") {
		result.data = store->login(data.value("account").toString().trimmed(),
			data.value("password").toString(),
			packet.value("deviceId").toString());
		result.account = result.data.value("account").toString();
		result.token = result.data.value("token").toString();
		result.deviceId = result.data.value("deviceId").toString();
		result.login = true;
		result.ok = true;
		return result;
	}

	const QString token = packet.value("token").toString();
	result.account = store->authenticate(token);
	if (result.account.isEmpty())
		throw std::runtime_error("会话已失效，请重新登录");
	result.token = token;

	if (action == "logout") {
		store->logout(token);
		result.logout = true;
	}
	else if (action == "snapshot") {
		result.data = store->snapshot(result.account);
	}
	else if (action == "search_user") {
		result.data = {{"user", store->searchUser(
			result.account, data.value("account").toString())}};
	}
	else if (action == "send_friend_request") {
		const QString peer = data.value("account").toString();
		store->sendFriendRequest(result.account, peer);
		result.stateAccounts = {result.account, peer};
	}
	else if (action == "accept_friend_request") {
		const QString peer = data.value("account").toString();
		store->acceptFriendRequest(result.account, peer);
		result.stateAccounts = {result.account, peer};
	}
	else if (action == "reject_friend_request") {
		const QString peer = data.value("account").toString();
		store->rejectFriendRequest(result.account, peer);
		result.stateAccounts = {result.account, peer};
	}
	else if (action == "remove_friend") {
		const QString peer = data.value("account").toString();
		store->removeFriend(result.account, peer);
		result.stateAccounts = {result.account, peer};
	}
	else if (action == "history" || action == "sync_messages") {
		result.data = store->syncMessages(result.account,
			data.value("account").toString(),
			action == "history" ? 0 : qint64(data.value("afterSeq").toDouble()),
			data.value("limit").toInt(200));
	}
	else if (action == "send_message") {
		const QString peer = data.value("account").toString();
		const QJsonObject message = store->sendMessage(result.account, peer,
			data.value("body").toString(),
			data.value("clientMessageId").toString(), "text", {},
			packet.value("deviceId").toString(),
			data.value("replyToId").toString());
		result.data = {{"message", message}};
		result.notifications = {
			{peer, "message", message},
			{result.account, "message_committed", message}
		};
		result.stateAccounts = {result.account, peer};
	}
	else if (action == "send_file") {
		const QString peer = data.value("account").toString();
		const QByteArray bytes = QByteArray::fromBase64(
			data.value("base64").toString().toLatin1());
		const QJsonObject attachment = store->storeAttachment(result.account, peer,
			data.value("fileName").toString(), data.value("mimeType").toString(),
			bytes);
		const QJsonObject message = store->sendMessage(result.account, peer,
			QStringLiteral("[文件] %1").arg(attachment.value("fileName").toString()),
			data.value("clientMessageId").toString(), "file",
			attachment.value("id").toString(),
			packet.value("deviceId").toString(),
			data.value("replyToId").toString());
		result.data = {{"attachment", attachment}, {"message", message}};
		result.notifications = {
			{peer, "message", message},
			{result.account, "message_committed", message}
		};
		result.stateAccounts = {result.account, peer};
	}
	else if (action == "download_attachment") {
		result.data = {{"attachment", store->loadAttachment(result.account,
			data.value("attachmentId").toString())}};
	}
	else if (action == "ack_message") {
		const QString peer = data.value("account").toString();
		const QJsonObject receipt = store->acknowledgeMessage(result.account, peer,
			qint64(data.value("seq").toDouble()), data.value("kind").toString());
		result.data = {{"receipt", receipt}};
		result.notifications = {{peer, "message_receipt", receipt}};
	}
	else if (action == "edit_message" || action == "recall_message"
		|| action == "react_message") {
		QJsonObject message;
		if (action == "edit_message")
			message = store->editMessage(result.account,
				data.value("messageId").toString(), data.value("body").toString());
		else if (action == "recall_message")
			message = store->recallMessage(result.account,
				data.value("messageId").toString());
		else
			message = store->reactToMessage(result.account,
				data.value("messageId").toString(), data.value("emoji").toString());
		result.data = {{"message", message}};
		const QString other = message.value("sender").toString() == result.account
			? message.value("receiver").toString()
			: message.value("sender").toString();
		result.notifications = {
			{other, "message_updated", message},
			{result.account, "message_updated", message}
		};
	}
	else if (action == "list_devices") {
		result.data = {{"devices", store->devices(result.account)}};
	}
	else if (action == "revoke_device") {
		result.revokeDeviceId = data.value("deviceId").toString();
		store->revokeDevice(result.account, result.revokeDeviceId, token);
	}
	else if (action == "set_conversation_option") {
		store->setConversationOption(result.account,
			data.value("account").toString(), data.value("option").toString(),
			data.value("value").toBool());
		result.stateAccounts = {result.account};
	}
	else if (action == "conversation_option") {
		result.data = store->conversationOption(result.account,
			data.value("account").toString());
	}
	else if (action == "clear_conversation") {
		store->clearConversation(result.account, data.value("account").toString());
		result.stateAccounts = {result.account};
	}
	else if (action == "update_profile") {
		store->updateProfile(result.account, data.value("name").toString(),
			data.value("signature").toString());
		result.stateAccounts = {result.account};
	}
	else if (action == "change_password") {
		store->changePassword(result.account,
			data.value("currentPassword").toString(),
			data.value("newPassword").toString());
		result.reauthenticate = true;
	}
	else {
		throw std::runtime_error("未知操作");
	}
	result.ok = true;
	return result;
}
