import QtQuick
import QtCore

import QtQuick.Controls


import org.mauikit.controls as Maui
import org.mauikit.filebrowsing as FB

import org.maui.nota as Nota

import "views"
import "views/editor"
import "views/widgets" as Widgets

Maui.ApplicationWindow
{
    id: root

    title: currentEditor ? currentTab.title : ""

    readonly property alias currentTab : editorView.currentTab
    readonly property alias currentEditor: editorView.currentEditor

    readonly property font defaultFont : Maui.Style.monospacedFont
    readonly property alias appSettings: settings

    property bool focusMode : false
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
        property bool showWordCount: false
        property bool autoSave : true
        property bool enableSyntaxHighlighting : true
        property bool showSyntaxHighlightingLanguages: false
        property bool supportSplit :true
        property double tabSpace: 8
        property string theme : ""
        property string backgroundColor : "white"
        property string textColor : "black"
        property alias sideBarWidth : _sideBarView.sideBar.preferredWidth
        property font font : defaultFont
        property bool syncTerminal: true
        property bool terminalFollowsColorScheme: true
        property string terminalColorScheme: "Maui-Dark"
        property bool wrapText: true
    }

    //    onCurrentEditorChanged: syncSidebar(currentEditor.fileUrl)

    onClosing: (close) =>
               {
                   _closeDialog.callback = function ()
                   {
                       _closeDialog.discard = true
                       root.close()
                   }

                   if(!_closeDialog.discard)
                   {
                       for(var i = 0; i < editorView.count; i++)
                       {
                           if(editorView.tabHasUnsavedFiles(i))
                           {
                               close.accepted = false
                               _closeDialog.open()
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

    Maui.InfoDialog
    {
        id: _closeDialog
        property bool discard : false
        property var callback : ({})

        title: i18n("Unsaved files")
        message: i18n("You have unsaved files. You can go back and save them or choose to discard all changes and exit.")

        template.iconSource: "dialog-warning"
        template.iconVisible: true

        standardButtons: Dialog.Ok | Dialog.Discard
        onDiscarded:
        {
            close()

            if(callback instanceof Function)
            {
                callback()
            }
        }
        onAccepted: close()
    }


    Component
    {
        id: _settingsDialogComponent
        Widgets.SettingsDialog
        {
            onClosed: destroy()
        }
    }

    Component
    {
        id: _shortcutsDialogComponent
        Widgets.ShortcutsDialog
        {
            onClosed: destroy()
        }
    }

    Component
    {
        id: _fileDialogComponent
        FB.FileDialog
        {
            browser.settings.onlyDirs: false
            browser.settings.filterType: FB.FMList.TEXT
            browser.settings.sortBy: FB.FMList.MODIFIED

            onClosed: destroy()
        }
    }

    property FB.TagsDialog tagsDialog : null
    Component
    {
        id: _tagsDialogComponent
        FB.TagsDialog
        {
            onTagsReady: (tags) => composerList.updateToUrls(tags)
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
                anchors.margins: Maui.Style.contentMargins
            }

            EditorView
            {
                id: editorView
                anchors.fill: parent
            }

            background: Rectangle
            {
                color: currentEditor ? currentEditor.document.backgroundColor : Maui.Theme.backgroundColor
            }
        }
    }

    Component
    {
        id: historyViewComponent

        RecentView {}
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
        var props = ({'mode' : FB.FileDialog.Modes.Open,
                         'currentPath' : FB.FM.fileDir(root.currentEditor.fileUrl),
                         'callback' : (urls) =>
                                      {
                             console.log("ASKIGN TO OPEN URLS", urls)
                             root.openFiles(urls)
                         }})

        var dialog = _fileDialogComponent.createObject(root, props)
        dialog.open()
    }

    function copyFilesTo(urls)
    {
        var props = ({'browser.settings.onlyDirs' : true,
                         'mode' : FB.FileDialog.Modes.Save,
                         'singleSelection' : true,
                         'suggestedFileName' : FB.FM.getFileInfo(urls[0]).label,
                         'callback' : function(paths)
                         {
                             FB.FM.copy(urls, paths[0])
                         }})
        var dialog = _fileDialogComponent.createObject(root, props)
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
