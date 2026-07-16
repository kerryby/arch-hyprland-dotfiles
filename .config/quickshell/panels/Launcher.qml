import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../utils/Theme.js" as ThemeJS

FloatingWindow {
  id: launcherWindow
  visible: false

  width: 500
  height: 600

  color: ThemeService.surfaceColor

  Rectangle {
    anchors.fill: parent
    color: ThemeService.surfaceColor
    radius: 12
    border.width: 1
    border.color: ThemeJS.rgba(ThemeService.outline, 0.2)

    Column {
      anchors.fill: parent
      anchors.margins: 16
      spacing: 12

      TextField {
        id: searchField
        width: parent.width
        height: 40
        placeholderText: "Search apps..."
        placeholderTextColor: ThemeService.onSurfaceDim
        color: ThemeService.onSurface
        font.family: ThemeService.fontFamily
        font.pixelSize: 16

        background: Rectangle {
          radius: 8
          color: ThemeJS.rgba(ThemeService.onSurface, 0.05)
          border.width: 1
          border.color: searchField.activeFocus
            ? ThemeService.accent : ThemeJS.rgba(ThemeService.outline, 0.2)
        }

        onTextChanged: updateResults()
      }

      ListView {
        id: appList
        width: parent.width
        height: parent.height - searchField.height - 32
        clip: true
        spacing: 4

        model: ListModel {}

        delegate: Rectangle {
          width: parent.width
          height: 40
          radius: 6
          color: ma.containsMouse
            ? ThemeJS.rgba(ThemeService.accent, 0.1) : "transparent"

          Row {
            anchors {
              left: parent.left
              leftMargin: 8
              verticalCenter: parent.verticalCenter
            }
            spacing: 8

            Text {
              text: ""
              font.family: ThemeService.fontFamily
              font.pixelSize: 16
              color: ThemeService.onSurface
              width: 24
              height: 24
              verticalAlignment: Text.AlignVCenter
              horizontalAlignment: Text.AlignHCenter
            }

            Text {
              text: model.name || ""
              font.family: ThemeService.fontFamily
              font.pixelSize: 13
              color: ThemeService.onSurface
              anchors.verticalCenter: parent.verticalCenter
            }
          }

          MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
              var proc = Process.createObject(launcherWindow, {
                command: ["gtk-launch", model.desktop],
                running: true
              })
              launcherWindow.visible = false
            }
          }
        }
      }
    }
  }

  function updateResults() {
    var query = searchField.text.trim()
    appList.model.clear()
    if (query.length < 2) return

    var safeQuery = query.replace(/'/g, "'\\''")
    var proc = Process.createObject(launcherWindow, {
      command: ["bash", "-c",
        "for f in /usr/share/applications/*.desktop ~/.local/share/applications/*.desktop 2>/dev/null; do " +
        "  grep -q 'NoDisplay=true' \"$f\" && continue; " +
        "  name=$(grep '^Name=' \"$f\" | head -1 | cut -d= -f2); " +
        "  if echo \"$name\" | grep -qi \"" + safeQuery + "\"; then " +
        "    echo \"$name|$(basename $f)\"; " +
        "  fi; " +
        "done | sort -u | head -20"
      ],
      running: true,
      stdout: StdioCollector {
        onStreamFinished: function(data) {
          appList.model.clear()
          var lines = data.trim().split("\n")
          for (var i = 0; i < lines.length; i++) {
            var parts = lines[i].split("|")
            if (parts.length >= 2) {
              appList.model.append({
                name: parts[0],
                icon: "",
                desktop: parts[1]
              })
            }
          }
        }
      }
    })
  }

  function toggle() {
    launcherWindow.visible = !launcherWindow.visible
    if (launcherWindow.visible) {
      searchField.forceActiveFocus()
      searchField.text = ""
      updateResults()
    }
  }
}