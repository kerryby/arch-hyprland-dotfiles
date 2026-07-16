import QtQml
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

pragma Singleton

QtObject {
  id: trayModel

  property var items: []
  property var statusNotifierItems: []

  function updateItems() {
    statusNotifierItems = []
    items = []
  }

  Component.onCompleted: {
    print("System tray model initialized")
  }
}