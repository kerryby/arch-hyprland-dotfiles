import QtQuick

Row {
  id: rightSection
  height: parent.height
  spacing: 2

  TrayWidget {
    height: parent.height
  }

  VolumeWidget {
    height: parent.height
  }

  BatteryWidget {
    height: parent.height
  }

  PowerButton {
    height: parent.height
  }
}