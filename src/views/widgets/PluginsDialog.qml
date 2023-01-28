import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.2 as Maui

Maui.SettingsDialog
{
    id: control

    Maui.SectionGroup
    {
        title: i18n("Default Plugins")
        description: i18n("Activate or remove the default plugins")

        Layout.fillWidth: true
        Layout.fillHeight: true

        Maui.SectionItem
        {
            id: _qmlScene
            label1.text: i18n("QML Scene")
            label2.text: i18n("Load the current file in a QML scene.")

            property QtObject object : null
            Switch
            {
                Layout.fillHeight: true
                checkable: true
                checked: _qmlScene.object
                onToggled:
                {
                    if(checked)
                    {
                        if(!_qmlScene.object)
                        {
                            _qmlScene.object = control.load("qrc:/plugins/ActionBar.qml")
                        }

                    }else
                    {
                        _qmlScene.object.destroy()
                    }

                }
            }
        }

        Maui.SectionItem
        {
            id: _todos
            label1.text: i18n("ToDo")
            label2.text: i18n("List of to-do tasks.")

            property QtObject object : null
            Switch
            {
                Layout.fillHeight: true
                checkable: true
                checked: _todos.object
                onToggled:
                {
                    if(checked)
                    {
                        if(!_todos.object)
                        {
                            _todos.object = control.load("qrc:/plugins/ToDos.qml")
                        }

                    }else
                    {
                        _todos.object.destroy()
                    }

                }
            }
        }



        Maui.SectionItem
        {
            label1.text: i18n("Builder")
            label2.text: i18n("Configure a project to build and run.")
        }

        Maui.SectionItem
        {
            label1.text: i18n("HTML Previewer")
            label2.text: i18n("Preview HTML code live.")
        }

    }


    Maui.SectionGroup
    {
        title: i18n("Load Plugins")
        description: i18n("Activate or remove the third party plugins")

        Layout.fillWidth: true
        Layout.fillHeight: true

        spacing: 0
        Maui.SectionItem
        {
            label1.text: i18n("Builder")
            label2.text: i18n("Configure a project to build and run.")
        }
    }


    function load(url )
    {
        const component = Qt.createComponent(url);
console.log("Plugin status", component.errorString())
        if (component.status === Component.Ready)
        {
            console.log("setting plugin <<", url)
            const object = component.createObject(editorView.plugin)
            return object
        }

        return null
    }
}
