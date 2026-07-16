import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../utils/Theme.js" as ThemeJS

FloatingWindow {
  id: controlCenter
  visible: false

  width: 350
  height: 400

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

      Text {
        text: "Control Center"
        font.family: ThemeService.fontFamily
        font.pixelSize: 16
        font.weight: Font.Bold
        color: ThemeService.onSurface
      }

      Rectangle {
        width: parent.width
        height: 60
        radius: 8
        color: ThemeJS.rgba(ThemeService.onSurface, 0.05)

        Row {
          anchors.centerIn: parent
          spacing: 16

          ControlButton { label: ""; onClicked: Process.createObject(controlCenter, { command: ["noctalia","msg","bluetooth-toggle"], running: true }) }
          ControlButton { label: ""; onClicked: Process.createObject(controlCenter, { command: ["noctalia","msg","wifi-toggle"], running: true }) }
          ControlButton { label: ""; onClicked: Process.createObject(controlCenter, { command: ["noctalia","msg","nightlight-toggle"], running: true }) }
          ControlButton { label: ""; onClicked: Process.createObject(controlCenter, { command: ["noctalia","msg","caffeine-toggle"], running: true }) }
        }
      }

      Rectangle {
        width: parent.width
        height: 50
        radius: 8
        color: ThemeJS.rgba(ThemeService.onSurface, 0.05)

        Row {
          anchors.centerIn: parent
          spacing: 12

          Text {
            text: "Volume"
            font.family: ThemeService.fontFamily
            font.pixelSize: 12
            color: ThemeService.onSurfaceDim
            anchors.verticalCenter: parent.verticalCenter
          }

          Slider {
            id: volumeSlider
            width: 150
            from: 0
            to: 100
            value: 75
            onValueChanged: {
              var proc = Process.createObject(controlCenter, {
                command: ["noctalia", "msg", "volume-set", Math.round(value).toString()],
                running: true
              })
            }
          }
        }
      }

      Rectangle {
        width: parent.width
        height: 50
        radius: 8
        color: ThemeJS.rgba(ThemeService.onSurface, 0.05)

        Row {
          anchors.centerIn: parent
          spacing: 12

          Text {
            text: "Brightness"
            font.family: ThemeService.fontFamily
            font.pixelSize: 12
            color: ThemeService.onSurfaceDim
            anchors.verticalCenter: parent.verticalCenter
          }

          Slider {
            id: brightnessSlider
            width: 150
            from: 0
            to: 100
            value: 100
            onValueChanged: {
              var proc = Process.createObject(controlCenter, {
                command: ["brightnessctl", "set", Math.round(value) + "%"],
                running: true
              })
            }
          }
        }
      }
    }
  }

  function toggle() {
    controlCenter.visible = !controlCenter.visible
  }
}