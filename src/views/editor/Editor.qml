import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.2 as Maui
import org.kde.kirigami 2.7 as Kirigami
import org.maui.nota 1.0 as Nota

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
    showLineNumbers: settings.showLineNumbers
    body.color: settings.textColor
    body.font.family: settings.font.family
    body.font.pointSize: settings.font.pointSize
    document.backgroundColor: settings.backgroundColor
    showSyntaxHighlightingLanguages: settings.showSyntaxHighlightingLanguages
    document.theme: settings.theme
    document.enableSyntaxHighlighting: settings.enableSyntaxHighlighting
    document.autoSave: settings.autoSave
    document.tabSpace: ((settings.tabSpace+1) * body.font.pointSize) / 2

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

    footBar.visible: showSyntaxHighlightingLanguages

    Keys.enabled: true
    Keys.onPressed:
    {
        if((event.key === Qt.Key_S) && (event.modifiers & Qt.ControlModifier))
        {
            saveFile(document.fileUrl, control)
        }

        if((event.key === Qt.Key_F3) && (event.modifiers & Qt.ControlModifier))
        {
            root.currentTab.split("")
        }

        if(event.key === Qt.Key_F4)
        {
            settings.terminalVisible = !settings.terminalVisible
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
            settings.showLineNumbers = !settings.showLineNumbers
        }
    }

    DropArea
    {
        id: _dropArea
        property var urls : []
        anchors.fill: parent
        onDropped:
        {
            if(drop.urls)
            {
                var m_urls = drop.urls.join(",")
                _dropArea.urls = m_urls.split(",")
                _dropAreaMenu.popup()

                //                Nota.Nota.requestFiles( _dropArea.urls )
            }
        }

        Menu
        {
            id: _dropAreaMenu

            MenuItem
            {
                text: i18n("Open here")
                onTriggered:
                {
                    control.fileUrl = _dropArea.urls[0]
                }
            }

            MenuItem
            {
                text: i18n("Open in new tab")
                onTriggered:
                {
                    Nota.Nota.requestFiles( _dropArea.urls )
                }
            }

            MenuItem
            {
                enabled: _dropArea.urls.length === 1 && currentTab.count <= 1 && settings.supportSplit
                text: i18n("Open in new split")
                onTriggered:
                {
                    currentTab.split(_dropArea.urls[0])
                }
            }

            MenuItem
            {
                text: i18n("Cancel")
            }
        }
    }


    Rectangle
    {
        visible: _splitView.currentIndex === control._index && _splitView.count === 2
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        color: Kirigami.Theme.highlightColor
        height: 8
    }
}
