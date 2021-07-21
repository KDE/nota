import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami
import org.mauikit.controls 1.2 as Maui

Maui.Dialog
{
    id: control
    title: i18n("New file")
    maxWidth: 350

    page.padding: 0
    spacing: 0
    persistent: false
    defaultButtons: false
    rejectButton.visible : false
    acceptButton.visible: false

    Maui.AlternateListItem
    {
        Layout.fillWidth: true
        hoverEnabled: true
        implicitHeight: 80

        Maui.ListItemTemplate
        {
            anchors.fill: parent
            headerSizeHint: iconSizeHint + Maui.Style.space.big
            iconSizeHint: Maui.Style.iconSizes.big
            iconSource: "folder-open"
            label1.text: i18n("Open File")
            label2.text: i18n("Open one or multiple files")
        }

        onClicked:
        {
            openFileDialog()
            control.close()
        }
    }

    Maui.AlternateListItem
    {
        Layout.fillWidth: true
        hoverEnabled: true
        implicitHeight: 80

        Maui.ListItemTemplate
        {
            anchors.fill: parent
            headerSizeHint: iconSizeHint + Maui.Style.space.big
            iconSizeHint: Maui.Style.iconSizes.big
            iconSource: "folder-recent"
            label1.text: i18n("Recent File")
            label2.text: i18n("Open recently used files")
        }

        onClicked:
        {
            _stackView.push(historyView)
            control.close()
        }
    }

    Maui.AlternateListItem
    {
        Layout.fillWidth: true
        hoverEnabled: true
        implicitHeight: 80
        lastOne: true

        Maui.ListItemTemplate
        {
            anchors.fill: parent
            headerSizeHint: iconSizeHint + Maui.Style.space.big
            iconSizeHint: Maui.Style.iconSizes.big
            iconSource: "text-x-generic"
            label1.text: i18n("Text File")
            label2.text: i18n("Simple text file with syntax highlighting")
        }

        onClicked:
        {
            editorView.openTab("")
            //                _editorListView.currentItem.body.textFormat = TextEdit.PlainText
            control.close()
        }
    }
}
