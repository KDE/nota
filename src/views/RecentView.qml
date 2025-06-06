import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.mauikit.controls as Maui
import org.mauikit.filebrowsing as FB

import org.maui.nota as Nota
import "widgets"

DocsBrowser
{
    id: control

    altHeader: Maui.Handy.isMobile
    headerMargins: Maui.Style.defaultPadding
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
            onTriggered: copyFilesTo(_selectionBar.uris)

        }
    }

    function addToSelection(item)
    {
        if(_selectionbar.contains(item.path))
        {
            console.log("FIle exists already in selection", item.path)
            _selectionbar.removeAtUri(item.path)
            return
        }

        _selectionbar.append(item.path, item)
    }
}
