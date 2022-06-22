import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.3 as FB

Item
{
    id: control


    property alias page : _loader.item

    onVisibleChanged:
    {
        if(currentEditor)
            syncSidebar(currentEditor.fileUrl)
    }

    Loader
    {
        id: _loader
        asynchronous: true
        active: control.visible || item
        anchors.fill: parent

        sourceComponent: Maui.Page
        {
            property alias browser : browserView

            headBar.visible: true
            headBar.background: null
            background: null

            footBar.middleContent: Maui.ComboBox
            {
                Layout.fillWidth: true
                z : _drawer.z + 9999
                model: Maui.BaseModel
                {
                    list: FB.PlacesList
                    {
                        groups: [
                            FB.FMList.PLACES_PATH,
                            FB.FMList.DRIVES_PATH]
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
                    text: i18n("Up")
                    icon.name: "go-up"
                    onTriggered : browserView.goUp()
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
                        checked: browserView.settings.sortBy === FB.FMList.MIME
                        checkable: true
                        onTriggered: browserView.settings.sortBy = FB.FMList.MIME
                        autoExclusive: true
                    }

                    MenuItem
                    {
                        text: i18n("Date")
                        checked:browserView.settings.sortBy === FB.FMList.DATE
                        checkable: true
                        onTriggered: browserView.settings.sortBy = FB.FMList.DATE
                        autoExclusive: true
                    }

                    MenuItem
                    {
                        text: i18n("Modified")
                        checkable: true
                        checked: browserView.settings.sortBy === FB.FMList.MODIFIED
                        onTriggered: browserView.settings.sortBy = FB.FMList.MODIFIED
                        autoExclusive: true
                    }

                    MenuItem
                    {
                        text: i18n("Size")
                        checkable: true
                        checked: browserView.settings.sortBy === FB.FMList.SIZE
                        onTriggered: browserView.settings.sortBy = FB.FMList.SIZE
                        autoExclusive: true
                    }

                    MenuItem
                    {
                        text: i18n("Name")
                        checkable: true
                        checked: browserView.settings.sortBy === FB.FMList.LABEL
                        onTriggered: browserView.settings.sortBy = FB.FMList.LABEL
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

            FB.FileBrowser
            {
                id: browserView
                anchors.fill: parent
                currentPath: FB.FM.homePath()
                settings.viewType : FB.FMList.LIST_VIEW
                settings.filterType: FB.FMList.TEXT
                headBar.rightLayout.visible: false
                headBar.rightLayout.width: 0
                floatingFooter: false
                background: Rectangle
                {
                    color: Maui.Theme.backgroundColor
                    opacity: 0.2
                }
                browser.background:null
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
}
