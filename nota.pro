QT += qml
QT += quick
QT += sql
QT += widgets
QT += quickcontrols2

CONFIG += ordered
CONFIG += c++17
QMAKE_LINK += -nostdlib++

TARGET = nota
TEMPLATE = app

linux:unix:!android {

    message(Building for Linux KDE)
    QT += webengine
    LIBS += -lMauiKit

} else:android {

    message(Building for Android)
    include($$PWD/3rdparty/kirigami/kirigami.pri)
    include($$PWD/3rdparty/mauikit/mauikit.pri)

    DEFINES += STATIC_KIRIGAMI

} else {
    message("Unknown configuration")
}

DEFINES += QT_DEPRECATED_WARNINGS

SOURCES += \
        $$PWD/src/main.cpp

RESOURCES += \
    $$PWD/src/qml.qrc \
    $$PWD/assets/img_assets.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

DISTFILES += \
    3rdparty/mauikit/src/android/AndroidManifest.xml \
    3rdparty/mauikit/src/android/build.gradle \
    3rdparty/mauikit/src/android/gradle/wrapper/gradle-wrapper.jar \
    3rdparty/mauikit/src/android/gradle/wrapper/gradle-wrapper.properties \
    3rdparty/mauikit/src/android/gradlew \
    3rdparty/mauikit/src/android/gradlew.bat \
    3rdparty/mauikit/src/android/res/values/libs.xml

contains(ANDROID_TARGET_ARCH,armeabi-v7a) {
    ANDROID_PACKAGE_SOURCE_DIR = \
        $$PWD/3rdparty/mauikit/src/android
}
