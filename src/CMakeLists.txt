# Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
# Copyright 2018-2020 Nitrux Latinoamericana S.C.
#
# SPDX-License-Identifier: GPL-3.0-or-later

remove_definitions(-DQT_NO_CAST_FROM_ASCII -DQT_STRICT_ITERATORS -DQT_NO_CAST_FROM_BYTEARRAY -DQT_NO_URL_CAST_FROM_STRING)

set(nota_SRCS
    main.cpp
    models/historymodel.cpp
    controllers/server.cpp)

set(nota_HDRS
    models/historymodel.h
    nota.h)

set(nota_ASSETS   
    assets/img_assets.qrc)


 qt_add_resources(nota_QML_QRC qml.qrc plugins/plugins.qrc)

if(UNIX AND NOT ANDROID)
    qt_generate_dbus_interface(${CMAKE_CURRENT_SOURCE_DIR}/controllers/server.h org.kde.Nota.xml)
    qt_add_dbus_adaptor(nota_dbus_SRCS ${CMAKE_CURRENT_BINARY_DIR}/org.kde.Nota.xml controllers/server.h Server)
    qt_add_dbus_interface(nota_dbus_SRCS ${CMAKE_CURRENT_BINARY_DIR}/org.kde.Nota.xml notainterface)
endif()

if(ANDROID)
    add_library(${PROJECT_NAME} SHARED
        ${nota_SRCS}
        ${nota_HDRS}
        ${nota_ASSETS}
        ${nota_QML_QRC})
else()
    add_executable(${PROJECT_NAME}
        ${nota_SRCS}
        ${nota_dbus_SRCS}
        ${nota_HDRS}
        ${nota_ASSETS}
        ${nota_QML_QRC})
endif()

if (ANDROID)
    target_link_libraries(${PROJECT_NAME} Qt6::AndroidExtras Qt6::QuickControls2)
elseif(UNIX)
    target_link_libraries(${PROJECT_NAME} Qt6::Widgets Qt6::DBus)
endif()

target_compile_definitions(${PROJECT_NAME}
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

target_link_libraries(${PROJECT_NAME}
    MauiKit4
    MauiKit4::FileBrowsing
    MauiKit4::TextEditor
    Qt6::Quick
    Qt6::Qml
    KF6::CoreAddons
    KF6::I18n)

if(UNIX AND NOT APPLE AND NOT ANDROID)
    install(TARGETS ${PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
    install(FILES assets/nota.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
endif()
