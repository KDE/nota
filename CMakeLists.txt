# Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
# Copyright 2018-2020 Nitrux Latinoamericana S.C.
#
# SPDX-License-Identifier: GPL-3.0-or-later

cmake_minimum_required(VERSION 3.14)

set(NOTA_VERSION 1.2.2)
project(nota VERSION ${NOTA_VERSION})

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(REQUIRED_QT_VERSION 5.14.0)
set(REQUIRED_KF5_VERSION 5.60)

find_package(ECM ${REQUIRED_KF5_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake" ${ECM_MODULE_PATH})

option(EMBEDDED_TERMINAL "If set to true then tries to load the QmlTermWidget. v 0.1 is needed later version might not work" OFF)

find_package(Qt5 ${REQUIRED_QT_VERSION} REQUIRED NO_MODULE COMPONENTS Qml Quick Sql Svg QuickControls2 Concurrent)
find_package(KF5 ${REQUIRED_KF5_VERSION} REQUIRED COMPONENTS I18n CoreAddons SyntaxHighlighting)

if(ANDROID)
    find_package(Qt5 ${REQUIRED_QT_VERSION} REQUIRED NO_MODULE COMPONENTS AndroidExtras QuickControls2)
    message("CURRENT DIR" ${CMAKE_CURRENT_SOURCE_DIR})
    set(ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/android_files)
    set(ANDROID_ABIS "armeabi-v7a")
elseif(UNIX)
    find_package(KF5 ${REQUIRED_KF5_VERSION} REQUIRED COMPONENTS Config KIO)
endif()

find_package(MauiKit REQUIRED)

if(UNIX AND NOT APPLE AND NOT ANDROID)
    include(KDEInstallDirs)
    include(KDECMakeSettings)
    include(ECMInstallIcons)
    include(ECMAddAppIcon)
endif()

include(KDECompilerSettings NO_POLICY_SCOPE)
include(KDEClangFormat)
include(ECMSetupVersion)
include(ECMSourceVersionControl)
include(FeatureSummary)

if(${ECM_SOURCE_UNDER_VERSION_CONTROL})
execute_process(
  COMMAND git rev-parse --abbrev-ref HEAD
  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
  OUTPUT_VARIABLE GIT_BRANCH
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

# Get the latest abbreviated commit hash of the working branch
execute_process(
  COMMAND git log -1 --format=%h
  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
  OUTPUT_VARIABLE GIT_COMMIT_HASH
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

add_definitions(-DGIT_COMMIT_HASH="${GIT_COMMIT_HASH}")
add_definitions(-DGIT_BRANCH="${GIT_BRANCH}")

else()
    add_definitions(-DGIT_COMMIT_HASH="${NOTA_VERSION}")
    add_definitions(-DGIT_BRANCH="Stable")
endif()

set(nota_SRCS
    src/main.cpp
    src/models/documentsmodel.cpp
    src/models/historymodel.cpp
    )

set(nota_HDRS
    src/models/documentsmodel.h
    src/models/historymodel.h
    src/nota.h
    )

set(nota_ASSETS
    src/qml.qrc
    src/assets/img_assets.qrc
    )

if(ANDROID)
    add_library(${PROJECT_NAME} SHARED
        ${nota_SRCS}
        ${nota_HDRS}
        ${nota_ASSETS})
else()
    add_executable(${PROJECT_NAME}
        ${nota_SRCS}
        ${nota_HDRS}
        ${nota_ASSETS})
endif()

ecm_setup_version(${NOTA_VERSION}
    VARIABLE_PREFIX NOTA
    VERSION_HEADER "${CMAKE_CURRENT_BINARY_DIR}/nota_version.h"
    )

if(EMBEDDED_TERMINAL)
    target_compile_definitions(${PROJECT_NAME} PUBLIC EMBEDDED_TERMINAL)
endif()

if (ANDROID)
    target_link_libraries(${PROJECT_NAME} Qt5::AndroidExtras Qt5::QuickControls2)
elseif(UNIX)
    target_link_libraries(${PROJECT_NAME} KF5::ConfigCore KF5::KIOCore KF5::KIOFileWidgets KF5::KIONTLM KF5::KIOWidgets)
endif()

target_compile_definitions(${PROJECT_NAME}
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

target_link_libraries(${PROJECT_NAME} MauiKit Qt5::Sql Qt5::Quick Qt5::Qml Qt5::Svg KF5::CoreAddons KF5::I18n KF5::SyntaxHighlighting)

if(UNIX AND NOT APPLE AND NOT ANDROID)
    install(TARGETS ${PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
    install(FILES org.kde.nota.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})
    #install(FILES org.kde.nota.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})
    install(FILES src/assets/nota.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
endif()

feature_summary(WHAT ALL   FATAL_ON_MISSING_REQUIRED_PACKAGES)

file(GLOB_RECURSE ALL_CLANG_FORMAT_SOURCE_FILES *.cpp *.h)
kde_clang_format(${ALL_CLANG_FORMAT_SOURCE_FILES})
