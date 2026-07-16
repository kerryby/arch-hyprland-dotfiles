import QtQuick
import Quickshell
import Quickshell.Io
import "../../utils/Theme.js" as ThemeJS

Item {
  id: powerBtn
  width: 32
  height: parent.height

  Rectangle {
    anchors.fill: parent
    color: ma.containsMouse ? ThemeJS.rgba(ThemeService.errorColor, 0.15) : "transparent"
    radius: 6

    Text {
      anchors.centerIn: parent
      text: ""
      font.family: ThemeService.fontFamily
      font.pixelSize: 14
      color: ThemeService.errorColor
    }

    MouseArea {
      id: ma
      anchors.fill: parent
      hoverEnabled: true
      onClicked: {
        var proc = Process.createObject(powerBtn, {
          command: ["noctalia", "msg", "session", "logout"],
          running: true
        })
      }
    }
  }
}