import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab

MauiLab.SettingsDialog
{
    MauiLab.SettingsSection
    {
        title: qsTr("General")
        description: qsTr("Configure the app UI and plugins.")

        Switch
        {
            Layout.fillWidth: true
            checkable: true
            checked: root.enableSidebar
            Kirigami.FormData.label: qsTr("Enable Places Sidebar")
            onToggled:
            {
                root.enableSidebar = !root.enableSidebar
                Maui.FM.saveSettings("ENABLE_SIDEBAR", enableSidebar, "GENERAL")
            }
        }

        Switch
        {
            enabled: terminalLoader.item
            Layout.fillWidth: true
            checkable: true
            checked: root.terminalVisible
            Kirigami.FormData.label: qsTr("Enable Embedded Terminal")
            onToggled: toogleTerminal()
        }
    }

    MauiLab.SettingsSection
    {
        title: qsTr("Editor")
        description: qsTr("Configure the look and feel of the editor. The settings are applied globally")

        Switch
        {
            Layout.fillWidth: true
            checkable: true
            checked: root.showLineNumbers
            Kirigami.FormData.label: qsTr("Show line numbers")
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
            Kirigami.FormData.label: qsTr("Show Syntax Highlighting Languages")
            onToggled:
            {
                root.showSyntaxHighlightingLanguages = !root.showSyntaxHighlightingLanguages
                Maui.FM.saveSettings("SHOW_LINE_NUMBERS", showLineNumbers, "EDITOR")
            }
        }

        Switch
        {
            Layout.fillWidth: true
            Kirigami.FormData.label: qsTr("Enable Syntax Highlighting")
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
        title: qsTr("Fonts")
        description: qsTr("Configure the global editor font family and size")

        ComboBox
        {
            Layout.fillWidth: true
            Kirigami.FormData.label: qsTr("Family")
            model: Qt.fontFamilies()
            onActivated: root.fontFamily = currentText
        }

        SpinBox
        {
            Layout.fillWidth: true
            Kirigami.FormData.label: qsTr("Size")
            from: 0; to : 500
            value: currentTab ? currentTab.body.font.pointSize : Maui.Style.fontSizes.default
            onValueChanged: root.fontSize = value
        }
    }

    MauiLab.SettingsSection
    {
        title: qsTr("Style")
        description: qsTr("Configure the style of the syntax highliting. This configuration in not applied for rich text formats.")
        visible: root.enableSyntaxHighlighting

        ComboBox
        {
            Layout.fillWidth: true
            Kirigami.FormData.label: qsTr("Theme")
            model:  _dummyDocumentHandler.getThemes()
            onActivated: root.theme = currentText

            Maui.DocumentHandler
            {
                id: _dummyDocumentHandler
            }
        }

        Row
        {
            Layout.fillWidth: true
            Kirigami.FormData.label: qsTr("Color")
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
                    onClicked: root.backgroundColor = parent.color
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
                    onClicked: root.backgroundColor = parent.color
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
                    onClicked: root.backgroundColor = parent.color
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
                    onClicked: root.backgroundColor = parent.color
                }
            }
        }
    }

    MauiLab.SettingsSection
    {
        title: qsTr("Interface")
        description: qsTr("Configure the app UI.")

        Switch
        {
            Kirigami.FormData.label: qsTr("Focus Mode")
            checkable: true
            checked:  root.focusMode
            onToggled:
            {
                root.focusMode = !root.focusMode
            }
        }

        Switch
        {
            Kirigami.FormData.label: qsTr("Translucent Sidebar")
            checkable: true
            enabled: root.enableSidebar && Maui.Handy.isLinux
            checked:  root.translucency
            onToggled:  root.translucency = !root.translucency
        }

        Switch
        {
            Kirigami.FormData.label: qsTr("Dark Mode")
            checkable: true
            enabled: false
        }
    }
}
