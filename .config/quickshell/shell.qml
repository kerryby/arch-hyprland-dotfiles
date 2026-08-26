import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import "components" as Components
import "styles" as Styles

Scope {
    id: root

    // ================= ВЕРХНЯЯ ПАНЕЛЬ =================
    PanelWindow {
        id: barWindow

        exclusionMode: ExclusionMode.Ignore
        anchors {
            top: true
            left: true
            right: true
        }
        margins.top: 0

        color: "transparent"
        implicitHeight: 560

        // маска: остров + открытое меню трея (всё в одном окне бара)
        mask: Region {
            Region {
                item: islandRoot
            }
            Region {
                item: islandRoot.trayMenuOpen ? islandRoot.menuSurface : null
            }
        }

        Components.DynamicIsland {
            id: islandRoot

            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
            }
        }
    }

    // ================= ЛАУНЧЕР ПРИЛОЖЕНИЙ =================
    property bool launcherVisible: false
    property real launcherStamp: 0

    function showLauncher() {
        if (launcherVisible)
            return
        launcherVisible = true
        launcherStamp = Date.now()
        launcherCloseDelay.stop()
        launcherWindow.visible = true
        Qt.callLater(launcher.openUp)
    }

    function hideLauncher() {
        if (!launcherVisible)
            return
        launcherVisible = false
        launcher.closeDown()
        launcherCloseDelay.restart()
    }

    Timer {
        id: launcherCloseDelay

        interval: 200
        onTriggered: launcherWindow.visible = false
    }

    // автозакрытие через полсекунды после того, как мышь покинула меню
    Timer {
        interval: 100
        repeat: true
        running: launcherVisible
        onTriggered: {
            if (launcher.pointerInside || bottomHotArea.containsMouse)
                root.launcherStamp = Date.now()
            else if (Date.now() - root.launcherStamp > 500)
                root.hideLauncher()
        }
    }

    PanelWindow {
        id: launcherWindow

        readonly property real sw: screen?.width ?? 1920
        readonly property real sideM: Math.max(10, Math.round((sw - 420) / 2))

        exclusionMode: ExclusionMode.Ignore
        visible: false
        color: "transparent"
        anchors {
            bottom: true
            left: true
            right: true
        }
        margins.bottom: 0
        margins.left: sideM
        margins.right: sideM
        implicitHeight: 320

        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        Components.AppLauncher {
            id: launcher

            anchors.fill: parent
            onDismissed: root.hideLauncher()
        }
    }

    // нижняя линия-триггер лаунчера: открытие по наведению
    PanelWindow {
        id: bottomHotspot

        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        anchors {
            bottom: true
            left: true
            right: true
        }
        implicitHeight: 18

        // ввод только в зоне линии
        mask: Region {
            item: bottomTriggerZone
        }

        Item {
            id: bottomTriggerZone

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            width: 200
            height: parent.height

            MouseArea {
                id: bottomHotArea

                anchors.fill: parent
                hoverEnabled: true
                onEntered: root.showLauncher()
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 3
                width: 150
                height: 3
                radius: 1.5
                opacity: root.launcherVisible ? 0 : 1
                color: Qt.alpha(Styles.WallColor.line, bottomHotArea.containsMouse ? 0.95 : 0.45)

                Behavior on color {
                    ColorAnimation {
                        duration: 160
                    }
                }
                Behavior on opacity {
                    NumberAnimation {
                        duration: 160
                    }
                }
            }
        }
    }

    // ================= ЛЕВАЯ ПАНЕЛЬ =================
    property bool drawerOpen: false
    property real drawerStamp: 0

    function openDrawer() {
        if (drawerOpen)
            return
        drawerOpen = true
        drawerStamp = Date.now()
        drawerCloseDelay.stop()
        drawerWindow.visible = true
        Qt.callLater(drawer.openUp)
    }

    function closeDrawer() {
        if (!drawerOpen)
            return
        drawerOpen = false
        drawer.closeDown()
        drawerCloseDelay.restart()
    }

    Timer {
        id: drawerCloseDelay

        interval: 660
        onTriggered: drawerWindow.visible = false
    }

    // автозакрытие через полсекунды после того, как мышь покинула панель
    Timer {
        interval: 100
        repeat: true
        running: drawerOpen
        onTriggered: {
            if (drawer.pointerInside || leftHotArea.containsMouse)
                root.drawerStamp = Date.now()
            else if (Date.now() - root.drawerStamp > 500)
                root.closeDrawer()
        }
    }

    PanelWindow {
        id: drawerWindow

        exclusionMode: ExclusionMode.Ignore
        visible: false
        color: "transparent"
        anchors {
            top: true
            bottom: true
            left: true
        }
        margins.top: 110
        margins.bottom: 110
        implicitWidth: 360

        Components.LeftDrawer {
            id: drawer

            anchors.fill: parent
        }
    }

    // левая линия-триггер панели: открытие по наведению
    PanelWindow {
        id: leftHotspot

        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        anchors {
            left: true
            top: true
            bottom: true
        }
        implicitWidth: 18

        mask: Region {
            item: leftTriggerZone
        }

        Item {
            id: leftTriggerZone

            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            width: parent.width
            height: 240

            MouseArea {
                id: leftHotArea

                anchors.fill: parent
                hoverEnabled: true
                onEntered: root.openDrawer()
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 3
                width: 3
                height: 170
                radius: 1.5
                opacity: root.drawerOpen ? 0 : 1
                color: Qt.alpha(Styles.WallColor.line, leftHotArea.containsMouse ? 0.95 : 0.45)

                Behavior on color {
                    ColorAnimation {
                        duration: 160
                    }
                }
                Behavior on opacity {
                    NumberAnimation {
                        duration: 160
                    }
                }
            }
        }
    }

    // ================= IPC (Super+R уже забинден на qs ipc call qs toggleLauncher) =================
    Process {
        id: wallpaperProc

        command: ["bash", "-c", "~/.config/hypr/theme/switch.sh"]
    }

    IpcHandler {
        target: "qs"

        function toggleLauncher(): void {
            if (root.launcherVisible)
                root.hideLauncher()
            else
                root.showLauncher()
        }

        function toggleDrawer(): void {
            if (root.drawerOpen)
                root.closeDrawer()
            else
                root.openDrawer()
        }

        function toggleWallpaper(): void {
            wallpaperProc.running = true
        }
    }
}
