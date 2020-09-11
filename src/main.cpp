#include <QQmlApplicationEngine>
#include <QCommandLineParser>
#include <QQmlContext>
#include <QIcon>

#include <KI18n/KLocalizedContext>

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
#include "mauiapp.h"
#else
#include <MauiKit/mauiapp.h>
#endif

#include "nota.h"

//Models
#include "src/models/documentsmodel.h"
#include "src/models/historymodel.h"


#define NOTA_URI "org.maui.nota"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

#ifdef Q_OS_ANDROID
    QGuiApplication app(argc, argv);
    if (!MAUIAndroid::checkRunTimePermissions({"android.permission.WRITE_EXTERNAL_STORAGE"}))
        return -1;
#else
    QApplication app(argc, argv);
#endif

    app.setApplicationName("nota");
    app.setApplicationVersion(NOTA_VERSION_STRING);
    app.setApplicationDisplayName("Nota");
    app.setOrganizationName("Maui");
    app.setOrganizationDomain(NOTA_URI);
    app.setWindowIcon(QIcon(":/nota.svg"));

    MauiApp::instance()->setHandleAccounts(false); //for now nota can not handle cloud accounts
    MauiApp::instance()->setCredits ({QVariantMap({{"name", "Camilo Higuita"}, {"email", "milo.h@aol.com"}, {"year", "2019-2020"}}),
                                     QVariantMap({{"name", "Anupam Basak"}, {"email", "anupam.basak27@gmail.com"}, {"year", "2019-2020"}})});

    MauiApp::instance()->setIconName("qrc:/img/nota.svg");
    MauiApp::instance()->setWebPage("https://mauikit.org");
    MauiApp::instance()->setReportPage("https://invent.kde.org/maui/nota/-/issues");

    MauiApp::instance()->setDescription("Nota allows you to browse, create, and edit simple and rich text files.");
    MauiApp::instance()->setHandleAccounts(false);

    QCommandLineParser parser;
    parser.setApplicationDescription(MauiApp::instance()->getDescription());
    const QCommandLineOption versionOption = parser.addVersionOption();
    parser.addOption(versionOption);
    parser.process(app);

    const QStringList args = parser.positionalArguments();

#ifdef STATIC_KIRIGAMI
    KirigamiPlugin::getInstance().registerTypes();
#endif

#ifdef STATIC_MAUIKIT
    MauiKit::getInstance().registerTypes();
#endif

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url, args](QObject *obj, const QUrl &objUrl)
    {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);

        if(!args.isEmpty())
            Nota::instance()->requestFiles(args);

    }, Qt::QueuedConnection);

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));

    qmlRegisterSingletonInstance<Nota>(NOTA_URI, 1, 0, "Nota", Nota::instance());
    qmlRegisterType<DocumentsModel> (NOTA_URI, 1, 0, "Documents");
    qmlRegisterType<HistoryModel> (NOTA_URI, 1, 0, "History");

    engine.load(url);

    return app.exec();
}
