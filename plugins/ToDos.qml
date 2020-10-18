import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab
import org.maui.nota 1.0 as Nota

Maui.Page
{
    id: plugin

    ListModel
    {
        id: todos
    }

    Layout.fillWidth: true
    Layout.maximumHeight: 500
    Layout.preferredHeight: _listView.contentHeight + footBar.height

    ListView
    {
        id: _listView
        anchors.fill: parent
        model: todos
        delegate: CheckBox
        {
            width: parent.width
            checkable: true
            checked: false
            text: model.label
            font.strikeout: checked
//            onToggled: todos.remove(index)
        }
    }

    footBar.middleContent : Maui.TextField
    {
        placeholderText: i18n("New ToDo... Argh!")
        Layout.fillWidth: true
        onAccepted:
        {
             todos.append({'label': text})
            clear()
        }

    }
}
