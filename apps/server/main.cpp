#include <QCoreApplication>
#include <QDebug>

#include <mongocxx/instance.hpp>

#include "network/ChatServer.h"

int main(int argc, char* argv[])
{
	QCoreApplication application(argc, argv);
	QCoreApplication::setOrganizationName("RubbageChat");
	QCoreApplication::setApplicationName("RubbageChatServer");

	const mongocxx::instance mongoInstance{};
	ChatServer server;
	QString error;
	if (!server.start(&error)) {
		qCritical().noquote() << "RubbageChatServer 启动失败：" << error;
		return 2;
	}
	qInfo() << "RubbageChatServer 已启动，MongoDB 业务库已连接";
	return application.exec();
}
