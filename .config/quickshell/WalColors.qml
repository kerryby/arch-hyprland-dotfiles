import Quickshell
import QtQuick
import Quickshell.Io

Item {
    id: root

    function loadColors() {
        if (!reader.running) reader.running = true
    }

    Process {
        id: reader
        running: false
        command: ["bash", "-c", "cat /home/kerry/.cache/wal/colors.json"]
        stdout: StdioCollector { id: walOut; waitForEnd: true }
        onExited: {
            if (walOut.text && walOut.text.length > 0) {
                Theme.applyColors(walOut.text)
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: root.loadColors()
    }

    Component.onCompleted: root.loadColors()
}