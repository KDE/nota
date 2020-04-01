import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.6 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.maui.nota 1.0 as Nota

Maui.Page
{
    id: control

    headBar.middleContent: Maui.TextField
    {
        Layout.fillWidth: true
        placeholderText: qsTr("Filter...")
        onAccepted: _gridView.model.filter = text
        onCleared:  _gridView.model.filter = text
    }

    Maui.GridView
    {
        id: _gridView
        anchors.fill: parent
        itemSize: 100
        enableLassoSelection: true
        topMargin: Maui.Style.contentMargins

        onItemsSelected:
        {
            for(var i in indexes)
            {
                const item =  model.get(indexes[i])
                _selectionbar.append(item.path, item)
            }
        }

        model: Maui.BaseModel
        {
            list: _editorList.history
        }

        delegate: Item
        {
            id: _delegate

            property bool isCurrentItem : GridView.isCurrentItem
            property alias checked :_template.checked

            height: _gridView.cellHeight
            width: _gridView.cellWidth

            Maui.ItemDelegate
            {
                padding: Maui.Style.space.tiny
                isCurrentItem : GridView.isCurrentItem
                anchors.centerIn: parent
                height: _gridView.cellHeight - 10
                width: _gridView.itemSize - 10
                draggable: true
                Drag.keys: ["text/uri-list"]
                Drag.mimeData: Drag.active ?
                                   {
                                       "text/uri-list": control.filterSelectedItems(model.path)
                                   } : {}

                background: Item {}

            Maui.GridItemTemplate
            {
                id: _template
                isCurrentItem: _delegate.isCurrentItem
                anchors.fill: parent
                label1.text: model.label
                iconSource: model.icon
                iconSizeHint: height * 0.6
                checkable: selectionMode
                checked: _selectionbar.contains(model.path)
                onToggled: _selectionbar.append(model.path, _gridView.model.get(index))
            }

            Connections
            {
                target: _selectionbar
                onUriRemoved:
                {
                    if(uri === model.path)
                        _delegate.checked = false
                }

                onUriAdded:
                {
                    if(uri === model.path)
                        _delegate.checked = true
                }

                onCleared: _delegate.checked = false
            }

            onClicked:
            {
                _gridView.currentIndex = index
                if(Maui.Handy.singleClick)
                {
                    root.openTab(_gridView.model.get(index).path)
                }
            }

            onDoubleClicked:
            {
                _gridView.currentIndex = index
                if(!Maui.Handy.singleClick)
                {
                    root.openTab(_gridView.model.get(index).path)
                }
            }

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
