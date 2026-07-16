import QtQml
import Quickshell
import Quickshell.Io

pragma Singleton

QtObject {
  id: hyprIPC

  signal activeWorkspaceChanged(int id)
  signal windowOpened(string wmClass, string title)
  signal windowClosed(string wmClass, string title)

  property string socketPath: "$XDG_RUNTIME_DIR/hypr/" + (Quickshell.env.HYPRLAND_INSTANCE_SIGNATURE || "") + "/.socket2.sock"

  Process {
    id: activeWindowProc
    command: ["bash", "-c", "hyprctl activewindow -j"]
    running: true
    repeat: true
    interval: 500

    stdout: StdioCollector {
      onStreamFinished: function(data) {
        try {
          var info = JSON.parse(data)
          if (info && info.wmClass) {
            // emitchyprIPC.windowChanged(info.wmClass, info.title)
          }
        } catch (e) {}
      }
    }
  }
}