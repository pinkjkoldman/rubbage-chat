#include "MongoChatStore.h"

#include <QCryptographicHash>
#include <QDateTime>
#include <QJsonDocument>
#include <QMessageAuthenticationCode>
#include <QRandomGenerator>
#include <QRegularExpression>
#include <QUuid>

#include <bsoncxx/builder/basic/document.hpp>
#include <bsoncxx/builder/basic/kvp.hpp>
#include <bsoncxx/json.hpp>
#include <mongocxx/client.hpp>
#include <mongocxx/exception/exception.hpp>
#include <mongocxx/instance.hpp>
#include <mongocxx/options/find.hpp>
#include <mongocxx/options/index.hpp>
#include <mongocxx/options/update.hpp>
#include <mongocxx/uri.hpp>

using bsoncxx::builder::basic::kvp;
using bsoncxx::builder::basic::make_document;

namespace
{
qint64 nowMs()
{
	return QDateTime::currentMSecsSinceEpoch();
}

QByteArray randomBytes(int count)
{
	QByteArray bytes(count, Qt::Uninitialized);
	for (int i = 0; i < count; ++i)
		bytes[i] = char(QRandomGenerator::system()->generate() & 0xff);
	return bytes;
}

QByteArray pbkdf2(const QByteArray& password, const QByteArray& salt, int rounds)
{
	constexpr int outputLength = 32;
	QByteArray result;
	for (quint32 block = 1; result.size() < outputLength; ++block) {
		QByteArray suffix(4, '\0');
		suffix[0] = char((block >> 24) & 0xff);
		suffix[1] = char((block >> 16) & 0xff);
		suffix[2] = char((block >> 8) & 0xff);
		suffix[3] = char(block & 0xff);
		QByteArray u = QMessageAuthenticationCode::hash(
			salt + suffix, password, QCryptographicHash::Sha256);
		QByteArray accumulated = u;
		for (int i = 1; i < rounds; ++i) {
			u = QMessageAuthenticationCode::hash(
				u, password, QCryptographicHash::Sha256);
			for (int j = 0; j < accumulated.size(); ++j)
				accumulated[j] = char(accumulated[j] ^ u[j]);
		}
		result.append(accumulated);
	}
	return result.left(outputLength);
}

QString tokenHash(const QString& token)
{
	return QString::fromLatin1(QCryptographicHash::hash(
		token.toUtf8(), QCryptographicHash::Sha256).toHex());
}

QJsonObject jsonObject(const bsoncxx::document::view& view)
{
	return QJsonDocument::fromJson(
		QByteArray::fromStdString(bsoncxx::to_json(
			view, bsoncxx::ExtendedJsonMode::k_relaxed))).object();
}

bsoncxx::document::value bson(const QJsonObject& object)
{
	return bsoncxx::from_json(
		QJsonDocument(object).toJson(QJsonDocument::Compact).toStdString());
}

QString canonicalA(const QString& first, const QString& second)
{
	return first < second ? first : second;
}

QString canonicalB(const QString& first, const QString& second)
{
	return first < second ? second : first;
}

QJsonObject publicUser(const QJsonObject& user)
{
	const QString name = user.value("name").toString();
	return {
		{"account", user.value("account").toString()},
		{"name", name},
		{"initial", name.left(1).toUpper()},
		{"signature", user.value("signature").toString()},
		{"online", false}
	};
}

[[noreturn]] void fail(const QString& message)
{
	throw std::runtime_error(message.toStdString());
}
}

class MongoChatStore::Impl
{
public:
	Impl(const QString& uri, const QString& databaseName)
		: client(mongocxx::uri(uri.toStdString()))
		, database(client[databaseName.toStdString()])
	{
	}

	mongocxx::client client;
	mongocxx::database database;

	QJsonObject findUser(const QString& account)
	{
		auto result = database["users"].find_one(
			make_document(kvp("account", account.toStdString())));
		return result ? jsonObject(result->view()) : QJsonObject{};
	}

	bool friends(const QString& first, const QString& second)
	{
		return bool(database["friendships"].find_one(make_document(
			kvp("a", canonicalA(first, second).toStdString()),
			kvp("b", canonicalB(first, second).toStdString()))));
	}

	void createUser(const QString& account, const QString& name,
		const QString& password)
	{
		const QByteArray salt = randomBytes(16);
		const int rounds = 120000;
		const QString hash = QString::fromLatin1(
			pbkdf2(password.toUtf8(), salt, rounds).toHex());
		database["users"].insert_one(make_document(
			kvp("account", account.toStdString()),
			kvp("name", name.toStdString()),
			kvp("signature", QStringLiteral("这个人很神秘，还没有留下签名").toStdString()),
			kvp("passwordSalt", salt.toHex().toStdString()),
			kvp("passwordHash", hash.toStdString()),
			kvp("passwordRounds", rounds),
			kvp("createdAt", nowMs())));
	}

