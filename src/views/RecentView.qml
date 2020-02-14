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

            background: Item {}


            Maui.GridItemTemplate
            {
                isCurrentItem: _delegate.isCurrentItem
                anchors.centerIn: parent
                height: parent.height
                width: _gridView.itemSize
                label1.text: model.label
                iconSource: model.icon
                iconSizeHint: height * 0.5
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
