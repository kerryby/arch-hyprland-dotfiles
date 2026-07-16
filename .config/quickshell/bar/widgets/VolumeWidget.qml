import QtQuick
import Quickshell
import Quickshell.Io
import "../../utils/Theme.js" as ThemeJS

Item {
  id: volumeItem
  width: 36
  height: parent.height

  property int volume: 100
  property bool muted: false

  Text {
    id: volumeIcon
    anchors.centerIn: parent
    text: volumeItem.muted ? ""
      : volumeItem.volume > 50 ? ""
      : volumeItem.volume > 0 ? "" : ""
    font.family: ThemeService.fontFamily
    font.pixelSize: 14
    color: ThemeService.onSurface
  }

  MouseArea {
    anchors.fill: parent
    onClicked: {
      var proc = Process.createObject(volumeItem, {
        command: ["noctalia", "msg", "volume-mute"],
        running: true
      })
    }

    onWheel: function(wheel) {
      var dir = wheel.angleDelta.y > 0 ? "up" : "down"
      var proc = Process.createObject(volumeItem, {
        command: ["noctalia", "msg", "volume-" + dir, "5"],
        running: true
      })
    }
  }

  Process {
    id: volProc
    command: ["bash", "-c",
      "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2*100, $3}'"
    ]
    running: true
    stdout: StdioCollector {
      onStreamFinished: function(data) {
        var parts = data.trim().split(/\s+/)
        volumeItem.volume = Math.round(parseFloat(parts[0])) || 0
        volumeItem.muted = parts[1] === "[MUTED]"
      }
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: volProc.running = true
  }
}