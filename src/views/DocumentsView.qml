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
        model: Maui.BaseModel
        {
            id: _documentsModel
            list: Nota.Documents
            {
                id: _documentsList
            }
        }

        delegate: Maui.ItemDelegate
        {
            height: Maui.Style.rowHeight *2
            width: _listView.width

            padding: Maui.Style.space.medium

            Maui.ListItemTemplate
            {
                anchors.fill: parent
                label1.text: model.label
                label2.text: model.path
                iconSource: model.icon
                iconSizeHint: Maui.Style.iconSizes.big
            }

            onClicked:
            {
                root.openTab(_listView.model.get(index).path)
                _actionGroup.currentIndex = views.editor
            }
        }
    }
}
