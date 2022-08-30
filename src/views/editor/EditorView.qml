import QtQuick 2.14
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.3 as FB
import org.mauikit.texteditor 1.0 as TE

import org.maui.nota 1.0 as Nota

Maui.Page
{
    id: control

    readonly property alias count: _editorListView.count

    property alias currentTab : _editorListView.currentItem
    readonly property bool currentFileExistsLocally : FB.FM.fileExists(control.currentEditor.fileUrl)
    readonly property TE.TextEditor currentEditor: currentTab ? currentTab.currentItem.editor : null
    property alias listView: _editorListView
    property alias plugin: _pluginLayout
    property alias model : _editorListView.contentModel
    property alias tabView : _editorListView

    altHeader: Maui.Handy.isMobile
    headBar.visible: _editorListView.count > 0
    autoHideHeader: focusMode
    headBar.forceCenterMiddleContent: root.isWide

    title: currentTab.title
    showTitle: false
    showCSDControls: true

    headBar.leftContent: Loader
    {
        active: settings.enableSidebar
        visible: active
        asynchronous: true

        sourceComponent: ToolButton
        {
            icon.name: _sideBarView.sideBar.visible ? "sidebar-collapse" : "sidebar-expand"
            onClicked: _sideBarView.sideBar.toggle()

            text: i18n("Places")
            display: isWide ? ToolButton.TextBesideIcon : ToolButton.IconOnly

            checked: _sideBarView.sideBar.visible

            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered
            ToolTip.text: i18n("Toogle SideBar")
        }
    }

    headBar.farRightContent: Maui.ToolButtonMenu
    {
        icon.name: "list-add"

        MenuItem
        {
            icon.name: "folder-open"
            text: i18n("Open Files")
            onTriggered:
            {
                 openFileDialog()
            }
        }

        MenuItem
        {
            icon.name: "folder-recent"
            text: i18n("Open Recent Files")
            onTriggered:
            {
               _stackView.push(historyViewComponent)
            }
        }

        MenuItem
        {
            icon.name: "list-add"
            text: i18n("New")
            onTriggered:
            {
                editorView.openTab("")
            }
        }

        MenuSeparator {}

        Maui.MenuItemActionRow
        {
            Action
            {
                icon.name: checked ? "view-readermode-active" : "view-readermode"
                text: i18n("Focus")
                checked: root.focusMode
                checkable: true
                onTriggered: root.focusMode = !root.focusMode
            }

            Action
            {
                text: i18n("Terminal")
                icon.name: "dialog-scripts"
                enabled: Maui.Handy.isLinux
                onTriggered: currentTab.toggleTerminal()
                checkable: true
                checked: currentTab ? currentTab.terminalVisible : false
            }

            Action
            {
                enabled: settings.supportSplit
                text: i18n("Split")
                icon.name: root.currentTab.orientation === Qt.Horizontal ? "view-split-left-right" : "view-split-top-bottom"
                checked: root.currentTab && root.currentTab.count === 2
                checkable: true
                onTriggered:
                {
                    if(root.currentTab.count === 2)
                    {
                        root.currentTab.pop()
                        return
                    }//close the inactive split

                    root.currentTab.split("")
                }
            }
        }

        MenuSeparator {}

        MenuItem
        {
            text: i18n("Shortcuts")
            icon.name: "configure-shortcuts"
            onTriggered:
            {
                _dialogLoader.sourceComponent = _shortcutsDialogComponent
                dialog.open()
            }
        }

        MenuItem
        {
            text: i18n("Settings")
            icon.name: "settings-configure"
            onTriggered:
            {
                _dialogLoader.sourceComponent = _settingsDialogComponent
                dialog.open()
            }
        }

        MenuItem
        {
            text: i18n("Plugins")
            icon.name: "system-run"
            onTriggered:
            {
                _dialogLoader.sourceComponent = _plugingsDialogComponent
                dialog.open()
            }
        }

        MenuItem
        {
            text: i18n("About")
            icon.name: "documentinfo"
            onTriggered: root.about()
        }
    }

    headBar.middleContent: Loader
    {
        Layout.fillWidth: true
        Layout.maximumWidth: 500
        Layout.alignment: Qt.AlignCenter

        asynchronous: true
        sourceComponent: EditorBar {}
    }

//    Loader
//    {
//        anchors.fill: parent
//        asynchronous: true
//        sourceComponent: DropArea
//        {
//            id: _dropArea
//            property var urls : []
//            onDropped:
//            {
//                if(drop.urls)
//                {
//                    var m_urls = drop.urls.join(",")
//                    _dropArea.urls = m_urls.split(",")
//                    Nota.Nota.requestFiles( _dropArea.urls )
//                }
//            }
//        }
//    }

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
            onCloseTabClicked:
            {
                if( tabHasUnsavedFiles(index) )
                {
                    _dialogLoader.sourceComponent = _unsavedDialogComponent
                    dialog.callback = function () { closeTab(index) }

                    if(tabHasUnsavedFiles(index))
                    {
                        dialog.open()
                        return
                    }
                }
                else
                    closeTab(index)
            }
        }
    }

    Component
    {
        id: _editorLayoutComponent
        EditorLayout {}
    }

    function unsavedTabSplits(index) //which split indexes are unsaved
    {
        var indexes = []
        const tab =  control.model.get(index)
        for(var i = 0; i < tab.count; i++)
        {
            if(tab.model.get(i).editor.document.modified)
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
        if(_stackView.depth === 2)
        {
            _stackView.pop()
        }

        const index = fileIndex(path)

        if(index[0] >= 0)
        {
            _editorListView.currentIndex = index[0]
            currentTab.currentIndex = index[1]
            return
        }

        _editorListView.addTab(_editorLayoutComponent, {"path": path})
        historyList.append(path)
    }

    function closeTab(index) //no questions asked
    {
        _editorListView.closeTab(index)
    }

    function saveFile(path, item)
    {
        if(!item)
            return

        if (path && FB.FM.fileExists(path))
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
                historyList.append(paths[0])
            };

            dialog.open()
        }
    }
}
