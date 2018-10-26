import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.4 as Kirigami
import org.kde.mauikit 1.0 as Maui

import FMList 1.0

Maui.ApplicationWindow
{
    id: root
    title: qsTr("Nota")

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
        filterType: FMList.IMAGE
        sortBy: FMList.MIME
        multipleSelection: true
    }

    headBar.leftContent: [
        Maui.ToolButton
        {
            iconName: "document-open"
            onClicked: fileDialog.show(function (paths)
            {
                console.log("CALLBACK", paths)
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

    ColumnLayout
    {
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
