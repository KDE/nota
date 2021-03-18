#include <QCommandLineParser>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include <KI18n/KLocalizedString>

#include "../nota_version.h"

#ifdef Q_OS_ANDROID
#include <QGuiApplication>
#else
#include <QApplication>
#endif

#include <MauiKit/mauiapp.h>

#include "nota.h"

// Models
#include "models/historymodel.h"

#define NOTA_URI "org.maui.nota"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setAttribute(Qt::AA_DontCreateNativeWidgetSiblings);
    QCoreApplication::setAttribute(Qt::AA_UseHighDpiPixmaps, true);
    QCoreApplication::setAttribute(Qt::AA_DisableSessionManager, true);

#ifdef Q_OS_ANDROID
    QGuiApplication app(argc, argv);
    if (!MAUIAndroid::checkRunTimePermissions({"android.permission.WRITE_EXTERNAL_STORAGE"}))
        return -1;
#else
    QApplication app(argc, argv);
#endif

    app.setOrganizationName(QStringLiteral("Maui"));
    app.setWindowIcon(QIcon(":/nota.svg"));

    MauiApp::instance()->setHandleAccounts(false); // for now nota can not handle cloud accounts
    MauiApp::instance()->setIconName("qrc:/img/nota.svg");

    KLocalizedString::setApplicationDomain("nota");

    KAboutData about(QStringLiteral("nota"), i18n("Nota"), NOTA_VERSION_STRING, i18n("Nota allows you to browse, create, and edit simple and rich text files."), KAboutLicense::LGPL_V3,i18n("© 2019-%1 Nitrux Development Team", QString::number(QDate::currentDate().year())), QString(GIT_BRANCH) + "/" + QString(GIT_COMMIT_HASH));

    about.addAuthor(i18n("Camilo Higuita"), i18n("Developer"), QStringLiteral("milo.h@aol.com"));
    about.addAuthor(i18n("Anupam Basak"), i18n("Developer"), QStringLiteral("anupam.basak27@gmail.com"));
    about.setHomepage("https://mauikit.org");
    about.setProductName("maui/nota");
    about.setBugAddress("https://invent.kde.org/maui/nota/-/issues");
    about.setOrganizationDomain("org.maui.nota");
    about.setProgramLogo(app.windowIcon());

    KAboutData::setApplicationData(about);

    QCommandLineParser parser;
    parser.process(app);

    about.setupCommandLine(&parser);
    about.processCommandLine(&parser);
    const QStringList args = parser.positionalArguments();

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(
                &engine,
                &QQmlApplicationEngine::objectCreated,
                &app,
                [url, args](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);

        if (!args.isEmpty())
            Nota::instance()->requestFiles(args);
    },
    Qt::QueuedConnection);

    qmlRegisterSingletonInstance<Nota>(NOTA_URI, 1, 0, "Nota", Nota::instance());
    qmlRegisterType<HistoryModel>(NOTA_URI, 1, 0, "History");

    engine.load(url);

    return app.exec();
}
