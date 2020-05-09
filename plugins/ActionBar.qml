import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab
import org.maui.nota 1.0 as Nota

Maui.ToolBar
{
Layout.fillWidth: true
position: ToolBar.Footer
ToolButton
{
icon.name: "debug-run"
	
}


ToolButton
{
icon.name: "run-build"
onClicked: 
{
console.log("trying to run a script", currentEditor.fileUrl)
Nota.Nota.run("qmlscene", [currentEditor.fileUrl])

}
	
}


ToolButton
{
icon.name: "cm_runterm"
	
}

}