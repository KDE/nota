import QtQuick 2.9
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui

Maui.Editor
{
    Layout.fillHeight: true
    Layout.fillWidth: true

    property var onSaveClicked;

    headBar.rightContent: Maui.ToolButton
    {
        id: saveBtn
        iconName: "document-save"
        onClicked: {
            onSaveClicked();
        }
    }
}
