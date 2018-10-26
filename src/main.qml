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
            onTriggered: terminal.visible = !terminal.visible
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
        headBarVisible: false
        detailsView: true
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

            headBar.rightContent:
                Maui.ToolButton
            {
                iconName: "document-save"
            }
        }

        Maui.Terminal
        {
            id: terminal
            Layout.fillWidth: true
            Layout.preferredHeight: unit *200
            Layout.minimumHeight: unit *100
            kterminal.colorScheme: "DarkPastels"
        }
    }
}
