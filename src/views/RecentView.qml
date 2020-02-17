import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.6 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.maui.nota 1.0 as Nota

Maui.Page
{
    id: control

    property bool selectionMode :  false
    headBar.middleContent: Maui.TextField
    {
        Layout.fillWidth: true
        placeholderText: qsTr("Filter...")
        onAccepted: _gridView.model.filter = text
        onCleared:  _gridView.model.filter = text
    }

    headBar.rightContent: ToolButton
    {
        icon.name: "item-select"
        onClicked: control.selectionMode = !control.selectionMode
        checked: control.selectionMode
    }

    Maui.GridView
    {
        id: _gridView
        anchors.fill: parent

        itemSize: 120

        model: Maui.BaseModel
        {
            list: _editorList.history
        }

        delegate: Maui.ItemDelegate
        {
            id: _delegate
            isCurrentItem : GridView.isCurrentItem
            height: _gridView.cellHeight
            width: _gridView.cellWidth
            property bool isSelected: _selectionbar.contains(model.path)

            background: Item {}

            Maui.GridItemTemplate
            {
                id: _template
                isCurrentItem: _delegate.isCurrentItem
                anchors.centerIn: parent
                height: parent.height
                width: _gridView.itemSize
                label1.text: model.label
                iconSource: model.icon
                iconSizeHint: height * 0.6
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

            padding: Maui.Style.space.medium
            onClicked:
            {
                _gridView.currentIndex = index
                root.openTab(_gridView.model.get(index).path)
            }

        }
    }
}