	void setPassword(const QString& account, const QString& password)
	{
		const QByteArray salt = randomBytes(16);
		const int rounds = 120000;
		const QByteArray hash = pbkdf2(password.toUtf8(), salt, rounds).toHex();
		database["users"].update_one(
			make_document(kvp("account", account.toStdString())),
			make_document(kvp("$set", make_document(
				kvp("passwordSalt", salt.toHex().toStdString()),
				kvp("passwordHash", hash.toStdString()),
				kvp("passwordRounds", rounds)))));
	}

	bool passwordMatches(const QJsonObject& user, const QString& password)
	{
		const QByteArray salt = QByteArray::fromHex(
			user.value("passwordSalt").toString().toLatin1());
		const int rounds = user.value("passwordRounds").toInt();
		const QByteArray actual = pbkdf2(password.toUtf8(), salt, rounds).toHex();
		return !salt.isEmpty() && rounds >= 10000
			&& actual == user.value("passwordHash").toString().toLatin1();
	}
};

MongoChatStore::MongoChatStore(const QString& uri, const QString& databaseName)
	: d(std::make_unique<Impl>(uri, databaseName))
{
}

MongoChatStore::~MongoChatStore() = default;

bool MongoChatStore::initialize(QString* error)
{
	try {
		d->database.run_command(make_document(kvp("ping", 1)));
		mongocxx::options::index unique;
		unique.unique(true);
		d->database["users"].create_index(
			make_document(kvp("account", 1)), unique);
		d->database["sessions"].create_index(
			make_document(kvp("tokenHash", 1)), unique);
		d->database["friendships"].create_index(
			make_document(kvp("a", 1), kvp("b", 1)), unique);
		d->database["friend_requests"].create_index(
			make_document(kvp("sender", 1), kvp("receiver", 1), kvp("status", 1)));
		d->database["messages"].create_index(
			make_document(kvp("clientMessageId", 1)), unique);
		d->database["messages"].create_index(
			make_document(kvp("a", 1), kvp("b", 1), kvp("createdAt", 1)));
		d->database["conversation_options"].create_index(
			make_document(kvp("owner", 1), kvp("peer", 1)), unique);

		if (d->findUser("100000001").isEmpty())
			d->createUser("100000001", "演示账号 Alpha", "rubbagechat");
		else
			d->setPassword("100000001", "rubbagechat");
		if (d->findUser("100000002").isEmpty())
			d->createUser("100000002", "演示账号 Beta", "rubbagechat");
		else
			d->setPassword("100000002", "rubbagechat");
		return true;
	}
	catch (const std::exception& exception) {
		if (error)
			*error = QString::fromUtf8(exception.what());
		return false;
	}
}

QJsonObject MongoChatStore::registerUser(const QString& name, const QString& password)
{
	const QString cleanName = name.trimmed();
	if (cleanName.size() < 2 || cleanName.size() > 20)
		fail(QStringLiteral("昵称需要 2-20 个字符"));
	if (password.size() < 8 || password.size() > 72)
		fail(QStringLiteral("密码需要 8-72 个字符"));

	QString account;
	for (int attempt = 0; attempt < 100; ++attempt) {
		account = QString::number(
			QRandomGenerator::system()->bounded(100000000, 1000000000));
		if (d->findUser(account).isEmpty())
			break;
		account.clear();
	}
	if (account.isEmpty())
		fail(QStringLiteral("暂时无法分配账号，请重试"));
	d->createUser(account, cleanName, password);
	return {{"account", account}, {"name", cleanName}};
}

QJsonObject MongoChatStore::login(const QString& account, const QString& password)
{
	if (!QRegularExpression("^\\d{9}$").match(account).hasMatch())
		fail(QStringLiteral("账号必须是 9 位数字"));
	const QJsonObject user = d->findUser(account);
	if (user.isEmpty() || !d->passwordMatches(user, password))
		fail(QStringLiteral("账号或密码不正确"));
	const QString token = QString::fromLatin1(randomBytes(32).toHex());
	d->database["sessions"].insert_one(make_document(
		kvp("tokenHash", tokenHash(token).toStdString()),
		kvp("account", account.toStdString()),
		kvp("createdAt", nowMs()),
		kvp("expiresAt", nowMs() + 30LL * 24 * 60 * 60 * 1000)));
	QJsonObject result = publicUser(user);
	result.insert("token", token);
	result.insert("snapshot", snapshot(account));
	return result;
}

