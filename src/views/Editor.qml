import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab
import org.kde.kirigami 2.7 as Kirigami
import QtQml.Models 2.3

Maui.Editor
{
    id: control
    readonly property int _index : ObjectModel.index

    SplitView.fillHeight: true
    SplitView.fillWidth: true
    SplitView.preferredHeight: _splitView.orientation === Qt.Vertical ? _splitView.height / (_splitView.count) :  _splitView.height
    SplitView.minimumHeight: _splitView.orientation === Qt.Vertical ?  200 : 0


    SplitView.preferredWidth: _splitView.orientation === Qt.Horizontal ? _splitView.width / (_splitView.count) : _splitView.width
    SplitView.minimumWidth: _splitView.orientation === Qt.Horizontal ? 300 :  0

    opacity: _splitView.currentIndex === _index ? 1 : 0.7

    headBar.visible: false
    showLineNumbers: root.showLineNumbers
    body.color: root.textColor
    body.font.family: root.font.family
    body.font.pointSize: root.font.pointSize
    document.backgroundColor: root.backgroundColor
    showSyntaxHighlightingLanguages: root.showSyntaxHighlightingLanguages
    document.theme: root.theme
    document.enableSyntaxHighlighting: root.enableSyntaxHighlighting
    onFileUrlChanged: syncTerminal(control.fileUrl)

    MouseArea
    {
        anchors.fill: parent
        propagateComposedEvents: true
        //        hoverEnabled: true
        //        onEntered: _splitView.currentIndex = control.index
        onPressed:
        {
            _splitView.currentIndex = control._index
            mouse.accepted = false
        }
    }

    footBar.visible: false
    footBar.leftContent: [

        Maui.TextField
        {
            id: _findField
            placeholderText: qsTr("Find")
            onAccepted:
            {
                console.log("FIND THE QUERY", text)
                document.find(text)
            }
        },

        Maui.TextField
        {
            placeholderText: qsTr("Replace")
        },

        Button
        {
            text: qsTr("Replace")
        }

    ]


    Keys.enabled: true
    Keys.onPressed:
    {
        if((event.key === Qt.Key_S) && (event.modifiers & Qt.ControlModifier))
        {
            saveFile(document.fileUrl, _tabBar.currentIndex)
        }

        if((event.key === Qt.Key_F3) && (event.modifiers & Qt.ControlModifier))
        {
            root.currentTab.split("", Qt.Vertical)
        }

        if(event.key === Qt.Key_F4)
        {
            root.terminalVisible = !root.terminalVisible
            Maui.FM.saveSettings("TERMINAL", terminalVisible, "EXTENSIONS")
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

        if((event.key === Qt.Key_L) && (event.modifiers & Qt.ControlModifier))
        {
            root.showLineNumbers = !root.showLineNumbers
        }

        if((event.key === Qt.Key_F) && (event.modifiers & Qt.ControlModifier))
        {
            footBar.visible = !footBar.visible
            if(footBar.visible)
            {
                _findField.forceActiveFocus()
            }else
            {
                editor.forceActiveFocus()
            }
        }
    }
}
