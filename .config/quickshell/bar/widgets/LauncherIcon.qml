import QtQuick
import Quickshell
import Quickshell.Io
import "../../utils/Theme.js" as ThemeJS

Item {
  id: launcherIcon
  width: 36
  height: parent.height

  Rectangle {
    anchors.fill: parent
    color: ma.containsMouse ? ThemeJS.rgba(ThemeService.accent, 0.15) : "transparent"
    radius: 6

    Text {
      anchors.centerIn: parent
      text: ""
      font.family: ThemeService.fontFamily
      font.pixelSize: 18
      color: ThemeService.accent
    }

    MouseArea {
      id: ma
      anchors.fill: parent
      hoverEnabled: true
      onClicked: {
        var proc = Process.createObject(launcherIcon, {
          command: ["noctalia", "msg", "panel-toggle", "launcher"],
          running: true
        })
      }
    }
  }
}