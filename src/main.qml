import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab
import org.maui.nota 1.0 as Nota
import QtQuick.Window 2.0
import QtQml.Models 2.3

import "views"
import "views/widgets" as Widgets

Maui.ApplicationWindow
{
    id: root
    title: currentTab ? currentTab.title : ""

    Maui.App.iconName: "qrc:/img/nota.svg"
    Maui.App.description: qsTr("Nota allows you to edit text files.")
    Maui.App.handleAccounts: false
    background.opacity: translucency ? 0.5 : 1

    readonly property var views : ({editor: 0, documents: 1, recent: 2})

    property alias currentTab : _editorListView.currentItem
    property alias dialog : _dialogLoader.item

    property bool selectionMode :  false
    property bool translucency : Maui.Handy.isLinux

    property bool terminalVisible : Maui.FM.loadSettings("TERMINAL", "EXTENSIONS", false)
    //Global editor props
    property bool focusMode : false
    property bool enableSidebar : Maui.FM.loadSettings("ENABLE_SIDEBAR", "EXTENSIONS", !focusMode) == "true"

    property bool showLineNumbers : Maui.FM.loadSettings("SHOW_LINE_NUMBERS", "EDITOR", true) == "true"
    property bool enableSyntaxHighlighting : Maui.FM.loadSettings("ENABLE_SYNTAX_HIGHLIGHTING", "EDITOR", true) == "true"
    property bool showSyntaxHighlightingLanguages: false

    property string theme : Maui.FM.loadSettings("THEME", "EDITOR", "Default")
    property color backgroundColor : Maui.FM.loadSettings("BACKGROUND_COLOR", "EDITOR", root.Kirigami.Theme.backgroundColor)
    property color textColor : Maui.FM.loadSettings("TEXT_COLOR", "EDITOR", root.Kirigami.Theme.textColor)

    property font font : Maui.FM.loadSettings("FONT", "EDITOR", defaultFont)

    readonly property font defaultFont:
    {
        family: "Noto Sans Mono"
        pointSize: Maui.Style.fontSizes.default
    }

    onCurrentTabChanged: syncSidebar(currentTab.fileUrl)

    MauiLab.Doodle
    {
        id: _doodleDialog
        sourceItem: root.currentTab ? root.currentTab.body : null
    }

    mainMenu: [

        MenuItem
        {
            text: qsTr("Settings")
            icon.name: "settings-configure"
            onTriggered:
            {
                _dialogLoader.sourceComponent = _settingsDialogComponent
                dialog.open()
            }
        }
        ]

    ObjectModel
    {
        id: _documentModel
    }

    onClosing:
    {
        _dialogLoader.sourceComponent = _unsavedDialogComponent

        if(!dialog.discard)
        {
            for(var i = 0; i<_editorListView.count; i++)
            {
                const doc =  _documentModel.get(i)
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
            title: qsTr("Un saved files")
            message: qsTr("You have un saved files. You can go back and save them or choose to dicard all changes and exit.")
            page.padding: Maui.Style.space.big
            acceptButton.text: qsTr("Go back")
            rejectButton.text: qsTr("Discard")
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

    headBar.visible: root.currentTab && _swipeView.currentIndex === views.editor && Kirigami.Settings.isMobile ? root.currentTab.height > Kirigami.Units.gridUnit*30 : !focusMode

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
            onClicked: openFile()

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
            if(currentTab)
                syncSidebar(currentTab.fileUrl)
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
                            root.openTab(item.path)
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
                            root.openTab(item.path)
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

    Maui.Page
    {
        anchors.fill: parent
        spacing: 0

        flickable: _swipeView.currentItem.item ? _swipeView.currentItem.item.flickable : null

        MauiLab.AppViews
        {
            id: _swipeView
            anchors.fill: parent

            Maui.Page
            {
                id: editorView
                MauiLab.AppView.iconName: "document-edit"
                MauiLab.AppView.title: qsTr("Editor")

                header: Maui.TabBar
                {
                    id: _tabBar
                    visible: _editorListView.count > 1
                    width: parent.width
                    position: TabBar.Header
                    currentIndex : _editorListView.currentIndex
                    onNewTabClicked: root.openTab("")

                    Repeater
                    {
                        id: _repeater
                        model: _editorModel

                        Maui.TabButton
                        {
                            id: _tabButton
                            readonly property int index_ : index
                            implicitHeight: _tabBar.implicitHeight
                            implicitWidth: Math.max(parent.width / _repeater.count, 120)
                            checked: index === _tabBar.currentIndex

                            text: model.label

                            onClicked: _editorListView.currentIndex = index
                            onCloseClicked:
                            {
                                if( _documentModel.get(model.index).document.modified)
                                {
                                    _saveDialog.fileIndex = model.index
                                    _saveDialog.open()
                                }
                                else
                                    closeTab(model.index)
                            }

                            Maui.Dialog
                            {
                                id: _saveDialog
                                property int fileIndex
                                page.padding: Maui.Style.space.huge
                                title: qsTr("Save file")
                                message: qsTr(String("This file has been modified, you can save your changes now or discard them.\n")) + _editorModel.get(_tabButton.index).path

                                acceptButton.text: qsTr("Save")
                                rejectButton.text: qsTr("Discard")

                                onAccepted:
                                {
                                    _documentModel.get(fileIndex).saveFile(_editorModel.get(fileIndex).path, fileIndex)
                                    closeTab(fileIndex)
                                    _saveDialog.close()
                                }

                                onRejected:
                                {
                                    _saveDialog.close()
                                    closeTab(fileIndex)
                                }
                            }
                        }
                    }
                }

                Maui.Holder
                {
                    id: _holder
                    visible: !_editorListView.count
                    emoji: "qrc:/img/document-edit.svg"
                    emojiSize: Maui.Style.iconSizes.huge
                    isMask: true
                    onActionTriggered: openTab("")
                    title: qsTr("Create a new document")
                    body: qsTr("You can create a new document by clicking the New File button, or here.<br>
                    Alternative you can open existing files from the left places sidebar or by clicking the Open button")
                }

                Maui.FloatingButton
                {
                    id: _overlayButton
                    z: 999
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: Maui.Style.toolBarHeightAlt
                    anchors.bottomMargin: Maui.Style.toolBarHeight + (root.currentTab ? root.currentTab.footBar.height : 0)
                    height: Maui.Style.toolBarHeight
                    width: height

                    icon.name: "document-new"
                    icon.color: Kirigami.Theme.highlightedTextColor

                    onClicked: openTab("")

                    Maui.Badge
                    {
                        anchors
                        {
                            horizontalCenter: parent.right
                            verticalCenter: parent.top
                        }

                        onClicked: _newDocumentMenu.open()

                        Maui.PlusSign
                        {
                            color: parent.Kirigami.Theme.textColor
                            height: 10
                            width: height
                            anchors.centerIn: parent
                        }
                    }

                    Maui.Dialog
                    {
                        id: _newDocumentMenu
                        maxHeight: 300
                        maxWidth: 400
                        defaultButtons: false
                        footBar.middleContent: Button
                        {
                            text: qsTr("New template")
                        }

                        ColumnLayout
                        {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.margins: Maui.Style.space.big
                            spacing: Maui.Style.space.big

                            Maui.ItemDelegate
                            {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                Maui.ListItemTemplate
                                {
                                    anchors.fill:parent
                                    iconSizeHint: Math.min(height, Maui.Style.iconSizes.big)
                                    iconSource: "text-x-generic"
                                    label1.text: qsTr("Text file")
                                    label2.text: qsTr("Simple text file with syntax highlighting")
                                }

                                onClicked:
                                {
                                    openTab("")
                                    _editorListView.currentItem.body.textFormat = TextEdit.PlainText
                                    _newDocumentMenu.close()
                                }
                            }


                            Maui.ItemDelegate
                            {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                Maui.ListItemTemplate
                                {
                                    anchors.fill:parent
                                    iconSizeHint: Math.min(height, Maui.Style.iconSizes.big)
                                    iconSource: "text-enriched"
                                    label1.text: qsTr("Rich text file")
                                    label2.text: qsTr("With support for basic text format editing")
                                }

                                onClicked:
                                {
                                    openTab("")
                                    _editorListView.currentItem.body.textFormat = TextEdit.RichText
                                    _newDocumentMenu.close()
                                }
                            }

                            Maui.ItemDelegate
                            {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                Maui.ListItemTemplate
                                {
                                    anchors.fill:parent
                                    iconSizeHint: Math.min(height, Maui.Style.iconSizes.big)
                                    iconSource: "text-html"
                                    label1.text: qsTr("HTML text file")
                                    label2.text: qsTr("Text file with HTML markup support")
                                }
                            }
                        }
                    }
                }

                ListView
                {
                    id: _editorListView
                    anchors.fill: parent
                    orientation: ListView.Horizontal
                    model: _documentModel
                    snapMode: ListView.SnapOneItem
                    spacing: 0
                    interactive: Maui.Handy.isTouch && count > 1
                    highlightFollowsCurrentItem: true
                    highlightMoveDuration: 0
                    highlightResizeDuration : 0
                    onMovementEnded: currentIndex = indexAt(contentX, contentY)
                    cacheBuffer: count
                    clip: true
                }
            }

            MauiLab.AppViewLoader
            {
                MauiLab.AppView.iconName: "view-pim-journal"
                MauiLab.AppView.title: qsTr("Documents")
                visible: !focusMode

                DocumentsView
                {
                    id: _documentsView
                }
            }

            MauiLab.AppViewLoader
            {
                MauiLab.AppView.iconName: "view-media-recent"
                MauiLab.AppView.title: qsTr("Recent")
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
                text: qsTr("Open")
                icon.name: "document-open"
                onTriggered:
                {
                    const paths =  _selectionbar.uris
                    for(var i in paths)
                        openTab(paths[i])

                    _selectionbar.clear()
                }
            }

            Action
            {
                text: qsTr("Share")
                icon.name: "document-share"
            }

            Action
            {
                text: qsTr("Export")
                icon.name: "document-export"
            }
        }
    }

    DropArea
    {
        id: _dropArea
        anchors.fill: parent
        onDropped:
        {
            if(drop.urls)
            {
                var urls = drop.urls.join(",")
                Nota.Nota.requestFiles(urls.split(","))
            }
        }
    }

    Connections
    {
        target: Nota.Nota
        onOpenFiles:
        {
            for(var i in urls)
                openTab(urls[i])
        }
    }

    function openTab(path)
    {
        _swipeView.currentIndex = views.editor

        const index = _editorList.urlIndex(path)
        if(index >= 0)
            _editorListView.currentIndex = index;

        if(!_editorList.append(path))
            return ;

        var component = Qt.createComponent("Editor.qml");
        if (component.status === Component.Ready)
        {
            _documentModel.append(component.createObject(_documentModel));

            _editorListView.currentIndex = _documentModel.count - 1
            _documentModel.get(_documentModel.count - 1).fileUrl = path
            syncSidebar(path)
        }
    }

    function closeTab(index)
    {
        console.log("CLOSING FILE", index, _editorList.count, _documentModel.count)
        _editorList.remove(index)
        _documentModel.remove(index)
        console.log("CLOSING FILE", index, _editorList.count, _documentModel.count)
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

    function openFile()
    {
        _dialogLoader.sourceComponent = _fileDialogComponent
        dialog.mode = dialog.modes.OPEN
        dialog.settings.onlyDirs = false
        dialog.show(function (paths)
        {
            for(var i in paths)
            {
                openTab(paths[i])
            }
        });
    }
}
