#include <QCoreApplication>
#include <QDir>
#include <QFileInfo>
#include <QFontDatabase>
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
	QCoreApplication::setApplicationVersion("2.1");

	QQuickStyle::setStyle("Basic");
	const int fontId = QFontDatabase::addApplicationFont(
		":/assets/PICOSC Harmony Manrope-VF.ttf");
	if (fontId >= 0) {
		const QStringList families = QFontDatabase::applicationFontFamilies(fontId);
		if (!families.isEmpty()) {
			QFont font(families.first());
			font.setHintingPreference(QFont::PreferNoHinting);
			application.setFont(font);
		}
	}

	ChatController controller;
	const bool uiSmokeTest =
		application.arguments().contains("--qml-ui-smoke-test");
	const int sceneIndex = application.arguments().indexOf("--qml-smoke-scene");
	const QString scene = sceneIndex >= 0
		&& sceneIndex + 1 < application.arguments().size()
		? application.arguments().at(sceneIndex + 1) : "login";
	if (uiSmokeTest && scene == "main")
		controller.login("100000001", "rubbagechat");

	QQmlApplicationEngine engine;
	engine.rootContext()->setContextProperty("appController", &controller);
	QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
		&application, []() { QCoreApplication::exit(-1); }, Qt::QueuedConnection);
	engine.load(QUrl(QStringLiteral("qrc:/ui/Main.qml")));
	if (engine.rootObjects().isEmpty())
		return -1;

	if (uiSmokeTest) {
		const int pathIndex =
			application.arguments().indexOf("--qml-ui-smoke-test");
		const QString screenshotPath = pathIndex + 1 < application.arguments().size()
			&& !application.arguments().at(pathIndex + 1).startsWith("--")
			? QFileInfo(application.arguments().at(pathIndex + 1)).absoluteFilePath()
			: QCoreApplication::applicationDirPath() + "/qml-ui-smoke.png";
		QTimer::singleShot(1200, &application,
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
