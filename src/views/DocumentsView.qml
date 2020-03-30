import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.6 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.maui.nota 1.0 as Nota

Maui.Page
{
    id: control

    property alias model : _documentsModel
    property alias list : _documentsList

    headBar.middleContent: Maui.TextField
    {
        Layout.fillWidth: true
        placeholderText: qsTr("Filter...")
        onAccepted: _listView.model.filter = text
        onCleared:  _listView.model.filter = text
    }

    Maui.ListBrowser
    {
        id: _listView
        anchors.fill: parent
        topMargin: Maui.Style.contentMargins

        model: Maui.BaseModel
        {
            id: _documentsModel
            list: Nota.Documents
            {
                id: _documentsList
            }
        }
        spacing: Maui.Style.space.medium

        enableLassoSelection: true

        onItemsSelected:
        {
            for(var i in indexes)
            {
                const item =  model.get(indexes[i])
                _selectionbar.append(item.path, item)
            }
        }

        delegate: Maui.ItemDelegate
        {
            id: _delegate
            height: Maui.Style.rowHeight *1.5
            width: parent.width
            leftPadding: Maui.Style.space.small
            rightPadding: Maui.Style.space.small
            property alias checked :_template.checked
            isCurrentItem: ListView.isCurrentItem || checked
            draggable: true
            Drag.keys: ["text/uri-list"]
            Drag.mimeData: Drag.active ?
                               {
                                   "text/uri-list": control.filterSelectedItems(model.path)
                               } : {}

            Maui.ListItemTemplate
            {
                id: _template
                anchors.fill: parent
                label1.text: model.label
                label2.text: model.path
                iconSource: model.icon
                iconSizeHint: Maui.Style.iconSizes.big
                checked: _selectionbar.contains(model.path)
                onToggled: _selectionbar.append(model.path, _listView.model.get(index))
                isCurrentItem: parent.isCurrentItem
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
                _listView.currentIndex = index
                if(Maui.Handy.singleClick)
                {
                    root.openTab(_listView.model.get(index).path)
                }
            }

            onDoubleClicked:
            {
                _listView.currentIndex = index
                if(!Maui.Handy.singleClick)
                {
                    root.openTab(_listView.model.get(index).path)
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
