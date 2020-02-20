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

            property bool isSelected: _selectionbar.contains(model.path)

            Maui.ListItemTemplate
            {
                id: _template
                anchors.fill: parent
                label1.text: model.label
                label2.text: model.path
                iconSource: model.icon
                iconSizeHint: Maui.Style.iconSizes.big
                emblem.iconName: isSelected ? "checkbox" : " "
                emblem.visible: (control.selectionMode || isSelected)
                emblem.size: Maui.Style.iconSizes.medium

                emblem.border.color: emblem.Kirigami.Theme.textColor
                emblem.color: isSelected ? emblem.Kirigami.Theme.highlightColor : Qt.rgba(emblem.Kirigami.Theme.backgroundColor.r, emblem.Kirigami.Theme.backgroundColor.g, emblem.Kirigami.Theme.backgroundColor.b, 0.7)

                Connections
                {
                    target: _template.emblem
                    onClicked: _selectionbar.append(model.path, _gridView.model.get(index))
                }
            }

            Connections
            {
                target: _selectionbar
                onUriRemoved:
                {
                    if(uri === model.path)
                        _delegate.isSelected = false
                }

                onUriAdded:
                {
                    if(uri === model.path)
                        _delegate.isSelected = true
                }

                onCleared: _delegate.isSelected = false
            }

            onClicked: root.openTab(_listView.model.get(index).path)
        }
    }
}
