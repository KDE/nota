Maui.ToolActions
          {
              expanded: true
              autoExclusive: false
              checkable: false

              Action
              {
                  icon.name: "go-previous"
                  onTriggered : currentBrowser.goBack()
              }

              Action
              {
                  icon.name: "go-next"
                  onTriggered: currentBrowser.goNext()
              }
          },

          Maui.ToolActions
          {
              id: _viewTypeGroup
              autoExclusive: true
              expanded: headBar.width > Kirigami.Units.gridUnit * 32
              currentIndex: Maui.FM.loadSettings("VIEW_TYPE", "BROWSER", Maui.FMList.LIST_VIEW)
              onCurrentIndexChanged:
              {
                  if(currentTab && currentBrowser)
                  currentBrowser.settings.viewType = currentIndex

                  Maui.FM.saveSettings("VIEW_TYPE", currentIndex, "BROWSER")
              }

              Action
              {
                  icon.name: "view-list-icons"
                  text: qsTr("Grid")
                  shortcut: "Ctrl+G"
              }

              Action
              {
                  icon.name: "view-list-details"
                  text: qsTr("List")
                  shortcut: "Ctrl+L"
              }

              Action
              {
                  icon.name: "view-file-columns"
                  text: qsTr("Columns")
                  shortcut: "Ctrl+M"
              }
          }
}
