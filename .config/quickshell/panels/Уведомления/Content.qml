import QtQuick
import "../../"

Column {
    spacing: 6

    Text {
        text: "\u2630 Уведомления"
        color: Theme.fg
        font.pixelSize: Theme.fontSize
        font.family: Theme.font
        font.weight: Font.Medium
    }

    Rectangle {
        width: parent.width
        height: 44
        radius: 8
        color: Qt.rgba(1,1,1,0.04)

        Text {
            text: "Нет новых уведомлений"
            color: Theme.fgDim
            font.pixelSize: Theme.fontSize - 1
            font.family: Theme.font
            anchors.centerIn: parent
        }
    }

    Text {
        text: "Режим DND: выкл"
        color: Theme.fgDim
        font.pixelSize: Theme.fontSize - 1
        font.family: Theme.font
    }
}
