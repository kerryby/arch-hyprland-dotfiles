import QtQuick
import Quickshell
import Quickshell.Io
import "../../utils/Theme.js" as ThemeJS

Row {
  id: workspaceRow
  spacing: 2
  height: parent.height

  property var hyprWorkspaces: []
  property int activeWorkspace: 1

  Repeater {
    model: 6

    Rectangle {
      width: 28
      height: 22
      radius: 4

      color: {
        if (index + 1 === workspaceRow.activeWorkspace)
          return ThemeJS.rgba(ThemeService.accent, 0.3)
        if (workspaceRow.hyprWorkspaces.indexOf(index + 1) >= 0)
          return ThemeJS.rgba(ThemeService.onSurface, 0.1)
        return "transparent"
      }

      border.width: index + 1 === workspaceRow.activeWorkspace ? 1 : 0
      border.color: index + 1 === workspaceRow.activeWorkspace
        ? ThemeService.accent : "transparent"

      Text {
        anchors.centerIn: parent
        text: (index + 1).toString()
        font.pixelSize: 11
        font.family: ThemeService.fontFamily
        color: index + 1 === workspaceRow.activeWorkspace
          ? ThemeService.accent : ThemeService.onSurfaceDim
      }

      MouseArea {
        anchors.fill: parent
        onClicked: {
          var proc = Process.createObject(workspaceRow, {
            command: ["hyprctl", "dispatch", "workspace", (index + 1).toString()],
            running: true
          })
        }
      }
    }
  }

  Process {
    id: activeWpProc
    command: ["hyprctl", "activeworkspace", "-j"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: function(data) {
        try {
          var info = JSON.parse(data)
          workspaceRow.activeWorkspace = parseInt(info.id) || 1
        } catch (e) {}
      }
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: activeWpProc.running = true
  }

  Process {
    id: wpListProc
    command: ["hyprctl", "workspaces", "-j"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: function(data) {
        try {
          var workspaces = JSON.parse(data)
          var ids = []
          for (var i = 0; i < workspaces.length; i++) {
            ids.push(parseInt(workspaces[i].id))
          }
          workspaceRow.hyprWorkspaces = ids
        } catch (e) {}
      }
    }
  }

  Timer {
    interval: 2000
    running: true
    repeat: true
    onTriggered: wpListProc.running = true
  }
}