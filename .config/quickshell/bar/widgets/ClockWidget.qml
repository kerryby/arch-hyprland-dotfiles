import QtQuick
import Quickshell
import Quickshell.Io
import "../../utils/Theme.js" as ThemeJS

Item {
  id: clockItem
  height: parent.height
  width: clockRow.width + 16

  property string timeText: "00:00"
  property string dateText: ""

  Row {
    id: clockRow
    anchors.centerIn: parent
    spacing: 8

    Text {
      text: clockItem.timeText
      font.pixelSize: 14
      font.family: ThemeService.fontFamily
      font.weight: Font.Bold
      color: ThemeService.onSurface
      verticalAlignment: Text.AlignVCenter
    }

    Rectangle {
      width: 1
      height: 14
      color: ThemeJS.rgba(ThemeService.outline, 0.3)
      anchors.verticalCenter: parent.verticalCenter
    }

    Text {
      text: clockItem.dateText
      font.pixelSize: 10
      font.family: ThemeService.fontFamily
      color: ThemeService.onSurfaceDim
      verticalAlignment: Text.AlignVCenter
    }
  }

  Process {
    id: clockProc
    command: ["bash", "-c", "date '+%H:%M|%A, %d %B'"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: function(data) {
        var parts = data.trim().split("|")
        if (parts.length === 2) {
          clockItem.timeText = parts[0]
          clockItem.dateText = parts[1]
        }
      }
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: clockProc.running = true
  }
}