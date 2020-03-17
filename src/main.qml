import QtQuick 2.9
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab
import org.maui.nota 1.0 as Nota
import QtQuick.Window 2.0
import QtQml.Models 2.3
import "views"

Maui.ApplicationWindow
{
    id: root
    title: qsTr("Nota")

    //    property bool terminalVisible: Maui.FM.loadSettings("TERMINAL", "MAINVIEW", false) == "true"
    //    property alias terminal : terminalLoader.item
    property var views : ({editor: 0, documents: 1, recent: 2})
    Maui.App.iconName: "qrc:/img/nota.svg"
    Maui.App.description: qsTr("Nota is a simple text editor for Plasma Mobile, GNU/Linux distros and Android")

    ObjectModel
    {
        id: _documentModel
    }

    onClosing:
    {
        if(!_unsavedDialog.discard)
        {
            for(var i = 0; i<_editorListView.count; i++)
            {
                const doc =  _documentModel.get(i)
                if(doc.document.modified)
                {
                    close.accepted = false
                    _unsavedDialog.open()
                    return
                }
            }
        }

        close.accepted = true
    }

    Maui.Dialog
    {
        id: _unsavedDialog
        property bool discard : false
        title: qsTr("Un saved files")
        message: qsTr("You have un saved files. You can go back and save them or choose to dicard all changes and exit.")
        page.padding: Maui.Style.space.big
        acceptButton.text: qsTr("Go back")
        rejectButton.text: qsTr("Discard")
        onRejected: {
            discard = true
            root.close()
        }

        onAccepted: _unsavedDialog.close()
    }

    Maui.FileDialog
    {
        id: fileDialog
        settings.onlyDirs: false
        settings.filterType: Maui.FMList.TEXT
        settings.sortBy: Maui.FMList.MODIFIED
        mode: modes.OPEN
    }

    headBar.rightContent: [
        ToolButton
        {
            icon.name: "document-open"
            onClicked:
            {
                fileDialog.mode = fileDialog.modes.OPEN
                fileDialog.settings.onlyDirs = false
                fileDialog.show(function (paths)
                {
                    for(var i in paths)
                        openTab(paths[i])
                });
            }
        }
    ]

     sideBar: Maui.AbstractSideBar
    {
        id : _drawer
        width: visible ? Math.min(Kirigami.Units.gridUnit * 14, root.width) : 0
        collapsed: !isWide
        collapsible: true
        dragMargin: Maui.Style.space.big
        overlay.visible: collapsed && position > 0 && visible

        Connections
        {
            target: _drawer.overlay
            onClicked: _drawer.visible = false
        }

        Maui.Page
        {
            anchors.fill: parent
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

                onItemClicked:
                {
                    var item = currentFMList.get(index)
                    if(item.isdir == "true")
                        openFolder(item.path)
                    else
                        root.openTab(item.path)
                }
            }
        }
    }

    Maui.BaseModel
    {
        id: _editorModel
        list: Nota.Editor
        {
            id: _editorList
        }
    }

    ColumnLayout
    {
        anchors.fill: parent

        MauiLab.AppViews
        {
            id: _swipeView
            Layout.fillHeight: true
            Layout.fillWidth: true

            ColumnLayout
            {
                id: editorView
                spacing: 0

                MauiLab.AppView.iconName: "document-edit"
                MauiLab.AppView.title: qsTr("Editor")

                Maui.TabBar
                {
                    id: _tabBar
                    visible: _editorListView.count > 1
                    Layout.fillWidth: true
                    Layout.preferredHeight: _tabBar.implicitHeight
                    position: TabBar.Header
                    currentIndex : _editorListView.currentIndex

                    Repeater
                    {
                        id: _repeater
                        model: _editorModel

                        Maui.TabButton
                        {
                            id: _tabButton
                            readonly property int index_ : index
                            implicitHeight: _tabBar.implicitHeight
                            implicitWidth: Math.max(_tabBar.width / _repeater.count, 120)
                            checked: index === _tabBar.currentIndex

                            text: model.label

                            onClicked: _editorListView.currentIndex = index
                            onCloseClicked:
                            {
                                if( _documentModel.get(model.index).document.modified)
                                {
                                    _saveDialog.fileIndex = model.index
                                    _saveDialog.open()
                                }
                                else
                                    closeTab(model.index)
                            }

                            Maui.Dialog
                            {
                                id: _saveDialog
                                property int fileIndex
                                page.padding: Maui.Style.space.huge
                                title: qsTr("Save file")
                                message: qsTr(String("This file has been modified, you can save your changes now or discard them.\n")) + _editorModel.get(_tabButton.index).path

                                acceptButton.text: qsTr("Save")
                                rejectButton.text: qsTr("Discard")

                                onAccepted:
                                {
                                    _documentModel.get(fileIndex).saveFile(_editorModel.get(fileIndex).path, fileIndex)
                                    closeTab(fileIndex)
                                    _saveDialog.close()
                                }

                                onRejected:
                                {
                                    _saveDialog.close()
                                    closeTab(fileIndex)
                                }
                            }
                        }
                    }
                }

                ListView
                {
                    id: _editorListView
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    orientation: ListView.Horizontal
                    model: _documentModel
                    snapMode: ListView.SnapOneItem
                    spacing: 0
                    interactive: Maui.Handy.isTouch && count > 1
                    highlightFollowsCurrentItem: true
                    highlightMoveDuration: 0
                    highlightResizeDuration : 0
                    onMovementEnded: currentIndex = indexAt(contentX, contentY)
                    cacheBuffer: count
                    clip: true

                    Maui.Holder
                    {
                        id: _holder
                        visible: !_editorListView.count
                        emoji: "qrc:/img/document-edit.svg"
                        emojiSize: Maui.Style.iconSizes.huge
                        isMask: true
                        onActionTriggered: openTab("")
                        title: qsTr("Create a new document")
                        body: qsTr("You can create a new document by clicking the New File button, or here.<br>
                    Alternative you can open existing files from the left places sidebar or by clicking the Open button")
                    }

                    Maui.FloatingButton
                    {
                        id: _overlayButton
                        z: 999
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.margins: Maui.Style.toolBarHeight
                        anchors.bottomMargin: Maui.Style.toolBarHeight
                        height: Maui.Style.toolBarHeight
                        width: height

                        icon.name: "document-new"
                        icon.color: Kirigami.Theme.highlightedTextColor

                        onClicked: openTab("")

                        Maui.Badge
                        {
                            iconName: "list-add"
                            anchors
                            {
                                horizontalCenter: parent.right
                                verticalCenter: parent.top
                            }

                            onClicked: _newDocumentMenu.open()
                        }

                        Maui.Dialog
                        {
                            id: _newDocumentMenu
                            maxHeight: 300
                            maxWidth: 400
                            defaultButtons: false
                            footBar.middleContent: Button
                            {
                                text: qsTr("New template")
                            }

                            ColumnLayout
                            {
                                anchors.fill: parent
                                anchors.margins: Maui.Style.space.big
                                spacing: Maui.Style.space.big

                                Maui.ItemDelegate
                                {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    Maui.ListItemTemplate
                                    {
                                        anchors.fill:parent
                                        iconSizeHint: Math.min(height, Maui.Style.iconSizes.big)
                                        iconSource: "text-x-generic"
                                        label1.text: qsTr("Text file")
                                        label2.text: qsTr("Simple text file with syntax highlighting")
                                    }

                                    onClicked:
                                    {
                                        openTab("")
                                        _editorListView.currentItem.body.textFormat = TextEdit.PlainText
                                        _newDocumentMenu.close()
                                    }
                                }


                                Maui.ItemDelegate
                                {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    Maui.ListItemTemplate
                                    {
                                        anchors.fill:parent
                                        iconSizeHint: Math.min(height, Maui.Style.iconSizes.big)
                                        iconSource: "text-enriched"
                                        label1.text: qsTr("Rich text file")
                                        label2.text: qsTr("With support for basic text format editing")
                                    }

                                    onClicked:
                                    {
                                        openTab("")
                                        _editorListView.currentItem.body.textFormat = TextEdit.RichText
                                        _newDocumentMenu.close()
                                    }
                                }

                                Maui.ItemDelegate
                                {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    Maui.ListItemTemplate
                                    {
                                        anchors.fill:parent
                                        iconSizeHint: Math.min(height, Maui.Style.iconSizes.big)
                                        iconSource: "text-html"
                                        label1.text: qsTr("HTML text file")
                                        label2.text: qsTr("Text file with HTML markup support")
                                    }
                                }
                            }
                        }
                    }
                }

                //            Loader
                //            {
                //                id: terminalLoader
                //                visible: terminalVisible
                //                focus: true
                //                Layout.fillWidth: true
                //                Layout.alignment: Qt.AlignBottom
                //                Layout.minimumHeight: 100
                //                Layout.maximumHeight: 200
                //                //            anchors.bottom: parent.bottom
                //                //            anchors.top: handle.bottom
                //                source: !isMobile ? "Terminal.qml" : undefined
                //            }
            }


            MauiLab.AppViewLoader
            {
                MauiLab.AppView.iconName: "view-pim-journal"
                MauiLab.AppView.title: qsTr("Documents")
                DocumentsView
                {
                    id: _documentsView
                }
            }

            MauiLab.AppViewLoader
            {
                MauiLab.AppView.iconName: "view-media-recent"
                MauiLab.AppView.title: qsTr("Recent")
                RecentView
                {
                    id:_recentView
                }
            }
        }

        MauiLab.SelectionBar
        {
            id: _selectionbar
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: Math.min(parent.width, implicitWidth)
            Layout.margins: Maui.Style.space.medium
            onItemClicked : console.log(index)

            onExitClicked: clear()

            Action
            {
                text: qsTr("Open")
                icon.name: "document-open"
                onTriggered:
                {
                    const paths =  _selectionbar.uris
                    for(var i in paths)
                        openTab(paths[i])

                    _selectionbar.clear()
                }
            }

            Action
            {
                text: qsTr("Share")
                icon.name: "document-share"
            }

            Action
            {
                text: qsTr("Export")
                icon.name: "document-export"
            }
        }

    }


    Connections
    {
        target: Nota.Nota
        onOpenFiles:
        {
            for(var i in urls)
                openTab(urls[i])
        }
    }

    function openTab(path)
    {
        _swipeView.currentIndex = views.editor

        const index = _editorList.urlIndex(path)
        if(index >= 0)
            _editorListView.currentIndex = index;

        if(!_editorList.append(path))
            return ;

        var component = Qt.createComponent("Editor.qml");
        if (component.status === Component.Ready)
        {
            _documentModel.append(component.createObject(_documentModel));

            _editorListView.currentIndex = _documentModel.count - 1
            _documentModel.get(_documentModel.count - 1).fileUrl = path

            if(path && Maui.FM.fileExists(path))
                browserView.openFolder(Maui.FM.fileDir(path))
        }
    }

    function closeTab(index)
    {
        console.log("CLOSING FILE", index, _editorList.count, _documentModel.count)
        _editorList.remove(index)
        _documentModel.remove(index)
        console.log("CLOSING FILE", index, _editorList.count, _documentModel.count)

    }
}
