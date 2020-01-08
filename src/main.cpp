#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QIcon>

#ifndef STATIC_MAUIKIT
#include "nota_version.h"
#endif

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

//Models
#include "src/models/documentsmodel.h"
#include "src/models/editormodel.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
	QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

#ifdef Q_OS_ANDROID
	QGuiApplication app(argc, argv);
    if (!MAUIAndroid::checkRunTimePermissions())
            return -1;
#else
	QApplication app(argc, argv);
#endif

	app.setApplicationName("nota");
    app.setApplicationVersion(NOTA_VERSION_STRING);
    app.setApplicationDisplayName("Nota");
    app.setOrganizationName("Maui");
    app.setOrganizationDomain("org.maui.nota");

	app.setWindowIcon(QIcon(":/nota.svg"));

#ifdef STATIC_KIRIGAMI
	KirigamiPlugin::getInstance().registerTypes();
#endif

#ifdef STATIC_MAUIKIT
	MauiKit::getInstance().registerTypes();
#endif

    qmlRegisterType<DocumentsModel> ("org.maui.nota", 1, 0, "Documents");
    qmlRegisterType<EditorModel> ("org.maui.nota", 1, 0, "Editor");
    qmlRegisterType<HistoryModel> ();

	QQmlApplicationEngine engine;
	engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
	if (engine.rootObjects().isEmpty())
		return -1;

	return app.exec();
}
