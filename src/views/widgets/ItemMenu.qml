import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.3 as Maui
import org.kde.kirigami 2.8 as Kirigami

Maui.ContextualMenu
{
    id: control

    property bool isFav : false
    property int index : -1
    property Maui.BaseModel model : null

    onOpened: isFav = Maui.FM.isFav(control.model.get(index).path)

    MenuItem
    {
        text: i18n("Select")
        icon.name: "item-select"
        onTriggered:
        {
            if(Kirigami.Settings.isMobile)
                root.selectionMode = true

            addToSelection(control.model.get(index))
        }
    }

    MenuSeparator{}

    MenuItem
    {
        text: i18n(isFav ? "UnFav it": "Fav it")
        icon.name: "love"
        onTriggered: Maui.FM.toggleFav(control.model.get(index).path)
    }

    MenuItem
    {
        text: i18n("Tags")
        icon.name: "tag"
        onTriggered:
        {
            _dialogLoader.sourceComponent = _tagsDialogComponent
            dialog.composerList.urls = [control.model.get(index).path]
            dialog.open()
        }
    }

    MenuItem
    {
        text: i18n("Share")
        icon.name: "document-share"
        onTriggered: Maui.Platform.shareFiles([control.model.get(index).path])
    }

    MenuItem
    {
        text: i18n("Export")
        icon.name: "document-save-as"
        onTriggered:
        {
            var pic = control.model.get(index).path
            _dialogLoader.sourceComponent= _fileDialogComponent
            dialog.mode = dialog.modes.SAVE
            dialog.suggestedFileName= Maui.FM.getFileInfo(control.model.get(index).path).label
            dialog.show(function(paths)
            {
                for(var i in paths)
                    Maui.FM.copy(pic, paths[i])
            });
            close()
        }
    }

    MenuItem
    {
        visible: !Maui.Handy.isAndroid
        text: i18n("Show in folder")
        icon.name: "folder-open"
        onTriggered:
        {
            Maui.FM.openLocation([control.model.get(index).path])
            close()
        }
    }

    MenuItem
    {
        text: i18n("Info")
        icon.name: "documentinfo"
        onTriggered:
        {
//            getFileInfo(control.model.get(index).url)
            close()
        }
    }

    MenuSeparator{}

    MenuItem
    {
        text: i18n("Copy")
        icon.name: "document-copy"
        onTriggered:
        {
            Maui.Handy.copyToClipboard({"urls": [control.model.get(index).path]}, false)
        }
    }

    MenuItem
    {
        text: i18n("Remove")
        icon.name: "edit-delete"
        Kirigami.Theme.textColor: Kirigami.Theme.negativeTextColor
        onTriggered:
        {
            removeDialog.open()
            close()
        }

        Maui.Dialog
        {
            id: removeDialog

            title: i18n("Delete file?")
            acceptButton.text: i18n("Accept")
            rejectButton.text: i18n("Cancel")
            message: i18n("Are sure you want to delete \n%1", control.model.get(index).path)
            page.margins: Maui.Style.space.big
            template.iconSource: "emblem-warning"

            onRejected: close()
            onAccepted:
            {
                control.model.list.deleteAt(control.index)
                close()
            }
        }
    }
}
