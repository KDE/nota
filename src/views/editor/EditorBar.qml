import QtQuick 2.14

import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.3 as FB

Item
{
    id: control
    implicitHeight: Maui.Style.rowHeight
    Maui.Theme.colorSet: Maui.Theme.Button
        Maui.Theme.inherit: false

    RowLayout
    {
        spacing: 2
        anchors.fill: parent

        AbstractButton
        {
            enabled: currentEditor.body.canUndo
            focusPolicy: Qt.NoFocus

            Layout.fillHeight: true
            implicitWidth: height * 1.4

            background: Maui.ShadowedRectangle
            {
                color: Maui.Theme.backgroundColor

                corners
                {
                    topLeftRadius: Maui.Style.radiusV
                    topRightRadius: 0
                    bottomLeftRadius: Maui.Style.radiusV
                    bottomRightRadius: 0
                }
            }
            onClicked: currentEditor.body.undo()

            Maui.Icon
            {
                color: Maui.Theme.textColor
                anchors.centerIn: parent
                source: "edit-undo"
                implicitHeight: Maui.Style.iconSizes.small
                implicitWidth: implicitHeight
            }
        }

        AbstractButton
        {
            Layout.fillWidth: true
            Layout.fillHeight: true
            padding: Maui.Style.space.small
            leftPadding: padding
            rightPadding: padding
            topPadding: padding
            bottomPadding: padding

            background: Maui.ShadowedRectangle
            {
                color: Maui.Theme.backgroundColor
                border.width: 1
                border.color: _docMenu.visible ? Maui.Theme.highlightColor : color
                corners
                {
                    topLeftRadius: 0
                    topRightRadius: Maui.Style.radiusV
                    bottomLeftRadius: 0
                    bottomRightRadius: Maui.Style.radiusV
                }

            }

            contentItem: Maui.ListItemTemplate
            {
                spacing: 0
                label1.horizontalAlignment: Qt.AlignHCenter
                label2.horizontalAlignment: Qt.AlignHCenter
                label1.text: currentEditor.title
//                label2.text: currentEditor.fileUrl
                label2.font.pointSize: Maui.Style.fontSizes.small

                Maui.Icon
                {
                    color: Maui.Theme.textColor
                    source: _docMenu.visible ? "go-up" : "go-down"
                    implicitHeight: Maui.Style.iconSize
                    implicitWidth: implicitHeight
                }
            }

            onClicked: _docMenu.show((width*0.5)-(_docMenu.width*0.5), height + Maui.Style.space.medium)
 }
    }
}
