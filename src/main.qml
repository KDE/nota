import QtQuick 2.9
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import QtQml.Models 2.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import QtQuick.Window 2.0

import "views"

Maui.ApplicationWindow
{
    id: root
    title: qsTr("Nota")

    property bool terminalVisible: Maui.FM.loadSettings("TERMINAL", "MAINVIEW", false) == "true"
    property alias terminal : terminalLoader.item
    property var views : ({editor: 0, documents: 1, recent: 2})
    property int currentView : views.editor

    Maui.App.iconName: "qrc:/img/nota.svg"
    Maui.App.description: qsTr("Nota is a simple text editor for Plasma Mobile, GNU/Linux distros and Android")

    ObjectModel { id: tabsObjectModel }

    rightIcon.visible: false

    onCurrentViewChanged:
    {
        _drawer.visible = currentView === views.editor
    }

    mainMenu: [
        MenuItem
        {
            text: qsTr("Show terminal")
            checkable: true
            checked: terminal.visible
            onTriggered:
            {
                terminalVisible = !terminalVisible
                Maui.FM.saveSettings("TERMINAL",terminalVisible, "MAINVIEW")
            }
        }
    ]

    Maui.FileDialog
    {
        id: fileDialog
        settings.onlyDirs: false
        settings.filterType: Maui.FMList.TEXT
        settings.sortBy: Maui.FMList.MODIFIED
        mode: modes.OPEN
    }

    headBar.rightContent: [
        ToolButton
        {
            icon.name: "document-open"
            onClicked: {
                fileDialog.settings.onlyDirs = false;
                fileDialog.mode = fileDialog.modes.OPEN;
                fileDialog.singleSelection = false
                fileDialog.show(function (paths) {
                    for(var i in paths)
                        openTab(paths[i])
                });
            }
        },
        ToolButton
        {
            icon.name: "document-new"
            onClicked: openTab("")
        }
    ]

    headBar.leftContent: Kirigami.ActionToolBar
    {
        display: isWide ? ToolButton.TextBesideIcon : ToolButton.IconOnly
        position: ToolBar.Header
        Layout.fillWidth: true

        actions: [
            Action
            {
                text: qsTr("Editor")
                icon.name: "editor"
                checked: currentView === views.editor
                onTriggered: currentView = views.editor
            },
            Action
            {
                text: qsTr("Documents")
                icon.name: "view-pim-journal" // to do
                checked: currentView === views.documents
                onTriggered: currentView = views.documents

            },
            Action
            {
                text: qsTr("Recent")
                icon.name: "view-media-recent" // to do
                checked: currentView === views.recent
                onTriggered: currentView = views.recent
            }
        ]
    }

    globalDrawer: Maui.GlobalDrawer
    {
        id : _drawer
        width: Kirigami.Units.gridUnit * 14
        //        height: root.height - headBar.height - ( modal ? _editorList.currentItem.footBar.height : 0)
        modal: root.width < Kirigami.Units.gridUnit * 62
        handleVisible: false

        contentItem: Maui.Page
        {
            headBar.middleContent: ComboBox
            {
                Layout.fillWidth: true

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
                headBar.position: ToolBar.Footer
                headBar.visible: true
                viewType : Maui.FMList.LIST_VIEW
                settings.filterType: Maui.FMList.TEXT
                headBar.rightLayout.visible: false
                headBar.rightLayout.width: 0

                onItemClicked:
                {
                    var item = currentFMList.get(index)

                    if(Maui.FM.isDir(item.path))
                        openFolder(item.path)
                    else
                        root.openTab(item.path)
                }
            }
        }
    }

    SwipeView
    {
        id: _swipeView
        anchors.fill: parent
        currentIndex: currentView

        onCurrentItemChanged: currentItem.forceActiveFocus()
        onCurrentIndexChanged: currentView = currentIndex

        ColumnLayout
        {
            id: editorView
            spacing: 0

            Maui.TabBar
            {
                id: _tabBar
                visible: _editorList.count > 1
                Layout.fillWidth: true
                Layout.preferredHeight: _tabBar.implicitHeight
                position: TabBar.Header
                currentIndex : _editorList.currentIndex

                ListModel { id: tabsListModel }

                //                        Keys.onPressed:
                //                        {
                //                            if(event.key == Qt.Key_Return)
                //                            {
                //                                _browserList.currentIndex = currentIndex
                //                                control.currentPath =  tabsObjectModel.get(currentIndex).path
                //                            }
                //                        }

                Repeater
                {
                    id: _repeater
                    model: tabsListModel

                    Maui.TabButton
                    {
                        id: _tabButton
                        implicitHeight: _tabBar.implicitHeight
                        implicitWidth: Math.max(_tabBar.width / _repeater.count, 120)
                        checked: index === _tabBar.currentIndex

                        text: title

                        onClicked: _editorList.currentIndex = index
                        onCloseClicked:
                        {
                            const removedIndex = index
                            tabsObjectModel.remove(removedIndex)
                            tabsListModel.remove(removedIndex)
                        }
                    }
                }
            }


            Kirigami.Separator
            {
                color: Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.7))
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                visible: _tabBar.visible
            }

            ListView
            {
                id: _editorList
                Layout.fillHeight: true
                Layout.fillWidth: true
                orientation: ListView.Horizontal
                model: tabsObjectModel
                snapMode: ListView.SnapOneItem
                spacing: 0
                interactive: isMobile
                highlightFollowsCurrentItem: true
                highlightMoveDuration: 0


                Maui.Holder
                {
                    id: _holder
                    visible: !tabsListModel.count
                    emoji: "qrc:/Type.png"
                    emojiSize: Maui.Style.iconSizes.huge
                    isMask: false
                    onActionTriggered: openTab()
                    title: qsTr("Create a new document")
                    body: qsTr("You can reate a new document by clicking the New File button, or the tab bar Add icon.
                Alternative you can open existing files from the left places sidebar or by clicking the Open button")
                }

            }

            Loader
            {
                id: terminalLoader
                visible: terminalVisible
                focus: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignBottom
                Layout.minimumHeight: 100
                Layout.maximumHeight: 200
                //            anchors.bottom: parent.bottom
                //            anchors.top: handle.bottom
                source: !isMobile ? "Terminal.qml" : undefined
            }
        }


        DocumentsView
        {
            id: _documentsView
        }
    }


    function openTab(path)
    {
        var component = Qt.createComponent("Editor.qml");
        if (component.status === Component.Ready)
        {
            var object = component.createObject(tabsObjectModel);
            tabsObjectModel.append(object);
        }

        tabsListModel.append({
                                 title: qsTr("Untitled"),
                                 path: path,
                             })

        _editorList.currentIndex = tabsObjectModel.count - 1

        if(path && Maui.FM.fileExists(path))
        {
            setTabMetadata(path)
            tabsObjectModel.get(tabsObjectModel.count - 1).document.load(path)
            browserView.openFolder(path)
        }
    }

    function setTabMetadata(filepath) {
        tabsListModel.setProperty(_tabBar.currentIndex, "title", Maui.FM.getFileInfo(filepath).label)
        tabsListModel.setProperty(_tabBar.currentIndex, "path", filepath)
    }
}