QString MongoChatStore::authenticate(const QString& token)
{
	if (token.size() < 32)
		return {};
	auto session = d->database["sessions"].find_one(make_document(
		kvp("tokenHash", tokenHash(token).toStdString()),
		kvp("expiresAt", make_document(kvp("$gt", nowMs())))));
	return session ? jsonObject(session->view()).value("account").toString() : QString{};
}

void MongoChatStore::logout(const QString& token)
{
	d->database["sessions"].delete_one(
		make_document(kvp("tokenHash", tokenHash(token).toStdString())));
}

QJsonObject MongoChatStore::snapshot(const QString& account)
{
	QJsonArray contacts;
	auto friendships = d->database["friendships"].find(bson(QJsonObject{
		{"$or", QJsonArray{
			QJsonObject{{"a", account}}, QJsonObject{{"b", account}}
		}}
	}).view());
	for (const auto& row : friendships) {
		const QJsonObject friendship = jsonObject(row);
		const QString peer = friendship.value("a").toString() == account
			? friendship.value("b").toString() : friendship.value("a").toString();
		const QJsonObject user = d->findUser(peer);
		if (!user.isEmpty())
			contacts.append(publicUser(user));
	}

	QJsonArray requests;
	auto pending = d->database["friend_requests"].find(make_document(
		kvp("receiver", account.toStdString()), kvp("status", "pending")));
	for (const auto& row : pending) {
		const QString sender = jsonObject(row).value("sender").toString();
		const QJsonObject user = d->findUser(sender);
		if (!user.isEmpty())
			requests.append(publicUser(user));
	}

	QJsonArray conversations;
	for (const QJsonValue& contactValue : contacts) {
		QJsonObject contact = contactValue.toObject();
		const QString peer = contact.value("account").toString();
		mongocxx::options::find options;
		options.sort(make_document(kvp("createdAt", -1)));
		options.limit(1);
		auto cursor = d->database["messages"].find(make_document(
			kvp("a", canonicalA(account, peer).toStdString()),
			kvp("b", canonicalB(account, peer).toStdString())), options);
		QString lastMessage = QStringLiteral("开始聊天");
		QString time;
		for (const auto& row : cursor) {
			const QJsonObject message = jsonObject(row);
			lastMessage = message.value("body").toString();
			time = QDateTime::fromMSecsSinceEpoch(
				qint64(message.value("createdAt").toDouble()))
				.toString("HH:mm");
		}
		const QJsonObject preference = conversationOption(account, peer);
		contact.insert("lastMessage", lastMessage);
		contact.insert("time", time);
		contact.insert("unread", int(d->database["messages"].count_documents(
			make_document(kvp("sender", peer.toStdString()),
				kvp("receiver", account.toStdString()), kvp("read", false)))));
		contact.insert("pinned", preference.value("pinned").toBool());
		contact.insert("muted", preference.value("muted").toBool());
		conversations.append(contact);
	}
	return {
		{"profile", publicUser(d->findUser(account))},
		{"contacts", contacts},
		{"requests", requests},
		{"conversations", conversations}
	};
}

QJsonObject MongoChatStore::searchUser(const QString& owner, const QString& account)
{
	const QJsonObject user = d->findUser(account.trimmed());
	if (user.isEmpty())
		return {};
	QJsonObject result = publicUser(user);
	result.insert("isFriend", d->friends(owner, account));
	return result;
}

void MongoChatStore::sendFriendRequest(const QString& sender, const QString& receiver)
{
	if (sender == receiver)
		fail(QStringLiteral("不能添加自己为好友"));
	if (d->findUser(receiver).isEmpty())
		fail(QStringLiteral("未找到该用户"));
	if (d->friends(sender, receiver))
		fail(QStringLiteral("对方已经是你的好友"));
	if (d->database["friend_requests"].find_one(make_document(
		kvp("sender", sender.toStdString()), kvp("receiver", receiver.toStdString()),
		kvp("status", "pending"))))
		fail(QStringLiteral("好友申请已发送"));
	d->database["friend_requests"].insert_one(make_document(
		kvp("sender", sender.toStdString()), kvp("receiver", receiver.toStdString()),
		kvp("status", "pending"), kvp("createdAt", nowMs())));
}

