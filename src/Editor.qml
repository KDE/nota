import QtQuick 2.9
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Maui.Editor
{
    height: _editorListView.height
    width: _editorListView.width

    footBar.visible: true

    footBar.leftContent: Maui.TextField
    {
        placeholderText: qsTr("Find")
        onAccepted:
        {
            console.log("FIND THE QUERY", text)
            document.find(text)
        }
    }

    headBar.rightContent: Maui.ToolActions
    {
        autoExclusive: false
        checkable: false
        expanded: true

        Action
        {
            text: qsTr("Save")
            icon.name: "document-save"
            onTriggered: saveFile(document.fileUrl, _tabBar.currentIndex)
        }

        Action
        {
            icon.name: "document-save-as"
            text: qsTr("Save as...")
            onTriggered: saveFile("", _tabBar.currentIndex)
        }
    }

    function saveFile(path, index)
    {
        if (path && Maui.FM.fileExists(path))
        {
            document.saveAs(path);
        } else
        {
            fileDialog.mode = fileDialog.modes.SAVE;
//            fileDialog.settings.singleSelection = true
            fileDialog.show(function (paths)
            {
                document.saveAs(paths[0]);
                _editorList.update(index, paths[0]);
            });
        }
    }
}
