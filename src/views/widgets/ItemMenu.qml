import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.mauikit.controls as Maui
import org.mauikit.filebrowsing as FB

Maui.ContextualMenu
{
    id: control

    property bool isFav : false
    property int index : -1
    property Maui.BaseModel model : null

    onOpened: isFav = FB.Tagging.isFav(control.model.get(index).path)

    Maui.MenuItemActionRow
    {
        Action
        {
//            text: i18n(isFav ? "UnFav it": "Fav it")
            checked: isFav
            checkable: true
            icon.name: "love"
            onTriggered: FB.Tagging.toggleFav(control.model.get(index).path)
        }

        Action
        {
//            text: i18n("Tags")
            icon.name: "tag"
            onTriggered:
            {
                if(!root.tagsDialog)
                {
                    root.tagsDialog = _tagsDialogComponent.createObject(root)
                }

                root.tagsDialog.composerList.urls = [control.model.get(index).path]
                root.tagsDialog.open()
            }
        }

        Action
        {
//            text: i18n("Share")
            icon.name: "document-share"
            onTriggered: Maui.Platform.shareFiles([control.model.get(index).path])
        }
    }

    MenuSeparator{}

    MenuItem
    {
        text: i18n("Select")
        icon.name: "item-select"
        onTriggered:
        {
            if(Maui.Handy.isMobile)
                selectionMode = true

            addToSelection(control.model.get(index))
        }
    }

    MenuSeparator{}

    MenuItem
    {
        text: i18n("Save as")
        icon.name: "document-save-as"
        onTriggered: copyFilesTo([control.model.get(index).path])
    }

    MenuItem
    {
        enabled: !Maui.Handy.isAndroid
        text: i18n("Show in Folder")
        icon.name: "folder-open"
        onTriggered:
        {
            FB.FM.openLocation([control.model.get(index).path])
        }
    }

    MenuItem
    {
        text: i18n("Info")
        icon.name: "documentinfo"
        onTriggered:
        {
//            getFileInfo(control.model.get(index).url)
        }
    }

    MenuSeparator{}

    MenuItem
    {
        text: i18n("Copy")
        icon.name: "edit-copy"
        onTriggered:
        {
            Maui.Handy.copyToClipboard({"urls": [control.model.get(index).path]}, false)
        }
    }

    MenuItem
    {
        text: i18n("Remove")
        icon.name: "edit-delete"
        Maui.Theme.textColor: Maui.Theme.negativeTextColor
        onTriggered:
        {
            removeDialog.open()
        }

        Maui.InfoDialog
        {
            id: removeDialog

            title: i18n("Delete File?")
//            acceptButton.text: i18n("Accept")
//            rejectButton.text: i18n("Cancel")
            message: i18n("Are sure you want to delete \n%1", control.model.get(index).path)

            template.iconSource: "emblem-warning"

            onRejected: close()
            onAccepted:
            {
                control.model.list.deleteAt(control.index)
            }
        }
    }
}
