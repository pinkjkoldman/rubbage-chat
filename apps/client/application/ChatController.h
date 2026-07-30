#pragma once

#include <QHash>
#include <QJsonArray>
#include <QJsonObject>
#include <QObject>
#include <QSettings>
#include <QSslSocket>
#include <QTimer>
#include <QUrl>
#include <QVariantList>

class ChatController final : public QObject
{
	Q_OBJECT
	Q_PROPERTY(bool authenticated READ authenticated NOTIFY authenticatedChanged)
	Q_PROPERTY(bool connected READ connected NOTIFY connectedChanged)
	Q_PROPERTY(QString currentUserAccount READ currentUserAccount NOTIFY currentUserChanged)
	Q_PROPERTY(QString currentUserName READ currentUserName NOTIFY currentUserChanged)
	Q_PROPERTY(QString currentUserSignature READ currentUserSignature NOTIFY currentUserChanged)
	Q_PROPERTY(QString selectedPeerAccount READ selectedPeerAccount NOTIFY selectedPeerChanged)
	Q_PROPERTY(QString selectedPeerName READ selectedPeerName NOTIFY selectedPeerChanged)
	Q_PROPERTY(bool selectedPeerOnline READ selectedPeerOnline NOTIFY selectedPeerChanged)
	Q_PROPERTY(QVariantList contacts READ contacts NOTIFY contactsChanged)
	Q_PROPERTY(QVariantList conversations READ conversations NOTIFY conversationsChanged)
	Q_PROPERTY(QVariantList messages READ messages NOTIFY messagesChanged)
	Q_PROPERTY(QVariantList requests READ requests NOTIFY requestsChanged)
	Q_PROPERTY(QVariantMap searchResult READ searchResult NOTIFY searchResultChanged)
	Q_PROPERTY(int notificationCount READ notificationCount NOTIFY requestsChanged)
	Q_PROPERTY(QString lastRegisteredAccount READ lastRegisteredAccount NOTIFY lastRegisteredAccountChanged)
	Q_PROPERTY(QString toastMessage READ toastMessage NOTIFY toastChanged)
	Q_PROPERTY(bool toastError READ toastError NOTIFY toastChanged)
	Q_PROPERTY(QString theme READ theme WRITE setTheme NOTIFY settingsChanged)
	Q_PROPERTY(bool effectiveDark READ effectiveDark NOTIFY settingsChanged)
	Q_PROPERTY(bool notificationsEnabled READ notificationsEnabled WRITE setNotificationsEnabled NOTIFY settingsChanged)
	Q_PROPERTY(bool enterToSend READ enterToSend WRITE setEnterToSend NOTIFY settingsChanged)
	Q_PROPERTY(bool showOnlineStatus READ showOnlineStatus WRITE setShowOnlineStatus NOTIFY settingsChanged)
	Q_PROPERTY(bool compactMode READ compactMode WRITE setCompactMode NOTIFY settingsChanged)
	Q_PROPERTY(bool fileTransferActive READ fileTransferActive NOTIFY fileTransferChanged)
	Q_PROPERTY(qreal fileTransferProgress READ fileTransferProgress NOTIFY fileTransferChanged)
	Q_PROPERTY(QString fileTransferLabel READ fileTransferLabel NOTIFY fileTransferChanged)
	Q_PROPERTY(QString serverHost READ serverHost NOTIFY networkSettingsChanged)
	Q_PROPERTY(int chatPort READ chatPort NOTIFY networkSettingsChanged)
	Q_PROPERTY(int filePort READ filePort NOTIFY networkSettingsChanged)

public:
	explicit ChatController(QObject* parent = nullptr);
	~ChatController() override;

	bool authenticated() const { return m_authenticated; }
	bool connected() const { return m_connected; }
	QString currentUserAccount() const { return m_currentUserAccount; }
	QString currentUserName() const { return m_currentUserName; }
	QString currentUserSignature() const { return m_currentUserSignature; }
	QString selectedPeerAccount() const { return m_selectedPeerAccount; }
	QString selectedPeerName() const { return m_selectedPeerName; }
	bool selectedPeerOnline() const { return m_selectedPeerOnline; }
	QVariantList contacts() const { return m_contacts; }
	QVariantList conversations() const { return m_conversations; }
	QVariantList messages() const { return m_messages; }
	QVariantList requests() const { return m_requests; }
	QVariantMap searchResult() const { return m_searchResult; }
	int notificationCount() const { return m_requests.size(); }
	QString lastRegisteredAccount() const { return m_lastRegisteredAccount; }
	QString toastMessage() const { return m_toastMessage; }
	bool toastError() const { return m_toastError; }
	QString theme() const { return m_theme; }
	bool effectiveDark() const;
	bool notificationsEnabled() const { return m_notificationsEnabled; }
	bool enterToSend() const { return m_enterToSend; }
	bool showOnlineStatus() const { return m_showOnlineStatus; }
	bool compactMode() const { return m_compactMode; }
	bool fileTransferActive() const { return m_fileTransferActive; }
	qreal fileTransferProgress() const { return m_fileTransferProgress; }
	QString fileTransferLabel() const { return m_fileTransferLabel; }
	QString serverHost() const { return m_serverHost; }
	int chatPort() const { return m_chatPort; }
	int filePort() const { return m_filePort; }

