#include <QCommandLineParser>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDate>

#include <KI18n/KLocalizedString>

#ifdef Q_OS_ANDROID
#include <QGuiApplication>
#include <MauiKit/Core/mauiandroid.h>
#else
#include <QApplication>
#endif

#include <MauiKit/Core/mauiapp.h>

#include "nota.h"
#include "../nota_version.h"

// Models
#include "models/historymodel.h"

#define NOTA_URI "org.maui.nota"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setAttribute(Qt::AA_UseHighDpiPixmaps, true);

#ifdef Q_OS_ANDROID
    QGuiApplication app(argc, argv);
    if (!MAUIAndroid::checkRunTimePermissions({"android.permission.WRITE_EXTERNAL_STORAGE"}))
        return -1;
#else
    QApplication app(argc, argv);
#endif

    app.setOrganizationName(QStringLiteral("Maui"));
    app.setWindowIcon(QIcon(":/img/nota.svg"));

    MauiApp::instance()->setIconName("qrc:/img/nota.svg");

    KLocalizedString::setApplicationDomain("nota");

    KAboutData about(QStringLiteral("nota"), i18n("Nota"), NOTA_VERSION_STRING, i18n("Browse, create and edit text files."), KAboutLicense::LGPL_V3,i18n("© 2019-%1 Maui Development Team", QString::number(QDate::currentDate().year())), QString(GIT_BRANCH) + "/" + QString(GIT_COMMIT_HASH));

    about.addAuthor(i18n("Camilo Higuita"), i18n("Developer"), QStringLiteral("milo.h@aol.com"));
    about.addAuthor(i18n("Anupam Basak"), i18n("Developer"), QStringLiteral("anupam.basak27@gmail.com"));
    about.setHomepage("https://mauikit.org");
    about.setProductName("maui/nota");
    about.setBugAddress("https://invent.kde.org/maui/nota/-/issues");
    about.setOrganizationDomain(NOTA_URI);
    about.setProgramLogo(app.windowIcon());

    KAboutData::setApplicationData(about);

    QCommandLineParser parser;

    about.setupCommandLine(&parser);
    parser.process(app);

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
    qmlRegisterSingletonType<HistoryModel>(NOTA_URI, 1, 0, "History", [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
        Q_UNUSED(scriptEngine)
        Q_UNUSED(engine)
           return new HistoryModel;
       });
    engine.load(url);

    return app.exec();
}
