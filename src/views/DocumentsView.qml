import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.6 as Kirigami
import org.kde.mauikit 1.0 as Maui
import Qt.labs.platform 1.1

Maui.FileBrowser
{
    id: browser
    settings.filterType: Maui.FMList.TEXT

    onItemClicked:
    {
        var item = currentFMList.get(index)
        if(item.isdir == "true")
            openFolder(item.path)
        else
        {
            root.openTab(item.path)
            _actionGroup.currentIndex = views.editor
        }
    }
}
