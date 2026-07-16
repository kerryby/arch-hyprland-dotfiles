import QtQuick
import QtQuick.Layouts

Row {
  id: centerSection
  height: parent.height
  spacing: 8

  ClockWidget {
    id: clock
    height: parent.height
  }

  MediaWidget {
    id: media
    height: parent.height
  }
}