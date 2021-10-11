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

    page.padding: Maui.Style.space.medium
    spacing: Maui.Style.space.medium
    persistent: false
    defaultButtons: false
    rejectButton.visible : false
    acceptButton.visible: false

    Maui.ListBrowserDelegate
    {
        Layout.fillWidth: true
        implicitHeight: 80

        template.headerSizeHint: iconSizeHint + Maui.Style.space.big
        iconSizeHint: Maui.Style.iconSizes.big
        iconSource: "folder-open"
        label1.text: i18n("Open Files")
        label2.text: i18n("Open one or multiple files")


        onClicked:
        {
            openFileDialog()
            control.close()
        }
    }

    Maui.ListBrowserDelegate
    {
        Layout.fillWidth: true
        implicitHeight: 80

        template.headerSizeHint: iconSizeHint + Maui.Style.space.big
        iconSizeHint: Maui.Style.iconSizes.big
        iconSource: "folder-recent"
        label1.text: i18n("Open Recent Files")
        label2.text: i18n("Open recently used files")


        onClicked:
        {
            _stackView.push(historyViewComponent)
            control.close()
        }
    }

    Maui.ListBrowserDelegate
    {
        Layout.fillWidth: true
        implicitHeight: 80

        template.headerSizeHint: iconSizeHint + Maui.Style.space.big
        iconSizeHint: Maui.Style.iconSizes.big
        iconSource: "text-x-generic"
        label1.text: i18n("New Text File")
        label2.text: i18n("Simple text file with syntax highlighting")


        onClicked:
        {
            editorView.openTab("")
            //                _editorListView.currentItem.body.textFormat = TextEdit.PlainText
            control.close()
        }
    }
}
