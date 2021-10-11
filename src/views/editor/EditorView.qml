import QtQuick 2.14
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.14 as Kirigami

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

    altHeader: Kirigami.Settings.isMobile
    headBar.visible: _editorListView.count > 0
    autoHideHeader: focusMode
    headBar.forceCenterMiddleContent: root.isWide

    title: currentTab.title
    showTitle: false
    showCSDControls: true

    headerColorSet: altHeader ? Kirigami.Theme.Window : Kirigami.Theme.Header

    headBar.leftContent: Loader
    {
        active: settings.enableSidebar
        visible: active
        asynchronous: true

        sourceComponent: ToolButton
        {
            icon.name: _drawer.visible ? "sidebar-collapse" : "sidebar-expand"
            onClicked: _drawer.toggle()

            text: i18n("Places")
            display: isWide ? ToolButton.TextBesideIcon : ToolButton.IconOnly

            checked: _drawer.visible

            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered
            ToolTip.text: i18n("Toogle SideBar")
        }
    }

    headBar.farRightContent: ToolButton
    {
        icon.name: "list-add"
        onClicked:
        {
            _dialogLoader.sourceComponent = _newDocumentDialogComponent
            dialog.open()
        }
    }

    headBar.middleContent: Loader
    {
        Layout.fillWidth: true
        Layout.maximumWidth: 500
        asynchronous: true
        sourceComponent: EditorBar {}
    }

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
