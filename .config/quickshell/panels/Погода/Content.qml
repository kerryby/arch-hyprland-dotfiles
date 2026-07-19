import QtQuick
import "../../"

Column {
    spacing: 8

    Row {
        spacing: 10
        Text {
            text: "\u2600"
            font.pixelSize: 32
            color: Theme.yellow
            anchors.verticalCenter: parent.verticalCenter
        }
        Column {
            Text {
                text: "24\u00B0C"
                color: Theme.fg
                font.pixelSize: 20
                font.family: Theme.font
                font.weight: Font.Bold
            }
            Text {
                text: "Ясно"
                color: Theme.fgDim
                font.pixelSize: Theme.fontSize - 1
                font.family: Theme.font
            }
        }
    }
    Text {
        text: "Влажность: 45%"
        color: Theme.fgDim
        font.pixelSize: Theme.fontSize - 1
        font.family: Theme.font
    }
    Text {
        text: "Ветер: 3 м/с, СЗ"
        color: Theme.fgDim
        font.pixelSize: Theme.fontSize - 1
        font.family: Theme.font
    }
    Text {
        text: "Мин: 18\u00B0C / Макс: 26\u00B0C"
        color: Theme.fgDim
        font.pixelSize: Theme.fontSize - 1
        font.family: Theme.font
    }
}
