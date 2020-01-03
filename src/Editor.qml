import QtQuick 2.9
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Maui.Editor
{
    height: _editorList.height
    width: _editorList.width

    footBar.visible: false

    headBar.rightContent: Kirigami.ActionToolBar
    {
        position: ToolBar.Header
        Layout.fillWidth: true
        //        hiddenActions: t_actions

        display: isWide ? ToolButton.TextBesideIcon : ToolButton.IconOnly

        actions :[
            Kirigami.Action
            {
                id: saveBtn
                icon.name: "document-save"
                onTriggered: {
                    saveFile(document.fileUrl)
                }
            },

            Kirigami.Action
            {
                icon.name: "document-save-as"
                text: "Save as..."
                onTriggered: saveFile()
            }
        ]
    }

    function saveFile(path)
    {
        if (path && Maui.FM.fileExists(path))
        {
            document.saveAs(path);
        } else
        {
            fileDialog.mode = fileDialog.modes.SAVE;
            fileDialog.singleSelection = true
            fileDialog.show(function (paths) {

                console.log("save as", paths)

                document.saveAs(paths[0]);
                setTabMetadata(paths[0]);
            });
        }
    }
}
