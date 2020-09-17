import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.6 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.maui.nota 1.0 as Nota
import "widgets"

DocsBrowser
{
    id: control

    property alias list : _documentsList
    headBar.visible: true
    
    holder.visible: _documentsList.count === 0
    holder.emoji: "qrc:/assets/dialog-information.svg"
    holder.title : i18n("No Documents!")
    holder.body: i18n("Add a new source to browse your text files")
    holder.emojiSize: Maui.Style.iconSizes.huge
    
    model: Maui.BaseModel
    {
        id: _documentsModel
        list: Nota.Documents
        {
            id: _documentsList
        }

        sort: "place"
        recursiveFilteringEnabled: true
        sortCaseSensitivity: Qt.CaseInsensitive
        filterCaseSensitivity: Qt.CaseInsensitive
    }

    listView.section.criteria: ViewSection.FullString
    listView.section.property: "place"
    listView.section.delegate: Maui.ListItemTemplate
    {
        property var item : Maui.FM.getFileInfo(section)
        spacing: Maui.Style.space.medium
        width: parent.width
        height: Maui.Style.rowHeight*2
        margins: Maui.Style.space.medium
        iconSource: item.icon
        iconSizeHint: Maui.Style.iconSizes.big
        label1.text: item.label
        label2.text: item.path
        label3.text:  Maui.FM.formatDate(Date(item.modified), "MM/dd/yyyy")
        label4.text: Maui.FM.formatSize(model.size)
        label1.font.pointSize: Maui.Style.fontSizes.big
        label1.font.weight: Font.Bold
    }
    
    listDelegate: Maui.ItemDelegate
    {
        id: _listDelegate

        property alias checked :_listTemplate.checked
        isCurrentItem: ListView.isCurrentItem || checked

        height: Maui.Style.rowHeight *1.5
        width: parent.width
        leftPadding: Maui.Style.space.small
        rightPadding: Maui.Style.space.small
        draggable: true
        Drag.keys: ["text/uri-list"]
        Drag.mimeData: Drag.active ?
                           {
                               "text/uri-list": control.filterSelectedItems(model.path)
                           } : {}

    Maui.ListItemTemplate
    {
        id: _listTemplate
        leftMargin: Maui.Style.space.medium
        anchors.fill: parent
        label1.text: model.label
        label3.text: Maui.FM.formatDate(model.modified, "MM/dd/yyyy")
        label4.text: model.mime
        iconSource: model.icon
        iconSizeHint: Maui.Style.iconSizes.small
        checkable: selectionMode
        checked: _selectionbar.contains(model.path)
        onToggled: addToSelection(control.model.get(index))
        isCurrentItem: _listDelegate.isCurrentItem
    }

    Connections
    {
        target: _selectionbar
        function onUriRemoved(uri)
        {
            if(uri === model.path)
                _listDelegate.checked = false
        }

        function onUriAdded(uri)
        {
            if(uri === model.path)
                _listDelegate.checked = true
        }

        function onCleared()
        {
            _listDelegate.checked = false
        }
    }

    onClicked:
    {
        control.currentIndex = index
        if(selectionMode || (mouse.button == Qt.LeftButton && (mouse.modifiers & Qt.ControlModifier)))
        {
            const item = control.model.get(control.currentIndex)
            addToSelection(item)

        }else if(Maui.Handy.singleClick)
        {
            editorView.openTab(control.model.get(index).path)
        }
    }

    onDoubleClicked:
    {
        control.currentIndex = index
        if(!Maui.Handy.singleClick && !selectionMode)
        {
            editorView.openTab(control.model.get(index).path)
        }
    }

    onRightClicked:
    {
        control.currentIndex = index
        menu.popup()
    }
}
}
