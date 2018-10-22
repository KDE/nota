import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.4 as Kirigami
import org.kde.mauikit 1.0 as Maui

Maui.ApplicationWindow
{
    id: root
    title: qsTr("Nota")

    headBar.middleContent: [
        Maui.ToolButton
        {
            id: document
            iconName: "document-new"
        },
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
