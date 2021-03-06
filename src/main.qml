import QtQuick 2.14
import QtQuick.Controls 2.14

import Qt.labs.settings 1.0

import org.kde.kirigami 2.7 as Kirigami
import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.3 as FB

import org.maui.nota 1.0 as Nota

import "views"
import "views/editor"
import "views/widgets" as Widgets

Maui.ApplicationWindow
{
    id: root
    title: currentEditor ? currentTab.title : ""

    altHeader: Kirigami.Settings.isMobile
    headBar.visible: false

    readonly property var views : ({editor: 0, recent: 1, documents: 2})

    property alias currentTab : editorView.currentTab
    property alias currentEditor: editorView.currentEditor
    property alias dialog : _dialogLoader.item

    property bool focusMode : false

    readonly property font defaultFont:
    {
        family: "Noto Sans Mono"
        pointSize: Maui.Style.fontSizes.default
    }

    //Global editor props
    property alias appSettings: settings

    Settings
    {
        id: settings
        category: "General"

        property bool enableSidebar : false
        property bool showLineNumbers : true
        property bool autoSave : true
        property bool enableSyntaxHighlighting : true
        property bool showSyntaxHighlightingLanguages: false
        property bool supportSplit :true
        property double tabSpace: 8
        property string theme : ""
        property color backgroundColor : root.Kirigami.Theme.backgroundColor
        property color textColor : root.Kirigami.Theme.textColor

        property font font : defaultFont
    }

    onCurrentEditorChanged: syncSidebar(currentEditor.fileUrl)

    onClosing:
    {
        _dialogLoader.sourceComponent = _unsavedDialogComponent

        dialog.callback = function () {root.close()}

        if(!dialog.discard)
        {
            for(var i = 0; i < editorView.count; i++)
            {
                if(editorView.tabHasUnsavedFiles(i))
                {
                    close.accepted = false
                    dialog.open()
                    return
                }
            }
        }

        close.accepted = true
    }

    Widgets.PluginsDialog
    {
        id: _plugingsDialog
    }

    NewFileDialog
    {
        id: _newDocumentMenu
    }

    headBar.leftContent: ToolButton
    {
        visible: settings.enableSidebar
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

    Loader
    {
        id: _dialogLoader
    }

    Component
    {
        id: _unsavedDialogComponent

        Maui.Dialog
        {
            property bool discard : false
            property var callback : ({})
            title: i18n("Unsaved files")
            message: i18n("You have unsaved files. You can go back and save them or choose to discard all changes and exit.")
            page.margins: Maui.Style.space.big
            template.iconSource: "emblem-warning"
            acceptButton.text: i18n("Go back")
            rejectButton.text: i18n("Discard")
            onRejected:
            {
                discard = true

                if(callback instanceof Function)
                {
                    callback()
                }
                close()
            }
            onAccepted: close()
        }
    }

    Component
    {
        id: _settingsDialogComponent
        Widgets.SettingsDialog
        {}
    }

    Component
    {
        id: _shortcutsDialogComponent
        Widgets.ShortcutsDialog {}
    }

    Component
    {
        id: _fileDialogComponent
        FB.FileDialog
        {
            settings.onlyDirs: false
            settings.filterType: FB.FMList.TEXT
            settings.sortBy: FB.FMList.MODIFIED
        }
    }

    Component
    {
        id: _tagsDialogComponent
        FB.TagsDialog
        {
            onTagsReady: composerList.updateToUrls(tags)
            composerList.strict: false
            taglist.strict: false
        }
    }

    sideBar: PlacesSidebar
    {
        id : _drawer
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
                Nota.Nota.requestFiles( _dropArea.urls )
            }
        }
    }

    Component.onCompleted:
    {
        if(Maui.Handy.isAndroid)
        {
            Maui.Android.statusbarColor(headBar.Kirigami.Theme.backgroundColor, false)
            Maui.Android.navBarColor(headBar.visible ? headBar.Kirigami.Theme.backgroundColor : Kirigami.Theme.backgroundColor, false)
        }

        editorView.openTab("")

    }

    StackView
    {
        id: _stackView
        anchors.fill: parent
        focus: true

        initialItem: EditorView
        {
            id: editorView
        }

        RecentView
        {
            id: historyView
            visible: StackView.status === StackView.Active
        }
    }

    Connections
    {
        target: Nota.Nota
        function onOpenFiles(urls)
        {
            for(var i in urls)
                editorView.openTab(urls[i])
        }
    }

    function syncSidebar(path)
    {
        if(path && FB.FM.fileExists(path) && settings.enableSidebar)
        {
            _drawer.browser.openFolder(FB.FM.fileDir(path))
        }
    }

    function openFileDialog()
    {
        _dialogLoader.sourceComponent = _fileDialogComponent
        dialog.mode = dialog.modes.OPEN
        dialog.currentPath = FB.FM.fileDir(root.currentEditor.fileUrl)
        dialog.callback =  function (urls)
        {
            for(var url of urls)
            {
                editorView.openTab(url)
            }
        }
        dialog.open()
    }
}
