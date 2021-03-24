import QtQuick 2.14
import QtQml 2.14
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.3 as Maui

import org.maui.nota 1.0 as Nota

import QtQuick.Window 2.0

Maui.Page
{
    id: control

    readonly property alias count: _editorListView.count

    property alias currentTab : _editorListView.currentItem
    readonly property Maui.Editor currentEditor: currentTab ? currentTab.currentItem : null
    property alias listView: _editorListView
    property alias plugin: _pluginLayout
    property alias model : _editorListView.contentModel

    autoHideHeader: root.focusMode

    headBar.leftContent: [

        Maui.ToolActions
        {
            expanded: true
            autoExclusive: false
            checkable: false

            Action
            {
                icon.name: "edit-undo"
                enabled: currentEditor.body.canUndo
                onTriggered: currentEditor.body.undo()
            }

            Action
            {
                icon.name: "edit-redo"
                enabled: currentEditor.body.canRedo
                onTriggered: currentEditor.body.redo()
            }
        },

        Maui.ToolActions
        {
            visible: (currentEditor.document.isRich || currentEditor.body.textFormat === Text.RichText) && !currentEditor.body.readOnly
            expanded: true
            autoExclusive: false
            checkable: false

            Action
            {
                icon.name: "format-text-bold"
                checked: currentEditor.document.bold
                onTriggered: currentEditor.document.bold = !currentEditor.document.bold
            }

            Action
            {
                icon.name: "format-text-italic"
                checked: currentEditor.document.italic
                onTriggered: currentEditor.document.italic = !currentEditor.document.italic
            }

            Action
            {
                icon.name: "format-text-underline"
                checked: currentEditor.document.underline
                onTriggered: currentEditor.document.underline = !currentEditor.document.underline
            }

            Action
            {
                icon.name: "format-text-uppercase"
                checked: currentEditor.document.uppercase
                onTriggered: currentEditor.document.uppercase = !currentEditor.document.uppercase
            }
        }
    ]

    headBar.visible: _editorListView.count > 0
    headBar.middleContent: ToolButton
    {
        //        visible: root.focusMode
        icon.name: checked ? "view-readermode-active" : "view-readermode"
        //            text: i18n("Focus")
        checked: root.focusMode
        onClicked: root.focusMode = !root.focusMode
    }

    altHeader: false
    headBar.rightContent:[

        ToolButton
        {
            icon.name: "terminal"
            visible: settings.supportTerminal && Nota.Nota.supportsEmbededTerminal()
            onClicked: currentTab.toggleTerminal()
            checked: currentTab ? currentTab.terminalVisible : false
        },

        ToolButton
        {
            id: _splitButton
            visible: settings.supportSplit
            icon.name: root.currentTab.orientation === Qt.Horizontal ? "view-split-left-right" : "view-split-top-bottom"
            checked: root.currentTab && root.currentTab.count === 2

            onClicked:
            {
                if(root.currentTab.count === 2)
                {
                    root.currentTab.pop()
                    return
                }//close the innactive split

                root.currentTab.split("")
            }
        },

        ToolButton
        {
            icon.name: "edit-find"
            onClicked:
            {
                currentEditor.showFindBar = !currentEditor.showFindBar
            }
            checked: currentEditor.showFindBar
        },

        Maui.ToolActions
        {
            autoExclusive: false
            checkable: false
            expanded: false
            display: ToolButton.TextBesideIcon
            defaultIconName: "document-save"

            Action
            {
                text: i18n("Save")
                icon.name: "document-save"
                enabled: currentEditor ? currentEditor.document.modified : false
                onTriggered: saveFile( control.currentEditor.fileUrl, control.currentEditor)
            }

            Action
            {
                icon.name: "document-save-as"
                text: i18n("Save as...")
                onTriggered: saveFile("", control.currentEditor)
            }
        }
    ]

    ColumnLayout
    {
        id: _pluginLayout
        anchors.fill: parent
        spacing: 0

        Maui.TabView
        {
            id: _editorListView
            Layout.fillWidth: true
            Layout.fillHeight: true

            holder.emoji: "qrc:/img/document-edit.svg"

            holder.title: i18n("Create a new document")
            holder.body: i18n("You can create or open a new document.")

            onNewTabClicked: control.openTab("")
        }
    }



    function unsavedTabSplits(index) //which split indexes are unsaved
    {
        var indexes = []
        const tab =  control.model.get(index)
        for(var i = 0; i < tab.count; i++)
        {
            if(tab.model.get(i).document.modified)
            {
                indexes.push(i)
            }
        }
        return indexes
    }

    function tabHasUnsavedFiles(index) //if a tab has at least one unsaved file in a split
    {
        return unsavedTabSplits(index).length
    }

    function fileIndex(path) //find the [tab, split] index for a path
    {
        if(path.length === 0)
        {
            return [-1, -1]
        }

        for(var i = 0; i < control.count; i++)
        {
            const tab =  control.model.get(i)
            for(var j = 0; j < tab.count; j++)
            {
                const doc = tab.model.get(j)
                if(doc.fileUrl.toString() === path)
                {
                    return [i, j]
                }
            }
        }
        return [-1,-1]
    }

    function openTab(path)
    {
        _swipeView.currentIndex = views.editor
        const index = fileIndex(path)

        if(index[0] >= 0)
        {
            _editorListView.currentIndex = index[0]
            currentTab.currentIndex = index[1]
            return
        }

        var component = Qt.createComponent("qrc:/views/editor/EditorLayout.qml");
        if (component.status === Component.Ready)
        {
            _editorListView.addTab(component, {"path": path})
            _historyList.append(path)
            _editorListView.incrementCurrentIndex();
        }
    }

    function closeTab(index) //no questions asked
    {
        _editorListView.closeTab(index)
    }

    function saveFile(path, item)
    {
        if(!item)
            return

        if (path && Maui.FM.fileExists(path))
        {
            item.document.saveAs(path)
        } else
        {
            _dialogLoader.sourceComponent = _fileDialogComponent
            dialog.mode = dialog.modes.SAVE;
            //            fileDialog.settings.singleSelection = true
            dialog.callback = function (paths)
            {
                item.document.saveAs(paths[0])
                _historyList.append(paths[0])
            };

            dialog.open()
        }
    }

}
