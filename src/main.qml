import QtQuick 2.14
import QtQuick.Controls 2.14

import Qt.labs.settings 1.0

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
    Maui.Style.styleType: Maui.Handy.isAndroid ? (appSettings.darkMode ? Maui.Style.Dark : Maui.Style.Light) : undefined

    readonly property var views : ({editor: 0, recent: 1, documents: 2})

    property alias currentTab : editorView.currentTab
    property alias currentEditor: editorView.currentEditor
    property alias dialog : _dialogLoader.item

    property bool focusMode : false

    property font defaultFont : Qt.font({family: "Noto Sans Mono", pointSize: Maui.Style.fontSizes.default})

    //Global editor props
    property alias appSettings: settings

    //    Maui.WindowBlur
    //    {
    //        view: root
    //        geometry: Qt.rect(root.x, root.y, root.width, root.height)
    //        windowRadius: Maui.Style.radiusV
    //        enabled: !Maui.Handy.isMobile
    //    }

    Settings
    {
        id: settings

        property bool enableSidebar : false
        property bool showLineNumbers : true
        property bool autoSave : true
        property bool enableSyntaxHighlighting : true
        property bool showSyntaxHighlightingLanguages: false
        property bool supportSplit :true
        property double tabSpace: 8
        property string theme : ""
        property string backgroundColor : "white"
        property string textColor : "black"
        property bool darkMode : Maui.Style.styleType === Maui.Style.Dark
        property alias sideBarWidth : _sideBarView.sideBar.preferredWidth
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

    Nota.History
    {
        id: historyList
    }

    Component
    {
        id: _plugingsDialogComponent

        Widgets.PluginsDialog {}
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
        Widgets.SettingsDialog {}
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

    StackView
    {
        id: _stackView
        anchors.fill: parent

        Keys.enabled: true
        Keys.onEscapePressed: _stackView.pop()

        initialItem: Maui.SideBarView
        {
            id: _sideBarView
            sideBar.enabled: settings.enableSidebar
            sideBar.autoHide: true
            sideBar.autoShow: false
            sideBarContent: PlacesSidebar
            {
                id : _drawer
                anchors.fill: parent
            }

            EditorView
            {
                id: editorView
                anchors.fill: parent
            }
        }

        Component
        {
            id: historyViewComponent

            RecentView {}
        }
    }

    Component.onCompleted:
    {
        setAndroidStatusBarColor()
    }

    function setAndroidStatusBarColor()
    {
        if(Maui.Handy.isAndroid)
        {
            Maui.Android.statusbarColor(Maui.Theme.backgroundColor, !appSettings.darkMode)
            Maui.Android.navBarColor(Maui.Theme.backgroundColor, !appSettings.darkMode)
        }
    }

    function syncSidebar(path)
    {
        if(path && FB.FM.fileExists(path) && settings.enableSidebar)
        {
            _drawer.page.browser.openFolder(FB.FM.fileDir(path))
        }
    }

    function openFileDialog()
    {
        _dialogLoader.sourceComponent = _fileDialogComponent
        dialog.mode = dialog.modes.OPEN

        if(root.currentEditor && editorView.currentFileExistsLocally)
        dialog.currentPath = FB.FM.fileDir(root.currentEditor.fileUrl)

        dialog.callback =  function (urls)
        {
            root.openFiles(urls)
        }
        dialog.open()
    }

    function activateWindow()
    {
        console.log("RAISE WINDOW FORM QML")
        root.raise()
        //        root.requ
    }

    function openFile(url : string)
    {
        editorView.openTab(url)
    }

    function openFiles(urls : variant)
    {
        for(var url of urls)
        {
            root.openFile(url)
        }
    }

    function openTab()
    {
        editorView.openTab("")
    }

    function isUrlOpen(url : string) : bool
    {
        return editorView.isUrlOpen(url)
    }

        function focusFile(url : string)
        {
        editorView.openTab(url)
    }
}
