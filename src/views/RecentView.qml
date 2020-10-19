import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.6 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab
import org.maui.nota 1.0 as Nota
import "widgets"

DocsBrowser
{
    id: control
    viewType: MauiLab.AltBrowser.ViewType.Grid
    model: Maui.BaseModel
    {
        list: _historyList
        sort: "modified"
        sortOrder: Qt.DescendingOrder
        recursiveFilteringEnabled: true
        sortCaseSensitivity: Qt.CaseInsensitive
        filterCaseSensitivity: Qt.CaseInsensitive
    }
    floatingFooter: true
    holder.visible: _historyList.count === 0
    holder.emoji: "qrc:/assets/dialog-information.svg"
    holder.title : i18n("No Recent Files!")
    holder.body: i18n("Here you will see your recently opened files")
    holder.emojiSize: Maui.Style.iconSizes.huge
}
