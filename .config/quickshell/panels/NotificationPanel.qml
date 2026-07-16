import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../utils/Theme.js" as ThemeJS

FloatingWindow {
  id: notifPanel
  visible: false

  width: 380
  height: 500

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
      spacing: 8

      Row {
        width: parent.width
        height: 32

        Text {
          text: "Notifications"
          font.family: ThemeService.fontFamily
          font.pixelSize: 16
          font.weight: Font.Bold
          color: ThemeService.onSurface
        }

        Item { width: 1; height: 1; Layout.fillWidth: true }

        Text {
          text: ""
          font.family: ThemeService.fontFamily
          font.pixelSize: 16
          color: ThemeService.onSurfaceDim

          MouseArea {
            anchors.fill: parent
            onClicked: {
              var proc = Process.createObject(notifPanel, {
                command: ["noctalia", "msg", "notification-clear-history"],
                running: true
              })
            }
          }
        }
      }

      Rectangle {
        width: parent.width
        height: 1
        color: ThemeJS.rgba(ThemeService.outline, 0.2)
      }

      ListView {
        id: notifList
        width: parent.width
        height: parent.height - 60
        clip: true
        spacing: 8
        model: ListModel {}
      }
    }
  }

  function toggle() {
    notifPanel.visible = !notifPanel.visible
  }
}