	Q_INVOKABLE void login(const QString& account, const QString& password);
	Q_INVOKABLE void registerAccount(const QString& name, const QString& password, const QString& confirmation);
	Q_INVOKABLE void logout();
	Q_INVOKABLE void refreshAll();
	Q_INVOKABLE void selectPeer(const QString& account);
	Q_INVOKABLE void sendMessage(const QString& text);
	Q_INVOKABLE void sendFile(const QUrl& fileUrl);
	Q_INVOKABLE void downloadAttachment(const QString& attachmentId);
	Q_INVOKABLE void searchUser(const QString& account);
	Q_INVOKABLE void sendFriendRequest(const QString& account);
	Q_INVOKABLE void acceptFriendRequest(const QString& account);
	Q_INVOKABLE void rejectFriendRequest(const QString& account);
	Q_INVOKABLE void removeFriend(const QString& account);
	Q_INVOKABLE void togglePinned(const QString& account);
	Q_INVOKABLE void toggleMuted(const QString& account);
	Q_INVOKABLE void clearCurrentConversation();
	Q_INVOKABLE void updateProfile(const QString& name, const QString& signature);
	Q_INVOKABLE void changePassword(const QString& currentPassword,
		const QString& newPassword, const QString& confirmation);
	Q_INVOKABLE QVariantMap conversationOptions(const QString& account) const;
	Q_INVOKABLE void clearToast();
	Q_INVOKABLE void applyNetworkSettings(const QString& host, int chatPort, int filePort);

	void setTheme(const QString& value);
	void setNotificationsEnabled(bool value);
	void setEnterToSend(bool value);
	void setShowOnlineStatus(bool value);
	void setCompactMode(bool value);

signals:
	void authenticatedChanged();
	void connectedChanged();
	void currentUserChanged();
	void selectedPeerChanged();
	void contactsChanged();
	void conversationsChanged();
	void messagesChanged();
	void requestsChanged();
	void searchResultChanged();
	void lastRegisteredAccountChanged();
	void toastChanged();
	void settingsChanged();
	void fileTransferChanged();
	void networkSettingsChanged();

private:
	void connectToServer();
	void setConnected(bool value);
	QString sendRequest(const QString& action, const QJsonObject& data = {},
		bool authenticated = true);
	void processIncomingData();
	void processPacket(const QJsonObject& packet);
	void processResponse(const QString& action, const QJsonObject& data);
	void processEvent(const QString& event, const QJsonObject& data);
	void applySnapshot(const QJsonObject& snapshot);
	void applyPresence(const QString& account, bool online);
	void applyHistory(const QJsonArray& messages);
	void resetIdentity();
	void showToast(const QString& message, bool error = false);
	void saveSetting(const QString& key, const QVariant& value);
	QVariantMap peerMap(const QString& account) const;

	QSslSocket m_socket;
	QByteArray m_incomingBuffer;
	QTimer m_reconnectTimer;
	QTimer m_pingTimer;
	QSettings m_settings;
	QHash<QString, QString> m_pendingActions;
	QList<QJsonObject> m_outbox;
	QString m_token;
	bool m_authenticated = false;
	bool m_connected = false;
	QString m_currentUserAccount;
	QString m_currentUserName;
	QString m_currentUserSignature;
	QString m_selectedPeerAccount;
	QString m_selectedPeerName;
	bool m_selectedPeerOnline = false;
	QVariantList m_contacts;
	QVariantList m_conversations;
	QVariantList m_messages;
	QVariantList m_requests;
	QVariantMap m_searchResult;
	QString m_lastRegisteredAccount;
	QString m_toastMessage;
	bool m_toastError = false;
	QString m_theme;
	bool m_notificationsEnabled = true;
	bool m_enterToSend = true;
	bool m_showOnlineStatus = true;
	bool m_compactMode = false;
	bool m_fileTransferActive = false;
	qreal m_fileTransferProgress = 0.0;
	QString m_fileTransferLabel;
	QString m_serverHost = "127.0.0.1";
	bool m_tlsEnabled = false;
	int m_chatPort = 7502;
	int m_filePort = 7028;
};
