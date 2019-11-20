project(nota)
cmake_minimum_required(VERSION 3.0)

find_package(ECM 1.7.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake" ${ECM_MODULE_PATH})

find_package(MauiKit REQUIRED)
find_package(Qt5 REQUIRED NO_MODULE COMPONENTS Qml Quick Sql Svg QuickControls2 Widgets Xml)
find_package(KF5 ${KF5_VERSION} REQUIRED COMPONENTS I18n Notifications Config KIO Attica SyntaxHighlighting)
include(KDEInstallDirs)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(KDECMakeSettings)
include(ECMInstallIcons)
include(FeatureSummary)
include(ECMAddAppIcon)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTORCC ON)

set(nota_SRCS
    src/main.cpp
    )

set(nota_HDRS

    )

set(nota_ASSETS
    src/qml.qrc
    assets/img_assets.qrc
    )

add_executable(nota
    ${nota_SRCS}
    ${nota_HDRS}
    ${nota_ASSETS}
    )

if (ANDROID)
    find_package(Qt5 REQUIRED COMPONENTS AndroidExtras WebView)

    target_link_libraries(nota MauiKit Qt5::AndroidExtras)
else()
    find_package(Qt5 REQUIRED COMPONENTS WebEngine)

#    target_link_libraries(nota KF5::ConfigCore KF5::Notifications KF5::KIOCore KF5::I18n KF5::Attica)
endif()

target_link_libraries(nota Qt5::Sql Qt5::Qml Qt5::Widgets Qt5::Svg)

install(TARGETS nota ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
install(FILES org.kde.nota.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})

#TODO: port to ecm_install_icons()
# install(FILES assets/pix.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
# install(FILES org.kde.pix.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})

feature_summary(WHAT ALL   FATAL_ON_MISSING_REQUIRED_PACKAGES)
