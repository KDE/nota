import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab
import org.kde.kirigami 2.7 as Kirigami
import org.maui.nota 1.0 as Nota

SplitView
{
    id: control
    property alias document: _editor.document
    property alias editor: _editor
    property alias body: _editor.body
    property alias footBar: _editor.footBar
    property alias headBar: _editor.headBar
    property alias fileUrl : _editor.fileUrl
    property alias title : _editor.title
    property alias footer : _editor.footer
    property alias header : _editor.header

    property alias terminal : terminalLoader.item

    height: _editorListView.height
    width: _editorListView.width
    spacing: 0
    orientation: Qt.Vertical

    handle: Rectangle
    {
        implicitWidth: 6
        implicitHeight: 6
        color: SplitHandle.pressed ? Kirigami.Theme.highlightColor
                                   : (SplitHandle.hovered ? Qt.lighter(Kirigami.Theme.backgroundColor, 1.1) : Kirigami.Theme.backgroundColor)

        Rectangle
        {
            anchors.centerIn: parent
            width: 48
            height: parent.height
            color: _splitSeparator.color
        }

        Kirigami.Separator
        {
            id: _splitSeparator
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.left: parent.left
        }

        Kirigami.Separator
        {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.left: parent.left
        }
    }


    Maui.Editor
    {
        id: _editor
        SplitView.fillHeight: true
        SplitView.fillWidth: true

        showLineNumbers: root.showLineNumbers
        body.font.family: root.fontFamily
        body.font.pointSize: root.fontSize
        document.backgroundColor: document.enableSyntaxHighlighting ? root.backgroundColor : Kirigami.Theme.backgroundColor
        showSyntaxHighlightingLanguages: root.showSyntaxHighlightingLanguages
        document.theme: root.theme
        document.enableSyntaxHighlighting: root.enableSyntaxHighlighting
        onFileUrlChanged: syncTerminal(control.fileUrl)

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
            //        visible: root.focusMode
            icon.name: "quickview"
            text: qsTr("Focus")
            checked: root.focusMode
            onClicked: root.focusMode = !root.focusMode
        }

        altHeader: Kirigami.Settings.isMobile
        headBar.rightContent:[
            Maui.ToolActions
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
            },

            ToolButton
            {
                icon.name: "tool_pen"
                onClicked: _doodleDialog.open()
                checked: _doodleDialog.visible
            }]

        Keys.enabled: true
        Keys.onPressed:
        {
            if((event.key === Qt.Key_S) && (event.modifiers & Qt.ControlModifier))
            {
                 saveFile(document.fileUrl, _tabBar.currentIndex)
            }

            if(event.key === Qt.F4)
            {
                 toggleTerminal()
            }

            if((event.key === Qt.Key_T) && (event.modifiers & Qt.ControlModifier))
            {
                 syncTerminal(control.fileUrl)
                control.terminal.forceActiveFocus()
            }

            if((event.key === Qt.Key_O) && (event.modifiers & Qt.ControlModifier))
            {
                 openFile()
            }

            if((event.key === Qt.Key_N) && (event.modifiers & Qt.ControlModifier))
            {
                 openTab("")
            }
        }
    }

    Loader
    {
        id: terminalLoader
        active: Nota.Nota.supportsEmbededTerminal()
        visible: active && terminalVisible && terminal
        SplitView.fillWidth: true
        SplitView.preferredHeight: 200
        SplitView.maximumHeight: parent.height * 0.5
        SplitView.minimumHeight : 100
        source: "Terminal.qml"
        onLoaded: syncTerminal(control.fileUrl)

        Behavior on SplitView.preferredHeight
        {
            NumberAnimation
            {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InQuad
            }
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

    function syncTerminal(path)
    {
        if(control.terminal && control.terminal.visible && Maui.FM.fileExists(path))
            control.terminal.session.sendText("cd '" + String(Maui.FM.fileDir(path)).replace("file://", "") + "'\n")
    }
}



