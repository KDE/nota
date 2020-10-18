import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.2 as Maui
import org.maui.nota 1.0 as Nota

Maui.Dialog
{
    id: control

    rejectButton.visible : false
    page.padding: 0
    acceptButton.visible: true
    acceptButton.text: i18n("New template")

   stack: ColumnLayout
    {
        Layout.fillWidth: true
        Layout.fillHeight: true

        spacing: 0

        Maui.AlternateListItem
        {
            Layout.fillWidth: true
            Layout.fillHeight: true

            alt: true

            Maui.ListItemTemplate
            {
                anchors.fill:parent
                iconSizeHint: Math.min(height, Maui.Style.iconSizes.big)
                iconSource: "folder-open"
                label1.text: i18n("Open file")
                label2.text: i18n("Open one or multiple files from the file system")
            }

            onClicked:
            {
                openFile()
                control.close()
            }
        }

        Maui.AlternateListItem
        {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Maui.ListItemTemplate
            {
                anchors.fill:parent
                iconSizeHint: Math.min(height, Maui.Style.iconSizes.big)
                iconSource: "text-x-generic"
                label1.text: i18n("Text file")
                label2.text: i18n("Simple text file with syntax highlighting")
            }

            onClicked:
            {
                openTab("")
                _editorListView.currentItem.body.textFormat = TextEdit.PlainText
                control.close()
            }
        }


        Maui.AlternateListItem
        {
            Layout.fillWidth: true
            Layout.fillHeight: true
            alt: true
            Maui.ListItemTemplate
            {
                anchors.fill:parent
                iconSizeHint: Math.min(height, Maui.Style.iconSizes.big)
                iconSource: "text-enriched"
                label1.text: i18n("Rich text file")
                label2.text: i18n("With support for basic text format editing")
            }

            onClicked:
            {
                openTab("")
                _editorListView.currentItem.body.textFormat = TextEdit.RichText
                control.close()
            }
        }

        Maui.AlternateListItem
        {
            Layout.fillWidth: true
            Layout.fillHeight: true
            lastOne: true

            Maui.ListItemTemplate
            {
                anchors.fill:parent
                iconSizeHint: Math.min(height, Maui.Style.iconSizes.big)
                iconSource: "text-html"
                label1.text: i18n("HTML text file")
                label2.text: i18n("Text file with HTML markup support")
            }
        }
    }
}
