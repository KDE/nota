import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.3 as FB

Maui.AltBrowser
{
    id: control

    enableLassoSelection: true

    gridView.itemSize: Math.min(200, Math.max(100, Math.floor(width* 0.3)))
    gridView.itemHeight: gridView.itemSize + Maui.Style.rowHeight

    viewType: root.isWide ? Maui.AltBrowser.ViewType.Grid : Maui.AltBrowser.ViewType.List

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

            if(event.key === Qt.Key_Escape)
            {
                control.StackView.view.pop()
            }
        }
    }

    headBar.middleContent: Maui.SearchField
    {
        Layout.fillWidth: true
        Layout.maximumWidth: 500
        Layout.alignment: Qt.AlignCenter
        placeholderText: i18n("Filter...")
        onAccepted: control.model.filter = text
        onCleared:  control.model.filter = text
    }

    gridDelegate: Item
    {
        height: GridView.view.cellHeight
        width: GridView.view.cellWidth

        Maui.GridBrowserDelegate
        {
            id: _gridItemDelegate

            template.imageWidth: control.gridView.itemSize
            template.imageHeight: control.gridView.itemSize

            anchors.margins: Maui.Handy.isMobile ? Maui.Style.space.small : Maui.Style.space.medium
            anchors.fill: parent

            draggable: true
            Drag.keys: ["text/uri-list"]

            Drag.mimeData: Drag.active ?
                               {
                                   "text/uri-list": control.filterSelectedItems(model.path)
                               } : {}


            isCurrentItem: parent.GridView.isCurrentItem || checked
            label1.text: model.label
            imageSource: model.thumbnail
            iconSource: model.icon
            template.fillMode: Image.PreserveAspectFit
            iconSizeHint: height * 0.6
            checkable: control.selectionMode
            checked: _selectionbar.contains(model.path)
            onToggled: addToSelection(model)

            Connections
            {
                target: _selectionbar
                function onUriRemoved(uri)
                {
                    if(uri === model.path)
                        _gridItemDelegate.checked = false
                }

                function onUriAdded(uri)
                {
                    if(uri === model.path)
                        _gridItemDelegate.checked = true
                }

                function onCleared()
                {
                    _gridItemDelegate.checked = false
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
                _menu.show()
            }

            onPressAndHold:
            {
                control.currentIndex = index
                _menu.show()
            }
        }
    }

    listDelegate: Maui.ListBrowserDelegate
    {
        id: _listDelegate

        isCurrentItem: ListView.isCurrentItem || checked

        height: Maui.Style.rowHeight *1.5
        width: ListView.view.width
        draggable: true
        Drag.keys: ["text/uri-list"]
        Drag.mimeData: Drag.active ?
                           {
                               "text/uri-list": control.filterSelectedItems(model.path)
                           } : {}

    label1.text: model.label
    label2.text: model.path
    label3.text: Maui.Handy.formatDate(model.modified, "MM/dd/yyyy")
    label4.text: model.mime
    iconSource: model.icon
    iconSizeHint: Maui.Style.iconSizes.medium
    checkable: control.selectionMode
    checked: _selectionbar.contains(model.path)
    onToggled: addToSelection(model)

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
        _menu.show()
    }

    onPressAndHold:
    {
        control.currentIndex = index
        _menu.show()
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
