import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab
import org.maui.nota 1.0 as Nota

import "views"
import "views/widgets" as Widgets

Maui.ApplicationWindow
{
    id: root
    title: currentEditor ? currentTab.title : ""

    Maui.App.description: i18n("Nota allows you to edit text files.")
    Maui.App.handleAccounts: false
    background.opacity: translucency ? 0.5 : 1

    readonly property var views : ({editor: 0, documents: 1, recent: 2})

    property alias currentTab : editorView.currentTab
    property alias currentEditor: editorView.currentEditor
    property alias dialog : _dialogLoader.item

    property bool selectionMode :  false
    property bool translucency : Maui.Handy.isLinux
    property bool terminalVisible : Maui.FM.loadSettings("TERMINAL", "EXTENSIONS", false)
    //Global editor props
    property bool focusMode : false
    property bool enableSidebar : Maui.FM.loadSettings("ENABLE_SIDEBAR", "EXTENSIONS", !focusMode) == "true"
    property bool defaultBlankFile : Maui.FM.loadSettings("DEFAULT_BLANK_FILE", "SETTINGS", false) == "true"

    property bool showLineNumbers : Maui.FM.loadSettings("SHOW_LINE_NUMBERS", "EDITOR", true) == "true"
    property bool enableSyntaxHighlighting : Maui.FM.loadSettings("ENABLE_SYNTAX_HIGHLIGHTING", "EDITOR", true) == "true"
    property bool showSyntaxHighlightingLanguages: false
    property bool supportSplit :!Kirigami.Settings.isMobile && root.width > 600

    property string theme : Maui.FM.loadSettings("THEME", "EDITOR", "Default")
    property color backgroundColor : Maui.FM.loadSettings("BACKGROUND_COLOR", "EDITOR", root.Kirigami.Theme.backgroundColor)
    property color textColor : Maui.FM.loadSettings("TEXT_COLOR", "EDITOR", root.Kirigami.Theme.textColor)

    property font font : Maui.FM.loadSettings("FONT", "EDITOR", defaultFont)

    readonly property font defaultFont:
    {
        family: "Noto Sans Mono"
        pointSize: Maui.Style.fontSizes.default
    }

    onCurrentEditorChanged: syncSidebar(currentEditor.fileUrl)

    MauiLab.Doodle
    {
        id: _doodleDialog
        sourceItem: root.currentEditor ? root.currentEditor.body : null
    }

    Maui.NewDialog
    {
        id: _pluginLoader
        title: i18n("Plugin")
        message: i18n("Load a plugin. The file must be a QML file, this file can access Nota properties and functionality to extend its features or add even more.")
        onFinished:     {
            const url = text
            if(Maui.FM.fileExists(url))
            {

                const component = Qt.createComponent(url);

                if (component.status === Component.Ready)
                {
                    console.log("setting plugin <<", url)
                    const object = component.createObject(editorView.plugin);

                }
            }
        }
    }

    mainMenu: [

        MenuItem
        {
            text: i18n("Settings")
            icon.name: "settings-configure"
            onTriggered:
            {
                _dialogLoader.sourceComponent = _settingsDialogComponent
                dialog.open()
            }
        },

        MenuItem
        {
            text: "Load plugin"
            icon.name: "plugin"
            onTriggered: _pluginLoader.open()
        }

    ]


    onClosing:
    {
        _dialogLoader.sourceComponent = _unsavedDialogComponent

        if(!dialog.discard)
        {
            for(var i = 0; i < editorView.count; i++)
            {
                const doc =  editorView.model.get(i)
                if(doc.document.modified)
                {
                    close.accepted = false
                    dialog.open()
                    return
                }
            }
        }

        close.accepted = true
    }

    Loader
    {
        id: _dialogLoader
    }

    Component
    {
        id: _unsavedDialogComponent

        Maui.Dialog
        {
            property bool discard : false
            title: i18n("Un saved files")
            message: i18n("You have un saved files. You can go back and save them or choose to dicard all changes and exit.")
            page.padding: Maui.Style.space.big
            acceptButton.text: i18n("Go back")
            rejectButton.text: i18n("Discard")
            onRejected:
            {
                discard = true
                root.close()
            }
            onAccepted: close()
        }
    }

    Component
    {
        id: _settingsDialogComponent
        Widgets.SettingsDialog
        {}
    }

    Component
    {
        id: _fileDialogComponent
        Maui.FileDialog
        {
            settings.onlyDirs: false
            settings.filterType: Maui.FMList.TEXT
            settings.sortBy: Maui.FMList.MODIFIED
            mode: modes.OPEN
        }
    }

    headBar.visible: root.currentEditor && _swipeView.currentIndex === views.editor && Kirigami.Settings.isMobile ?  ! Qt.inputMethod.visible : !focusMode

    headBar.leftContent: ToolButton
    {
        visible: root.enableSidebar
        icon.name: "view-split-left-right"
        checked: _drawer.visible
        onClicked: _drawer.visible ? _drawer.close() : _drawer.open()
    }

    headBar.rightContent: [

        ToolButton
        {
            icon.name: "document-open"
            onClicked: editorView.openFile()

        },
        ToolButton
        {
            visible: Maui.Handy.isTouch
            icon.name: "item-select"
            onClicked:
            {
                selectionMode = !selectionMode
                if(_swipeView.currentIndex === views.editor)
                {
                    _swipeView.currentIndex = views.documents
                }
            }

            checked: selectionMode
        }
    ]

    sideBar: Maui.AbstractSideBar
    {
        id : _drawer
        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.Window
        width: visible ? Math.min(Kirigami.Units.gridUnit * 14, root.width) : 0
        collapsed: !isWide
        collapsible: true
        dragMargin: Maui.Style.space.big
        overlay.visible: collapsed && position > 0 && visible
        visible: (_swipeView.currentIndex === views.editor) && enableSidebar
        enabled: root.enableSidebar

        onVisibleChanged:
        {
            if(currentEditor)
                syncSidebar(currentEditor.fileUrl)
        }

        Connections
        {
            target: _drawer.overlay
            onClicked: _drawer.close()
        }

        background: Rectangle
        {
            color: Kirigami.Theme.backgroundColor
            opacity: translucency ? 0.5 : 1
        }

        Maui.Page
        {
            anchors.fill: parent
            Kirigami.Theme.inherit: false
            Kirigami.Theme.colorSet: Kirigami.Theme.Window
            background: Rectangle
            {
                color: Kirigami.Theme.backgroundColor
                opacity: translucency ? 0.7 : 1
            }
            headBar.visible: true
            headBar.middleContent: ComboBox
            {
                Layout.fillWidth: true
                z : _drawer.z + 9999
                model: Maui.BaseModel
                {
                    list: Maui.PlacesList
                    {
                        groups: [
                            Maui.FMList.PLACES_PATH,
                            Maui.FMList.DRIVES_PATH,
                            Maui.FMList.TAGS_PATH]
                    }
                }

                textRole: "label"
                onActivated:
                {
                    currentIndex = index
                    browserView.openFolder(model.list.get(index).path)
                }
            }

            Maui.FileBrowser
            {
                id: browserView
                anchors.fill: parent
                currentPath: Maui.FM.homePath()
                settings.viewType : Maui.FMList.LIST_VIEW
                settings.filterType: Maui.FMList.TEXT
                headBar.rightLayout.visible: false
                headBar.rightLayout.width: 0
                selectionMode: root.selectionMode
                selectionBar: _selectionbar

                Kirigami.Theme.backgroundColor: "transparent"

                onItemClicked:
                {
                    var item = currentFMList.get(index)
                    if(Maui.Handy.singleClick)
                    {
                        if(item.isdir == "true")
                        {
                            openFolder(item.path)
                        }else
                        {
                            editorView.openTab(item.path)
                        }
                    }
                }

                onItemDoubleClicked:
                {
                    var item = currentFMList.get(index)
                    if(!Maui.Handy.singleClick)
                    {
                        if(item.isdir == "true")
                        {
                            openFolder(item.path)
                        }else
                        {
                            editorView.openTab(item.path)
                        }
                    }
                }
            }
        }
    }

    Maui.BaseModel
    {
        id: _editorModel
        list: Nota.Editor
        {
            id: _editorList
        }
    }

    DropArea
    {
        id: _dropArea
        property var urls : []
        anchors.fill: parent
        onDropped:
        {
            if(drop.urls)
            {
                var m_urls = drop.urls.join(",")
                _dropArea.urls = m_urls.split(",")
                Nota.Nota.requestFiles( _dropArea.urls )
            }
        }
    }

    Component.onCompleted:if(root.defaultBlankFile)
    {
        editorView.openTab("")
    }

    Maui.Page
    {
        anchors.fill: parent
        spacing: 0

        flickable: _swipeView.currentItem.item ? _swipeView.currentItem.item.flickable : null

        MauiLab.AppViews
        {
            id: _swipeView
            anchors.fill: parent
            currentIndex: !root.currentEditor ? views.recent : views.editor

            EditorView
            {
                id: editorView
                MauiLab.AppView.iconName: "document-edit"
                MauiLab.AppView.title: i18n("Editor")

            }

            MauiLab.AppViewLoader
            {
                MauiLab.AppView.iconName: "view-pim-journal"
                MauiLab.AppView.title: i18n("Documents")
                visible: !focusMode

                DocumentsView
                {
                    id: _documentsView
                }
            }

            MauiLab.AppViewLoader
            {
                MauiLab.AppView.iconName: "view-media-recent"
                MauiLab.AppView.title: i18n("Recent")
                visible: !focusMode

                RecentView
                {
                    id:_recentView
                }
            }
        }

        footer: MauiLab.SelectionBar
        {
            id: _selectionbar

            padding: Maui.Style.space.big
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(parent.width-(Maui.Style.space.medium*2), implicitWidth)
            maxListHeight: root.height - (Maui.Style.contentMargins*2)

            onItemClicked : console.log(index)

            onExitClicked: clear()

            Action
            {
                text: i18n("Open")
                icon.name: "document-open"
                onTriggered:
                {
                    const paths =  _selectionbar.uris
                    for(var i in paths)
                        editorView.openTab(paths[i])

                    _selectionbar.clear()
                }
            }

            Action
            {
                text: i18n("Share")
                icon.name: "document-share"
            }

            Action
            {
                text: i18n("Export")
                icon.name: "document-export"
            }
        }
    }


    Connections
    {
        target: Nota.Nota
        onOpenFiles:
        {
            for(var i in urls)
                editorView.openTab(urls[i])
        }
    }

    function syncSidebar(path)
    {
        if(path && Maui.FM.fileExists(path) && root.enableSidebar)
        {
            browserView.openFolder(Maui.FM.fileDir(path))
        }
    }

    function toggleTerminal()
    {
        terminalVisible = !terminalVisible
        Maui.FM.saveSettings("TERMINAL", terminalVisible, "EXTENSIONS")
    }

}
