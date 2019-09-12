import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.6 as Kirigami
import org.kde.mauikit 1.0 as Maui
import Qt.labs.platform 1.1

Maui.FileBrowser
{
    id: browser
    currentPath: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
    list.filterType: Maui.FMList.TEXT
    list.viewType : Maui.FMList.ICON_VIEW

    onItemClicked:
    {
        var item = list.get(index)
        openTab(item.path)
        currentView = views.editor
    }
}
