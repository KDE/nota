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

Maui.ApplicationWindow
{
    id: root
    title: currentTab ? currentTab.title : ""

    Maui.App.iconName: "qrc:/img/nota.svg"
    Maui.App.description: qsTr("Nota allows you to edit text files.")
    Maui.App.handleAccounts: false
    //    Maui.App.enableCSD: true
    color: translucency ? "transparent" : Kirigami.Theme.backgroundColor

    readonly property var views : ({editor: 0, documents: 1, recent: 2})

    property alias currentTab : _editorListView.currentItem
    property alias terminal : terminalLoader.item
    property alias dialog : _dialogLoader.item

    property bool terminalVisible : Maui.FM.loadSettings("TERMINAL", "EXTENSIONS", false) == "true"
    property bool selectionMode :  false
    property bool translucency : Maui.Handy.isLinux

    //Global editor props
    property bool focusMode : false
    property bool enableSidebar : true
    property bool showLineNumbers : true
    property bool enableSyntaxHighlighting : true
    property bool showSyntaxHighlightingLanguages: false

    property string theme
    property color backgroundColor
    property string fontFamily : "Noto Sans Mono"
    property int fontSize : 10

    onTerminalVisibleChanged: if(terminalVisible && currentTab) syncTerminal(currentTab.fileUrl)
    onCurrentTabChanged:  if(terminalVisible && currentTab) syncTerminal(currentTab.fileUrl)

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
        },

        MenuSeparator {visible: terminal},

        MenuItem
        {
            visible: terminal
            text: qsTr("Show Terminal")
            icon.name: "utilities-terminal"
            onTriggered: toogleTerminal()
            checked : terminalVisible
            checkable: true
        }]

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

        MauiLab.SettingsDialog
        {
            MauiLab.SettingsSection
            {
                title: qsTr("General")
                description: qsTr("Configure the app UI and plugins.")

                Switch
                {
                    Layout.fillWidth: true
                    checkable: true
                    checked: root.enableSidebar
                    Kirigami.FormData.label: qsTr("Enable Places Sidebar")
                    onToggled:
                    {
                        root.enableSidebar = !root.enableSidebar
                        Maui.FM.saveSettings("ENABLE_SIDEBAR", enableSidebar, "GENERAL")
                    }
                }

                Switch
                {
                    enabled: terminalLoader.item
                    Layout.fillWidth: true
                    checkable: true
                    checked: root.terminalVisible
                    Kirigami.FormData.label: qsTr("Enable Embedded Terminal")
                    onToggled: toogleTerminal()
                }
            }

            MauiLab.SettingsSection
            {
                title: qsTr("Editor")
                description: qsTr("Configure the look and feel of the editor. The settings are applied globally")

                Switch
                {
                    Layout.fillWidth: true
                    checkable: true
                    checked: root.showLineNumbers
                    Kirigami.FormData.label: qsTr("Show line numbers")
                    onToggled:
                    {
                        root.showLineNumbers = !root.showLineNumbers
                        Maui.FM.saveSettings("SHOW_LINE_NUMBERS", showLineNumbers, "EDITOR")
                    }
                }

                Switch
                {
                    Layout.fillWidth: true
                    checkable: true
                    checked: root.showSyntaxHighlightingLanguages
                    Kirigami.FormData.label: qsTr("Show Syntax Highlighting Languages")
                    onToggled:
                    {
                        root.showSyntaxHighlightingLanguages = !root.showSyntaxHighlightingLanguages
                        Maui.FM.saveSettings("SHOW_LINE_NUMBERS", showLineNumbers, "EDITOR")
                    }
                }

                Switch
                {
                    Layout.fillWidth: true
                    Kirigami.FormData.label: qsTr("Enable Syntax Highlighting")
                    checkable: true
                    checked: root.enableSyntaxHighlighting
                    onToggled:
                    {
                        root.enableSyntaxHighlighting = !root.enableSyntaxHighlighting
                        Maui.FM.saveSettings("ENABLE_SYNTAX_HIGHLIGHTING", enableSyntaxHighlighting, "EDITOR")
                    }
                }
            }

            MauiLab.SettingsSection
            {
                title: qsTr("Fonts")
                description: qsTr("Configure the global editor font family and size")

                ComboBox
                {
                    Layout.fillWidth: true
                    Kirigami.FormData.label: qsTr("Family")
                    model: Qt.fontFamilies()
                    onActivated: root.fontFamily = currentText
                }

                SpinBox
                {
                    Layout.fillWidth: true
                    Kirigami.FormData.label: qsTr("Size")
                    from: 0; to : 500
                    value: currentTab ? currentTab.body.font.pointSize : Maui.Style.fontSizes.default
                    onValueChanged: root.fontSize = value
                }
            }

            MauiLab.SettingsSection
            {
                title: qsTr("Style")
                description: qsTr("Configure the style of the syntax highliting. This configuration in not applied for rich text formats.")
                visible: root.enableSyntaxHighlighting

                ComboBox
                {
                    Layout.fillWidth: true
                    Kirigami.FormData.label: qsTr("Theme")
                    model:  _dummyDocumentHandler.getThemes()
                    onActivated: root.theme = currentText

                    Maui.DocumentHandler
                    {
                        id: _dummyDocumentHandler
                    }
                }

                Row
                {
                    Layout.fillWidth: true
                    Kirigami.FormData.label: qsTr("Color")
                    spacing: Maui.Style.space.medium

                    Rectangle
                    {
                        height: 22
                        width: 22
                        radius: Maui.Style.radiusV
                        color: "#333"
                        border.color: Qt.darker(color)

                        MouseArea
                        {
                            anchors.fill: parent
                            onClicked: root.backgroundColor = parent.color
                        }
                    }

                    Rectangle
                    {
                        height: 22
                        width: 22
                        radius: Maui.Style.radiusV
                        color: "#fafafa"
                        border.color: Qt.darker(color)

                        MouseArea
                        {
                            anchors.fill: parent
                            onClicked: root.backgroundColor = parent.color
                        }
                    }

                    Rectangle
                    {
                        height: 22
                        width: 22
                        radius: Maui.Style.radiusV
                        color: "#fff3e6"
                        border.color: Qt.darker(color)
                        MouseArea
                        {
                            anchors.fill: parent
                            onClicked: root.backgroundColor = parent.color
                        }
                    }

                    Rectangle
                    {
                        height: 22
                        width: 22
                        radius: Maui.Style.radiusV
                        color: "#4c425b"
                        border.color: Qt.darker(color)
                        MouseArea
                        {
                            anchors.fill: parent
                            onClicked: root.backgroundColor = parent.color
                        }
                    }
                }
            }

            MauiLab.SettingsSection
            {
                title: qsTr("Interface")
                description: qsTr("Configure the app UI.")

                Switch
                {
                    Kirigami.FormData.label: qsTr("Focus Mode")
                    checkable: true
                    checked:  root.focusMode
                    onToggled:
                    {
                        root.focusMode = !root.focusMode
                        root.enableSidebar = false
                    }
                }

                Switch
                {
                    Kirigami.FormData.label: qsTr("Translucent Sidebar")
                    checkable: true
                    enabled: root.enableSidebar && Maui.Handy.isLinux
                    checked:  root.translucency
                    onToggled:  root.translucency = !root.translucency
                }

                Switch
                {
                    Kirigami.FormData.label: qsTr("Dark Mode")
                    checkable: true
                    enabled: false
                }
            }
        }
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

