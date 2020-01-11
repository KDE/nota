import QtQuick 2.9
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
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

    rightIcon.visible: false

    //    mainMenu: [
    //        MenuItem
    //        {
    //            text: qsTr("Show terminal")
    //            checkable: true
    //            checked: terminal.visible
    //            onTriggered:
    //            {
    //                terminalVisible = !terminalVisible
    //                Maui.FM.saveSettings("TERMINAL",terminalVisible, "MAINVIEW")
    //            }
    //        }
    //    ]

    ObjectModel
    {
        id: _documentModel
    }

    onClosing:
    {
        _unsavedFilesModel.clear()
        for(var i = 0; i<_editorListView.count; i++)
        {
            const doc =  _documentModel.get(i)
            if(doc.document.modified)
                _unsavedFilesModel.append({'file': _editorModel.get(i), 'documentIndex': i})
        }

        if(_unsavedFilesModel.count > 0 && !_unsavedDialog.discard)
        {
            close.accepted = false
            _unsavedDialog.open()
        }else close.accepted = true
    }

    Maui.Dialog
    {
        id: _unsavedDialog

        property bool discard : false
        acceptButton.visible: false
        page.title: qsTr("Un saved files")
        headBar.visible: true
        maxHeight: 500
        maxWidth: 400
        page.padding: Maui.Style.space.big

        ListView
        {
            id: _unsavedFilesListView
            anchors.fill: parent
            spacing: Maui.Style.space.medium
            model: ListModel
            {
                id: _unsavedFilesModel
            }

            onCountChanged: if(count === 0) _unsavedDialog.close()

            clip: true

            delegate : Maui.ItemDelegate
            {
                id: _unsavedFileDelegate
                property int index_ : index
                width: parent.width
                height: Maui.Style.rowHeight * 1.2

                RowLayout
                {
                    anchors.fill: parent

                    Maui.ListItemTemplate
                    {
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        label1.text: model.file.label
                        label2.text: model.file.path
                        iconSource: model.file.icon
                        iconSizeHint: Maui.Style.iconSizes.big
                    }

                    Row
                    {
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                        Layout.preferredWidth: implicitWidth

                        Button
                        {
                            text: qsTr("Save")
                            onClicked:
                            {
                               _documentModel.get(model.documentIndex).saveFile(model.file.path, model.documentIndex)
//                                closeTab(model.index)
                                _unsavedFilesModel.remove(_unsavedFileDelegate.index_)
                            }
                        }

                        Button
                        {
                            text: qsTr("Discard")
                            onClicked:
                            {
                                closeTab(model.documentIndex)
                                _unsavedFilesModel.remove(_unsavedFileDelegate.index_)
                            }
                        }
                    }
                }
            }
        }

        rejectButton.text: qsTr("Discard")
        onRejected:
        {
            discard = true
            root.close()
        }
    }

    Maui.FileDialog
    {
        id: fileDialog
        settings.onlyDirs: false
        settings.filterType: Maui.FMList.TEXT
        settings.sortBy: Maui.FMList.MODIFIED
        mode: modes.OPEN
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
                text: qsTr("Add new template file")
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

    headBar.rightContent: [
        ToolButton
        {
            icon.name: "document-open"
            onClicked:
            {
                fileDialog.mode = fileDialog.modes.OPEN
                fileDialog.settings.onlyDirs = false
                fileDialog.settings.singleSelection = false
                fileDialog.show(function (paths)
                {
                    for(var i in paths)
                        openTab(paths[i])
                });
            }
        }
    ]

    headBar.middleContent: Maui.ActionGroup
    {
        id: _actionGroup
        currentIndex: _swipeView.currentIndex
        Layout.fillHeight: true
        width: implicitWidth

        Action
        {
            text: qsTr("Editor")
            icon.name: "document-edit"
        }

        Action
        {
            text: qsTr("Documents")
            icon.name: "view-pim-journal" // to do
        }

        Action
        {
            text: qsTr("Recent")
            icon.name: "view-media-recent" // to do
        }
    }

    sideBar: Maui.AbstractSideBar
    {
        id : _drawer
        focus: true
        width: visible ? Math.min(Kirigami.Units.gridUnit * (Kirigami.Settings.isMobile? 14 : 16), root.width) : 0
        modal: !isWide
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        dragMargin: Maui.Style.space.big

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
                headBar.position: ToolBar.Footer
                headBar.visible: true
                viewType : Maui.FMList.LIST_VIEW
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

    SwipeView
    {
        id: _swipeView
        anchors.fill: parent
        currentIndex: _actionGroup.currentIndex

        onCurrentItemChanged: currentItem.forceActiveFocus()
        onCurrentIndexChanged: _actionGroup.currentIndex = currentIndex

        ColumnLayout
        {
            id: editorView
            spacing: 0

            Maui.TabBar
            {
                id: _tabBar
                visible: _editorListView.count > 1
                Layout.fillWidth: true
                Layout.preferredHeight: _tabBar.implicitHeight
                position: TabBar.Header
                currentIndex : _editorListView.currentIndex


                //                        Keys.onPressed:
                //                        {
                //                            if(event.key == Qt.Key_Return)
                //                            {
                //                                _browserList.currentIndex = currentIndex
                //                                control.currentPath =  tabsObjectModel.get(currentIndex).path
                //                            }
                //                        }

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
                            console.log("CLOSING EDITOR AT", _tabButton.index_)
                            if( _documentModel.get(_tabButton.index_).document.modified)
                                _saveDialog.open()
                            else
                                closeTab(_tabButton.index_)
                        }

                        Maui.Dialog
                        {
                            id: _saveDialog
                            page.padding: Maui.Style.space.huge
                            title: qsTr("Save file")
                            message: qsTr(String("This file has been modified, you can save your changes now or discard them.\n")) + _editorModel.get(_tabButton.index).path

                            acceptButton.text: qsTr("Save")
                            rejectButton.text: qsTr("Discard")

                            onAccepted:
                            {
                                _documentModel.get(_tabButton.index_).saveFile(_editorModel.get(_tabButton.index_).path, _tabButton.index_)
                                _saveDialog.close()
                            }

                            onRejected:
                            {
                                _saveDialog.close()
                                _editorList.remove(_tabButton.index_)
                            }
                        }
                    }
                }
            }


            //            Kirigami.Separator
            //            {
            //                color: Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.7))
            //                Layout.fillWidth: true
            //                Layout.preferredHeight: 1
            //                visible: _tabBar.visible
            //            }

            ListView
            {
                id: _editorListView
                Layout.fillHeight: true
                Layout.fillWidth: true
                orientation: ListView.Horizontal
                model: _documentModel
                snapMode: ListView.SnapOneItem
                spacing: 0
                interactive: Kirigami.Settings.isMobile && count > 1
                highlightFollowsCurrentItem: true
                highlightMoveDuration: 0
                onMovementEnded: currentIndex = indexAt(contentX, contentY)
                cacheBuffer: count
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

//                delegate: Editor
//                {
//                    Component.onCompleted: fileUrl = model.path
//                }

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


        DocumentsView
        {
            id: _documentsView
        }

        RecentView
        {
            id:_recentView
        }
    }

    function openTab(path)
    {
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
        _documentModel.remove(index)
        _editorList.remove(index)
    }
}
