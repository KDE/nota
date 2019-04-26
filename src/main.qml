import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQml.Models 2.3
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

        Item
        {
            Layout.fillWidth: true
            Layout.preferredHeight: toolBarHeight

            Kirigami.Separator
            {
                color: borderColor
                z: tabsBar.z + 1
                anchors
                {
                    bottom: parent.bottom
                    right: parent.right
                    left: parent.left
                }
            }

            Rectangle
            {
                anchors.fill: parent
                color: Qt.darker(backgroundColor, 1.1)
            }

            RowLayout
            {

                anchors.fill : parent

                TabBar
                {
                    id: tabsBar
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    ListModel { id: tabsListModel }

                    ObjectModel { id: tabsObjectModel }

                    background: Rectangle
                    {
                        color: "transparent"
                    }

                    Repeater
                    {
                        model: tabsListModel

                        TabButton
                        {
                            width: 150 * unit
                            checked: shouldFocus
                            implicitHeight: toolBarHeight

                            background: Rectangle
                            {
                                color: checked ? backgroundColor : viewBackgroundColor

                                Kirigami.Separator
                                {
                                    color: borderColor
                                    z: tabsBar.z + 1
                                    visible: tabsListModel.count > 1
                                    anchors
                                    {
                                        bottom: parent.bottom
                                        top: parent.top
                                        right: parent.right
                                    }
                                }
                            }

                            contentItem: Item
                            {
                                height: toolBarHeight
                                width: 150 *unit
                                anchors.bottom: tabsBar.bottom

                                Label
                                {
                                    text: title
                                    //                             verticalAlignment: Qt.AlignVCenter
                                    font.pointSize: fontSizes.default
                                    anchors.centerIn: parent
                                    color: textColor
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    elide: Text.ElideRight
                                }

                                Maui.ToolButton
                                {
                                    Layout.fillHeight: true
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    padding: 2 * unit

                                    iconName: "dialog-close"
                                    //                             icon.color: "transparent"
                                    visible: tabsListModel.count > 1

                                    onClicked:
                                    {
                                        var removedIndex = index
                                        tabsObjectModel.remove(removedIndex)
                                        tabsListModel.remove(removedIndex)
                                    }
                                }

                            }
                        }
                    }
                }

                Maui.ToolButton
                {
                    implicitWidth: toolBarHeight
                    Layout.fillHeight: true

                    iconName: "list-add"


                    onClicked:
                    {

                        var component = Qt.createComponent("Editor.qml");
                        if (component.status === Component.Ready){
                            var object = component.createObject(tabsObjectModel, {
                                                                    onSaveClicked : function() {
                                                                        editorSaveClicked();
                                                                    }
                                                                });
                            tabsObjectModel.append(object);
                        }

                        tabsListModel.setProperty(tabsBar.currentIndex, "shouldFocus", false);
                        tabsListModel.append({
                                                 title: "Untitled",
                                                 path: "",
                                                 shouldFocus: true
                                             })
                    }
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
