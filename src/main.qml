import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.4 as Kirigami
import org.kde.mauikit 1.0 as Maui
import QtQuick.Window 2.0

import FMList 1.0

Maui.ApplicationWindow
{
    id: root
    title: qsTr("Nota")

    property int sidebarWidth: Kirigami.Units.gridUnit * 11 > Screen.width  * 0.3 ? Screen.width : Kirigami.Units.gridUnit * 11

    property bool terminalVisible: false
    property alias terminal : terminalLoader.item
    pageStack.defaultColumnWidth: sidebarWidth
    pageStack.initialPage: [browserView, editorView]
    pageStack.interactive: isMobile
    pageStack.separatorVisible: pageStack.wideMode

    mainMenu: [
        Maui.MenuItem
        {
            text: qsTr("Save As")
            onTriggered: saveFile()
        },
        Maui.MenuItem
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
        filterType: FMList.TEXT
        sortBy: FMList.MODIFIED
        mode: modes.OPEN
    }

    headBar.leftContent: [
        Maui.ToolButton
        {
            iconName: "document-open"
            onClicked: {
                fileDialog.onlyDirs = false;
                fileDialog.mode = 0;
                fileDialog.show(function (paths) {
                    var filepath = "";

                    if (typeof paths === "object") {
                        filepath = paths[0];
                    } else {
                        filepath = paths;
                    }

                    editor.document.load("file://" + filepath);
                    setTabMetadata(filepath);
                });
            }
        },
        Maui.ToolButton
        {
            iconName: "document-new"
        }
    ]

    headBar.rightContent: [
        Maui.ToolButton
        {
            id: recent
            iconName: "view-media-recent"
        },
        Maui.ToolButton
        {
            id: gallery
            iconName: "view-books"
        }
    ]



    Maui.FileBrowser
    {
        id: browserView
        headBar.visible: false
        list.viewType : FMList.LIST_VIEW
        list.filterType: FMList.TEXT
        trackChanges: false
        thumbnailsSize: iconSizes.small
        showEmblems: false
        z: 1

        floatingBar: false
        onItemClicked:
        {
            var item = list.get(index)

            if(Maui.FM.isDir(item.path))
                openFolder(item.path)
            else {
                editor.document.load("file://"+item.path)
                console.log("OPENIGN FILE", item.path)

                setTabMetadata(item.path);
            }
        }

    }

    ColumnLayout
    {
        id: editorView
        anchors.fill: parent

        TabBar {
            id: tabsBar
            Layout.fillWidth: true

            onCurrentIndexChanged: {
                console.log("Tab["+currentIndex+"] Activated\nPath: "+tabsListModel.get(currentIndex).path)
                editor.body.text = tabsListModel.get(currentIndex).content
            }

            ListModel {
                id: tabsListModel

                ListElement {
                    title: "Untitled"
                    path: ""
                    content: ""
                    shouldFocus: true
                }
            }

            Repeater {
                model: tabsListModel

                TabButton {
                    width: 150
                    checked: shouldFocus

                    contentItem: Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true


                        RowLayout
                        {
                            anchors.fill: parent
                            spacing: space.small

                            Label
                            {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignCenter
                                text: title
                                font.pointSize: fontSizes.default
                                color: textColor
                                horizontalAlignment: Qt.AlignHCenter
                                verticalAlignment:  Qt.AlignVCenter
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                elide: Text.ElideRight
                            }

                            Maui.ToolButton
                            {
                                Layout.fillHeight: true

                                iconName: "window-close"
                                onClicked:
                                {
                                    var removedIndex = index
                                    tabsListModel.remove(removedIndex)
                                    console.log("Tab["+removedIndex+"] closed")
                                }
                            }
                        }

                    }
                }
            }

            TabButton
            {
                width: this.height

                contentItem: Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true


                    Maui.ToolButton
                    {
                        anchors.centerIn: parent
enabled: false
                        iconName: "list-add"
                    }
                }

                onPressed: {
                    tabsListModel.setProperty(tabsBar.currentIndex, "shouldFocus", false);
                    tabsListModel.append({
                      title: "Untitled",
                      path: "",
                      content: "",
                      shouldFocus: true
                    })
                }
            }
        }

        Maui.Editor
        {
            id: editor
            Layout.fillHeight: true
            Layout.fillWidth: true
            anchors.topMargin: tabsBar.height

            headBar.rightContent: Maui.ToolButton
            {
                iconName: "document-save"
                onClicked: {
//                    if (editor.document.fileUrl == "") {
//                        saveFile();
//                    } else {
//                        saveFile(editor.document.fileUrl);
//                    }
                    saveFile(tabsListModel.get(tabsBar.currentIndex).path);
                }
            }

            anchors.top: parent.top
            anchors.bottom: terminalVisible ? handle.top : parent.bottom
        }

        Rectangle
        {
            id: handle
            visible: terminalVisible

            Layout.fillWidth: true
            height: 5
            color: "transparent"

            Kirigami.Separator
            {
                anchors
                {
                    bottom: parent.bottom
                    right: parent.right
                    left: parent.left
                }
            }

            MouseArea
            {
                anchors.fill: parent
                drag.target: parent
                drag.axis: Drag.YAxis
                drag.smoothed: true
                cursorShape: Qt.SizeVerCursor
            }
        }

        Loader
        {
            id: terminalLoader
            visible: terminalVisible
            focus: true
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignBottom
            Layout.minimumHeight: 100
            Layout.maximumHeight: root.height * 0.3
            anchors.bottom: parent.bottom
            anchors.top: handle.bottom
//            source: !isMobile ? "Terminal.qml" : undefined
        }
    }

    Connections {
        target: editor.body
        onTextChanged: {
            tabsListModel.setProperty(tabsBar.currentIndex, "content", editor.body.text)
        }
    }

    function saveFile(path) {
        if (path) {
            editor.document.saveAs(path);
        } else {
            fileDialog.mode = 1;
            fileDialog.show(function (paths) {
                var filepath = "";

                if (typeof paths === "object") {
                    filepath = paths[0];
                } else {
                    filepath = paths;
                }

                editor.document.saveAs("file://" + filepath + "/" + fileDialog.textField.text);
                setTabMetadata(filepath + "/" + fileDialog.textField.text);
            });
        }
    }

    function setTabMetadata(filepath) {
        tabsListModel.setProperty(tabsBar.currentIndex, "title", filepath.split("/").slice(-1)[0])
        tabsListModel.setProperty(tabsBar.currentIndex, "path", "file://" + filepath)
    }
}
