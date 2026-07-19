import QtQuick
import "../../"

Column {
    spacing: 8

    Text {
        text: "Громкость: 65%"
        color: Theme.fg
        font.pixelSize: Theme.fontSize
        font.family: Theme.font
    }
    Rectangle {
        width: parent.width
        height: 5
        radius: 2
        color: Qt.rgba(1,1,1,0.1)

        Rectangle {
            width: parent.width * 0.65
            height: 5
            radius: 2
            color: Theme.accent
        }
    }
    Text {
        text: "Микрофон: выкл"
        color: Theme.fgDim
        font.pixelSize: Theme.fontSize - 1
        font.family: Theme.font
    }
    Text {
        text: "Устройство: динамики"
        color: Theme.fgDim
        font.pixelSize: Theme.fontSize - 1
        font.family: Theme.font
    }
}
