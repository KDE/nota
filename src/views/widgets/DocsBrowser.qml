import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.kde.mauikit 1.2 as Maui
import org.kde.kirigami 2.8 as Kirigami

Maui.AltBrowser
{
    id: control
    enableLassoSelection: true
    focus: true
    gridView.itemSize: 120
    gridView.itemHeight: gridView.itemSize * 1.3

    property alias menu : _menu

    ItemMenu
    {
        id: _menu
        index: control.currentIndex
        model: control.model
    }

    Connections
    {
        target: control.currentView
        function onItemsSelected(indexes)
        {
            for(var i in indexes)
            {
                const item =  control.model.get(indexes[i])
                addToSelection(item)
            }
        }
    }

    headBar.leftContent: Maui.ToolActions
    {
        autoExclusive: true
        expanded: isWide
        currentIndex : control.viewType === Maui.AltBrowser.ViewType.List ? 0 : 1
        display: ToolButton.TextBesideIcon
        cyclic: true

        Action
        {
            text: i18n("List")
            icon.name: "view-list-details"
            onTriggered: control.viewType = Maui.AltBrowser.ViewType.List
        }

        Action
        {
            text: i18n("Grid")
            icon.name: "view-list-icons"
            onTriggered: control.viewType= Maui.AltBrowser.ViewType.Grid
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
            height: parent.height- 15
            width: control.gridView.itemSize - 20
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
            checkable: root.selectionMode
            checked: _selectionbar.contains(model.path)
            onToggled: addToSelection(model)
        }

        Connections
        {
            target: _selectionbar
            function onUriRemoved(uri)
            {
                if(uri === model.path)
                    _gridDelegate.checked = false
            }

            function onUriAdded(uri)
            {
                if(uri === model.path)
                    _gridDelegate.checked = true
            }

            function onCleared()
            {
                _gridDelegate.checked = false
            }
        }

        onClicked:
        {
            control.currentIndex = index
            if(selectionMode || (mouse.button == Qt.LeftButton && (mouse.modifiers & Qt.ControlModifier)))
            {
                addToSelection(model)

            }else if(Maui.Handy.singleClick)
            {
                editorView.openTab(model.path)
            }
        }

        onDoubleClicked:
        {
            control.currentIndex = index
            if(!Maui.Handy.singleClick && !selectionMode)
            {
                editorView.openTab(model.path)
            }
        }

        onRightClicked:
        {
            control.currentIndex = index
            _menu.popup()
        }

        onPressAndHold:
        {
            control.currentIndex = index
            _menu.popup()
        }
    }
}

listDelegate: Maui.ItemDelegate
{
    id: _listDelegate

    property alias checked :_listTemplate.checked
    isCurrentItem: ListView.isCurrentItem || checked

    height: Maui.Style.rowHeight *1.5
    width: ListView.view.width
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
        checkable: root.selectionMode
        checked: _selectionbar.contains(model.path)
        onToggled: addToSelection(model)
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
            addToSelection(model)

        }else if(Maui.Handy.singleClick)
        {
            editorView.openTab(model.path)
        }
    }

    onDoubleClicked:
    {
        control.currentIndex = index
        if(!Maui.Handy.singleClick && !selectionMode)
        {
            editorView.openTab(model.path)
        }
    }

    onRightClicked:
    {
        control.currentIndex = index
        _menu.popup()
    }

    onPressAndHold:
    {
        control.currentIndex = index
        _menu.popup()
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
