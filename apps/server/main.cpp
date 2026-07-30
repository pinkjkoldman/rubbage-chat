#include <QCoreApplication>
#include <QDir>
#include <QFileInfo>
#include <QFont>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QQuickWindow>
#include <QTimer>

#include <mongocxx/instance.hpp>

#include "network/ChatServer.h"

int main(int argc, char* argv[])
{
	QGuiApplication application(argc, argv);
	QCoreApplication::setOrganizationName("RubbageChat");
	QCoreApplication::setApplicationName("RubbageChatServer");
	QCoreApplication::setApplicationVersion("2.4.0-beta.1");

	QFont interfaceFont = application.font();
	QStringList interfaceFamilies{
		"-apple-system",
		"SF Pro",
		"SF Pro Text",
		"SF Pro Display",
		"PingFang SC",
		"Microsoft YaHei UI",
		"Segoe UI"
	};
	for (const QString& family : interfaceFont.families()) {
		if (!interfaceFamilies.contains(family, Qt::CaseInsensitive))
			interfaceFamilies.append(family);
	}
	interfaceFont.setFamilies(interfaceFamilies);
	interfaceFont.setWeight(QFont::Normal);
	interfaceFont.setHintingPreference(QFont::PreferNoHinting);
	application.setFont(interfaceFont);

	const mongocxx::instance mongoInstance{};
	ChatServer server;
	if (application.arguments().contains(QStringLiteral("--headless"))) {
		QString error;
		if (!server.start(&error))
			return 2;
		return application.exec();
	}

	QQuickStyle::setStyle(QStringLiteral("Basic"));
	QQmlApplicationEngine engine;
	engine.rootContext()->setContextProperty(
		QStringLiteral("serverController"), &server);
	QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
		&application, []() { QCoreApplication::exit(-1); }, Qt::QueuedConnection);
	engine.load(QUrl(QStringLiteral("qrc:/ui/ServerDashboard.qml")));
	if (engine.rootObjects().isEmpty())
		return -1;

	const int smokeIndex =
		application.arguments().indexOf(QStringLiteral("--server-ui-smoke-test"));
	if (smokeIndex >= 0) {
		const QString screenshotPath =
			smokeIndex + 1 < application.arguments().size()
			&& !application.arguments().at(smokeIndex + 1).startsWith("--")
			? QFileInfo(application.arguments().at(smokeIndex + 1)).absoluteFilePath()
			: QCoreApplication::applicationDirPath() + "/server-ui-smoke.png";
		QTimer::singleShot(1700,
			[&application, &engine, screenshotPath]() {
				QQuickWindow* window = qobject_cast<QQuickWindow*>(
					engine.rootObjects().constFirst());
				if (!window) {
					application.exit(30);
					return;
				}
				QDir().mkpath(QFileInfo(screenshotPath).absolutePath());
				const QImage image = window->grabWindow();
				application.exit(!image.isNull() && image.save(screenshotPath) ? 0 : 31);
			});
	}

	return application.exec();
}
