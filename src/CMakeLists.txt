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

qt_add_resources(nota_ASSETS
    assets/img_assets.qrc)

if(UNIX AND NOT ANDROID)
    qt_generate_dbus_interface(${CMAKE_CURRENT_SOURCE_DIR}/controllers/server.h org.kde.Nota.xml)
    qt_add_dbus_adaptor(nota_dbus_SRCS ${CMAKE_CURRENT_BINARY_DIR}/org.kde.Nota.xml controllers/server.h Server)
    qt_add_dbus_interface(nota_dbus_SRCS ${CMAKE_CURRENT_BINARY_DIR}/org.kde.Nota.xml notainterface)
endif()

if(ANDROID)
    qt_add_executable(${PROJECT_NAME}
        MANUAL_FINALIZATION
        ${nota_SRCS}
        ${nota_HDRS}
        ${nota_ASSETS})

    set_property(TARGET ${PROJECT_NAME} APPEND PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/android_files)
    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/android_files/version.gradle.in ${CMAKE_BINARY_DIR}/src/version.gradle)

else()
    qt_add_executable(${PROJECT_NAME}
        ${nota_SRCS}
        ${nota_dbus_SRCS}
        ${nota_HDRS}
        ${nota_ASSETS})
endif()

qt_add_qml_module(${PROJECT_NAME} URI app.maui.nota
    NO_PLUGIN
    QML_FILES
    main.qml
    views/RecentView.qml
    views/widgets/DocsBrowser.qml
    views/widgets/SettingsDialog.qml
    views/Terminal.qml
    views/widgets/TerminalColorSchemes.qml
    views/PlacesSidebar.qml
    views/editor/EditorView.qml
    views/editor/Editor.qml
    views/editor/EditorLayout.qml
    views/widgets/ItemMenu.qml
    views/widgets/PluginsDialog.qml
    views/widgets/ShortcutsDialog.qml

    plugins/ActionBar.qml
    plugins/Dicto.qml
    plugins/QMLLive.qml
    plugins/ToDos.qml)

if (ANDROID)
    target_link_libraries(${PROJECT_NAME}
        PRIVATE
        Qt6::QuickControls2
        Qt6::Sql
        Qt6::Multimedia)
elseif(UNIX)
    target_link_libraries(${PROJECT_NAME} PRIVATE Qt6::Widgets Qt6::DBus)
endif()

target_compile_definitions(${PROJECT_NAME}
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

target_link_libraries(${PROJECT_NAME}
    PRIVATE
    MauiKit4
    MauiKit4::FileBrowsing
    MauiKit4::TextEditor
    Qt6::Core
    Qt6::Quick
    Qt6::Qml
    KF6::CoreAddons
    KF6::I18n)

if(UNIX AND NOT APPLE AND NOT ANDROID)
    install(TARGETS ${PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
    install(FILES assets/nota.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
endif()

qt_finalize_target(${PROJECT_NAME})
