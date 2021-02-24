import QtQuick 2.14
import QtQml 2.14
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.2 as Maui
import org.maui.nota 1.0 as Nota

import QtQuick.Window 2.0
import QtQml.Models 2.3

Maui.Page
{
    id: control
    property alias currentTab : _editorListView.currentItem
    readonly property Maui.Editor currentEditor: currentTab ? currentTab.currentItem : null
    property alias listView: _editorListView
    readonly property alias count: _editorListView.count
    readonly property alias model : _documentModel
    property alias plugin: _pluginLayout

    ObjectModel
    {
        id: _documentModel
    }

    header: Maui.TabBar
    {
        id: _tabBar
        visible: _documentModel.count > 1

        width: parent.width
        position: TabBar.Header
        currentIndex : _editorListView.currentIndex
        onNewTabClicked: editorView.openTab("")

        Repeater
        {
            id: _repeater
            model: _documentModel.count

            Maui.TabButton
            {
                id: _tabButton
                readonly property int index_ : index
                implicitHeight: _tabBar.implicitHeight
                implicitWidth: Math.max(parent.width / _repeater.count, 120)

                checked: index === _tabBar.currentIndex

                text: _documentModel.get(index).title

                onClicked: _editorListView.currentIndex = index
                onCloseClicked:
                {
                    if( tabHasUnsavedFiles(model.index) )
                    {
                        _dialogLoader.sourceComponent = _unsavedDialogComponent
                        dialog.callback = function () { closeTab(model.index) }

                        if(tabHasUnsavedFiles(model.index))
                        {
                            dialog.open()
                            return
                        }
                    }
                    else
                        closeTab(model.index)
                }
            }
        }
    }

    Maui.FloatingButton
    {
        id: _overlayButton
        z: 999
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Maui.Style.toolBarHeightAlt
        anchors.bottomMargin: Maui.Style.toolBarHeight + (root.currentEditor && root.currentEditor.footBar.visible ? root.currentEditor.footBar.height : 0) + (currentTab.terminal ? currentTab.terminal.height : 0)
        height: Maui.Style.toolBarHeight
        width: height

        icon.name: "document-new"
        icon.color: Kirigami.Theme.highlightedTextColor

        onClicked: openTab("")

        Maui.Badge
        {
            anchors
            {
                horizontalCenter: parent.right
                verticalCenter: parent.top
            }

            onClicked: _newDocumentMenu.open()

            Maui.PlusSign
            {
                color: parent.Kirigami.Theme.textColor
                height: 10
                width: height
                anchors.centerIn: parent
            }
        }

        NewFileDialog
        {
            id: _newDocumentMenu
            maxHeight: 300
            maxWidth: 400
         }
    }

    Maui.Page
    {
        anchors.fill: parent
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
//            ToolButton
//            {
//                icon.name: "tool_pen"
//                onClicked: _doodleDialog.open()
//                checked: _doodleDialog.visible
//            },

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

            Maui.ToolActions
            {
                autoExclusive: false
                checkable: false
                expanded: isWide
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

            ListView
            {
                id: _editorListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                orientation: ListView.Horizontal
                model: _documentModel
                snapMode: ListView.SnapOneItem
                spacing: 0
                interactive: Maui.Handy.isTouch && count > 1
                highlightFollowsCurrentItem: true
                highlightMoveDuration: 0
                highlightResizeDuration : 0
                onMovementEnded: currentIndex = indexAt(contentX, contentY)
                cacheBuffer: count
                clip: true
            }
        }
    }

    Maui.Holder
    {
        id: _holder
        visible: !_editorListView.count
        emoji: "qrc:/img/document-edit.svg"
        emojiSize: Maui.Style.iconSizes.huge
        isMask: true
        onActionTriggered: openTab("")
        title: i18n("Create a new document")
        body: i18n("You can create a new document by clicking the New File button, or here.<br>Alternative you can open existing files from the left places sidebar or by clicking the Open button")
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
            _documentModel.append(component.createObject(_documentModel, {"path": path}))
            _historyList.append(path)
            _editorListView.currentIndex = _documentModel.count - 1
        }
    }

    function closeTab(index) //no questions asked
    {
        var item = _documentModel.get(index)
        item.destroy()
        _documentModel.remove(index)
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
