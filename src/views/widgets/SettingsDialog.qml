import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab
import org.maui.nota 1.0 as Nota

MauiLab.SettingsDialog
{
    MauiLab.SettingsSection
    {
        title: i18n("General")
        description: i18n("Configure the app UI, behaviour and plugins.")

        Switch
        {
            Layout.fillWidth: true
            checkable: true
            checked: root.enableSidebar
            Kirigami.FormData.label: i18n("Enable places sidebar")
            onToggled:
            {
                root.enableSidebar = !root.enableSidebar
                Maui.FM.saveSettings("ENABLE_SIDEBAR", enableSidebar, "EXTENSIONS")
            }
        }

        Switch
        {
            Layout.fillWidth: true
            checkable: true
            checked: root.defaultBlankFile
            Kirigami.FormData.label: i18n("Open blank file by default")
            onToggled:
            {
                root.defaultBlankFile = !root.defaultBlankFile
                Maui.FM.saveSettings("DEFAULT_BLANK_FILE", defaultBlankFile, "SETTINGS")
            }
        }

        Switch
        {
            enabled: Nota.Nota.supportsEmbededTerminal()
            Layout.fillWidth: true
            checkable: true
            checked: root.terminalVisible
            Kirigami.FormData.label: i18n("Enable embedded terminal")
            onToggled:
            {
                root.terminalVisible = !root.terminalVisible
                Maui.FM.saveSettings("TERMINAL", terminalVisible, "EXTENSIONS")
            }
        }
    }

    MauiLab.SettingsSection
    {
        title: i18n("Editor")
        description: i18n("Configure the look and feel of the editor. The settings are applied globally")

        Switch
        {
            Layout.fillWidth: true
            checkable: true
            checked: root.showLineNumbers
            Kirigami.FormData.label: i18n("Show line numbers")
            onToggled:
            {
                root.showLineNumbers = !root.showLineNumbers
                Maui.FM.saveSettings("SHOW_LINE_NUMBERS", showLineNumbers, "EDITOR")
            }
        }

        Switch
        {
            Layout.fillWidth: true
            checkable: true
            checked: root.showSyntaxHighlightingLanguages
            Kirigami.FormData.label: i18n("Show syntax highlighting languages")
            onToggled:
            {
                root.showSyntaxHighlightingLanguages = !root.showSyntaxHighlightingLanguages
                Maui.FM.saveSettings("SHOW_SYNTAXHIGHLIGHTING_BOX", showSyntaxHighlightingLanguages, "EDITOR")
            }
        }

        Switch
        {
            Layout.fillWidth: true
            Kirigami.FormData.label: i18n("Enable syntax highlighting")
            checkable: true
            checked: root.enableSyntaxHighlighting
            onToggled:
            {
                root.enableSyntaxHighlighting = !root.enableSyntaxHighlighting
                Maui.FM.saveSettings("ENABLE_SYNTAX_HIGHLIGHTING", enableSyntaxHighlighting, "EDITOR")
            }
        }
    }

    MauiLab.SettingsSection
    {
        title: i18n("Fonts")
        description: i18n("Configure the global editor font family and size")

        ComboBox
        {
            Layout.fillWidth: true
            Kirigami.FormData.label: i18n("Family")
            model: Qt.fontFamilies()
            Component.onCompleted: currentIndex = find(root.font.family, Qt.MatchExactly)
            onActivated:
            {
                root.font.family = currentText
                Maui.FM.saveSettings("FONT", root.font, "EDITOR")
            }
        }

        SpinBox
        {
            Layout.fillWidth: true
            Kirigami.FormData.label: i18n("Size")
            from: 0; to : 500
            value: root.font.pointSize
            onValueChanged:
            {
                root.font.pointSize = value
                Maui.FM.saveSettings("FONT", root.font, "EDITOR")
            }
        }
    }

    MauiLab.SettingsSection
    {
        title: i18n("Style")
        description: i18n("Configure the style of the syntax highliting. This configuration in not applied for rich text formats.")
        visible: root.enableSyntaxHighlighting

        ComboBox
        {
            Layout.fillWidth: true
            Kirigami.FormData.label: i18n("Theme")
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

        Row
        {
            Layout.fillWidth: true
            Kirigami.FormData.label: i18n("Color")
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

    MauiLab.SettingsSection
    {
        title: i18n("Interface")
        description: i18n("Configure the app UI.")

        Switch
        {
            Kirigami.FormData.label: i18n("Focus Mode")
            checkable: true
            checked:  root.focusMode
            onToggled:
            {
                root.focusMode = !root.focusMode
            }
        }

        Switch
        {
            Kirigami.FormData.label: i18n("Translucent Sidebar")
            checkable: true
            enabled: root.enableSidebar && Maui.Handy.isLinux
            checked:  root.translucency
            onToggled:  root.translucency = !root.translucency
        }

        Switch
        {
            Kirigami.FormData.label: i18n("Dark Mode")
            checkable: true
            enabled: false
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
