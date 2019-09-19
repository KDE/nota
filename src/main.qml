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

    property bool terminalVisible: false
    property alias terminal : terminalLoader.item
    property var views : ({editor: 0, documents: 1, recent: 2})
    property int currentView : views.editor

    Component.onCompleted:
    {
//        Maui.App.iconName = "qrc:/nota.svg"
        Maui.App.description = qsTr("Nota is a simple text editor for Plasma Mobile, GNU/Linux distros and Android")
    }
    about.appIcon: "qrc:/buho.svg"


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
            onTriggered: terminalVisible = !terminalVisible
        }
    ]

    Maui.FileDialog
    {
        id: fileDialog
        onlyDirs: false
        filterType: Maui.FMList.TEXT
        sortBy: Maui.FMList.MODIFIED
        mode: modes.OPEN
    }

    headBar.rightContent: [
        ToolButton
        {
            icon.name: "document-open"
            onClicked: {
                fileDialog.onlyDirs = false;
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
        modal: root.width < Kirigami.Units.gridUnit * 62
        handleVisible: modal

        contentItem: Maui.FileBrowser
        {
            id: browserView

            headBar.position: ToolBar.Footer
            headBar.visible: true
            list.viewType : Maui.FMList.LIST_VIEW
            list.filterType: Maui.FMList.TEXT
            trackChanges: false
            showEmblems: false
            z: parent.z+1

            onItemClicked:
            {
                var item = list.get(index)

                if(Maui.FM.isDir(item.path))
                    openFolder(item.path)
                else
                    openTab(item.path)
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

            Rectangle
            {
                id: _tabBar
                Kirigami.Theme.colorSet: Kirigami.Theme.View
                Kirigami.Theme.inherit: false
                Layout.fillWidth: true
                Layout.preferredHeight: visible ? Maui.Style.rowHeight : 0
                visible: _editorList.count > 1
                color: "transparent"

                RowLayout
                {
                    spacing: 0
                    anchors.fill : parent

                    TabBar
                    {
                        id: tabsBar
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        currentIndex : _editorList.currentIndex
                        clip: true

                        ListModel { id: tabsListModel }

                        background: Rectangle
                        {
                            color: "transparent"
                        }

                        Repeater
                        {
                            model: tabsListModel

                            TabButton
                            {
                                id: _tabButton
                                readonly property int tabWidth: 150 * unit
                                implicitWidth: Math.min(tabWidth, root.width)
                                implicitHeight: Maui.Style.rowHeight
                                checked: index === _editorList.currentIndex

                                onClicked: _editorList.currentIndex = index

                                background: Rectangle
                                {
                                    color: checked ? Kirigami.Theme.focusColor : Kirigami.Theme.backgroundColor
//                                    opacity: checked ? 0.4 : 1
                                }

                                contentItem: RowLayout
                                {
                                    spacing: 0
                                    height: parent.height
                                    width: parent.width

                                    Label
                                    {
                                        text: title
                                        font.pointSize: fontSizes.default
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        Layout.margins: space.small
                                        Layout.alignment: Qt.AlignCenter
                                        verticalAlignment: Qt.AlignVCenter
                                        horizontalAlignment: Qt.AlignHCenter
                                        color: Kirigami.Theme.textColor
                                        wrapMode: Text.NoWrap
                                        elide: Text.ElideRight
                                    }

                                    ToolButton
                                    {
                                        Layout.preferredHeight: iconSizes.medium
                                        Layout.preferredWidth: iconSizes.medium
                                        icon.height: iconSizes.medium
                                        icon.width: iconSizes.width
                                        Layout.margins: space.medium
                                        Layout.alignment: Qt.AlignRight

                                        icon.name: "dialog-close"

                                        onClicked:
                                        {
                                            var removedIndex = index
                                            tabsObjectModel.remove(removedIndex)
                                            tabsListModel.remove(removedIndex)
                                        }
                                    }
                                }

                                Kirigami.Separator
                                {
                                    color: Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.7))
//                                        z: tabsBar.z + 1
                                    width : 1
                                    //                                    visible: tabsListModel.count > 1
                                    anchors
                                    {
                                        bottom: parent.bottom
                                        top: parent.top
                                        right: parent.right
                                    }
                                }
                            }
                        }
                    }
                    ToolButton
                    {
                        Layout.margins: space.medium
                        Layout.alignment: Qt.AlignVCenter
                        Layout.fillHeight: true
                        Layout.preferredWidth: iconSizes.medium
                        icon.name: "list-add"
                        flat: true
                        onClicked: openTab("")
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
                    emojiSize: iconSizes.huge
                    isMask: false
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
        tabsListModel.setProperty(tabsBar.currentIndex, "title", Maui.FM.getFileInfo(filepath).label)
        tabsListModel.setProperty(tabsBar.currentIndex, "path", filepath)
    }
}
