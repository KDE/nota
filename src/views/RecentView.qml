import QtQuick 2.14
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.3 as Maui

import org.maui.nota 1.0 as Nota
import "widgets"

DocsBrowser
{
    id: control
    property bool selectionMode : false
    altHeader: Maui.Handy.isMobile

    headBar.forceCenterMiddleContent: false
    floatingFooter: true
    holder.visible: historyList.count === 0
    holder.emoji: "qrc:/assets/dialog-information.svg"
    holder.title : i18n("No Recent Files!")
    holder.body: i18n("Here you will see your recently opened files")


    headBar.farLeftContent: ToolButton
    {
        icon.name: "go-previous"
        onClicked: control.StackView.view.pop()
    }  

    model: Maui.BaseModel
    {
        id: _historyModel

        list: historyList

        sort: "modified"
        sortOrder: Qt.DescendingOrder
        recursiveFilteringEnabled: true
        sortCaseSensitivity: Qt.CaseInsensitive
        filterCaseSensitivity: Qt.CaseInsensitive
    }

    property string typingQuery

    Maui.Chip
    {
        z: control.z + 99999
        Maui.Theme.colorSet:Maui.Theme.Complementary
        visible: _typingTimer.running
        label.text: typingQuery
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        showCloseButton: false
        anchors.margins: Maui.Style.space.medium
    }

    Timer
    {
        id: _typingTimer
        interval: 250
        onTriggered:
        {
            const index = historyList.indexOfName(typingQuery)
            if(index > -1)
            {
                control.currentIndex = _historyModel.mappedFromSource(index)
            }

            typingQuery = ""
        }
    }

    Connections
    {
        target: control.currentView

        function onKeyPress(event)
        {
            const index = control.currentIndex
            const item = control.model.get(index)

            var pat = /^([a-zA-Z0-9 _-]+)$/
            if(event.count === 1 && pat.test(event.text))
            {
                typingQuery += event.text
                _typingTimer.restart()
            }
        }
    }

    footer: Maui.SelectionBar
    {
        id: _selectionbar

        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width-(Maui.Style.space.medium*2), implicitWidth)
        maxListHeight: root.height - (Maui.Style.contentMargins*2)

        onItemClicked: (index) => console.log(index)

        onExitClicked:
        {
            control.selectionMode = false
            clear()
        }

        listDelegate: Maui.ListBrowserDelegate
        {
            width: ListView.view.width
            iconSource: model.icon
            label1.text: model.label
            label2.text: model.url

            checkable: true
            checked: true
            onToggled: _selectionbar.removeAtIndex(index)

            background: null
        }

        Action
        {
            text: i18n("Open")
            icon.name: "document-open"
            onTriggered:
            {
                const paths =  _selectionbar.uris
                for(var i in paths)
                    editorView.openTab(paths[i])

                _selectionbar.clear()
            }
        }

        Action
        {
            text: i18n("Share")
            icon.name: "document-share"
            onTriggered: Maui.Platform.shareFiles(_selectionbar.uris)
        }

        Action
        {
            text: i18n("Export")
            icon.name: "document-export"
            onTriggered:
            {
                _dialogLoader.sourceComponent= _fileDialogComponent
                dialog.mode = dialog.modes.OPEN
                dialog.settings.onlyDirs = true
                dialog.callback = function(paths)
                {
                    for(var url of _selectionbar.uris)
                    {
                        for(var i in paths)
                        {
                            FB.FM.copy(url, paths[i])
                        }
                    }
                };

                dialog.open()
            }
        }
    }

    function addToSelection(item)
    {
        _selectionbar.append(item.path, item)
    }
}
