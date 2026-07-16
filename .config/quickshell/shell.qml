import Quickshell
import Quickshell.Io
import QtQuick
import QtQml

ShellRoot {
  id: root

  Process {
    id: wallpaperDaemon
    command: ["swww", "daemon"]
    running: true
  }

  Bar {
    id: mainBar
  }

  OSD {
    id: osdOverlay
  }

  Launcher {
    id: appLauncher
  }

  ControlCenter {
    id: controlCenter
  }

  NotificationPanel {
    id: notificationPanel
  }

  Component.onCompleted: {
    print("Quickshell Noctalia replica loaded")
    WallpaperService.scanWallpapers()
  }
}