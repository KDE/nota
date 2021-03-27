import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.kde.mauikit 1.3 as Maui
import org.kde.kirigami 2.14 as Kirigami

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

        function onKeyPress(event)
        {
            const index = control.currentIndex
            const item = control.model.get(index)

            if((event.key == Qt.Key_Left || event.key == Qt.Key_Right || event.key == Qt.Key_Down || event.key == Qt.Key_Up) && (event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier))
            {
                control.currentView.itemsSelected([index])
            }

            if(event.key === Qt.Key_Return)
            {
                editorView.openTab(item.path)
            }
        }
    }

    headBar.leftContent: ToolButton
    {
        enabled: list.count > 0
       icon.name: control.viewType === Maui.AltBrowser.ViewType.List ? "view-list-icons" : "view-list-details"

        onClicked:
        {
            control.viewType =  control.viewType === Maui.AltBrowser.ViewType.List ? Maui.AltBrowser.ViewType.Grid : Maui.AltBrowser.ViewType.List
        }
    }

    headBar.middleContent: Maui.TextField
    {
        Layout.fillWidth: true
        Layout.maximumWidth: 500
        placeholderText: i18n("Filter...")
        onAccepted: control.model.filter = text
        onCleared:  control.model.filter = text
    }

    gridDelegate: Item
    {
        id: _gridDelegate

        property bool isCurrentItem : GridView.isCurrentItem
        property alias checked :_gridItemDelegate.checked

        height: control.gridView.cellHeight
        width: control.gridView.cellWidth

        Maui.GridBrowserDelegate
        {
            id: _gridItemDelegate
            anchors.centerIn: parent
            height: parent.height- 15
            width: control.gridView.itemSize - 20
            draggable: true
            Drag.keys: ["text/uri-list"]

            Drag.mimeData: Drag.active ?
                               {
                                   "text/uri-list": control.filterSelectedItems(model.path)
                               } : {}


        isCurrentItem: _gridDelegate.isCurrentItem || checked
        label1.text: model.label
        iconSource: model.icon
        iconSizeHint: height * 0.6
        checkable: root.selectionMode
        checked: _selectionbar.contains(model.path)
        onToggled: addToSelection(model)

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
            if(root.selectionMode || (mouse.button == Qt.LeftButton && (mouse.modifiers & Qt.ControlModifier)))
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
            if(!Maui.Handy.singleClick && !root.selectionMode)
            {
                editorView.openTab(model.path)
            }
        }

        onRightClicked:
        {
            control.currentIndex = index
            _menu.open()
        }

        onPressAndHold:
        {
            control.currentIndex = index
            _menu.open()
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
        if(root.selectionMode || (mouse.button == Qt.LeftButton && (mouse.modifiers & Qt.ControlModifier)))
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
        if(!Maui.Handy.singleClick && !root.selectionMode)
        {
            editorView.openTab(model.path)
        }
    }

    onRightClicked:
    {
        control.currentIndex = index
        _menu.open()
    }

    onPressAndHold:
    {
        control.currentIndex = index
        _menu.open()
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
