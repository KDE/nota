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
                checked: settings.enableSidebar
                onToggled: settings.enableSidebar = !settings.enableSidebar
            }
        }

        Maui.SettingTemplate
        {
            label1.text: i18n("Open with Blank File")
            label2.text: i18n("Creates a blank file by default")

            Switch
            {
                checkable: true
                checked: settings.defaultBlankFile
                onToggled: settings.defaultBlankFile = !settings.defaultBlankFile
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
                checked: settings.terminalVisible
                onToggled: settings.terminalVisible = !settings.terminalVisible
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
                checked: settings.autoSave
                onToggled: settings.autoSave = !settings.autoSave
            }
        }

        Maui.SettingTemplate
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

        Maui.SettingTemplate
        {
            label1.text: i18n("Syntax Highlighting Languages")
            label2.text: i18n("Display avaliable languages")

            Switch
            {
                checkable: true
                checked: settings.showSyntaxHighlightingLanguages
                onToggled: settings.showSyntaxHighlightingLanguages = !settings.showSyntaxHighlightingLanguages
            }
        }

        Maui.SettingTemplate
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
                Component.onCompleted: currentIndex = find(settings.font.family, Qt.MatchExactly)
                onActivated: settings.font.family = currentText
            }
        }

        Maui.SettingTemplate
        {
            label1.text:  i18n("Size")

            SpinBox
            {
                from: 0; to : 500
                value: settings.font.pointSize
                onValueChanged: settings.font.pointSize = value
            }
        }
    }

    Maui.SettingsSection
    {
        title: i18n("Style")
        description: i18n("Configure the style of the syntax highliting. This configuration in not applied for rich text formats")
        visible: settings.enableSyntaxHighlighting

        Maui.SettingTemplate
        {
            label1.text:  i18n("Theme")
            label2.text: i18n("Editor color scheme style")

            ComboBox
            {
                model:  _dummyDocumentHandler.getThemes()
                Component.onCompleted: currentIndex = find(settings.theme, Qt.MatchExactly)

                onActivated: settings.theme = currentText

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
        settings.backgroundColor = backgroundColor
        settings.textColor = textColor
    }
}
