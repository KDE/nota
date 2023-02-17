import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.3 as Maui
import org.mauikit.texteditor 1.0 as TE

import org.maui.nota 1.0 as Nota

Maui.SettingsDialog
{
    Maui.SectionGroup
    {
        title: i18n("General")
        description: i18n("Configure the app UI, behaviour and plugins.")
        Maui.SectionItem
        {
            label1.text: i18n("Places Sidebar")
            label2.text: i18n("Browse your file system from the sidebar")

            Switch
            {
                checkable: true
                checked: settings.enableSidebar
                onToggled: settings.enableSidebar = !settings.enableSidebar
            }
        }

        Maui.SectionItem
        {
            label1.text: i18n("Dark Mode")
            label2.text: i18n("Switch between light and dark colorscheme")

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
        description: i18n("Configure the look and feel of the editor. The settings are applied globally")

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
            label1.text: i18n("Line Numbers")
            label2.text: i18n("Display the line numbers on the left side")

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
            label2.text: i18n("Display available languages")

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
            label2.text: i18n("Enable syntax highlighting for supported languages")
            Switch
            {
                checkable: true
                checked: settings.enableSyntaxHighlighting
                onToggled: settings.enableSyntaxHighlighting = !settings.enableSyntaxHighlighting
            }
        }
    }

    Maui.SectionGroup
    {
        title: i18n("Fonts")
        description: i18n("Configure the global font family and size")

        Maui.SectionItem
        {
            label1.text:  i18n("Family")

            Maui.FontsComboBox
            {
                Layout.fillWidth: true
                model: Qt.fontFamilies()
                Component.onCompleted: currentIndex = find(settings.font.family, Qt.MatchExactly)
                onActivated: settings.font.family = currentText
            }
        }

        Maui.SectionItem
        {
            label1.text:  i18n("Size")

            SpinBox
            {
                from: 8; to : 500
                value: settings.font.pointSize
                onValueChanged: settings.font.pointSize = value
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

    Maui.SectionGroup
    {
        title: i18n("Style")
        description: i18n("Configure the style of the syntax highliting. This configuration in not applied for rich text formats")
        visible: settings.enableSyntaxHighlighting

        Maui.SectionItem
        {
            label1.text:  i18n("Theme")
            label2.text: i18n("Editor color scheme style")


            GridLayout
            {
                columns: 3
                width: parent.parent.width
                opacity: enabled ? 1 : 0.5
                Repeater
                {
                    model: TE.ColorSchemesModel
                    {
                    }

                    delegate: Maui.GridBrowserDelegate
                    {
                        Layout.fillWidth: true
                        checked: model.name === settings.theme
                        onClicked: settings.theme = model.name

                        template.iconComponent: Pane
                        {
                            implicitHeight: Math.max(contentHeight + topPadding + bottomPadding, 64)
                            padding: Maui.Style.space.small

                            background: Rectangle
                            {
//                                color: model.background
                                color: appSettings.backgroundColor
                                radius: Maui.Style.radiusV
                            }

                            contentItem: Column
                            {
                                spacing: 2

                                Text
                                {
                                    wrapMode: Text.NoWrap
                                    elide: Text.ElideLeft
                                    width: parent.width
                                    //                                    font.pointSize: Maui.Style.fontSizes.small
                                    text: "Hello world!"
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

                        label1.text: model.name
                    }
                }
            }
        }

        Maui.SectionItem
        {
            label1.text:  i18n("Color")
            label2.text: i18n("Editor background color")

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
    }

    function switchBackgroundColor(backgroundColor, textColor)
    {
        root.appSettings.backgroundColor = backgroundColor
        root.appSettings.textColor = textColor
    }
}
