import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.3 as Maui
import org.mauikit.texteditor 1.0 as TE

import org.maui.nota 1.0 as Nota

Maui.SettingsDialog
{
    id: control

    Component
    {
        id:_fontPageComponent

        Maui.SettingsPage
        {
            title: i18n("Font")

            Maui.FontPicker
            {
                Layout.fillWidth: true

                mfont: settings.font
                model.onlyMonospaced: true

                onFontModified:
                {
                    settings.font = font
                }
            }
        }
    }

    Maui.SectionGroup
    {
        title: i18n("General")
        description: i18n("Configure the app UI, behaviour and plugins.")

        Maui.SectionItem
        {
            label1.text: i18n("Places Sidebar")
            label2.text: i18n("Browse your file system from the sidebar.")

            Switch
            {
                checkable: true
                checked: settings.enableSidebar
                onToggled: settings.enableSidebar = !settings.enableSidebar
            }
        }        

        Maui.SectionItem
        {
            label1.text:  i18n("Auto Save")
            label2.text: i18n("Auto saves your file every few seconds")

            Switch
            {
                checkable: true
                checked: settings.autoSave
                onToggled: settings.autoSave = !settings.autoSave
            }
        }

        Maui.SectionItem
        {
            visible: Maui.Handy.isAndroid

            label1.text: i18n("Dark Mode")
            label2.text: i18n("Switch between light and dark colorscheme.")

            Switch
            {
                Layout.fillHeight: true
                checked: settings.darkMode
                onToggled:
                {
                    settings.darkMode = !settings.darkMode
                    setAndroidStatusBarColor()
                }
            }
        }
    }

    Maui.SectionGroup
    {
        title: i18n("Editor")
        description: i18n("Configure the look and feel of the editor. The settings are applied globally.")

        Maui.SectionItem
        {
            label1.text: i18n("Line Numbers")
            label2.text: i18n("Display the line numbers on the left side.")

            Switch
            {
                checkable: true
                checked: settings.showLineNumbers
                onToggled: settings.showLineNumbers = !settings.showLineNumbers
            }
        }

        Maui.SectionItem
        {
            label1.text: i18n("Syntax Highlighting Languages")
            label2.text: i18n("Display available languages.")

            Switch
            {
                checkable: true
                checked: settings.showSyntaxHighlightingLanguages
                onToggled: settings.showSyntaxHighlightingLanguages = !settings.showSyntaxHighlightingLanguages
            }
        }

        Maui.SectionItem
        {
            label1.text: i18n("Syntax Highlighting")
            label2.text: i18n("Enable syntax highlighting for supported languages.")

            Switch
            {
                checkable: true
                checked: settings.enableSyntaxHighlighting
                onToggled: settings.enableSyntaxHighlighting = !settings.enableSyntaxHighlighting
            }
        }

        Maui.SectionItem
        {
            label1.text: i18n("Colors")
            label2.text: i18n("Configure the color scheme of the syntax highlighting. This configuration in not applied for rich text formats.")
            enabled: settings.enableSyntaxHighlighting

            ToolButton
            {
                checkable: true
                onToggled: control.addPage(_stylePageComponent)
                icon.name: "go-next"
            }
        }
    }

    Maui.SectionGroup
    {
        title: i18n("Display")
        description: i18n("Configure the font and diplay options.")

        Maui.SectionItem
        {
            label1.text: i18n("Font")
            label2.text: i18n("Font family and size.")

            ToolButton
            {
                checkable: true
                icon.name: "go-next"
                onToggled: control.addPage(_fontPageComponent)
            }
        }

        Maui.SectionItem
        {
            label1.text:  i18n("Tab Space")

            SpinBox
            {
                from: 2; to : 500
                value: settings.tabSpace
                onValueChanged: settings.tabSpace = value
            }
        }
    }

    Component
    {
        id:_stylePageComponent

        Maui.SettingsPage
        {
            title: i18n("Colors")

            Maui.SectionGroup
            {
                title: i18n("Colors")
                description: i18n("Configure the style of the syntax highliting. This configuration in not applied for rich text formats.")
                visible: settings.enableSyntaxHighlighting

                Maui.SectionItem
                {
                    label1.text:  i18n("Color")
                    label2.text: i18n("Editor background color.")

                    Maui.ColorsRow
                    {
                        spacing: Maui.Style.space.medium
                        currentColor: appSettings.backgroundColor
                        colors: ["#333", "#fafafa", "#fff3e6", "#4c425b"]

                        onColorPicked:
                        {
                            currentColor = color

                            var textColor

                            switch(color)
                            {
                            case "#333": textColor = "#fafafa"; break;
                            case "#fafafa": textColor = "#333"; break;
                            case "#fff3e6": textColor = Qt.darker(color, 2); break;
                            case "#4c425b": textColor = Qt.lighter(color, 2.5); break;
                            default: textColor = Maui.Theme.textColor;
                            }

                            switchBackgroundColor(color, textColor)
                        }

                    }
                }

                Maui.SectionItem
                {
                    label1.text:  i18n("Theme")
                    label2.text: i18n("Editor color scheme style.")
                    columns: 1

                    GridLayout
                    {
                        columns: 3
                        Layout.fillWidth: true
                        opacity: enabled ? 1 : 0.5

                        Repeater
                        {
                            model: TE.ColorSchemesModel {}

                            delegate: Maui.GridBrowserDelegate
                            {
                                Layout.fillWidth: true
                                checked: model.name === settings.theme
                                onClicked: settings.theme = model.name
                                label1.text: model.name

                                template.iconComponent: Control
                                {
                                    implicitHeight: Math.max(_layout.implicitHeight + topPadding + bottomPadding, 64)
                                    padding: Maui.Style.space.small

                                    background: Rectangle
                                    {
                                        color: appSettings.backgroundColor
                                        radius: Maui.Style.radiusV
                                    }

                                    contentItem: Column
                                    {
                                        id: _layout
                                        spacing: 2

                                        Text
                                        {
                                            wrapMode: Text.NoWrap
                                            elide: Text.ElideLeft
                                            width: parent.width
                                            text: "Nota { @ }"
                                            color: model.foreground
                                            font.family: settings.font.family
                                        }

                                        Rectangle
                                        {
                                            radius: 2
                                            height: 8
                                            width: parent.width
                                            color: model.highlight
                                        }

                                        Rectangle
                                        {
                                            radius: 2
                                            height: 8
                                            width: parent.width
                                            color: model.color3
                                        }

                                        Rectangle
                                        {
                                            radius: 2
                                            height: 8
                                            width: parent.width
                                            color: model.color4
                                        }

                                        Rectangle
                                        {
                                            radius: 2
                                            height: 8
                                            width: parent.width
                                            color: model.color5
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function switchBackgroundColor(backgroundColor, textColor)
    {
        root.appSettings.backgroundColor = backgroundColor
        root.appSettings.textColor = textColor
    }
}
