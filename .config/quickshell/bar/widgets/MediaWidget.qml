import QtQuick
import Quickshell
import Quickshell.Io
import "../../utils/Theme.js" as ThemeJS

Item {
  id: mediaItem
  height: parent.height

  property string title: ""
  property string artist: ""
  property string status: "stopped"

  Row {
    id: mediaRow
    anchors.centerIn: parent
    spacing: 6
    visible: mediaItem.status === "playing"

    Text {
      text: ""
      font.family: ThemeService.fontFamily
      font.pixelSize: 12
      color: ThemeService.accent
      anchors.verticalCenter: parent.verticalCenter
    }

    Text {
      text: ThemeJS.truncate(mediaItem.title, 25)
      font.pixelSize: 11
      font.family: ThemeService.fontFamily
      color: ThemeService.onSurface
      anchors.verticalCenter: parent.verticalCenter
    }

    Text {
      text: "-"
      font.pixelSize: 11
      color: ThemeService.onSurfaceDim
      anchors.verticalCenter: parent.verticalCenter
    }

    Text {
      text: ThemeJS.truncate(mediaItem.artist, 20)
      font.pixelSize: 11
      font.family: ThemeService.fontFamily
      color: ThemeService.onSurfaceDim
      anchors.verticalCenter: parent.verticalCenter
    }
  }

  Process {
    id: mediaProc
    command: ["bash", "-c",
      "playerctl -a metadata --format '{{title}}|{{artist}}|{{status}}' 2>/dev/null || echo '||stopped'"
    ]
    running: true
    stdout: StdioCollector {
      onStreamFinished: function(data) {
        var parts = data.trim().split("|")
        mediaItem.title = parts[0] || ""
        mediaItem.artist = parts[1] || ""
        mediaItem.status = parts[2] || "stopped"
      }
    }
  }

  Timer {
    interval: 2000
    running: true
    repeat: true
    onTriggered: mediaProc.running = true
  }
}