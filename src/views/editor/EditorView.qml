import QtQuick 2.14
import QtQml 2.14

import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.14 as Kirigami

import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.3 as FB
import org.mauikit.texteditor 1.0 as TE

import org.maui.nota 1.0 as Nota

import QtQuick.Window 2.0

Maui.Page
{
    id: control

    readonly property alias count: _editorListView.count

    property alias currentTab : _editorListView.currentItem
    readonly property TE.TextEditor currentEditor: currentTab ? currentTab.currentItem.editor : null
    property alias listView: _editorListView
    property alias plugin: _pluginLayout
    property alias model : _editorListView.contentModel
    property alias tabView : _editorListView

    altHeader: Kirigami.Settings.isMobile
    headBar.visible: _editorListView.count > 0
    headBar.forceCenterMiddleContent: false

    title: currentTab.title
    showTitle: false

    headerColorSet: altHeader ? Kirigami.Theme.Window : Kirigami.Theme.Header
    headBar.farLeftContent: Maui.ToolButtonMenu
    {
        id: menuBtn
        icon.name: "application-menu"

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
            onTriggered: _plugingsDialog.open()
        }

        MenuItem
        {
            text: i18n("About")
            icon.name: "documentinfo"
            onTriggered: root.about()
        }
    }

    headBar.farRightContent: ToolButton
    {
        icon.name: "list-add"
        onClicked:
        {
            _newDocumentMenu.open()
        }
    }

    headBar.middleContent:  Item
    {
        Layout.fillWidth: true
        Layout.maximumWidth: 500
        implicitHeight: Maui.Style.rowHeight

        RowLayout
        {
            spacing: 2
            anchors.fill: parent

            AbstractButton
            {
                enabled: currentEditor.body.canUndo
                focusPolicy: Qt.NoFocus

                Layout.fillHeight: true
                implicitWidth: height * 1.2

                background: Kirigami.ShadowedRectangle
                {
                    color: Qt.lighter(Kirigami.Theme.backgroundColor)

                    corners
                    {
                        topLeftRadius: Maui.Style.radiusV
                        topRightRadius: 0
                        bottomLeftRadius: Maui.Style.radiusV
                        bottomRightRadius: 0
                    }
                }
                onClicked: currentEditor.body.undo()

                Kirigami.Icon
                {
                    anchors.centerIn: parent
                    source: "edit-undo"
                    implicitHeight: Maui.Style.iconSizes.small
                    implicitWidth: implicitHeight
                }
            }

            AbstractButton
            {
                id: _docBar
                Layout.fillWidth: true
                Layout.fillHeight: true

                background: Rectangle
                {
                    color: Qt.lighter(Kirigami.Theme.backgroundColor)                    
                    border.width: 1
                    border.color: _docMenu.visible ? Kirigami.Theme.highlightColor : color
                }

                contentItem: Maui.ListItemTemplate
                {
                    anchors.fill: parent
                    spacing: 0
                    label1.horizontalAlignment: Qt.AlignHCenter
                    label2.horizontalAlignment: Qt.AlignHCenter
                    label1.text: currentEditor.title
                    label2.text: currentEditor.fileUrl
                    label2.font.pointSize: Maui.Style.fontSizes.small

                    Kirigami.Icon
                    {
                        source: "go-down"
                        implicitHeight: Maui.Style.iconSizes.small
                        implicitWidth: implicitHeight
                    }
                }

                onClicked: _docMenu.show(0, height + Maui.Style.space.medium)

                Maui.ContextualMenu
                {
                    id: _docMenu

                    MenuItem
                    {
                        icon.name: "edit-redo"
                        text: i18n("Redo")
                        enabled: currentEditor.body.canRedo
                        onTriggered: currentEditor.body.redo()
                    }

                    MenuSeparator {}

                    MenuItem
                    {
                        text: i18n("Save")
                        icon.name: "document-save"
                        enabled: currentEditor ? currentEditor.document.modified : false
                        onTriggered: saveFile( control.currentEditor.fileUrl, control.currentEditor)
                    }

                    MenuItem
                    {
                        icon.name: "document-save-as"
                        text: i18n("Save as...")
                        onTriggered: saveFile("", control.currentEditor)
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
                            currentEditor.showLineCount = checked
                        }

                        checked: currentEditor.showLineCount
                    }

                    MenuSeparator {}

                    MenuItem
                    {
                        text: i18n("Share")
                        icon.name: "document-share"
                        onTriggered: Maui.Platform.shareFiles([currentEditor.fileUrl])

                    }

                    MenuItem
                    {
                        text: i18n("Open with")
                        icon.name: "document-open"
                    }

                    MenuItem
                    {
                        visible: !Maui.Handy.isAndroid
                        text: i18n("Show in folder")
                        icon.name: "folder-open"
                        onTriggered:
                        {
                            FB.FM.openLocation([currentEditor.fileUrl])
                        }
                    }

                    MenuItem
                    {
                        text: i18n("Info")
                        icon.name: "documentinfo"
                        onTriggered:
                        {
                //            getFileInfo(control.model.get(index).url)
                        }
                    }

                    MenuItem
                    {
                        property bool isFav: FB.Tagging.isFav(currentEditor.fileUrl)
                        text: i18n(isFav ? "UnFav it": "Fav it")
                        icon.name: "love"
                        onTriggered:
                        {
                            FB.Tagging.toggleFav(currentEditor.fileUrl)
                            isFav = FB.Tagging.isFav(currentEditor.fileUrl)
                        }
                    }
                }
            }

            AbstractButton
            {
                focusPolicy: Qt.NoFocus

                Layout.fillHeight: true
                implicitWidth: height

                background: Kirigami.ShadowedRectangle
                {
                    color: Qt.lighter(Kirigami.Theme.backgroundColor)

                    corners
                    {
                        topLeftRadius: 0
                        topRightRadius: Maui.Style.radiusV
                        bottomLeftRadius: 0
                        bottomRightRadius: Maui.Style.radiusV
                    }
                }

                onClicked: _overflowMenu.show()

                Kirigami.Icon
                {
                    anchors.centerIn: parent
                    source: "overflow-menu"
                    implicitHeight: Maui.Style.iconSizes.small
                    implicitWidth: implicitHeight
                }

                Maui.ContextualMenu
                {
                    id: _overflowMenu

                    MenuItem
                    {
                        icon.name: checked ? "view-readermode-active" : "view-readermode"
                        text: i18n("Focus Mode")
                        checked: root.focusMode
                        checkable: true
                        onTriggered: root.focusMode = !root.focusMode
                    }

                    MenuItem
                    {
                        text: i18n("Terminal")
                        icon.name: "dialog-scripts"

                        onTriggered: currentTab.toggleTerminal()
                        checkable: true
                        checked: currentTab ? currentTab.terminalVisible : false
                    }

                    MenuItem
                    {
                        visible: settings.supportSplit
                        text: root.currentTab.orientation === Qt.Horizontal ? i18n("Split Horizontally") : i18n("Split Vertically")
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

                    MenuSeparator {}

                }
            }
        }
    }

    headBar.leftContent: [

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
        Nota.History.append(path)

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
                Nota.History.append(paths[0])
            };

            dialog.open()
        }
    }
}
