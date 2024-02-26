import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.3 as Maui
import org.mauikit.texteditor 1.0 as TE

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
//        description: i18n("Configure the app UI, behaviour and plugins.")

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
            label2.text: i18n("Auto saves your file every few seconds.")

            Switch
            {
                checkable: true
                checked: settings.autoSave
                onToggled: settings.autoSave = !settings.autoSave
            }
        }
    }

    Maui.SectionGroup
    {
        title: i18n("Editor")
//        description: i18n("Configure the look and feel of the editor. The settings are applied globally.")

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
            label1.text: i18n("Wrap Text")
            label2.text: i18n("Wrap the text into new lines.")

            Switch
            {
                checkable: true
                checked: settings.wrapText
                onToggled: settings.wrapText = !settings.wrapText
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
//        description: i18n("Configure the font and display options.")

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
    
    Maui.SectionGroup
    {
        title: i18n("Terminal")
       description: i18n("Embedded terminal options.")       
       enabled: Maui.Handy.isLinux     

        Maui.SectionItem
        {
            label1.text:  i18n("Sync Terminal")
            label2.text: i18n("Sync the terminal to the browser current working directory.")

            Switch
            {
                checkable: true
                checked:  settings.syncTerminal
                onToggled: settings.restoreSession = !settings.syncTerminal
            }
        }

        Maui.SectionItem
        {
           label1.text: i18n("Adaptive Color Scheme")
            label2.text: i18n("Colors based on the current style.")

            Switch
            {
                checked: settings.terminalFollowsColorScheme
                onToggled: settings.terminalFollowsColorScheme = !settings.terminalFollowsColorScheme
            }
        }
        
        Maui.SectionItem
        {
            label1.text: i18n("Color Scheme")
            label2.text: i18n("Change the color scheme of the terminal.")
            enabled: !settings.terminalFollowsColorScheme

            ToolButton
            {
                checkable: true
                icon.name: "go-next"
                onToggled: 
                {
                    var component = Qt.createComponent("TerminalColorSchemes.qml");
    var page = component.createObject(control);
                    control.addPage(page)
                }
            }
        }
    }

    Component
    {
        id:_stylePageComponent
        TE.ColorSchemesPage 
        {
          enabled: settings.enableSyntaxHighlighting
          
          currentTheme: appSettings.theme
          backgroundColor: appSettings.backgroundColor
          
          onColorsPicked: (background, text) =>
          {
              root.appSettings.backgroundColor = background
        root.appSettings.textColor = text
          }
          
          onCurrentThemeChanged: appSettings.theme = currentTheme
          
        }
    
    }

}
