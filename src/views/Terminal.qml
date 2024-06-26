// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later


import org.mauikit.controls as Maui
import org.mauikit.terminal as Term
import org.mauikit.filebrowsing as FB

Term.Terminal
{
    id: control

    Maui.Theme.colorSet: Maui.Theme.Window
    Maui.Theme.inherit: false
    
    kterminal.colorScheme: settings.terminalFollowsColorScheme ? "Adaptive" : settings.terminalColorScheme
  
    session.initialWorkingDirectory: String(FB.FM.fileDir(editor.fileUrl)).replace("file://", "")
    onUrlsDropped:
    {
        var str = ""
        for(var i in urls)
            str = str + urls[i].replace("file://", "")+ " "

        control.session.sendText(str)
    }

    onKeyPressed: (event) =>
    {
        if(event.key == Qt.Key_F4)
        {
            toggleTerminal()
        }
    }
}
