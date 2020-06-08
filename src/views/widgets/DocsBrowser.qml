import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3

import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab
import org.kde.kirigami 2.8 as Kirigami

MauiLab.AltBrowser
{
    id: control
    enableLassoSelection: true

    gridView.itemSize: 100
    gridView.topMargin: Maui.Style.contentMargins
    listView.topMargin: Maui.Style.contentMargins
    listView.spacing: Maui.Style.space.medium

    Connections
    {
        target: control.currentView
        onItemsSelected:
        {
            for(var i in indexes)
            {
                const item =  control.model.get(indexes[i])
                _selectionbar.append(item.path, item)
            }
        }
    }

    headBar.leftContent: Maui.ToolActions
    {
        autoExclusive: true
        expanded: isWide
        currentIndex : control.viewType === MauiLab.AltBrowser.ViewType.List ? 0 : 1
        display: ToolButton.TextBesideIcon

        Action
        {
            text: i18n("List")
            icon.name: "view-list-details"
            onTriggered: control.viewType = MauiLab.AltBrowser.ViewType.List
        }

        Action
        {
            text: i18n("Grid")
            icon.name: "view-list-icons"
            onTriggered: control.viewType= MauiLab.AltBrowser.ViewType.Grid
        }
    }

    headBar.middleContent: Maui.TextField
    {
        Layout.fillWidth: true
        placeholderText: i18n("Filter...")
        onAccepted: control.model.filter = text
        onCleared:  control.model.filter = text
    }

    gridDelegate: Item
    {
        id: _gridDelegate

        property bool isCurrentItem : GridView.isCurrentItem
        property alias checked :_gridTemplate.checked

        height: control.gridView.cellHeight
        width: control.gridView.cellWidth

        Maui.ItemDelegate
        {
            id: _gridItemDelegate
            padding: Maui.Style.space.tiny
            isCurrentItem : GridView.isCurrentItem
            anchors.centerIn: parent
            height: parent.height- 10
            width: control.gridView.itemSize - 10
            draggable: true
            Drag.keys: ["text/uri-list"]

            Drag.mimeData: Drag.active ?
                               {
                                   "text/uri-list": control.filterSelectedItems(model.path)
                               } : {}

        background: Item {}
        Maui.GridItemTemplate
        {
            id: _gridTemplate
            isCurrentItem: _gridDelegate.isCurrentItem || checked
            hovered: _gridItemDelegate.hovered || _gridItemDelegate.containsPress
            anchors.fill: parent
            label1.text: model.label
            iconSource: model.icon
            iconSizeHint: height * 0.6
            checkable: selectionMode
            checked: _selectionbar.contains(model.path)
            onToggled: _selectionbar.append(model.path, control.model.get(index))
        }

        Connections
        {
            target: _selectionbar
            onUriRemoved:
            {
                if(uri === model.path)
                    _gridDelegate.checked = false
            }

            onUriAdded:
            {
                if(uri === model.path)
                    _gridDelegate.checked = true
            }

            onCleared: _gridDelegate.checked = false
        }

        onClicked:
        {
            control.currentIndex = index
            if(selectionMode || (mouse.button == Qt.LeftButton && (mouse.modifiers & Qt.ControlModifier)))
            {
                const item = control.model.get(control.currentIndex)
                _selectionbar.append(item.path, item)

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
    }
}

//listView.section.labelPositioning: ViewSection.CurrentLabelAtStart
listView.section.criteria: model.sort === "title" ?  ViewSection.FirstCharacter : ViewSection.FullString
listView.section.property: model.sort
listView.section.delegate: Maui.LabelDelegate
{
    id: delegate
    width: parent.width
    height: Maui.Style.toolBarHeightAlt
    label: model.sort === "modified" ? Maui.FM.formatDate(Date(section), "MM/dd/yyyy") : (model.sort === "size" ? Maui.FM.formatSize(section)  : String(section).replace("file://", "").toUpperCase())
    labelTxt.font.pointSize: Maui.Style.fontSizes.big
    isSection: true
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
        anchors.fill: parent
        label1.text: model.label
        label2.text: model.path
        label3.text: Maui.FM.formatDate(model.modified, "MM/dd/yyyy")
        label4.text: model.mime
        iconSource: model.icon
        iconSizeHint: Maui.Style.iconSizes.big
        checkable: selectionMode
        checked: _selectionbar.contains(model.path)
        onToggled: _selectionbar.append(model.path, control.model.get(index))
        isCurrentItem: _listDelegate.isCurrentItem
    }

    Connections
    {
        target: _selectionbar
        onUriRemoved:
        {
            if(uri === model.path)
            _listDelegate.checked = false
        }

        onUriAdded:
        {
            if(uri === model.path)
            _listDelegate.checked = true
        }

        onCleared: _listDelegate.checked = false
    }

    onClicked:
    {
        control.currentIndex = index
        if(selectionMode || (mouse.button == Qt.LeftButton && (mouse.modifiers & Qt.ControlModifier)))
        {
            const item = control.model.get(control.currentIndex)
            _selectionbar.append(item.path, item)

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
}


function filterSelectedItems(path)
{
    if(_selectionbar && _selectionbar.count > 0 && _selectionbar.contains(path))
    {
        const uris = _selectionbar.uris
        return uris.join("\n")
    }

    return path
}
}
