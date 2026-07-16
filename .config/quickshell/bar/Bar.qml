import Quickshell
import Quickshell.Io
import QtQuick
import QtQml
import "../utils/Theme.js" as ThemeJS

Scope {
  id: barRoot

  Variants {
    model: Quickshell.screens

    delegate: Component {
      PanelWindow {
        id: barWindow
        required property var modelData
        screen: modelData

        anchors {
          top: true
          left: true
          right: true
        }

        implicitHeight: 36

        color: ThemeJS.rgba(ThemeService.surfaceColor, 0.95)

        Rectangle {
          anchors.fill: parent
          color: parent.color

          Row {
            id: barContent
            anchors {
              fill: parent
              leftMargin: 8
              rightMargin: 8
            }
            spacing: 4

            LeftSection {
              height: parent.height
            }

            Item {
              width: 1
              Layout.fillWidth: true
            }

            CenterSection {
              height: parent.height
            }

            Item {
              width: 1
              Layout.fillWidth: true
            }

            RightSection {
              height: parent.height
            }
          }
        }
      }
    }
  }
}