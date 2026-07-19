import QtQuick
import ".."

Item {
    property string label: ""
    property string value: ""

    width: parent.width
    height: 20

    Text {
        text: label + ":"
        color: Theme.fgDim
        font.pixelSize: Theme.fontSize - 1
        font.family: Theme.font
        anchors.verticalCenter: parent.verticalCenter
    }
    Text {
        text: value
        color: Theme.fg
        font.pixelSize: Theme.fontSize - 1
        font.family: Theme.font
        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
    }
}
