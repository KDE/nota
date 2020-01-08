import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.6 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.maui.nota 1.0 as Nota

Maui.Page
{
    id: control

//    headBar.middleContent: Maui.TextField
//    {
//        Layout.fillWidth: true
//        placeholderText: qsTr("Filter...")
//        onAccepted: _gridView.model.filter = text
//        onCleared:  _gridView.model.filter = text
//    }

//    Maui.GridView
//    {
//        id: _gridView
//        anchors.fill: parent

//        itemSize: 100

//        model: Maui.BaseModel
//        {
//            list: _editorList.history
//        }

//        delegate: Maui.ItemDelegate
//        {
//            height: _gridView.cellHeight
//            width: _gridView.cellWidth

//            Maui.GridItemTemplate
//            {
//                anchors.fill: parent
//                label1.text: model.label
//                iconSource: model.icon
//                iconSizeHint: Maui.Style.iconSizes.huge
//            }

//            padding: Maui.Style.space.medium
//            onClicked:
//            {
//                root.openTab(_gridView.model.get(index).path)
//                _actionGroup.currentIndex = views.editor
//            }
//        }
//    }
}