void MongoChatStore::acceptFriendRequest(const QString& receiver, const QString& sender)
{
	auto request = d->database["friend_requests"].find_one(make_document(
		kvp("sender", sender.toStdString()), kvp("receiver", receiver.toStdString()),
		kvp("status", "pending")));
	if (!request)
		fail(QStringLiteral("好友申请不存在或已处理"));
	mongocxx::options::update upsert;
	upsert.upsert(true);
	d->database["friendships"].update_one(make_document(
		kvp("a", canonicalA(sender, receiver).toStdString()),
		kvp("b", canonicalB(sender, receiver).toStdString())),
		make_document(kvp("$setOnInsert", make_document(kvp("createdAt", nowMs())))),
		upsert);
	d->database["friend_requests"].update_one(make_document(
		kvp("sender", sender.toStdString()), kvp("receiver", receiver.toStdString()),
		kvp("status", "pending")),
		make_document(kvp("$set", make_document(
			kvp("status", "accepted"), kvp("resolvedAt", nowMs())))));
}

void MongoChatStore::rejectFriendRequest(const QString& receiver, const QString& sender)
{
	auto result = d->database["friend_requests"].update_one(make_document(
		kvp("sender", sender.toStdString()), kvp("receiver", receiver.toStdString()),
		kvp("status", "pending")),
		make_document(kvp("$set", make_document(
			kvp("status", "rejected"), kvp("resolvedAt", nowMs())))));
	if (!result || result->matched_count() == 0)
		fail(QStringLiteral("好友申请不存在或已处理"));
}

void MongoChatStore::removeFriend(const QString& owner, const QString& peer)
{
	d->database["friendships"].delete_one(make_document(
		kvp("a", canonicalA(owner, peer).toStdString()),
		kvp("b", canonicalB(owner, peer).toStdString())));
}

QJsonObject MongoChatStore::sendMessage(const QString& sender, const QString& receiver,
	const QString& body, const QString& clientMessageId, const QString& type,
	const QString& attachmentId)
{
	if (!d->friends(sender, receiver))
		fail(QStringLiteral("只有好友之间才能发送消息"));
	const QString cleanBody = body.trimmed();
	if (cleanBody.isEmpty() || cleanBody.size() > 4000)
		fail(QStringLiteral("消息长度需要在 1-4000 个字符之间"));
	const QString id = clientMessageId.isEmpty()
		? QUuid::createUuid().toString(QUuid::WithoutBraces) : clientMessageId;
	const qint64 createdAt = nowMs();
	QJsonObject message{
		{"id", QUuid::createUuid().toString(QUuid::WithoutBraces)},
		{"clientMessageId", id},
		{"sender", sender},
		{"receiver", receiver},
		{"a", canonicalA(sender, receiver)},
		{"b", canonicalB(sender, receiver)},
		{"body", cleanBody},
		{"type", type},
		{"attachmentId", attachmentId},
		{"createdAt", double(createdAt)},
		{"read", false}
	};
	try {
		d->database["messages"].insert_one(bson(message).view());
	}
	catch (const mongocxx::exception&) {
		auto existing = d->database["messages"].find_one(
			make_document(kvp("clientMessageId", id.toStdString())));
		if (!existing)
			throw;
		return jsonObject(existing->view());
	}
	return message;
}

QJsonArray MongoChatStore::history(const QString& owner, const QString& peer, int limit)
{
	if (!d->friends(owner, peer))
		fail(QStringLiteral("只有好友之间才能读取会话"));
	const QJsonObject preference = conversationOption(owner, peer);
	const qint64 hiddenBefore = qint64(preference.value("hiddenBefore").toDouble());
	QJsonObject filter{
		{"a", canonicalA(owner, peer)},
		{"b", canonicalB(owner, peer)}
	};
	if (hiddenBefore > 0)
		filter.insert("createdAt", QJsonObject{{"$gt", double(hiddenBefore)}});
	mongocxx::options::find options;
	options.sort(make_document(kvp("createdAt", 1)));
	options.limit(qBound(1, limit, 500));
	QJsonArray messages;
	for (const auto& row : d->database["messages"].find(bson(filter).view(), options))
		messages.append(jsonObject(row));
	d->database["messages"].update_many(make_document(
		kvp("sender", peer.toStdString()), kvp("receiver", owner.toStdString()),
		kvp("read", false)),
		make_document(kvp("$set", make_document(kvp("read", true)))));
	return messages;
}

