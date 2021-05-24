import QtQuick 2.14
import QtQml 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami
import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.3 as FB

import org.maui.nota 1.0 as Nota

import QtQml.Models 2.3

Item
{
    id: control
    height: ListView.view.height
    width:  ListView.view.width

    property url path

    property alias currentIndex : _splitView.currentIndex
    property alias orientation : _splitView.orientation

    readonly property alias count : _splitView.count
    readonly property alias currentItem : _splitView.currentItem
    readonly property alias model : splitObjectModel
    readonly property string title : count === 2 ?  model.get(0).title + "  -  " + model.get(1).title : currentItem.title

    Maui.TabViewInfo.tabTitle: title
    Maui.TabViewInfo.tabToolTipText:  currentItem.fileUrl

    readonly property alias editor : _splitView.currentItem
    readonly property alias terminal : terminalLoader.item
    property bool terminalVisible : false

    ObjectModel { id: splitObjectModel }

    Keys.enabled: true
    Keys.onPressed:
    {
        if(event.key === Qt.Key_F3)
        {
            if(control.count === 2)
            {
                pop()
                return
            }//close the inactive split

            split("")
        }

        if((event.key === Qt.Key_Space) && (event.modifiers & Qt.ControlModifier))
        {
            console.log("KEYS PRESSED ON TABS LAYOUT OPEN TABS SEARCGH")

            tabView.findTab()
        }


        if(event.key === Qt.Key_F4)
        {
            control.terminalVisible = !control.terminalVisible
        }
    }

    onCurrentItemChanged: syncTerminal(control.editor.fileUrl)

    SplitView
    {
        anchors.fill: parent
        orientation: Qt.Vertical

        SplitView
        {
            id: _splitView
            SplitView.fillHeight: true
            SplitView.fillWidth: true

            Binding on orientation
            {
                value: width >= 600 ? Qt.Horizontal : Qt.Vertical
                restoreMode: Binding.RestoreValue
            }

            clip: true
            focus: true

            handle: Rectangle
            {
                implicitWidth: Maui.Handy.isTouch ? 10 : 6
                implicitHeight: Maui.Handy.isTouch ? 10 : 6

                color: SplitHandle.pressed ? Kirigami.Theme.highlightColor
                                           : (SplitHandle.hovered ? Qt.lighter(Kirigami.Theme.backgroundColor, 1.1) : Kirigami.Theme.backgroundColor)

                Rectangle
                {
                    anchors.centerIn: parent
                    height: _splitView.orientation == Qt.Horizontal ? 48 : parent.height
                    width:  _splitView.orientation == Qt.Horizontal ? parent.width : 48
                    color: _splitSeparator1.color
                }


                states: [  State
                    {
                        when: _splitView.orientation === Qt.Horizontal

                        AnchorChanges
                        {
                            target: _splitSeparator1
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: undefined
                        }

                        AnchorChanges
                        {
                            target: _splitSeparator2
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                            anchors.left: undefined
                        }
                    },

                    State
                    {
                        when: _splitView.orientation === Qt.Vertical

                        AnchorChanges
                        {
                            target: _splitSeparator1
                            anchors.top: parent.top
                            anchors.bottom: undefined
                            anchors.left: parent.left
                            anchors.right: parent.right
                        }

                        AnchorChanges
                        {
                            target: _splitSeparator2
                            anchors.top: undefined
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                            anchors.left: parent.left
                        }
                    }

                ]


                Kirigami.Separator
                {
                    id: _splitSeparator1
                }

                Kirigami.Separator
                {
                    id: _splitSeparator2
                }
            }

            onCurrentItemChanged:
            {
                currentItem.forceActiveFocus()
            }

            Component.onCompleted: split(control.path)
        }

        Loader
        {
            id: terminalLoader
            asynchronous: true
            active: settings.supportTerminal && Nota.Nota.supportsEmbededTerminal()
            visible: active && control.terminalVisible
            SplitView.fillWidth: true
            SplitView.preferredHeight: 200
            SplitView.maximumHeight: parent.height * 0.5
            SplitView.minimumHeight : 100
            source: "../Terminal.qml"
            onLoaded: syncTerminal(control.currentEditor.fileUrl)

            Behavior on SplitView.preferredHeight
            {
                NumberAnimation
                {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InQuad
                }
            }
        }

        handle: Rectangle
        {
            implicitWidth: 6
            implicitHeight: 6
            color: SplitHandle.pressed ? Kirigami.Theme.highlightColor
                                       : (SplitHandle.hovered ? Qt.lighter(Kirigami.Theme.backgroundColor, 1.1) : Kirigami.Theme.backgroundColor)

            Rectangle
            {
                anchors.centerIn: parent
                width: 48
                height: parent.height
                color: _splitSeparator.color
            }

            Kirigami.Separator
            {
                id: _splitSeparator
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.left: parent.left
            }

            Kirigami.Separator
            {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.left: parent.left
            }
        }
    }

    function syncTerminal(path)
    {
        if(control.terminal && control.terminal.visible && FB.FM.fileExists(path))
            control.terminal.session.sendText("cd '" + String(FB.FM.fileDir(path)).replace("file://", "") + "'\n")
    }

    function toggleTerminal()
    {
        control.terminalVisible = !control.terminalVisible
    }

    function split(path)
    {

//        _splitView.orientation = orientation

        if(_splitView.count === 1 && !settings.supportSplit)
        {
            return
        }

        if(_splitView.count === 2)
        {
            return
        }

        const component = Qt.createComponent("qrc:/views/editor/Editor.qml");

        console.log("Error:", component.errorString())

        if (component.status === Component.Ready)
        {
            console.log("setting split <<", path)
            const object = component.createObject(splitObjectModel, {'fileUrl': path});
            splitObjectModel.append(object)
            _splitView.insertItem(splitObjectModel.count, object) // duplicating object insertion due to bug on android not picking the repeater
            _splitView.currentIndex = splitObjectModel.count - 1
        }
    }

    function pop()
    {
        if(_splitView.count === 1)
        {
            return //can not pop all the browsers, leave at leats 1
        }

        closeSplit(_splitView.currentIndex === 1 ? 0 : 1)
    }

    function closeSplit(index) //closes a split but triggering a warning before
    {
        if(index >= _splitView.count)
        {
            return
        }

        const item = _splitView.itemAt(index)
        if( item.document.modified)
        {
            _dialogLoader.sourceComponent = _unsavedDialogComponent
            dialog.callback = function () { destroyItem(index) }
            dialog.open()
            return
        } else destroyItem(index)
    }

    function destroyItem(index) //deestroys a split view withouth warning
    {
        var item = _splitView.itemAt(index)
        item.destroy()
        splitObjectModel.remove(index)
        _splitView.currentIndex = 0
    }
}


