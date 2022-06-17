import QtQuick 2.14
import QtQuick.Controls 2.14

import org.mauikit.controls 1.3 as Maui
import org.mauikit.texteditor 1.0 as TE

import org.maui.nota 1.0 as Nota

Maui.SplitViewItem
{
    id: control

    property alias editor : _editor
    property alias fileUrl : _editor.fileUrl
    property alias title : _editor.title

    TE.TextEditor
    {
        id: _editor
        anchors.fill: parent

        headBar.visible: false
        showLineNumbers: settings.showLineNumbers
        body.color: settings.textColor
        body.font.family: settings.font.family
        body.font.pointSize: settings.font.pointSize
        document.backgroundColor: settings.backgroundColor
        Maui.Theme.backgroundColor: settings.backgroundColor
        document.theme: settings.theme
        document.enableSyntaxHighlighting: settings.enableSyntaxHighlighting
        document.autoSave: settings.autoSave
        document.tabSpace: ((settings.tabSpace+1) * body.font.pointSize) / 2

        onFileUrlChanged: syncTerminal(_editor.fileUrl)

        footBar.visible: settings.showSyntaxHighlightingLanguages
        footBar.rightContent: ComboBox
        {
            model: editor.document.getLanguageNameList()
            currentIndex: -1
            onCurrentIndexChanged: editor.document.formatName = model[currentIndex]
        }

        Keys.enabled: true
        Keys.onPressed:
        {
            if((event.key === Qt.Key_S) && (event.modifiers & Qt.ControlModifier))
            {
                saveFile(document.fileUrl, _editor)
                event.accepted = true
            }

            if((event.key === Qt.Key_T) && (event.modifiers & Qt.ControlModifier))
            {
                syncTerminal(_editor.fileUrl)
                _editor.terminal.forceActiveFocus()
                event.accepted = true
            }

            if((event.key === Qt.Key_O) && (event.modifiers & Qt.ControlModifier))
            {
                openFile()
                event.accepted = true
            }

            if((event.key === Qt.Key_N) && (event.modifiers & Qt.ControlModifier))
            {
                openTab("")
                event.accepted = true
            }

            if((event.key === Qt.Key_L) && (event.modifiers & Qt.ControlModifier))
            {
                settings.showLineNumbers = !settings.showLineNumbers
                event.accepted = true
            }
        }

        Loader
        {
            asynchronous: true
            anchors.fill: parent

            sourceComponent:  DropArea
            {
                id: _dropArea
                property var urls : []
                onDropped:
                {
                    if(drop.urls)
                    {
                        var m_urls = drop.urls.join(",")
                        _dropArea.urls = m_urls.split(",")
                        _dropAreaMenu.show()
                    }
                }

                Maui.ContextualMenu
                {
                    id: _dropAreaMenu

                    MenuItem
                    {
                        text: i18n("Open here")
                        icon.name : "open-for-editing"
                        onTriggered:
                        {
                            _editor.fileUrl = _dropArea.urls[0]
                        }
                    }

                    MenuItem
                    {
                        text: i18n("Open in new tab")
                        icon.name: "tab-new"
                        onTriggered:
                        {
                            Nota.Nota.requestFiles( _dropArea.urls )
                        }
                    }

                    MenuItem
                    {
                        enabled: _dropArea.urls.length === 1 && currentTab.count <= 1 && settings.supportSplit
                        text: i18n("Open in new split")
                        icon.name: "view-split-left-right"
                        onTriggered:
                        {
                            currentTab.split(_dropArea.urls[0])
                        }
                    }

                    MenuSeparator{}

                    MenuItem
                    {
                        text: i18n("Cancel")
                        icon.name: "dialog-cancel"
                        onTriggered:
                        {
                            _dropAreaMenu.close()
                        }
                    }

                    onClosed: _editor.forceActiveFocus()
                }
            }
        }
    }

    Component.onCompleted:
    {
        _editor.forceActiveFocus()
    }
}
