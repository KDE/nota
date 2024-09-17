#include <QCommandLineParser>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include <KLocalizedString>

#ifdef Q_OS_ANDROID
#include <QGuiApplication>
#include <MauiKit4/Core/mauiandroid.h>
#else
#include <QApplication>
#endif

#include <MauiKit4/Core/mauiapp.h>
#include <MauiKit4/TextEditor/moduleinfo.h>

#include "nota.h"
#include "../nota_version.h"

// Models
#include "models/historymodel.h"

#include "controllers/server.h"

#define NOTA_URI "org.maui.nota"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
#ifdef Q_OS_ANDROID
    QGuiApplication app(argc, argv);
#else
    QApplication app(argc, argv);
#endif

    app.setOrganizationName(QStringLiteral("Maui"));
    app.setWindowIcon(QIcon(":/img/nota.svg"));

    KLocalizedString::setApplicationDomain("nota");

    KAboutData about(QStringLiteral("nota"),
                     QStringLiteral("Nota"),
                     NOTA_VERSION_STRING,
                     i18n("Browse, create and edit text files."),
                     KAboutLicense::LGPL_V3,
                     APP_COPYRIGHT_NOTICE,
                     QString(GIT_BRANCH) + "/" + QString(GIT_COMMIT_HASH));

    about.addAuthor(QStringLiteral("Camilo Higuita"), i18n("Developer"), QStringLiteral("milo.h@aol.com"));
    about.addAuthor(QStringLiteral("Anupam Basak"), i18n("Developer"), QStringLiteral("anupam.basak27@gmail.com"));
    about.setHomepage("https://mauikit.org");
    about.setProductName("maui/nota");
    about.setBugAddress("https://invent.kde.org/maui/nota/-/issues");
    about.setOrganizationDomain(NOTA_URI);
    about.setProgramLogo(app.windowIcon());

    const auto FBData = MauiKitTextEditor::aboutData();
    about.addComponent(FBData.name(), MauiKitTextEditor::buildVersion(), FBData.version(), FBData.webAddress());

    KAboutData::setApplicationData(about);
    MauiApp::instance()->setIconName("qrc:/img/nota.svg");

    QCommandLineParser parser;

    about.setupCommandLine(&parser);
    parser.process(app);

    about.processCommandLine(&parser);
    const QStringList args = parser.positionalArguments();
    QStringList paths;

    if (!args.isEmpty())
    {
        for(const auto &path : args)
            paths << QUrl::fromUserInput(path).toString();
    }

#ifdef Q_OS_ANDROID
    if (!MAUIAndroid::checkRunTimePermissions({"android.permission.MANAGE_EXTERNAL_STORAGE",
                                               "android.permission.WRITE_EXTERNAL_STORAGE"}))
        qWarning() << "Failed to get WRITE and READ permissions";

#endif

#if (defined Q_OS_LINUX || defined Q_OS_FREEBSD) && !defined Q_OS_ANDROID
    if (AppInstance::attachToExistingInstance(QUrl::fromStringList(paths), false))
    {
        // Successfully attached to existing instance of Nota
        return 0;
    }else
    {
        //        const QString serviceName = QStringLiteral("org.kde.index-%1").arg(QCoreApplication::applicationPid());
        //        auto instances = IndexInstance::appInstances(serviceName);
        //        if(instances.size() > 0)
        //        {
        //            instances.first().first->activateWindow();
        //        }
    }

    AppInstance::registerService();
#endif

    auto server = std::make_unique<Server>();

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/app/maui/nota/main.qml"));
    QObject::connect(
                &engine,
                &QQmlApplicationEngine::objectCreated,
                &app,
                [url, args, &server](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);

        server->setQmlObject(obj);
        server->openFiles(args, false);

    },
    Qt::QueuedConnection);

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));

    qmlRegisterSingletonInstance<Server>(NOTA_URI, 1, 0, "Server", server.get());
    qmlRegisterSingletonInstance<Nota>(NOTA_URI, 1, 0, "Nota", Nota::instance());
    qmlRegisterType<HistoryModel>(NOTA_URI, 1, 0, "History");

    engine.load(url);

    return app.exec();
}
