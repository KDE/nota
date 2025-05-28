import QtQuick
import QtQuick.Controls

import org.mauikit.controls as Maui
import org.mauikit.filebrowsing as FB

import org.maui.nota as Nota

Item
{
    id: control

    Maui.Controls.title: title
    Maui.Controls.toolTipText:  currentItem.fileUrl

    property url path

    property alias currentIndex : _splitView.currentIndex
    property alias orientation : _splitView.orientation

    readonly property alias count : _splitView.count
    readonly property alias currentItem : _splitView.currentItem
    readonly property alias model : _splitView.contentModel
    readonly property string title : count === 2 ?  model.get(0).title + "  -  " + model.get(1).title : currentItem.title

    readonly property alias editor : _splitView.currentItem
    readonly property alias terminal : terminalLoader.item
    property bool terminalVisible : false

    Keys.enabled: true
    Keys.onPressed: (event) =>
                    {
                        if(event.key === Qt.Key_F3)
                        {
                            if(control.count === 2)
                            {
                                pop()
                                return
                            }//close the inactive split

                            split("")
                            event.accepted = true
                        }

                        if((event.key === Qt.Key_Space) && (event.modifiers & Qt.ControlModifier))
                        {
                            tabView.findTab()
                            event.accepted = true
                        }


                        if(event.key === Qt.Key_F4)
                        {
                            toggleTerminal()
                            event.accepted = true
                        }
                    }

    Maui.SplitView
    {
        anchors.fill: parent
        orientation: Qt.Vertical
        background: null
        clip: false

        Maui.SplitView
        {
            id: _splitView

            SplitView.fillHeight: true
            SplitView.fillWidth: true

            orientation : width >= 600 ? Qt.Horizontal : Qt.Vertical

            onCurrentItemChanged: syncTerminal(control.editor.fileUrl)

            Component.onCompleted: split(control.path)
            background: null
            clip: false
        }

        Maui.SplitViewItem
        {
            SplitView.fillWidth: true
            SplitView.preferredHeight: 200
            SplitView.maximumHeight: parent.height * 0.5
            SplitView.minimumHeight : 100
            background: null
            autoClose: false
            visible: control.terminalVisible
            focus: false
            focusPolicy: Qt.NoFocus

            Loader
            {
                id: terminalLoader
                asynchronous: true
                active: Maui.Handy.isLinux
                visible: active && control.terminalVisible
                anchors.fill: parent
                source: "../Terminal.qml"
                onLoaded:
                {
                    control.forceActiveFocus()
                    syncTerminal(control.editor.fileUrl)
                }
            }
        }
    }

    Component
    {
        id: _editorComponent
        Editor {}
    }

    function syncTerminal(path)
    {
        if(!path || !FB.FM.fileExists(path))
            return

        if(control.terminal && appSettings.syncTerminal)
        {
            const dir = String(FB.FM.fileDir(path)).replace("file://", "")
            if(control.terminal.session.currentDir === dir)
                return
            control.terminal.session.changeDir(dir)

        }
    }

    function toggleTerminal()
    {
        control.terminalVisible = !control.terminalVisible

        if(terminalVisible)
        {
            terminalLoader.item.forceActiveFocus()
        }else
        {
            control.forceActiveFocus()
        }
    }

    function split(path)
    {
        if(_splitView.count === 1 && !settings.supportSplit)
        {
            return
        }

        if(_splitView.count === 2)
        {
            return
        }

        _splitView.addSplit(_editorComponent, {'fileUrl': path})
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
        if( item.editor.document.modified)
        {
            _closeDialog.callback = function () { destroyItem(index) }
            _closeDialog.open()
            return
        } else
        {
            destroyItem(index)
        }
    }

    function destroyItem(index) //deestroys a split view withouth warning
    {
        _splitView.closeSplit(index)
    }

    function forceActiveFocus()
    {
        control.currentItem.forceActiveFocus()
    }
}