//    autoHideHeader: focusMode
//    floatingHeader: focusMode
    headBar.visible: root.currentTab && _swipeView.currentIndex === views.editor && !focusMode ? (root.currentTab.height > Kirigami.Units.gridUnit*30) : !focusMode

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
            onClicked:
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

    background: Rectangle
    {
        color: Kirigami.Theme.backgroundColor
        opacity: 0
    }

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
                selectionMode: root.selectionModec
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

    SplitView
    {
        anchors.fill: parent
        spacing: 0
        orientation: Qt.Vertical

        handle: Rectangle
        {
            implicitWidth: 10
            implicitHeight: 10
            color: SplitHandle.pressed ? Kirigami.Theme.highlightColor
                                       : (SplitHandle.hovered ? Qt.lighter(Kirigami.Theme.backgroundColor, 1.1) : Kirigami.Theme.backgroundColor)

            Kirigami.Separator
            {
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.left: parent.left
            }
        }

        ColumnLayout
        {
            id: _layout

            SplitView.fillHeight: true
            SplitView.fillWidth: true

            spacing: 0

            MauiLab.AppViews
            {
                id: _swipeView
                Layout.fillHeight: true
                Layout.fillWidth: true

                ColumnLayout
                {
                    id: editorView
                    spacing: 0

                    MauiLab.AppView.iconName: "document-edit"
                    MauiLab.AppView.title: qsTr("Editor")

                    Maui.TabBar
                    {
                        id: _tabBar
                        visible: _editorListView.count > 1
                        Layout.fillWidth: true
                        Layout.preferredHeight: _tabBar.implicitHeight
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

                    ListView
                    {
                        id: _editorListView
                        Layout.fillHeight: true
                        Layout.fillWidth: true
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
                            anchors.bottomMargin: Maui.Style.toolBarHeight + root.currentTab.footer.height
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

            MauiLab.SelectionBar
            {
                id: _selectionbar
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: Math.min(parent.width, implicitWidth)
                Layout.margins: Maui.Style.space.medium
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

        Loader
        {
            id: terminalLoader
            active: Nota.Nota.supportsEmbededTerminal()
            visible: active && terminalVisible && terminal
            SplitView.fillWidth: true
            SplitView.preferredHeight: 200
            SplitView.maximumHeight: parent.height * 0.5
            SplitView.minimumHeight : 100
            source: "Terminal.qml"

            Behavior on Layout.preferredHeight
            {
                NumberAnimation
                {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InQuad
                }
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

            if(path && Maui.FM.fileExists(path) && root.enableSidebar)
                browserView.openFolder(Maui.FM.fileDir(path))
        }
    }

    function closeTab(index)
    {
        console.log("CLOSING FILE", index, _editorList.count, _documentModel.count)
        _editorList.remove(index)
        _documentModel.remove(index)
        console.log("CLOSING FILE", index, _editorList.count, _documentModel.count)

    }

    function syncTerminal(path)
    {
        if(root.terminal && root.terminalVisible)
            root.terminal.session.sendText("cd '" + String(Maui.FM.fileDir(path)).replace("file://", "") + "'\n")
    }

    function toogleTerminal()
    {
        terminalVisible = !terminalVisible
        Maui.FM.saveSettings("TERMINAL", terminalVisible, "EXTENSIONS")
    }
}
