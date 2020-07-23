import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.2 as Maui
import org.maui.nota 1.0 as Nota

Maui.AbstractSideBar
    {
        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.Window
        width: visible ? Math.min(Kirigami.Units.gridUnit * 14, root.width) : 0
        collapsed: !isWide
        collapsible: true
        dragMargin: Maui.Style.space.big
        overlay.visible: collapsed && position > 0 && visible
        visible: (_swipeView.currentIndex === views.editor) && enableSidebar
        enabled: root.enableSidebar

        onVisibleChanged:
        {
            if(currentEditor)
                syncSidebar(currentEditor.fileUrl)
        }

        Connections
        {
            target: _drawer.overlay
            onClicked: _drawer.close()
        }

        background: Rectangle
        {
            color: Kirigami.Theme.backgroundColor
            opacity: translucency ? 0.5 : 1
        }

        Maui.Page
        {
            anchors.fill: parent
            Kirigami.Theme.inherit: false
            Kirigami.Theme.colorSet: Kirigami.Theme.Window
            background: Rectangle
            {
                color: Kirigami.Theme.backgroundColor
                opacity: translucency ? 0.7 : 1
            }
            headBar.visible: true
            headBar.middleContent: ComboBox
            {
                Layout.fillWidth: true
                z : _drawer.z + 9999
                model: Maui.BaseModel
                {
                    list: Maui.PlacesList
                    {
                        groups: [
                            Maui.FMList.PLACES_PATH,
                            Maui.FMList.DRIVES_PATH,
                            Maui.FMList.TAGS_PATH]
                    }
                }

                textRole: "label"
                onActivated:
                {
                    currentIndex = index
                    browserView.openFolder(model.list.get(index).path)
                }
            }

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
                Kirigami.Theme.backgroundColor: "transparent"

                onItemClicked:
                {
                    var item = currentFMList.get(index)
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
                    var item = currentFMList.get(index)
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
