import QtQuick
import ".."

Item {
    property string text: ""
    signal clicked

    width: 28; height: 22

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: ma.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    Text {
        anchors.centerIn: parent
        text: parent.text
        color: Theme.fgDim
        font.pixelSize: 12
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: parent.clicked()
    }
}
