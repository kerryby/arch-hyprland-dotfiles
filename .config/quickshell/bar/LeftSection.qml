import QtQuick
import QtQuick.Layouts

Row {
  id: leftSection
  spacing: 4
  height: parent ? parent.height : 36

  LauncherIcon {
    height: parent.height
  }

  WorkspacesWidget {
    height: parent.height
  }
}