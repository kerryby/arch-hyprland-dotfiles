import QtQuick
import Quickshell
import Quickshell.Io
import "../utils/Theme.js" as ThemeJS

PanelWindow {
  id: osdWindow
  visible: false

  anchors {
    top: true
    horizontalCenter: true
  }

  implicitWidth: 300
  implicitHeight: 60

  color: "transparent"

  property int timeoutMs: 2000

  function show(text, icon) {
    osdText.text = (icon || "") + "  " + (text || "")
    osdWindow.visible = true
    osdTimer.restart()
  }

  Rectangle {
    anchors.centerIn: parent
    width: osdRow.width + 32
    height: 44
    radius: 12
    color: ThemeJS.rgba(ThemeService.surfaceContainer, 0.9)
    border.width: 1
    border.color: ThemeJS.rgba(ThemeService.outline, 0.2)

    Row {
      id: osdRow
      anchors.centerIn: parent
      spacing: 8

      Text {
        id: osdText
        text: ""
        font.family: ThemeService.fontFamily
        font.pixelSize: 18
        color: ThemeService.onSurface
      }
    }
  }

  Timer {
    id: osdTimer
    interval: osdWindow.timeoutMs
    running: false
    repeat: false
    onTriggered: osdWindow.visible = false
  }
}