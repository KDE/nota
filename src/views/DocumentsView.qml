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

    Maui.ListBrowser
    {
        id: _gridView
        anchors.fill: parent
        model: Maui.BaseModel
        {
            list: Nota.Documents {}
        }

        delegate: Maui.ListBrowserDelegate
        {
            height: Maui.Style.rowHeight *2
            width: parent.width
            label1.text: model.label
            label2.text: model.path

            padding: Maui.Style.space.medium
            onClicked:
            {
                root.openTab(_gridView.model.get(index).path)
                _actionGroup.currentIndex = views.editor
            }
        }
    }
}
