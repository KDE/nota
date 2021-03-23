import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.2 as Maui
import org.maui.nota 1.0 as Nota

Maui.AbstractSideBar
{
    preferredWidth: Kirigami.Units.gridUnit * 14
    collapsed: !isWide
    collapsible: true
    dragMargin: Maui.Style.space.big

    //    visible: (_swipeView.currentIndex === views.editor) && settings.enableSidebar
    enabled: settings.enableSidebar

    property alias browser : browserView

    onVisibleChanged:
    {
        if(currentEditor)
            syncSidebar(currentEditor.fileUrl)
    }

    Maui.Page
    {
        anchors.fill: parent

        headBar.visible: true
        footBar.middleContent: ComboBox
        {
            Layout.fillWidth: true
            z : _drawer.z + 9999
            model: Maui.BaseModel
            {
                list: Maui.PlacesList
                {
                    groups: [
                        Maui.FMList.PLACES_PATH,
                        Maui.FMList.DRIVES_PATH]
                }
            }

            textRole: "label"
            onActivated:
            {
                currentIndex = index
                browserView.openFolder(model.get(index).path)
            }
        }


        headBar.leftContent: Maui.ToolActions
        {
            expanded: true
            autoExclusive: false
            checkable: false

            Action
            {
                text: i18n("Previous")
                icon.name: "go-previous"
                onTriggered : browserView.goBack()
            }

            Action
            {
                text: i18n("Next")
                icon.name: "go-next"
                onTriggered: browserView.goNext()
            }
        }

        headBar.rightContent: [

            ToolButton
            {
                icon.name: "edit-find"
                checked: browserView.headBar.visible
                onClicked:
                {
                    browserView.headBar.visible = !browserView.headBar.visible
                }
            },

            Maui.ToolButtonMenu
            {
                icon.name: "view-sort"

                MenuItem
                {
                    text: i18n("Show Folders First")
                    checked: browserView.settings.foldersFirst
                    checkable: true
                    onTriggered: browserView.settings.foldersFirst = !browserView.settings.foldersFirst
                }

                MenuSeparator {}

                MenuItem
                {
                    text: i18n("Type")
                    checked: browserView.settings.sortBy === Maui.FMList.MIME
                    checkable: true
                    onTriggered: browserView.settings.sortBy = Maui.FMList.MIME
                    autoExclusive: true
                }

                MenuItem
                {
                    text: i18n("Date")
                    checked:browserView.settings.sortBy === Maui.FMList.DATE
                    checkable: true
                    onTriggered: browserView.settings.sortBy = Maui.FMList.DATE
                    autoExclusive: true
                }

                MenuItem
                {
                    text: i18n("Modified")
                    checkable: true
                    checked: browserView.settings.sortBy === Maui.FMList.MODIFIED
                    onTriggered: browserView.settings.sortBy = Maui.FMList.MODIFIED
                    autoExclusive: true
                }

                MenuItem
                {
                    text: i18n("Size")
                    checkable: true
                    checked: browserView.settings.sortBy === Maui.FMList.SIZE
                    onTriggered: browserView.settings.sortBy = Maui.FMList.SIZE
                    autoExclusive: true
                }

                MenuItem
                {
                    text: i18n("Name")
                    checkable: true
                    checked: browserView.settings.sortBy === Maui.FMList.LABEL
                    onTriggered: browserView.settings.sortBy = Maui.FMList.LABEL
                    autoExclusive: true
                }

                MenuSeparator{}

                MenuItem
                {
                    id: groupAction
                    text: i18n("Group")
                    checkable: true
                    checked: browserView.settings.group
                    onTriggered:
                    {
                        browserView.settings.group = !browserView.settings.group
                    }
                }
            }


        ]


        Maui.FileBrowser
        {
            id: browserView
            anchors.fill: parent
            currentPath: Maui.FM.homePath()
            settings.viewType : Maui.FMList.LIST_VIEW
            settings.filterType: Maui.FMList.TEXT
            headBar.rightLayout.visible: false
            headBar.rightLayout.width: 0
            selectionMode: root.selectionMode
            selectionBar: _selectionbar
            floatingFooter: false

            onItemClicked:
            {
                var item = currentFMModel.get(index)
                if(Maui.Handy.singleClick)
                {
                    if(item.isdir == "true")
                    {
                        openFolder(item.path)
                    }else
                    {
                        editorView.openTab(item.path)
                    }
                }
            }

            onItemDoubleClicked:
            {
                var item = currentFMModel.get(index)
                if(!Maui.Handy.singleClick)
                {
                    if(item.isdir == "true")
                    {
                        openFolder(item.path)
                    }else
                    {
                        editorView.openTab(item.path)
                    }
                }
            }
        }
    }
}
