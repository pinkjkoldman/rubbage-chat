#pragma once

#include <QJsonArray>
#include <QJsonObject>
#include <QString>

#include <memory>

class MongoChatStore
{
public:
	explicit MongoChatStore(const QString& uri, const QString& databaseName);
	~MongoChatStore();

	bool initialize(QString* error);
	QJsonObject registerUser(const QString& name, const QString& password);
	QJsonObject login(const QString& account, const QString& password);
	QString authenticate(const QString& token);
	void logout(const QString& token);

	QJsonObject snapshot(const QString& account);
	QJsonObject searchUser(const QString& owner, const QString& account);
	void sendFriendRequest(const QString& sender, const QString& receiver);
	void acceptFriendRequest(const QString& receiver, const QString& sender);
	void rejectFriendRequest(const QString& receiver, const QString& sender);
	void removeFriend(const QString& owner, const QString& peer);

	QJsonObject sendMessage(const QString& sender, const QString& receiver,
		const QString& body, const QString& clientMessageId,
		const QString& type = "text", const QString& attachmentId = {});
	QJsonArray history(const QString& owner, const QString& peer, int limit = 200);
	QJsonObject storeAttachment(const QString& owner, const QString& receiver,
		const QString& fileName, const QString& mimeType, const QByteArray& bytes);
	QJsonObject loadAttachment(const QString& requester, const QString& attachmentId);

	void setConversationOption(const QString& owner, const QString& peer,
		const QString& option, bool value);
	QJsonObject conversationOption(const QString& owner, const QString& peer);
	void clearConversation(const QString& owner, const QString& peer);
	void updateProfile(const QString& account, const QString& name,
		const QString& signature);
	void changePassword(const QString& account, const QString& currentPassword,
		const QString& newPassword);

private:
	class Impl;
	std::unique_ptr<Impl> d;
};
