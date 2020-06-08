cmake_minimum_required(VERSION 3.0)
set(NOTA_VERSION 1.1.1)
project(nota VERSION ${NOTA_VERSION})

find_package(ECM 1.7.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake" ${ECM_MODULE_PATH})

option(EMBEDDED_TERMINAL "If set to true then tries to load the QmlTermWidget. v 0.1 is needed later version might not work" OFF)

find_package(MauiKit REQUIRED)
find_package(Qt5 REQUIRED NO_MODULE COMPONENTS Qml Sql Svg)
find_package(KF5 ${KF5_VERSION} REQUIRED COMPONENTS I18n Notifications Config KIO Attica SyntaxHighlighting)
include(KDEInstallDirs)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(KDECMakeSettings)
include(ECMInstallIcons)
include(ECMAddAppIcon)
include(ECMSetupVersion)
include(FeatureSummary)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTORCC ON)

set(nota_SRCS
    src/main.cpp
    src/models/documentsmodel.cpp
    src/models/editormodel.cpp
    )

set(nota_HDRS
    src/models/documentsmodel.h
    src/models/editormodel.h
    src/nota.h
    )

set(nota_ASSETS
    src/qml.qrc
    src/assets/img_assets.qrc
    )

add_executable(nota
    ${nota_SRCS}
    ${nota_HDRS}
    ${nota_ASSETS}
    )

ecm_setup_version(${NOTA_VERSION}
    VARIABLE_PREFIX NOTA
    VERSION_HEADER "${CMAKE_CURRENT_BINARY_DIR}/nota_version.h"
    )

if (ANDROID)
    find_package(Qt5 REQUIRED COMPONENTS AndroidExtras WebView)

    target_link_libraries(nota MauiKit Qt5::AndroidExtras)
else()
    find_package(Qt5 REQUIRED COMPONENTS WebEngine)

endif()

if(EMBEDDED_TERMINAL)
    target_compile_definitions(nota PUBLIC EMBEDDED_TERMINAL)
endif()

target_link_libraries(nota MauiKit Qt5::Sql Qt5::Qml Qt5::Svg  KF5::ConfigCore KF5::Notifications KF5::KIOCore KF5::I18n KF5::Attica)

install(TARGETS nota ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
install(FILES org.kde.nota.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})
#install(FILES org.kde.nota.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})

#TODO: port to ecm_install_icons()
ecm_install_icons(ICONS src/assets/nota.svg
                  DESTINATION share/icons)

feature_summary(WHAT ALL   FATAL_ON_MISSING_REQUIRED_PACKAGES)
