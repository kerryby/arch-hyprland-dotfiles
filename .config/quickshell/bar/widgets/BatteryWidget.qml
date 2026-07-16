import QtQuick
import Quickshell
import Quickshell.Io
import "../../utils/Theme.js" as ThemeJS

Item {
  id: batteryItem
  width: 48
  height: parent.height

  property int batteryPercent: 100
  property bool charging: false

  Text {
    id: batteryText
    anchors.centerIn: parent
    font.family: ThemeService.fontFamily
    font.pixelSize: 11

    text: {
      var icon = batteryItem.charging ? "" : ""
      if (!batteryItem.charging) {
        if (batteryItem.batteryPercent < 20) icon = ""
        else if (batteryItem.batteryPercent < 40) icon = ""
        else if (batteryItem.batteryPercent < 60) icon = ""
        else if (batteryItem.batteryPercent < 85) icon = ""
      }
      return icon + " " + batteryItem.batteryPercent + "%"
    }

    color: batteryItem.batteryPercent < 20 && !batteryItem.charging
      ? ThemeService.errorColor : ThemeService.onSurface
  }

  Process {
    id: batProc
    command: ["bash", "-c",
      "echo $(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo 100); " +
      "cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo Unknown"
    ]
    running: true
    stdout: StdioCollector {
      onStreamFinished: function(data) {
        var lines = data.trim().split("\n")
        batteryItem.batteryPercent = parseInt(lines[0]) || 0
        batteryItem.charging = lines[1] === "Charging"
      }
    }
  }

  Timer {
    interval: 30000
    running: true
    repeat: true
    onTriggered: batProc.running = true
  }
}