QJsonObject MongoChatStore::storeAttachment(const QString& owner,
	const QString& receiver, const QString& fileName, const QString& mimeType,
	const QByteArray& bytes)
{
	if (!d->friends(owner, receiver))
		fail(QStringLiteral("只有好友之间才能发送文件"));
	if (bytes.isEmpty() || bytes.size() > 6 * 1024 * 1024)
		fail(QStringLiteral("文件大小需要在 1 字节到 6 MB 之间"));
	const QString safeName = fileName.left(180);
	const QString id = QUuid::createUuid().toString(QUuid::WithoutBraces);
	const QString sha256 = QString::fromLatin1(
		QCryptographicHash::hash(bytes, QCryptographicHash::Sha256).toHex());
	d->database["attachments"].insert_one(make_document(
		kvp("id", id.toStdString()), kvp("owner", owner.toStdString()),
		kvp("receiver", receiver.toStdString()), kvp("fileName", safeName.toStdString()),
		kvp("mimeType", mimeType.left(120).toStdString()), kvp("size", qint64(bytes.size())),
		kvp("sha256", sha256.toStdString()),
		kvp("base64", bytes.toBase64().toStdString()), kvp("createdAt", nowMs())));
	return {{"id", id}, {"fileName", safeName}, {"size", double(bytes.size())},
		{"sha256", sha256}};
}

QJsonObject MongoChatStore::loadAttachment(
	const QString& requester, const QString& attachmentId)
{
	auto result = d->database["attachments"].find_one(make_document(
		kvp("id", attachmentId.toStdString())));
	if (!result)
		fail(QStringLiteral("附件不存在"));
	const QJsonObject attachment = jsonObject(result->view());
	if (attachment.value("owner").toString() != requester
		&& attachment.value("receiver").toString() != requester)
		fail(QStringLiteral("无权下载该附件"));
	return {
		{"id", attachment.value("id").toString()},
		{"fileName", attachment.value("fileName").toString()},
		{"mimeType", attachment.value("mimeType").toString()},
		{"size", attachment.value("size").toDouble()},
		{"sha256", attachment.value("sha256").toString()},
		{"base64", attachment.value("base64").toString()}
	};
}

void MongoChatStore::setConversationOption(const QString& owner,
	const QString& peer, const QString& option, bool value)
{
	if (option != "pinned" && option != "muted")
		fail(QStringLiteral("未知会话选项"));
	mongocxx::options::update upsert;
	upsert.upsert(true);
	d->database["conversation_options"].update_one(make_document(
		kvp("owner", owner.toStdString()), kvp("peer", peer.toStdString())),
		make_document(kvp("$set", make_document(kvp(option.toStdString(), value)))),
		upsert);
}

QJsonObject MongoChatStore::conversationOption(
	const QString& owner, const QString& peer)
{
	auto result = d->database["conversation_options"].find_one(make_document(
		kvp("owner", owner.toStdString()), kvp("peer", peer.toStdString())));
	QJsonObject option = result ? jsonObject(result->view()) : QJsonObject{};
	return {{"pinned", option.value("pinned").toBool()},
		{"muted", option.value("muted").toBool()},
		{"hiddenBefore", option.value("hiddenBefore").toDouble()}};
}

void MongoChatStore::clearConversation(const QString& owner, const QString& peer)
{
	mongocxx::options::update upsert;
	upsert.upsert(true);
	d->database["conversation_options"].update_one(make_document(
		kvp("owner", owner.toStdString()), kvp("peer", peer.toStdString())),
		make_document(kvp("$set", make_document(kvp("hiddenBefore", nowMs())))), upsert);
}

void MongoChatStore::updateProfile(const QString& account, const QString& name,
	const QString& signature)
{
	const QString cleanName = name.trimmed();
	if (cleanName.size() < 2 || cleanName.size() > 20)
		fail(QStringLiteral("昵称需要 2-20 个字符"));
	if (signature.size() > 120)
		fail(QStringLiteral("签名不能超过 120 个字符"));
	d->database["users"].update_one(
		make_document(kvp("account", account.toStdString())),
		make_document(kvp("$set", make_document(
			kvp("name", cleanName.toStdString()),
			kvp("signature", signature.trimmed().toStdString())))));
}

void MongoChatStore::changePassword(const QString& account,
	const QString& currentPassword, const QString& newPassword)
{
	const QJsonObject user = d->findUser(account);
	if (!d->passwordMatches(user, currentPassword))
		fail(QStringLiteral("当前密码不正确"));
	if (newPassword.size() < 8 || newPassword.size() > 72)
		fail(QStringLiteral("新密码需要 8-72 个字符"));
	d->setPassword(account, newPassword);
	d->database["sessions"].delete_many(
		make_document(kvp("account", account.toStdString())));
}
