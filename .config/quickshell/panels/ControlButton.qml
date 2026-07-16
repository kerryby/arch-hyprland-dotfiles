import QtQuick
import "../utils/Theme.js" as ThemeJS

Rectangle {
  id: controlBtn
  width: 44
  height: 44
  radius: 8
  color: ma.containsMouse
    ? ThemeJS.rgba(ThemeService.accent, 0.15)
    : ThemeJS.rgba(ThemeService.onSurface, 0.05)

  property string label: "?"

  Text {
    anchors.centerIn: parent
    text: controlBtn.label
    font.family: ThemeService.fontFamily
    font.pixelSize: 20
    color: ThemeService.accent
  }

  MouseArea {
    id: ma
    anchors.fill: parent
    hoverEnabled: true
    onClicked: controlBtn.clicked()
  }

  signal clicked()
}