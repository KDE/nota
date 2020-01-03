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
        model: Maui.BaseModel
        {
            list: Nota.Documents
            {

            }
        }

        itemSize: 100
        adaptContent: true

        delegate: Maui.ItemDelegate
        {
            id: delegate
            isCurrentItem:  GridView.isCurrentItem
            height: _gridView.cellHeight
            width: _gridView.cellWidth
            padding: Maui.Style.space.medium
            hoverEnabled: true
            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered
            ToolTip.text: model.path

            Maui.GridItemTemplate
            {
                anchors.fill: parent
                label1.text: model.label
                iconSource: model.icon
                iconSizeHint: Maui.Style.iconSizes.huge
            }

            onClicked:
            {
                root.openTab(_gridView.model.get(index).path)
                _actionGroup.currentIndex = views.editor
            }
        }
    }


}
