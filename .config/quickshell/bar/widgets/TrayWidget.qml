import QtQuick
import Quickshell
import Quickshell.Io
import "../../utils/Theme.js" as ThemeJS

Item {
  id: trayItem
  width: childrenRect.width + 8
  height: parent.height

  Row {
    id: trayRow
    anchors.centerIn: parent
    spacing: 2
  }

  Process {
    id: trayProc
    command: ["bash", "-c", "echo 'sni-tray placeholder'"]
    running: false
  }
}