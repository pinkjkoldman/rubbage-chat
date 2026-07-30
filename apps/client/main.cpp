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

#include "application/ChatController.h"

int main(int argc, char* argv[])
{
	QGuiApplication application(argc, argv);
	QCoreApplication::setOrganizationName("RubbageChat");
	QCoreApplication::setApplicationName("RubbageChat");
	QCoreApplication::setApplicationVersion("2.3");

	QQuickStyle::setStyle("Basic");
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

	ChatController controller;
	const bool uiSmokeTest =
		application.arguments().contains("--qml-ui-smoke-test");
	const int sceneIndex = application.arguments().indexOf("--qml-smoke-scene");
	const QString scene = sceneIndex >= 0
		&& sceneIndex + 1 < application.arguments().size()
		? application.arguments().at(sceneIndex + 1) : "login";
	if (uiSmokeTest && scene != "login")
		controller.login("100000001", "rubbagechat");

	QQmlApplicationEngine engine;
	engine.rootContext()->setContextProperty("appController", &controller);
	QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
		&application, []() { QCoreApplication::exit(-1); }, Qt::QueuedConnection);
	engine.load(QUrl(QStringLiteral("qrc:/ui/Main.qml")));
	if (engine.rootObjects().isEmpty())
		return -1;

	if (uiSmokeTest) {
		if (scene != "login") {
			QTimer::singleShot(1100, &controller, [&controller]() {
				controller.clearToast();
			});
		}
		if (scene == "chat" || scene == "contacts") {
			QTimer::singleShot(700, &controller, [&controller]() {
				controller.selectPeer("100000002");
			});
		}
		if (scene == "contacts" || scene == "requests"
			|| scene.startsWith("settings")) {
			const int targetSection = scene == "contacts" ? 1
				: scene == "requests" ? 2 : 3;
			QTimer::singleShot(700, &engine, [&engine, targetSection]() {
				if (!engine.rootObjects().isEmpty())
					engine.rootObjects().constFirst()->setProperty(
						"section", targetSection);
			});
		}
		if (scene == "settings-network" || scene == "settings-account") {
			const int targetSettingsCategory =
				scene == "settings-network" ? 4 : 5;
			QTimer::singleShot(1200, &engine,
				[&engine, targetSettingsCategory]() {
				if (!engine.rootObjects().isEmpty())
					QMetaObject::invokeMethod(
						engine.rootObjects().constFirst(),
						"settingsSectionRequested",
						Q_ARG(int, targetSettingsCategory));
			});
		}
		const int pathIndex =
			application.arguments().indexOf("--qml-ui-smoke-test");
		const QString screenshotPath = pathIndex + 1 < application.arguments().size()
			&& !application.arguments().at(pathIndex + 1).startsWith("--")
			? QFileInfo(application.arguments().at(pathIndex + 1)).absoluteFilePath()
			: QCoreApplication::applicationDirPath() + "/qml-ui-smoke.png";
		QTimer::singleShot(scene == "login" || scene == "main" ? 1200 : 1800,
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
