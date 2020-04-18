import QtQuick 2.9
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Maui.Editor
{
    height: _editorListView.height
    width: _editorListView.width

    showLineNumbers: root.showLineNumbers
    body.font.family: root.fontFamily
    body.font.pointSize: root.fontSize
    document.backgroundColor: document.enableSyntaxHighlighting ? root.backgroundColor : Kirigami.Theme.backgroundColor
    showSyntaxHighlightingLanguages: root.showSyntaxHighlightingLanguages
    document.theme: root.theme
    document.enableSyntaxHighlighting: root.enableSyntaxHighlighting

//    floatingHeader: root.focusMode
    autoHideHeader: root.focusMode

    footBar.visible: false
    footBar.leftContent: Maui.TextField
    {
        placeholderText: qsTr("Find")
        onAccepted:
        {
            console.log("FIND THE QUERY", text)
            document.find(text)
        }
    }
    headBar.middleContent: Button
    {
        visible: root.focusMode
        text: qsTr("Focus")
        checked: root.focusMode
        onClicked: root.focusMode = false
    }

    altHeader: Kirigami.Settings.isMobile
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
            _dialogLoader.sourceComponent = _fileDialogComponent
            dialog.mode = dialog.modes.SAVE;
//            fileDialog.settings.singleSelection = true
            dialog.show(function (paths)
            {
                document.saveAs(paths[0]);
                _editorList.update(index, paths[0]);
            });
        }
    }
}
