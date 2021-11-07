import QtQuick 2.14

import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.14 as Kirigami

import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.3 as FB

Item
{
    id: control
    implicitHeight: Maui.Style.rowHeight

    RowLayout
    {
        spacing: 2
        anchors.fill: parent

        AbstractButton
        {
            enabled: currentEditor.body.canUndo
            focusPolicy: Qt.NoFocus

            Layout.fillHeight: true
            implicitWidth: height * 1.4

            background: Kirigami.ShadowedRectangle
            {
                color: Qt.lighter(Kirigami.Theme.backgroundColor)

                corners
                {
                    topLeftRadius: Maui.Style.radiusV
                    topRightRadius: 0
                    bottomLeftRadius: Maui.Style.radiusV
                    bottomRightRadius: 0
                }
            }
            onClicked: currentEditor.body.undo()

            Kirigami.Icon
            {
                anchors.centerIn: parent
                source: "edit-undo"
                implicitHeight: Maui.Style.iconSizes.small
                implicitWidth: implicitHeight
            }
        }

        AbstractButton
        {
            Layout.fillWidth: true
            Layout.fillHeight: true

            background: Rectangle
            {
                color: Qt.lighter(Kirigami.Theme.backgroundColor)
                border.width: 1
                border.color: _docMenu.visible ? Kirigami.Theme.highlightColor : color
            }

            contentItem: Maui.ListItemTemplate
            {
                anchors.fill: parent
                spacing: 0
                label1.horizontalAlignment: Qt.AlignHCenter
                label2.horizontalAlignment: Qt.AlignHCenter
                label1.text: currentEditor.title
                label2.text: currentEditor.fileUrl
                label2.font.pointSize: Maui.Style.fontSizes.small

                Kirigami.Icon
                {
                    source: _docMenu.visible ? "go-up" : "go-down"
                    implicitHeight: Maui.Style.iconSizes.small
                    implicitWidth: implicitHeight
                }
            }

            onClicked: _docMenu.show((width*0.5)-(_docMenu.width*0.5), height + Maui.Style.space.medium)

            Maui.ContextualMenu
            {
                id: _docMenu

                Maui.MenuItemActionRow
                {
                    Action
                    {
                        icon.name: "edit-redo"
                        text: i18n("Redo")
                        enabled: currentEditor.body.canRedo
                        onTriggered: currentEditor.body.redo()
                    }


                    Action
                    {
                        text: i18n("Save")
                        icon.name: "document-save"
                        enabled: currentEditor ? currentEditor.document.modified : false
                        onTriggered: saveFile(currentEditor.fileUrl, currentEditor)
                    }

                    Action
                    {
                        icon.name: "document-save-as"
                        text: i18n("Save as")
                        onTriggered: saveFile("", currentEditor)
                    }
                }


                MenuSeparator {}

                MenuItem
                {
                    icon.name: "edit-find"
                    text: i18n("Find and Replace")
                    checkable: true

                    onTriggered:
                    {
                        currentEditor.showFindBar = !currentEditor.showFindBar
                    }
                    checked: currentEditor.showFindBar
                }

                MenuItem
                {
                    icon.name: "document-edit"
                    text: i18n("Line/Word Counter")
                    checkable: true

                    onTriggered:
                    {
                        currentEditor.showLineCount = checked
                    }

                    checked: currentEditor.showLineCount
                }

                MenuSeparator {}

                Maui.MenuItemActionRow
                {

                    Action
                    {
                        property bool isFav: FB.Tagging.isFav(currentEditor.fileUrl)
                        text: i18n(isFav ? "UnFav it": "Fav it")
                        checked: isFav
                        checkable: true
                        icon.name: "love"
                        enabled: currentFileExistsLocally
                        onTriggered:
                        {
                            FB.Tagging.toggleFav(currentEditor.fileUrl)
                            isFav = FB.Tagging.isFav(currentEditor.fileUrl)
                        }
                    }

                    Action
                    {
                        enabled: currentFileExistsLocally
                        text: i18n("Info")
                        icon.name: "documentinfo"
                        onTriggered:
                        {
                            //            getFileInfo(control.model.get(index).url)
                        }
                    }

                    Action
                    {
                        text: i18n("Share")
                        enabled: currentFileExistsLocally
                        icon.name: "document-share"
                        onTriggered: Maui.Platform.shareFiles([currentEditor.fileUrl])

                    }
                }

                MenuSeparator {}

                MenuItem
                {
                    icon.name: "go-jump"
                    text: i18n("Go to Line")

                    onTriggered:
                    {
                        _goToLineDialog.open()
                    }

                    Maui.NewDialog
                    {
                        id: _goToLineDialog
                        title: i18n("Go to Line")
                        textEntry.text: currentEditor.document.currentLineIndex+1
                        textEntry.placeholderText: i18n("Line number")
                        onFinished: currentEditor.goToLine(text)
                    }
                }

                MenuItem
                {
                    enabled: currentFileExistsLocally
                    text: i18n("Show in folder")
                    icon.name: "folder-open"
                    onTriggered:
                    {
                        FB.FM.openLocation([currentEditor.fileUrl])
                    }
                }

                MenuItem
                {
                    text: i18n("Delete file")
                    icon.name: "edit-delete"
                    enabled: currentFileExistsLocally
                    Kirigami.Theme.textColor: Kirigami.Theme.negativeTextColor
                    onTriggered:
                    {
                        _removeDialog.open()
                    }

                    Maui.Dialog
                    {
                        id: _removeDialog

                        title: i18n("Delete file?")
                        acceptButton.text: i18n("Accept")
                        rejectButton.text: i18n("Cancel")
                        message: i18n("Are sure you want to delete \n%1", currentEditor.fileUrl)
                        page.margins: Maui.Style.space.big
                        template.iconSource: "emblem-warning"

                        onRejected: close()
                        onAccepted:
                        {
                            FB.FM.deleteFile(currentEditor.fileUrl)
                        }
                    }
                }
            }
        }

        AbstractButton
        {
            focusPolicy: Qt.NoFocus

            Layout.fillHeight: true
            implicitWidth: height * 1.4

            background: Kirigami.ShadowedRectangle
            {
                color: Qt.lighter(Kirigami.Theme.backgroundColor)

                corners
                {
                    topLeftRadius: 0
                    topRightRadius: Maui.Style.radiusV
                    bottomLeftRadius: 0
                    bottomRightRadius: Maui.Style.radiusV
                }
            }

            onClicked: _overflowMenu.show(0,  height + Maui.Style.space.medium)

            Kirigami.Icon
            {
                anchors.centerIn: parent
                source: "overflow-menu"
                implicitHeight: Maui.Style.iconSizes.small
                implicitWidth: implicitHeight
            }

            Maui.ContextualMenu
            {
                id: _overflowMenu

                Maui.MenuItemActionRow
                {
                    Action
                    {
                        icon.name: checked ? "view-readermode-active" : "view-readermode"
                        text: i18n("Focus")
                        checked: root.focusMode
                        checkable: true
                        onTriggered: root.focusMode = !root.focusMode
                    }

                    Action
                    {
                        text: i18n("Terminal")
                        icon.name: "dialog-scripts"
                        enabled: Maui.Handy.isLinux
                        onTriggered: currentTab.toggleTerminal()
                        checkable: true
                        checked: currentTab ? currentTab.terminalVisible : false
                    }

                    Action
                    {
                        enabled: settings.supportSplit
                        text: i18n("Split")
                        icon.name: root.currentTab.orientation === Qt.Horizontal ? "view-split-left-right" : "view-split-top-bottom"
                        checked: root.currentTab && root.currentTab.count === 2
                        checkable: true
                        onTriggered:
                        {
                            if(root.currentTab.count === 2)
                            {
                                root.currentTab.pop()
                                return
                            }//close the inactive split

                            root.currentTab.split("")
                        }
                    }
                }

                MenuSeparator {}

                MenuItem
                {
                    text: i18n("Shortcuts")
                    icon.name: "configure-shortcuts"
                    onTriggered:
                    {
                        _dialogLoader.sourceComponent = _shortcutsDialogComponent
                        dialog.open()
                    }
                }

                MenuItem
                {
                    text: i18n("Settings")
                    icon.name: "settings-configure"
                    onTriggered:
                    {
                        _dialogLoader.sourceComponent = _settingsDialogComponent
                        dialog.open()
                    }
                }

                MenuItem
                {
                    text: i18n("Plugins")
                    icon.name: "system-run"
                    onTriggered:
                    {
                        _dialogLoader.sourceComponent = _plugingsDialogComponent
                        dialog.open()
                    }
                }

                MenuItem
                {
                    text: i18n("About")
                    icon.name: "documentinfo"
                    onTriggered: root.about()
                }
            }
        }
    }
}
