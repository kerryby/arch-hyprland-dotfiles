import QtQuick
import ".."

Item {
    property string text: ""
    signal clicked

    width: parent.width
    height: 28

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: ma.containsMouse ? Qt.rgba(1,1,1,0.08) : "transparent"
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    Text {
        text: parent.text
        color: Theme.fg
        font.pixelSize: Theme.fontSize
        font.family: Theme.font
        anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: parent.clicked()
    }
}
