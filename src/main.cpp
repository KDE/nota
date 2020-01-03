#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QIcon>

#include "nota_version.h"

#ifdef Q_OS_ANDROID
#include <QGuiApplication>
#else
#include <QApplication>
#endif

#ifdef STATIC_KIRIGAMI
#include "3rdparty/kirigami/src/kirigamiplugin.h"
#endif

#ifdef STATIC_MAUIKIT
#include "3rdparty/mauikit/src/mauikit.h"
#endif

#include "src/models/documentsmodel.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
	QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

#ifdef Q_OS_ANDROID
	QGuiApplication app(argc, argv);
#else
	QApplication app(argc, argv);
#endif

    app.setApplicationName("nota");
    app.setApplicationVersion(NOTA_VERSION_STRING);
    app.setApplicationDisplayName("Nota");

	app.setWindowIcon(QIcon(":/nota.svg"));

#ifdef STATIC_KIRIGAMI
	KirigamiPlugin::getInstance().registerTypes();
#endif

#ifdef STATIC_MAUIKIT
	MauiKit::getInstance().registerTypes();
#endif

	qmlRegisterType<DocumentsModel> ("org.maui.nota", 1, 0, "Documents");

	QQmlApplicationEngine engine;
	engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
	if (engine.rootObjects().isEmpty())
		return -1;

	return app.exec();
}
