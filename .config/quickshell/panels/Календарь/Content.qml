import Quickshell
import QtQuick
import "../../"

Column {
    spacing: 8

    SystemClock {
        id: calClock
        precision: SystemClock.Minutes
    }

    Text {
        text: Qt.formatDateTime(calClock.date, "dddd")
        color: Theme.fg
        font.pixelSize: Theme.fontSize
        font.family: Theme.font
    }
    Text {
        text: Qt.formatDateTime(calClock.date, "d MMMM yyyy")
        color: Theme.accentGlow
        font.pixelSize: Theme.fontSize + 3
        font.family: Theme.font
        font.weight: Font.Bold
    }

    Rectangle {
        width: parent.width
        height: 1
        color: Theme.fgDim
        opacity: 0.15
    }

    Text {
        text: "Сегодня важных событий нет"
        color: Theme.fgDim
        font.pixelSize: Theme.fontSize - 1
        font.family: Theme.font
    }
    Text {
        text: "\u2022 Встреча завтра в 10:00"
        color: Theme.fgDim
        font.pixelSize: Theme.fontSize - 1
        font.family: Theme.font
    }
}
