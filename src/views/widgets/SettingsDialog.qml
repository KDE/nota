import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.2 as Maui
import org.maui.nota 1.0 as Nota

Maui.SettingsDialog
{
    Maui.SettingsSection
    {
        title: i18n("General")
        description: i18n("Configure the app UI, behaviour and plugins.")
        Maui.SettingTemplate
        {
            label1.text: i18n("Places Sidebar")
            label2.text: i18n("Browse your file system from the sidebar")

            Switch
            {
                checkable: true
                checked: root.enableSidebar
                onToggled:
                {
                    root.enableSidebar = !root.enableSidebar
                    Maui.FM.saveSettings("ENABLE_SIDEBAR", enableSidebar, "EXTENSIONS")
                }
            }
        }

        Maui.SettingTemplate
        {
            label1.text: i18n("Open with Blank File")
            label2.text: i18n("Creates a blank file by default")

            Switch
            {
                checkable: true
                checked: root.defaultBlankFile
                onToggled:
                {
                    root.defaultBlankFile = !root.defaultBlankFile
                    Maui.FM.saveSettings("DEFAULT_BLANK_FILE", defaultBlankFile, "SETTINGS")
                }
            }
        }

        Maui.SettingTemplate
        {
            enabled: Nota.Nota.supportsEmbededTerminal()
            label1.text: i18n("Embedded Terminal")
            label2.text: i18n("Enabled an embedded terminal")

            Switch
            {
                checkable: true
                checked: root.terminalVisible
                onToggled:
                {
                    root.terminalVisible = !root.terminalVisible
                    Maui.FM.saveSettings("TERMINAL", terminalVisible, "EXTENSIONS")
                }
            }
        }
    }

    Maui.SettingsSection
    {
        title: i18n("Editor")
        description: i18n("Configure the look and feel of the editor. The settings are applied globally")

        Maui.SettingTemplate
        {
            label1.text:  i18n("Auto Save")
            label2.text: i18n("Auto saves your file every few seconds")
            Switch
            {
                checkable: true
                checked: root.autoSave
                onToggled:
                {
                    root.autoSave = !root.autoSave
                    Maui.FM.saveSettings("AUTO_SAVE", autoSave, "EDITOR")
                }
            }
        }

        Maui.SettingTemplate
        {
            label1.text: i18n("Line Numbers")
            label2.text: i18n("Display the line numbers on the left side")

            Switch
            {
                checkable: true
                checked: root.showLineNumbers
                onToggled:
                {
                    root.showLineNumbers = !root.showLineNumbers
                    Maui.FM.saveSettings("SHOW_LINE_NUMBERS", showLineNumbers, "EDITOR")
                }
            }
        }

        Maui.SettingTemplate
        {
            label1.text: i18n("Syntax Highlighting Languages")
            label2.text: i18n("Display avaliable languages")

            Switch
            {
                checkable: true
                checked: root.showSyntaxHighlightingLanguages
                onToggled:
                {
                    root.showSyntaxHighlightingLanguages = !root.showSyntaxHighlightingLanguages
                    Maui.FM.saveSettings("SHOW_SYNTAXHIGHLIGHTING_BOX", showSyntaxHighlightingLanguages, "EDITOR")
                }
            }
        }

        Maui.SettingTemplate
        {
            label1.text: i18n("Syntax Highlighting")
            label2.text: i18n("Enable syntax highlighting for supported languages")
            Switch
            {
                checkable: true
                checked: root.enableSyntaxHighlighting
                onToggled:
                {
                    root.enableSyntaxHighlighting = !root.enableSyntaxHighlighting
                    Maui.FM.saveSettings("ENABLE_SYNTAX_HIGHLIGHTING", enableSyntaxHighlighting, "EDITOR")
                }
            }
        }
    }

    Maui.SettingsSection
    {
        title: i18n("Fonts")
        description: i18n("Configure the global editor font family and size")

        Maui.SettingTemplate
        {
            label1.text:  i18n("Family")

            ComboBox
            {
                Layout.fillWidth: true
                model: Qt.fontFamilies()
                Component.onCompleted: currentIndex = find(root.font.family, Qt.MatchExactly)
                onActivated:
                {
                    root.font.family = currentText
                    Maui.FM.saveSettings("FONT", root.font, "EDITOR")
                }
            }
        }

        Maui.SettingTemplate
        {
            label1.text:  i18n("Size")

            SpinBox
            {
                from: 0; to : 500
                value: root.font.pointSize
                onValueChanged:
                {
                    root.font.pointSize = value
                    Maui.FM.saveSettings("FONT", root.font, "EDITOR")
                }
            }
        }
    }

    Maui.SettingsSection
    {
        title: i18n("Style")
        description: i18n("Configure the style of the syntax highliting. This configuration in not applied for rich text formats")
        visible: root.enableSyntaxHighlighting

        Maui.SettingTemplate
        {
            label1.text:  i18n("Theme")
            label2.text: i18n("Editor color scheme style")

            ComboBox
            {
                model:  _dummyDocumentHandler.getThemes()
                Component.onCompleted: currentIndex = find(root.theme, Qt.MatchExactly)

                onActivated:
                {
                    root.theme = currentText
                    Maui.FM.saveSettings("THEME", root.theme, "EDITOR")
                }

                Maui.DocumentHandler
                {
                    id: _dummyDocumentHandler
                }
            }
        }

        Maui.SettingTemplate
        {
            label1.text:  i18n("Color")
            label2.text: i18n("Editor background color")

            Row
            {
                spacing: Maui.Style.space.medium

                Rectangle
                {
                    height: 22
                    width: 22
                    radius: Maui.Style.radiusV
                    color: "#333"
                    border.color: Qt.darker(color)

                    MouseArea
                    {
                        anchors.fill: parent
                        onClicked: switchBackgroundColor(parent.color, "#fafafa")
                    }
                }

                Rectangle
                {
                    height: 22
                    width: 22
                    radius: Maui.Style.radiusV
                    color: "#fafafa"
                    border.color: Qt.darker(color)

                    MouseArea
                    {
                        anchors.fill: parent
                        onClicked: switchBackgroundColor(parent.color, "#333")
                    }
                }

                Rectangle
                {
                    height: 22
                    width: 22
                    radius: Maui.Style.radiusV
                    color: "#fff3e6"
                    border.color: Qt.darker(color)
                    MouseArea
                    {
                        anchors.fill: parent
                        onClicked: switchBackgroundColor(parent.color, Qt.darker(parent.color, 2))

                    }
                }

                Rectangle
                {
                    height: 22
                    width: 22
                    radius: Maui.Style.radiusV
                    color: "#4c425b"
                    border.color: Qt.darker(color)
                    MouseArea
                    {
                        anchors.fill: parent
                        onClicked: switchBackgroundColor(parent.color, Qt.lighter(parent.color, 2.5))
                    }
                }

                Rectangle
                {
                    height: 22
                    width: 22
                    radius: Maui.Style.radiusV
                    color: "transparent"
                    border.color: Kirigami.Theme.textColor
                    Maui.X
                    {
                        height: 16
                        width: 16
                        anchors.centerIn: parent
                        color: Kirigami.Theme.textColor
                    }

                    MouseArea
                    {
                        anchors.fill: parent
                        onClicked: switchBackgroundColor(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor)
                    }
                }
            }
        }
    }

    Maui.SettingsSection
    {
        title: i18n("Interface")
        description: i18n("Configure the application UI")


        Maui.SettingTemplate
        {
            label1.text: i18n("Translucent Sidebar")
            Switch
            {
                checkable: true
                enabled: root.enableSidebar && Maui.Handy.isLinux
                checked:  root.translucency
                onToggled:  root.translucency = !root.translucency
            }
        }

        Maui.SettingTemplate
        {
            enabled: false
            label1.text: i18n("Dark Mode")
            Switch
            {
                checkable: true
            }
        }
    }

    function switchBackgroundColor(backgroundColor, textColor)
    {
        root.backgroundColor = backgroundColor
        root.textColor = textColor

        Maui.FM.saveSettings("BACKGROUND_COLOR", root.backgroundColor, "EDITOR")
        Maui.FM.saveSettings("TEXT_COLOR", root.textColor, "EDITOR")
    }
}
