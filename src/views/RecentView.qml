import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.6 as Kirigami
import org.kde.mauikit 1.3 as Maui

import org.maui.nota 1.0 as Nota
import "widgets"

DocsBrowser
{
    id: control
    viewType: Maui.AltBrowser.ViewType.Grid

    model: Maui.BaseModel
    {
        list: _historyList
        sort: "modified"
        sortOrder: Qt.DescendingOrder
        recursiveFilteringEnabled: true
        sortCaseSensitivity: Qt.CaseInsensitive
        filterCaseSensitivity: Qt.CaseInsensitive
    }
    floatingFooter: true
    holder.visible: _historyList.count === 0
    holder.emoji: "qrc:/assets/dialog-information.svg"
    holder.title : i18n("No Recent Files!")
    holder.body: i18n("Here you will see your recently opened files")
    holder.emojiSize: Maui.Style.iconSizes.huge



    property string typingQuery

     Maui.Chip
     {
         z: control.z + 99999
         Kirigami.Theme.colorSet:Kirigami.Theme.Complementary
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
             const index = _historyList.indexOfName(typingQuery)
             if(index > -1)
             {
                 control.currentIndex = index
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
}
