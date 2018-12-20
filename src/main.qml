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
            onClicked: fileDialog.show(function (paths)
            {
                console.log("CALLBACK", paths, fileDialog.textField.text)
            })
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

        floatingBar: false
        onItemClicked:
        {
            var item = list.get(index)

            if(Maui.FM.isDir(item.path))
                openFolder(item.path)
            else
                editor.document.load("file://"+item.path)
                console.log("OPENIGN FILE", item.path)
        }

    }


    ColumnLayout
    {
        id: editorView
        anchors.fill: parent
        Maui.Editor
        {
            id: editor
            Layout.fillHeight: true
            Layout.fillWidth: true

            headBar.rightContent: Maui.ToolButton
            {
                iconName: "document-save"
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
            source: !isMobile ? "Terminal.qml" : undefined
        }
    }

//    Component.onCompleted:
//    {
//        editor.document.load("/home/camilo/Coding/qml/mauikit-kde/src/controls/AboutDialog.qml")
//    }
}
