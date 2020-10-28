QT *= qml \
     quick \
     sql \
     svg

CONFIG += ordered
CONFIG += c++17

TARGET = nota
TEMPLATE = app

VERSION_MAJOR = 1
VERSION_MINOR = 2
VERSION_BUILD = 0

VERSION = $${VERSION_MAJOR}.$${VERSION_MINOR}.$${VERSION_BUILD}

DEFINES += NOTA_VERSION_STRING=\\\"$$VERSION\\\"

linux:unix:!android {

    message(Building for Linux KDE)
    LIBS += -lMauiKit

} else {

    android {
        message(Building for Android)
        ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android_files
        DISTFILES += $$PWD/android_files/AndroidManifest.xml
        DEFINES *= ANDROID_OPENSSL

        ANDROID_ABIS = armeabi-v7a

        DISTFILES += \
            android_files/build.gradle \
            android_files/gradle/wrapper/gradle-wrapper.jar \
            android_files/gradle/wrapper/gradle-wrapper.properties \
            android_files/gradlew \
            android_files/gradlew.bat \
            android_files/res/values/libs.xml
    }

    DEFINES *= \
        COMPONENT_FM \
        COMPONENT_TAGGING \
        COMPONENT_EDITOR \
        MAUIKIT_STYLE

    include($$PWD/3rdparty/kirigami/kirigami.pri)
    include($$PWD/3rdparty/mauikit/mauikit.pri)

    DEFINES += STATIC_KIRIGAMI

    macos {
        DEFINES += EMBEDDED_TERMINAL
        ICON = $$PWD/macos_files/nota.icns
    }

    win32 {
        RC_ICONS = $$PWD/windows_files/nota.ico
    }
}

DEFINES += QT_DEPRECATED_WARNINGS

SOURCES += \
        $$PWD/src/main.cpp \
        $$PWD/src/models/documentsmodel.cpp \
        $$PWD/src/models/historymodel.cpp

HEADERS += \
        $$PWD/src/nota.h\
        $$PWD/src/models/documentsmodel.h \
        $$PWD/src/models/historymodel.h

RESOURCES += \
    $$PWD/src/qml.qrc \
    $$PWD/src/assets/img_assets.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

