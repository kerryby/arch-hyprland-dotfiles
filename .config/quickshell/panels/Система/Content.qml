import QtQuick
import Quickshell.Io
import "../../"

Item {
    clip: true

    Process {
        id: actionProc
        running: false
    }

    Column {
        width: parent.width
        spacing: 8

        Text {
            text: "\u2699 \u0421\u0438\u0441\u0442\u0435\u043C\u0430"
            color: Theme.fg
            font.pixelSize: Theme.fontSize + 1
            font.family: Theme.font
            font.weight: Font.Medium
        }

        Rectangle { width: parent.width; height: 1; color: Theme.borderDim }

        Text {
            text: "\u041E\u0421: Arch Linux"
            color: Theme.fgDim
            font.pixelSize: Theme.fontSize - 1
            font.family: Theme.font
        }

        Column {
            spacing: 4

            SystemRow { label: "CPU"; value: "12%" }
            SystemRow { label: "RAM"; value: "26%" }
            SystemRow { label: "\u0414\u0438\u0441\u043A"; value: "45%" }
        }

        Rectangle { width: parent.width; height: 1; color: Theme.borderDim }

        Column {
            spacing: 4

            ActionButton {
                text: "\uD83D\uDD12 \u0411\u043B\u043E\u043A\u0438\u0440\u043E\u0432\u0430\u0442\u044C"
                onClicked: {
                    actionProc.command = ["bash", "-c", "loginctl lock-session 2>/dev/null || qtile cmd-obj -s screen -f lock 2>/dev/null || hyprctl dispatch -- exec 'loginctl lock-session'"]
                    actionProc.running = true
                }
            }

            ActionButton {
                text: "\uD83D\uDD04 \u041F\u0435\u0440\u0435\u0437\u0430\u0433\u0440\u0443\u0437\u043A\u0430"
                onClicked: {
                    actionProc.command = ["systemctl", "reboot"]
                    actionProc.running = true
                }
            }

            ActionButton {
                text: "\u23F9 \u0412\u044B\u043A\u043B\u044E\u0447\u0435\u043D\u0438\u0435"
                onClicked: {
                    actionProc.command = ["systemctl", "poweroff"]
                    actionProc.running = true
                }
            }
        }
    }
}
