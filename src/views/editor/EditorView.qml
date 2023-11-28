import QtQuick 2.14
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.3 as FB
import org.mauikit.texteditor 1.0 as TE

import org.maui.nota 1.0 as Nota

Pane
{
    id: control

    readonly property alias count: _tabView.count

    readonly property alias currentTab : _tabView.currentItem
    readonly property bool currentFileExistsLocally : FB.FM.fileExists(control.currentEditor.fileUrl)
    readonly property TE.TextEditor currentEditor: currentTab ? currentTab.currentItem.editor : null

    readonly property alias listView: _tabView
    readonly property alias plugin: _pluginLayout
    readonly property alias model : _tabView.contentModel
    readonly property alias tabView : _tabView

    padding: 0

    Action
    {
        id: _openFileAction
        icon.name: "folder-open"
        text: i18n("Open Files")
        onTriggered:
        {
            openFileDialog()
        }
    }

    Action
    {
        id: _openRecentFileAction
        icon.name: "folder-recent"
        text: i18n("Open Recent Files")
        onTriggered:
        {
            _stackView.push(historyViewComponent)
        }
    }

    Action
    {
        id: _newFileAction
        icon.name: "list-add"
        text: i18n("New")
        onTriggered:
        {
            editorView.openTab("")
        }
    }

    contentItem: ColumnLayout
    {
        id: _pluginLayout
        spacing: 0

        Maui.TabView
        {
            id: _tabView
            Layout.fillWidth: true
            Layout.fillHeight: true

            altTabBar: !root.isWide

            holder.emoji: "qrc:/img/document-edit.svg"

            holder.title: i18n("Create a New Document")
            holder.body: i18n("You can create or open a new document.")
            holder.actions: [_newFileAction, _openFileAction, _openRecentFileAction]

            tabBar.visible: true
            tabBar.showNewTabButton: false
            tabBar.leftContent: Loader
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

            tabBar.rightContent: [

                ToolButton
                {
                    text: _tabView.count
                    visible: _tabView.count > 1
                    font.bold: true
                    font.pointSize: Maui.Style.fontSizes.small
                    onClicked: _tabView.openOverview()
                    background: Rectangle
                    {
                        color: Maui.Theme.alternateBackgroundColor
                        radius: Maui.Style.radiusV
                    }
                },

                Loader
                {
                    asynchronous: true
                    sourceComponent: Maui.ToolButtonMenu
                    {
                        icon.name: "list-add"

                        MenuItem
                        {
                            action: _newFileAction
                        }

                        MenuItem
                        {
                            action: _openFileAction
                        }

                        MenuItem
                        {
                            action: _openRecentFileAction
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
                                text: i18n("Split View")
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
                },

                Maui.WindowControls {}
            ]

            tabViewButton: Maui.TabViewButton
            {
                id:  _tabButton
                tabView: _tabView
                onClicked:
                {
                    if(_tabButton.mindex === _tabView.currentIndex)
                    {
                        _docMenuLoader.item.show((width*0.5)-(_docMenuLoader.item.width*0.5), height + Maui.Style.space.medium)
                        return
                    }

                    _tabView.setCurrentIndex(_tabButton.mindex)
                    _tabView.currentItem.forceActiveFocus()
                }

                rightContent: Maui.Icon
                {
                    visible: _tabButton.checked
                    source: "overflow-menu"
                    height: Maui.Style.iconSizes.small
                    width: height
                }

                onCloseClicked:
                {
                    _tabView.closeTabClicked(_tabButton.mindex)
                }

                Component
                {
                    id: _infoDialogComponent

                    Maui.PopupPage
                    {
                        id: _infoDialog
                        property var info: FB.FM.getFileInfo(currentEditor.fileUrl)

                        onClosed: destroy()
                        Maui.SectionItem
                        {
                            label1.text: i18n("Name")
                            label2.text: _infoDialog.info.name
                        }

                        Maui.SectionItem
                        {
                            label1.text: i18n("Date")
                            label2.text: _infoDialog.info.date
                        }

                        Maui.SectionItem
                        {
                            label1.text: i18n("Modified")
                            label2.text: _infoDialog.info.modified
                        }

                        Maui.SectionItem
                        {
                            label1.text: i18n("Size")
                            label2.text: Maui.Handy.formatSize(_infoDialog.info.size)
                        }

                        Maui.SectionItem
                        {
                            label1.text: i18n("Type")
                            label2.text:_infoDialog.info.mime
                        }
                    }
                }

                Component
                {
                    id: _goToLineDialogComponent

                    Maui.InputDialog
                    {
                        title: i18n("Go to Line")
                        textEntry.text: currentEditor.document.currentLineIndex+1
                        textEntry.placeholderText: i18n("Line number")
                        onFinished: currentEditor.goToLine(text)
                    }
                }

                Component
                {
                    id: _removeDialogComponent

                    Maui.InfoDialog
                    {

                        title: i18n("Delete File?")
                        message: i18n("Are sure you want to delete \n%1", currentEditor.fileUrl)

                        standardButtons: Dialog.Yes | Dialog.Cancel

                        template.iconSource: "dialog-question"
                        template.iconVisible: true

                        onRejected: close()
                        onAccepted:
                        {
                            FB.FM.deleteFile(currentEditor.fileUrl)
                        }
                    }
                }

                Loader
                {
                    id: _docMenuLoader
                    asynchronous: true
                    sourceComponent: Maui.ContextualMenu
                    {
                        Maui.MenuItemActionRow
                        {
                            Action
                            {
                                icon.name: "edit-undo"
                                text: i18n("Undo")
                                enabled: currentEditor.body.canUndo
                                onTriggered: currentEditor.body.undo()
                            }

                            Action
                            {
                                icon.name: "edit-redo"
                                text: i18n("Redo")
                                enabled: currentEditor.body.canRedo
                                onTriggered: currentEditor.body.redo()
                            }


                            Action
                            {
                                text: i18n("Save")
                                icon.name: "document-save"
                                enabled: currentEditor ? currentEditor.document.modified : false
                                onTriggered: saveFile(currentEditor.fileUrl, currentEditor)
                            }

                            Action
                            {
                                icon.name: "document-save-as"
                                text: i18n("Save as")
                                onTriggered: saveFile("", currentEditor)
                            }
                        }

                        MenuSeparator {}

                        MenuItem
                        {
                            icon.name: "edit-find"
                            text: i18n("Find and Replace")
                            checkable: true

                            onTriggered:
                            {
                                currentEditor.showFindBar = !currentEditor.showFindBar
                            }
                            checked: currentEditor.showFindBar
                        }

                        MenuItem
                        {
                            icon.name: "document-edit"
                            text: i18n("Line/Word Counter")
                            checkable: true

                            onTriggered:
                            {
                                settings.showWordCount = !settings.showWordCount
                            }

                            checked: settings.showWordCount
                        }

                        MenuSeparator {}

                        Maui.MenuItemActionRow
                        {
                            Action
                            {
                                property bool isFav: FB.Tagging.isFav(currentEditor.fileUrl)
                                text: i18n(isFav ? "UnFav it": "Fav it")
                                checked: isFav
                                checkable: true
                                icon.name: "love"
                                enabled: currentFileExistsLocally
                                onTriggered:
                                {
                                    FB.Tagging.toggleFav(currentEditor.fileUrl)
                                    isFav = FB.Tagging.isFav(currentEditor.fileUrl)
                                }
                            }

                            Action
                            {
                                enabled: currentFileExistsLocally
                                text: i18n("Info")
                                icon.name: "documentinfo"
                                onTriggered:
                                {

                                    var dialog = _infoDialogComponent.createObject(control)
                                    dialog.open()

                                }
                            }

                            Action
                            {
                                text: i18n("Share")
                                enabled: currentFileExistsLocally
                                icon.name: "document-share"
                                onTriggered: Maui.Platform.shareFiles([currentEditor.fileUrl])

                            }
                        }

                        MenuSeparator {}

                        MenuItem
                        {
                            icon.name: "go-jump"
                            text: i18n("Go to Line")

                            onTriggered:
                            {
                                _dialogLoader.sourceComponent = _goToLineDialogComponent
                                dialog.open()
                            }
                        }

                        MenuItem
                        {
                            enabled: currentFileExistsLocally
                            text: i18n("Show in Folder")
                            icon.name: "folder-open"
                            onTriggered:
                            {
                                FB.FM.openLocation([currentEditor.fileUrl])
                            }
                        }

                        MenuItem
                        {
                            text: i18n("Delete File")
                            icon.name: "edit-delete"
                            enabled: currentFileExistsLocally
                            Maui.Theme.textColor: Maui.Theme.negativeTextColor

                            onTriggered:
                            {
                                _dialogLoader.sourceComponent = _removeDialogComponent
                                dialog.open()
                            }
                        }
                    }
                }
            }

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
                {
                    closeTab(index)
                }
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
            _tabView.currentIndex = index[0]
            currentTab.currentIndex = index[1]
            return
        }

        _tabView.addTab(_editorLayoutComponent, {"path": path})
        historyList.append(path)
    }

    function closeTab(index) //no questions asked
    {
        _tabView.closeTab(index)
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

    function isUrlOpen(url : string) : bool
    {
        return fileIndex(url)[0] >= 0;
    }
    }
