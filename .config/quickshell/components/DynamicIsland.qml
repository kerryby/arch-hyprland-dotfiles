import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Services.SystemTray
import Quickshell.Networking
import Quickshell.Bluetooth
import Quickshell.Hyprland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Shapes
import "../styles" as Styles

Item {
    id: root

    property bool expanded: false
    property bool menuOpen: false
    property bool dndOn: false
    property date now: new Date()
    property bool started: false

    // --- яркость ---
    property bool hasBacklight: false
    property real backlightLevel: 0.5

    readonly property int pillHeight: 30
    readonly property int panelWidth: 660

    // --- трей (встроен в пилюлю, вторая страница) ---
    readonly property var trayItems: {
        const m = SystemTray.items
        return m.values !== undefined ? m.values : m
    }

    readonly property var toplevels: {
        const t = Hyprland.toplevels
        return t.values !== undefined ? t.values : t
    }

    property bool trayMenuOpen: false
    property var trayCurrentItem: null
    property real trayAnchorX: 0
    property var trayPendingItem: null
    property int trayHoverCount: 0

    // меню трея торчит за пределы острова — маска бара учитывает его
    readonly property alias menuSurface: trayMenuLayer

    // экранный X левого края острова (для выреза в рамке)
    readonly property real screenLeft: (QsWindow.window !== null ? (QsWindow.window.width - width) / 2 : 0)

    // ширина свёрнутой пилюли: общая для обеих страниц, чтобы не прыгала
    readonly property real pageGap: 26
    readonly property real collapsedWidth: Math.max(clockPage.implicitWidth, trayPage.implicitWidth + 8) + 36
    property int pillPage: 0

    onTrayItemsChanged: {
        if (trayCurrentItem !== null && !trayItems.includes(trayCurrentItem))
            closeTrayMenu()
    }

    function closeTrayMenu() {
        trayMenuOpen = false
        trayCurrentItem = null
    }

    function openTrayMenuFor(item, centerX) {
        if (!item)
            return
        if (!item.hasMenu) {
            launchOrFocus(item)
            return
        }
        trayCurrentItem = item
        trayAnchorX = Math.round(centerX)
        trayMenuOpen = true
    }

    // ---------- ЛКМ по иконке: запустить или сфокусировать ----------
    function iconBase(icon) {
        let s = String(icon ?? "")
        const scheme = s.indexOf("://")
        if (scheme !== -1)
            s = s.substring(s.lastIndexOf("/") + 1)
        return s.replace(/\.(svg|png|xpm)$/i, "")
    }

    function tokensFor(item) {
        const raw = [item.id ?? "", item.title ?? "", iconBase(item.icon)].join(" ")
        const found = raw.toLowerCase().match(/[a-z0-9]{3,}/g) ?? []
        return Array.from(new Set(found))
    }

    function windowScore(cls, initCls, tokens) {
        let score = 0
        for (const tok of tokens) {
            for (const c of [cls, initCls]) {
                if (!c)
                    continue
                if (c === tok) {
                    score = Math.max(score, 100)
                } else if (tok.length >= 4 && (c.includes(tok) || tok.includes(c))) {
                    score = Math.max(score, 60)
                }
            }
        }
        return score
    }

    function findWindow(tokens) {
        let best = null
        let bestScore = 0
        for (const t of root.toplevels) {
            const ipc = t.lastIpcObject ?? {}
            const cls = String(ipc.class ?? "").toLowerCase()
            const initCls = String(ipc.initialClass ?? "").toLowerCase()
            const score = windowScore(cls, initCls, tokens)
            if (score > bestScore) {
                bestScore = score
                best = t
            }
        }
        return best
    }

    function launchOrFocus(item) {
        if (!item)
            return
        if (root.trayPendingItem !== null)
            return

        const tokens = tokensFor(item)
        const win = findWindow(tokens)
        if (win !== null) {
            Hyprland.dispatch("focuswindow address:" + win.address)
            return
        }

        trayPendingItem = item
        trayLauncher.command = ["bash", "-c", launchSh, "bash", tokens.join("|")]
        trayLauncher.running = true
    }

    // скрипт: ищет .desktop по токенам иконки и запускает его Exec;
    // пустой вывод -> в QML срабатывает фолбэк activate()
    readonly property string trayLaunchSh: [
        'exec_line=""',
        'best=""',
        'bestscore=0',
        'IFS="|" read -ra TOKS <<< "$1"',
        'for d in "$HOME/.local/share/applications" "/usr/local/share/applications" "/usr/share/applications" "/var/lib/flatpak/exports/share/applications" "$HOME/.local/share/flatpak/exports/share/applications"; do',
        '  [[ -d "$d" ]] || continue',
        '  for f in "$d"/*.desktop; do',
        '    [[ -f "$f" ]] || continue',
        '    stem="$(basename "$f")"; stem="${stem%.desktop}"; stem="${stem,,}"',
        '    wm=""; nm=""',
        '    wm="$(grep -m1 \'^StartupWMClass=\' "$f" 2>/dev/null || true)"; wm="${wm#StartupWMClass=}"; wm="${wm,,}"',
        '    nm="$(grep -m1 \'^Name=\' "$f" 2>/dev/null || true)"; nm="${nm#Name=}"; nm="${nm,,}"',
        '    sc=0',
        '    for t in "${TOKS[@]}"; do',
        '      [[ ${#t} -ge 3 ]] || continue',
        '      [[ "$wm" == "$t" ]] && (( sc < 100 )) && sc=100',
        '      [[ "$stem" == "$t" ]] && (( sc < 90 )) && sc=90',
        '      case "$wm $stem $nm" in *"$t"*) (( sc < 50 )) && sc=50 ;; esac',
        '    done',
        '    (( sc > bestscore )) && { bestscore=$sc; best="$f"; }',
        '  done',
        'done',
        '[[ -n "$best" ]] || exit 0',
        'exec_line="$(grep -m1 \'^Exec=\' "$best" || true)"',
        'exec_line="${exec_line#Exec=}"',
        'exec_line="$(printf \'%s\' "$exec_line" | sed -e \'s/ %[fFuUdDnNickvm]//g\' -e \'s/[[:space:]]*$//\')"',
        '[[ -n "$exec_line" ]] || exit 0',
        'setsid bash -c "exec $exec_line >/dev/null 2>&1" &',
        'echo started'
    ].join("\n")

    Process {
        id: trayLauncher

        stdout: StdioCollector {
            onStreamFinished: {
                const it = root.trayPendingItem
                root.trayPendingItem = null
                if (it !== null && text.trim() === "")
                    it.activate()
            }
        }
    }

    QsMenuOpener {
        id: trayOpener

        menu: root.trayCurrentItem !== null ? root.trayCurrentItem.menu : null
    }

    readonly property var trayMenuEntries: trayOpener.children !== null ? (trayOpener.children.values ?? []) : []

    // --- media ---
    readonly property var players: {
        const m = Mpris.players
        return m.values !== undefined ? m.values : m
    }
    property int playerIndex: 0
    readonly property var player: players.length === 0
        ? null
        : players[Math.min(playerIndex, players.length - 1)]
    readonly property bool isPlaying: player?.isPlaying ?? false

    // --- audio ---
    readonly property var sinkNode: Pipewire.ready ? Pipewire.defaultAudioSink : null
    readonly property var sourceNode: Pipewire.ready ? Pipewire.defaultAudioSource : null
    readonly property real sinkVolume: sinkNode?.audio?.volume ?? 0
    readonly property bool sinkMuted: sinkNode?.audio?.muted ?? false
    readonly property real sourceVolume: sourceNode?.audio?.volume ?? 0
    readonly property bool sourceMuted: sourceNode?.audio?.muted ?? false

    PwObjectTracker {
        objects: [root.sinkNode, root.sourceNode]
    }

    implicitWidth: expanded ? panelWidth : collapsedWidth
    implicitHeight: expanded ? panelColumn.implicitHeight + 34 : pillHeight

    // ---------- желе ----------
    Behavior on implicitWidth {
        NumberAnimation {
            duration: Styles.Theme.jellyDur
            easing.type: Easing.OutElastic
            easing.period: Styles.Theme.jellyPeriod
            easing.amplitude: Styles.Theme.jellyAmp
        }
    }
    Behavior on implicitHeight {
        NumberAnimation {
            duration: Styles.Theme.jellyDur - 80
            easing.type: Easing.OutElastic
            easing.period: 0.55
            easing.amplitude: 0.9
        }
    }

    scale: started ? 1 : 0.6
    opacity: started ? 1 : 0
    transformOrigin: Item.Top
    Behavior on scale {
        NumberAnimation {
            duration: 560
            easing.type: Easing.OutElastic
            easing.period: 0.45
            easing.amplitude: 0.85
        }
    }
    Behavior on opacity {
        NumberAnimation {
            duration: 170
            easing.type: Easing.OutQuad
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.now = new Date()
    }

    Timer {
        id: autoCollapse

        interval: 12000
        onTriggered: if (!root.menuOpen && !root.trayMenuOpen)
            root.expanded = false
    }

    // закрытие с задержкой после ухода мыши (чтобы успеть вернуться)
    Timer {
        id: hideTimer

        interval: 650
        onTriggered: if (!bgMouse.containsMouse && !bgMouse.pressed && !trayMenuTrack.containsMouse)
            root.expanded = false
    }

    onExpandedChanged: {
        hideTimer.stop()
        if (expanded) {
            closeTrayMenu()
            autoCollapse.restart()
        } else {
            menuOpen = false
        }
    }

    onMenuOpenChanged: if (menuOpen)
        dndSyncTimer.restart()

    // --- подписи быстрых настроек ---
    readonly property string wifiSub: {
        if (!Networking.wifiHardwareEnabled)
            return "нет адаптера"
        if (!Networking.wifiEnabled)
            return "выключен"
        const devs = Networking.devices.values ?? []
        for (let i = 0; i < devs.length; i++) {
            if (devs[i].type === 1 && devs[i].connected)
                return String(devs[i].name || "подключено")
        }
        return "включен"
    }

    readonly property string btSub: {
        const a = Bluetooth.defaultAdapter
        if (!a)
            return "нет адаптера"
        return a.enabled ? "включен" : "выключен"
    }

    readonly property string ppSub: PowerProfiles.profile === 2 ? "производ." : PowerProfiles.profile === 0 ? "экономия" : "баланс"

    readonly property string ppIcon: PowerProfiles.profile === 2 ? Styles.Theme.icPerfFast : PowerProfiles.profile === 0 ? Styles.Theme.icPerfSave : Styles.Theme.icPerfBalanced

    function quickAction(kind) {
        if (kind === "wifi") {
            Networking.wifiEnabled = !Networking.wifiEnabled
        } else if (kind === "bt") {
            const a = Bluetooth.defaultAdapter
            if (a)
                a.enabled = !a.enabled
        } else if (kind === "pp") {
            PowerProfiles.profile = (PowerProfiles.profile + 1) % 3
        } else if (kind === "shot") {
            root.expanded = false
            shotProc.running = true
        } else if (kind === "dnd") {
            runMenuAction("dnd")
        } else if (kind === "mute") {
            runMenuAction("mute")
        } else if (kind === "lock") {
            root.expanded = false
            lockProc.running = true
        } else if (kind === "logout") {
            logoutProc.running = true
        }
    }

    function runMenuAction(kind) {
        if (kind === "shutdown") {
            root.expanded = false
            powerOffProc.running = true
        } else if (kind === "reboot") {
            root.expanded = false
            rebootProc.running = true
        } else if (kind === "dnd") {
            dndOn = !dndOn
            dndToggleProc.running = true
            dndSyncTimer.restart()
        } else if (kind === "mute") {
            if (root.sinkNode?.audio)
                root.sinkNode.audio.muted = !root.sinkNode.audio.muted
        } else if (kind === "lock") {
            root.expanded = false
            lockProc.running = true
        } else if (kind === "logout") {
            root.expanded = false
            logoutProc.running = true
        } else if (kind === "shot") {
            root.expanded = false
            shotProc.running = true
        } else if (kind === "files") {
            launchApp(["nautilus"])
        } else if (kind === "net") {
            launchApp(["nm-connection-editor"])
        } else if (kind === "mixer") {
            launchApp(["pavucontrol"])
        } else if (kind === "monitor") {
            launchApp(["alacritty", "-e", "btop"])
        } else if (kind === "wall") {
            root.expanded = false
            wallProc.running = true
        }
    }

    Process {
        id: powerOffProc

        command: ["systemctl", "poweroff"]
    }

    Process {
        id: rebootProc

        command: ["systemctl", "reboot"]
    }

    // запуск приложений из меню
    Process {
        id: appProc

        command: []
    }

    function launchApp(args) {
        root.expanded = false
        appProc.command = args
        appProc.running = true
    }

    // смена обоев через pywal-скрипт
    Process {
        id: wallProc

        command: ["bash", "-c", "~/.config/hypr/theme/switch.sh"]
    }

    // скриншот области
    Process {
        id: shotProc

        command: ["bash", "-c", "mkdir -p \"$HOME/Pictures/Screenshots\"; grim -g \"$(slurp)\" \"$HOME/Pictures/Screenshots/shot-$(date +%H%M%S).png\""]
    }

    // блокировка
    Process {
        id: lockProc

        command: ["bash", "-c", "command -v hyprlock >/dev/null 2>&1 && exec hyprlock || exec loginctl lock-session"]
    }

    Process {
        id: logoutProc

        command: ["hyprctl", "dispatch", "exit"]
    }

    Process {
        id: dndToggleProc

        command: ["sh", "-c", "if command -v dunstctl >/dev/null 2>&1; then dunstctl set-paused toggle; elif command -v makoctl >/dev/null 2>&1; then makoctl mode toggle >/dev/null 2>&1; elif command -v swaync-client >/dev/null 2>&1; then swaync-client -d >/dev/null 2>&1; fi"]
    }

    Process {
        id: dndQueryProc

        command: ["sh", "-c", "if command -v dunstctl >/dev/null 2>&1; then dunstctl is-paused 2>/dev/null; elif command -v makoctl >/dev/null 2>&1; then makoctl mode 2>/dev/null | grep -q do-not-disturb && echo true || echo false; elif command -v swaync-client >/dev/null 2>&1; then swaync-client get-dnd 2>/dev/null; else echo false; fi"]

        stdout: StdioCollector {
            onStreamFinished: root.dndOn = text.trim() === "true"
        }
    }

    Timer {
        id: dndSyncTimer

        interval: 350
        onTriggered: dndQueryProc.running = true
    }

    // --- подсветка ---
    Process {
        id: blQueryProc

        command: ["bash", "-c", "cur=$(cat /sys/class/backlight/*/brightness 2>/dev/null | head -n1); max=$(cat /sys/class/backlight/*/max_brightness 2>/dev/null | head -n1); if [ -n \"$cur\" ] && [ -n \"$max\" ] && [ \"$max\" -gt 0 ]; then echo \"$cur $max\"; fi"]

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(/\s+/)
                if (parts.length === 2) {
                    root.hasBacklight = true
                    root.backlightLevel = Math.max(0.01, Math.min(1, Number(parts[0]) / Number(parts[1])))
                }
            }
        }
    }

    function setBacklight(v) {
        root.backlightLevel = v
        blSetProc.value = Math.round(Math.max(1, v * 255))
        blSetProc.running = true
    }

    Component.onCompleted: {
        Qt.callLater(() => root.started = true)
        blQueryProc.running = true
        dndQueryProc.running = true
    }

    Process {
        id: blSetProc

        property int value: 100

        command: ["bash", "-c", "f=$(ls /sys/class/backlight/*/brightness 2>/dev/null | head -n1); [ -n \"$f\" ] && echo $1 > \"$f\"", "bash", String(blSetProc.value)]
    }

    // нижний радиус скругления (верхние углы всегда прямые)
    property real bottomRadius: root.expanded ? 26 : 14
    Behavior on bottomRadius {
        NumberAnimation {
            duration: 240
            easing.type: Easing.Bezier
            easing.bezierCurve: [0.22, 1, 0.36, 1]
        }
    }

    // фон: контур с прямыми верхними углами и скруглённым низом
    Item {
        id: bgGlowWrap

        anchors.fill: parent

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Styles.Theme.accent2
            shadowBlur: bgMouse.containsMouse ? 0.85 : 0.65
            shadowOpacity: bgMouse.containsMouse ? 0.8 : 0.55
            shadowVerticalOffset: 0
            shadowHorizontalOffset: 0
            shadowScale: bgMouse.containsMouse ? 1.05 : 1.02

            Behavior on shadowBlur {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on shadowOpacity {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on shadowScale {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                }
            }
        }

        Shape {
            id: background

            anchors.fill: parent
            antialiasing: true
            asynchronous: false

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#000000"
                shadowBlur: bgMouse.containsMouse ? 0.9 : 0.7
                shadowOpacity: bgMouse.containsMouse ? 0.65 : 0.55
                shadowVerticalOffset: 0
                shadowHorizontalOffset: 0

                Behavior on shadowBlur {
                    NumberAnimation {
                        duration: 160
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on shadowOpacity {
                    NumberAnimation {
                        duration: 160
                        easing.type: Easing.OutCubic
                    }
                }
            }

            // ---- заливка ----
            ShapePath {
                strokeWidth: 0
                strokeColor: "transparent"

                fillColor: root.expanded ? Styles.Theme.bgBottom : Qt.rgba(Styles.WallColor.line.r * 0.42, Styles.WallColor.line.g * 0.42, Styles.WallColor.line.b * 0.42, 0.94)

                startX: 0
                startY: 0

                PathLine {
                    x: background.width
                    y: 0
                }
                PathLine {
                    x: background.width
                    y: background.height - root.bottomRadius
                }
                PathArc {
                    x: background.width - root.bottomRadius
                    y: background.height
                    radiusX: root.bottomRadius
                    radiusY: root.bottomRadius
                }
                PathLine {
                    x: root.bottomRadius
                    y: background.height
                }
                PathArc {
                    x: 0
                    y: background.height - root.bottomRadius
                    radiusX: root.bottomRadius
                    radiusY: root.bottomRadius
                }
                PathLine {
                    x: 0
                    y: 0
                }
            }
        }
    }

    MouseArea {
        id: bgMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        // открытие по наведению
        onEntered: {
            hideTimer.stop()
            root.expanded = true
        }
        onExited: hideTimer.restart()
        onPositionChanged: if (root.expanded)
            autoCollapse.restart()

        // скролл по пилюле: вниз -> вправо к трею, вверх -> влево к часам
        onWheel: wheel => {
            if (root.expanded || root.trayMenuOpen)
                return
            const dy = wheel.angleDelta.y
            if (dy < 0)
                root.pillPage = Math.min(1, root.pillPage + 1)
            else if (dy > 0)
                root.pillPage = Math.max(0, root.pillPage - 1)
        }

        onClicked: {
            if (!root.expanded) {
                root.expanded = true
            } else {
                root.menuOpen = !root.menuOpen
            }
        }
    }

    // контент обрезается по границам острова -> раскрывается вместе с анимацией
    Item {
        id: contentClip

        anchors.fill: parent
        clip: true

        // ================= COLLAPSED PILL: страницы часы/трей =================
        Item {
            id: pillViewport

            readonly property real vw: root.collapsedWidth - 24

            anchors.centerIn: parent
            width: vw
            height: root.pillHeight
            visible: !root.expanded
            opacity: root.expanded ? 0 : 1
            clip: true

            Behavior on opacity {
                NumberAnimation {
                    duration: 90
                }
            }

            // стрип из двух страниц; активная всегда по центру.
            // скролл вниз -> панорама вправо (трей), скролл вверх -> влево (часы)
            Row {
                id: pillStrip

                spacing: root.pageGap
                anchors.verticalCenter: parent.verticalCenter
                x: pillPage === 0 ? (pillViewport.vw - clockPage.implicitWidth) / 2 : (pillViewport.vw - trayPage.implicitWidth) / 2 - (clockPage.implicitWidth + root.pageGap)

                Behavior on x {
                    NumberAnimation {
                        duration: 480
                        easing.type: Easing.OutElastic
                        easing.period: 0.45
                        easing.amplitude: 0.8
                    }
                }

                // ---- страница 1: часы ----
                RowLayout {
                    id: clockPage

                    spacing: 0

                    // цифры без «хвостов» выглядят выше центра — оптическая компенсация
                    transform: Translate {
                        y: 5
                    }

                    Text {
                        text: Qt.formatDateTime(root.now, "HH")
                        color: Styles.Theme.text
                        font.family: Styles.Theme.fontFamily
                        font.pixelSize: 16
                        font.bold: true
                    }

                    Text {
                        text: ":"
                        color: Styles.Theme.text
                        font.family: Styles.Theme.fontFamily
                        font.pixelSize: 16
                        font.bold: true
                    }

                    Text {
                        text: Qt.formatDateTime(root.now, "mm")
                        color: Styles.Theme.text
                        font.family: Styles.Theme.fontFamily
                        font.pixelSize: 16
                        font.bold: true
                    }

                    Text {
                        text: ":"
                        color: Styles.Theme.text
                        font.family: Styles.Theme.fontFamily
                        font.pixelSize: 16
                        font.bold: true
                    }

                    Text {
                        id: collapsedSeconds

                        text: Qt.formatDateTime(root.now, "ss")
                        color: Styles.Theme.text
                        font.family: Styles.Theme.fontFamily
                        font.pixelSize: 16
                        font.bold: true

                        SequentialAnimation {
                            id: secondsPulse

                            NumberAnimation {
                                target: collapsedSeconds
                                property: "scale"
                                to: 1.16
                                duration: 60
                                easing.type: Easing.OutQuad
                            }
                            NumberAnimation {
                                target: collapsedSeconds
                                property: "scale"
                                to: 1
                                duration: 220
                                easing.type: Easing.OutElastic
                                easing.period: 0.4
                                easing.amplitude: 0.8
                            }
                        }

                        onTextChanged: secondsPulse.restart()
                    }
                }

                // ---- страница 2: иконки трея ----
                Row {
                    id: trayPage

                    spacing: 2

                    Repeater {
                        model: root.trayItems

                        Item {
                            id: iconWrap

                            required property var modelData

                            width: 26
                            height: 26

                            Component.onDestruction: if (iconMa.containsMouse)
                                root.trayHoverCount = Math.max(0, root.trayHoverCount - 1)

                            Rectangle {
                                anchors.fill: parent
                                radius: 13
                                color: iconMa.containsMouse ? Styles.Theme.surfaceHover : "transparent"
                                scale: iconMa.pressed ? 0.86 : iconMa.containsMouse ? 1.08 : 1

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 110
                                    }
                                }
                                Behavior on scale {
                                    NumberAnimation {
                                        duration: 110
                                        easing.type: Easing.OutBack
                                    }
                                }
                            }

                            IconImage {
                                anchors.centerIn: parent
                                source: iconWrap.modelData.icon
                                asynchronous: true
                                width: 17
                                height: 17
                            }

                            MouseArea {
                                id: iconMa

                                anchors.fill: parent
                                anchors.margins: -3
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                                cursorShape: Qt.PointingHandCursor

                                onEntered: root.trayHoverCount++
                                onExited: root.trayHoverCount = Math.max(0, root.trayHoverCount - 1)

                                onClicked: mouse => {
                                    const it = iconWrap.modelData
                                    if (mouse.button === Qt.RightButton) {
                                        const p = iconWrap.mapToItem(root, iconWrap.width / 2, 0)
                                        root.openTrayMenuFor(it, p.x)
                                    } else if (mouse.button === Qt.MiddleButton) {
                                        it.secondaryActivate()
                                    } else {
                                        root.launchOrFocus(it)
                                    }
                                }

                                onWheel: wheel => {
                                    const dy = wheel.angleDelta.y
                                    const d = Math.trunc(dy / 120) || (dy > 0 ? 1 : -1)
                                    iconWrap.modelData.scroll(d, false)
                                }
                            }
                        }
                    }
                }
            }
        }

        // ================= EXPANDED PANEL =================
        ColumnLayout {
            id: panelColumn

            anchors {
                fill: parent
                leftMargin: 22
                rightMargin: 22
                topMargin: 20
                bottomMargin: 18
            }
            spacing: 12
            visible: root.expanded
            opacity: root.expanded ? 1 : 0
            enabled: root.expanded
            transform: Translate {
                y: root.expanded ? 0 : -14

                Behavior on y {
                    NumberAnimation {
                        duration: 290
                        easing.type: Easing.Bezier
                        easing.bezierCurve: [0.24, 1.1, 0.32, 1]
                    }
                }
            }
            Behavior on opacity {
                NumberAnimation {
                    duration: 160
                    easing.type: Easing.OutQuad
                }
            }

            // header: clock + battery + close
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                ColumnLayout {
                    spacing: 2

                    RowLayout {
                        spacing: 2

                        Text {
                            text: Qt.formatDateTime(root.now, "HH:mm")
                            color: Styles.Theme.text
                            font.family: Styles.Theme.fontFamily
                            font.pixelSize: 28
                            font.bold: true
                        }

                        Text {
                            text: ":" + Qt.formatDateTime(root.now, "ss")
                            color: Styles.Theme.accent2
                            font.family: Styles.Theme.fontFamily
                            font.pixelSize: 14
                            font.bold: true

                            Layout.alignment: Qt.AlignBottom
                            Layout.bottomMargin: 5
                        }
                    }

                    Text {
                        text: Qt.formatDate(root.now, Qt.locale("ru_RU"), "dddd, d MMMM")
                        color: Styles.Theme.textDim
                        font.family: Styles.Theme.fontFamily
                        font.pixelSize: 11
                        font.capitalization: Font.Capitalize
                        font.letterSpacing: 0.4
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                // батарея
                Rectangle {
                    visible: UPower.displayDevice?.isPresent ?? false
                    width: battRow.implicitWidth + 18
                    height: 30
                    radius: 15
                    color: Styles.Theme.surface

                    RowLayout {
                        id: battRow

                        anchors.centerIn: parent
                        spacing: 7

                        IconImage {
                            source: UPower.onBattery ? Styles.Theme.icBattery : Styles.Theme.icBatteryCharging
                            width: 15
                            height: 15
                        }

                        Text {
                            readonly property real frac: UPower.displayDevice?.percentage ?? 0
                            readonly property int pct: Math.round(frac <= 1 ? frac * 100 : frac)

                            text: pct + "%"
                            color: UPower.onBattery && pct <= 20 ? Styles.Theme.red : pct <= 40 ? Styles.Theme.yellow : Styles.Theme.text
                            font.family: Styles.Theme.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                        }
                    }
                }

                Rectangle {
                    width: 30
                    height: 30
                    radius: 15
                    color: menuMa.containsMouse ? Styles.Theme.surfaceHover : Styles.Theme.surface
                    scale: menuMa.pressed ? 0.88 : menuMa.containsMouse ? 1.08 : 1
                    rotation: root.menuOpen ? 90 : 0

                    Behavior on scale {
                        NumberAnimation {
                            duration: Styles.Theme.popDur
                            easing.type: Easing.OutBack
                            easing.overshoot: Styles.Theme.popOvershoot
                        }
                    }
                    Behavior on rotation {
                        NumberAnimation {
                            duration: 170
                            easing.type: Easing.OutBack
                        }
                    }

                    IconImage {
                        anchors.centerIn: parent
                        source: root.menuOpen ? Styles.Theme.icClose : Styles.Theme.icMenu
                        width: 14
                        height: 14
                    }

                    MouseArea {
                        id: menuMa

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.menuOpen = !root.menuOpen
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(1, 1, 1, 0.07)
            }

            // ================= SYSTEM MENU =================
            ColumnLayout {
                id: menuView

                Layout.fillWidth: true
                visible: root.menuOpen
                opacity: root.menuOpen ? 1 : 0
                enabled: root.menuOpen
                spacing: 6

                transform: Translate {
                    y: root.menuOpen ? 0 : -10

                    Behavior on y {
                        NumberAnimation {
                            duration: 260
                            easing.type: Easing.Bezier
                            easing.bezierCurve: [0.24, 1.1, 0.32, 1]
                        }
                    }
                }
                Behavior on opacity {
                    NumberAnimation {
                        duration: 130
                        easing.type: Easing.OutQuad
                    }
                }

                // единый плоский список: заголовки секций + строки действий
                readonly property var items: [
                    {
                        header: "СИСТЕМА"
                    },
                    {
                        kind: "dnd",
                        label: "Не беспокоить",
                        toggle: true
                    },
                    {
                        kind: "mute",
                        label: "Без звука",
                        toggle: true
                    },
                    {
                        kind: "lock",
                        label: "Заблокировать экран",
                        icon: Styles.Theme.icLock
                    },
                    {
                        kind: "logout",
                        label: "Выйти из сессии",
                        icon: Styles.Theme.icLogout,
                        danger: true
                    },
                    {
                        header: "ПРИЛОЖЕНИЯ"
                    },
                    {
                        kind: "files",
                        label: "Файловый менеджер",
                        icon: Styles.Theme.icFolder
                    },
                    {
                        kind: "net",
                        label: "Сетевые соединения",
                        icon: Styles.Theme.icNetWired
                    },
                    {
                        kind: "mixer",
                        label: "Микшер громкости",
                        icon: Styles.Theme.icMixer
                    },
                    {
                        kind: "monitor",
                        label: "Монитор системы",
                        icon: Styles.Theme.icStats
                    },
                    {
                        kind: "wall",
                        label: "Сменить обои",
                        icon: Styles.Theme.icWallpaper
                    },
                    {
                        kind: "shot",
                        label: "Скриншот области",
                        icon: Styles.Theme.icShot
                    },
                    {
                        header: "ПИТАНИЕ"
                    },
                    {
                        kind: "shutdown",
                        label: "Выключение",
                        icon: Styles.Theme.icShutdown,
                        danger: true
                    },
                    {
                        kind: "reboot",
                        label: "Перезагрузка",
                        icon: Styles.Theme.icReboot
                    }
                ]

                function tileColor(kind) {
                    if (kind === "shutdown" || kind === "logout")
                        return Qt.alpha(Styles.Theme.red, 0.16)
                    if (kind === "dnd" || kind === "wall" || kind === "shot")
                        return Qt.alpha(Styles.Theme.yellow, 0.16)
                    if (kind === "mute" || kind === "files" || kind === "reboot")
                        return Qt.alpha(Styles.Theme.accent2, 0.16)
                    return Qt.alpha(Styles.Theme.accent, 0.16)
                }

                function tileIcon(modelData) {
                    const kind = modelData.kind
                    if (kind === "dnd")
                        return root.dndOn ? Styles.Theme.icBellOff : Styles.Theme.icBell
                    if (kind === "mute")
                        return root.sinkMuted ? Styles.Theme.icVolMute : Styles.Theme.icVolHi
                    return modelData.icon ?? Styles.Theme.icMenu
                }

                Repeater {
                    model: menuView.items

                    Item {
                        id: menuEntry

                        required property var modelData
                        required property int index

                        readonly property bool isHeader: modelData.header !== undefined

                        Layout.fillWidth: true
                        implicitHeight: menuEntry.isHeader ? 18 : 34

                        // заголовок секции
                        Text {
                            visible: menuEntry.isHeader
                            anchors.fill: parent
                            anchors.leftMargin: 4
                            text: menuEntry.modelData.header ?? ""
                            color: Styles.Theme.textDim
                            font.family: Styles.Theme.fontFamily
                            font.pixelSize: 10
                            font.bold: true
                            font.letterSpacing: 2.2
                            verticalAlignment: Text.AlignVCenter
                        }

                        // строка действия
                        Rectangle {
                            id: menuRow

                            visible: !menuEntry.isHeader
                            anchors.fill: parent
                            radius: 12
                            color: rowMa.containsMouse ? Styles.Theme.surfaceHover : Styles.Theme.surface
                            scale: rowMa.pressed ? 0.96 : 1

                            readonly property bool isToggle: menuEntry.modelData.toggle === true
                            readonly property bool isDanger: menuEntry.modelData.danger === true
                            readonly property bool active: menuEntry.modelData.kind === "dnd" ? root.dndOn : menuEntry.modelData.kind === "mute" ? root.sinkMuted : false

                            Behavior on scale {
                                NumberAnimation {
                                    duration: Styles.Theme.popDur
                                    easing.type: Easing.OutBack
                                    easing.overshoot: Styles.Theme.popOvershoot
                                }
                            }
                            Behavior on color {
                                ColorAnimation {
                                    duration: 100
                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 9
                                anchors.rightMargin: 12
                                spacing: 11

                                transform: Translate {
                                    x: rowMa.containsMouse || rowMa.pressed ? 3 : 0

                                    Behavior on x {
                                        NumberAnimation {
                                            duration: 140
                                            easing.type: Easing.OutCubic
                                        }
                                    }
                                }

                                Rectangle {
                                    width: 26
                                    height: 26
                                    radius: 8
                                    color: menuView.tileColor(menuEntry.modelData.kind)

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 140
                                        }
                                    }

                                    IconImage {
                                        anchors.centerIn: parent
                                        source: menuView.tileIcon(menuEntry.modelData)
                                        width: 14
                                        height: 14
                                    }
                                }

                                Text {
                                    text: menuEntry.modelData.label ?? ""
                                    color: menuRow.active ? Styles.Theme.accent2 : menuRow.isDanger ? Styles.Theme.red : Styles.Theme.text
                                    font.family: Styles.Theme.fontFamily
                                    font.pixelSize: 12
                                }

                                Item {
                                    Layout.fillWidth: true
                                }

                                Rectangle {
                                    visible: menuRow.isToggle
                                    width: 8
                                    height: 8
                                    radius: 4
                                    color: menuRow.active ? Styles.Theme.green : "transparent"
                                    border.color: menuRow.active ? Styles.Theme.green : Styles.Theme.textDim
                                    border.width: 1

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 120
                                        }
                                    }
                                }

                                IconImage {
                                    visible: !menuRow.isToggle
                                    source: Styles.Theme.icChevron
                                    width: 13
                                    height: 13
                                    opacity: 0.45
                                }
                            }

                            MouseArea {
                                id: rowMa

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.runMenuAction(menuEntry.modelData.kind)
                            }
                        }
                    }
                }
            }

            // ================= QUICK SETTINGS =================
            Text {
                text: "БЫСТРЫЕ НАСТРОЙКИ"
                color: Styles.Theme.textDim
                font.family: Styles.Theme.fontFamily
                font.pixelSize: 10
                font.bold: true
                font.letterSpacing: 2.2
                visible: !root.menuOpen

                Layout.leftMargin: 4
            }

            GridLayout {
                id: quickGrid

                columns: 4
                columnSpacing: 8
                rowSpacing: 8
                visible: !root.menuOpen
                Layout.fillWidth: true

                Repeater {
                    model: [
                        {
                            kind: "wifi",
                            title: "Wi-Fi",
                            sub: root.wifiSub,
                            icon: Networking.wifiEnabled ? Styles.Theme.icWifi : Styles.Theme.icWifiOff,
                            tint: Styles.Theme.accent2
                        },
                        {
                            kind: "bt",
                            title: "Bluetooth",
                            sub: root.btSub,
                            icon: Styles.Theme.icBt,
                            tint: Styles.Theme.accent
                        },
                        {
                            kind: "pp",
                            title: "Питание",
                            sub: root.ppSub,
                            icon: root.ppIcon,
                            tint: Styles.Theme.green
                        },
                        {
                            kind: "shot",
                            title: "Область",
                            sub: "скриншот",
                            icon: Styles.Theme.icShot,
                            tint: Styles.Theme.yellow
                        },
                        {
                            kind: "dnd",
                            title: "Не беспокоить",
                            sub: root.dndOn ? "вкл" : "выкл",
                            icon: root.dndOn ? Styles.Theme.icBellOff : Styles.Theme.icBell,
                            tint: Styles.Theme.yellow
                        },
                        {
                            kind: "mute",
                            title: "Звук",
                            sub: root.sinkMuted ? "выкл" : Math.round(root.sinkVolume * 100) + "%",
                            icon: Styles.Theme.volumeIcon(root.sinkVolume, root.sinkMuted),
                            tint: Styles.Theme.accent2
                        },
                        {
                            kind: "lock",
                            title: "Блокировка",
                            sub: "экрана",
                            icon: Styles.Theme.icLock,
                            tint: Styles.Theme.accent
                        },
                        {
                            kind: "logout",
                            title: "Выход",
                            sub: "из сессии",
                            icon: Styles.Theme.icLogout,
                            tint: Styles.Theme.red
                        }
                    ]

                    Rectangle {
                        id: qTile

                        required property var modelData

                        readonly property bool active: modelData.kind === "dnd" ? root.dndOn : modelData.kind === "wifi" ? Networking.wifiEnabled : modelData.kind === "bt" ? (Bluetooth.defaultAdapter?.enabled ?? false) : modelData.kind === "mute" ? !root.sinkMuted : false

                        Layout.fillWidth: true
                        Layout.preferredHeight: 56
                        radius: 14
                        color: qTileMa.containsMouse ? Styles.Theme.surfaceHover : Styles.Theme.surface
                        scale: qTileMa.pressed ? 0.94 : qTileMa.containsMouse ? 1.03 : 1

                        Behavior on scale {
                            NumberAnimation {
                                duration: Styles.Theme.popDur
                                easing.type: Easing.OutBack
                                easing.overshoot: Styles.Theme.popOvershoot
                            }
                        }
                        Behavior on color {
                            ColorAnimation {
                                duration: 110
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 9
                            anchors.rightMargin: 6
                            spacing: 9

                            transform: Translate {
                                x: qTileMa.containsMouse || qTileMa.pressed ? 2 : 0

                                Behavior on x {
                                    NumberAnimation {
                                        duration: 140
                                        easing.type: Easing.OutCubic
                                    }
                                }
                            }

                            Rectangle {
                                width: 32
                                height: 32
                                radius: 10
                                color: Qt.alpha(qTile.modelData.tint, qTile.active ? 0.3 : 0.15)

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 140
                                    }
                                }

                                IconImage {
                                    anchors.centerIn: parent
                                    source: qTile.modelData.icon
                                    width: 16
                                    height: 16
                                }
                            }

                            ColumnLayout {
                                spacing: 1
                                Layout.fillWidth: true

                                Text {
                                    text: qTile.modelData.title
                                    color: qTile.active ? qTile.modelData.tint : Styles.Theme.text
                                    font.family: Styles.Theme.fontFamily
                                    font.pixelSize: 12
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: qTile.modelData.sub
                                    color: Styles.Theme.textDim
                                    font.family: Styles.Theme.fontFamily
                                    font.pixelSize: 10
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        MouseArea {
                            id: qTileMa

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.quickAction(qTile.modelData.kind)
                        }
                    }
                }
            }

            // яркость
            SliderRow {
                Layout.fillWidth: true
                visible: !root.menuOpen && root.hasBacklight
                icon: Styles.Theme.icBrightness
                accentColor: Styles.Theme.yellow
                value: root.backlightLevel
                muted: false
                onEdited: v => root.setBacklight(v)
                onToggleMuted: () => {
                }
            }

            // media card
            Text {
                text: "МЕДИА"
                color: Styles.Theme.textDim
                font.family: Styles.Theme.fontFamily
                font.pixelSize: 10
                font.bold: true
                font.letterSpacing: 2.2
                visible: !root.menuOpen && root.player !== null

                Layout.leftMargin: 4
            }

            MediaCard {
                Layout.fillWidth: true
                visible: !root.menuOpen && root.player !== null
                player: root.player
                players: root.players
                playerIndex: root.playerIndex
                onSelectPlayer: function(index) {
                    root.playerIndex = index
                }
            }

            // volume + mic
            Text {
                text: "ЗВУК"
                color: Styles.Theme.textDim
                font.family: Styles.Theme.fontFamily
                font.pixelSize: 10
                font.bold: true
                font.letterSpacing: 2.2
                visible: !root.menuOpen

                Layout.leftMargin: 4
                Layout.topMargin: 2
            }

            SliderRow {
                Layout.fillWidth: true
                visible: !root.menuOpen
                icon: Styles.Theme.volumeIcon(root.sinkVolume, root.sinkMuted)
                accentColor: Styles.Theme.accent2
                value: root.sinkVolume
                muted: root.sinkMuted
                onEdited: function(v) {
                    if (root.sinkNode?.audio)
                        root.sinkNode.audio.volume = v
                }
                onToggleMuted: () => {
                    if (root.sinkNode?.audio)
                        root.sinkNode.audio.muted = !root.sinkNode.audio.muted
                }
            }

            SliderRow {
                Layout.fillWidth: true
                visible: !root.menuOpen && root.sourceNode !== null
                icon: root.sourceMuted ? Styles.Theme.icMicOff : Styles.Theme.icMic
                accentColor: Styles.Theme.accent
                value: root.sourceVolume
                muted: root.sourceMuted
                onEdited: function(v) {
                    if (root.sourceNode?.audio)
                        root.sourceNode.audio.volume = v
                }
                onToggleMuted: () => {
                    if (root.sourceNode?.audio)
                        root.sourceNode.audio.muted = !root.sourceNode.audio.muted
                }
            }
        }
    }

    // ================= МЕНЮ ТРЕЯ (ПКМ по иконке) =================
    // вне contentClip: висит под пилюлей и может выходить за границы острова
    Item {
        id: trayMenuLayer

        x: 0
        y: 0
        width: Math.max(root.width, trayMenuCard.x + trayMenuCard.width + 8)
        height: Math.min(540, trayMenuCard.y + trayMenuCard.height + 12)

        visible: opacity > 0.01
        opacity: root.trayMenuOpen ? 1 : 0
        enabled: root.trayMenuOpen

        Behavior on opacity {
            NumberAnimation {
                duration: 140
                easing.type: Easing.OutQuad
            }
        }

        // клик мимо карточки закрывает меню
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.ArrowCursor
            onClicked: root.closeTrayMenu()
            onWheel: root.closeTrayMenu()
        }

        Rectangle {
            id: trayMenuCard

            x: Math.min(Math.max(root.trayAnchorX - width / 2, 4), Math.max(root.width - width - 4, 4))
            y: root.pillHeight + 6
            width: 250
            height: trayMenuCol.implicitHeight + 16
            radius: 16
            border.color: Styles.WallColor.line
            border.width: 1
            gradient: Gradient {
                GradientStop {
                    position: 0
                    color: Styles.Theme.bgTop
                }
                GradientStop {
                    position: 1
                    color: Styles.Theme.bgBottom
                }
            }

            scale: root.trayMenuOpen ? 1 : 0.88
            transformOrigin: Item.Top

            Behavior on scale {
                NumberAnimation {
                    duration: Styles.Theme.jellyDur - 100
                    easing.type: Easing.OutElastic
                    easing.period: Styles.Theme.jellyPeriod
                    easing.amplitude: Styles.Theme.jellyAmp
                }
            }

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#000000"
                shadowBlur: 0.7
                shadowOpacity: 0.6
                shadowVerticalOffset: 4
                shadowHorizontalOffset: 0
            }

            // геометрический трекер курсора: не перехватывает клики кнопок
            MouseArea {
                id: trayMenuTrack

                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                hoverEnabled: true
            }

            // мышь ушла и с иконок, и с пилюли, и с меню -> закрыть
            Timer {
                interval: 700
                repeat: true
                running: root.trayMenuOpen
                onTriggered: if (!trayMenuTrack.containsMouse && root.trayHoverCount === 0 && !bgMouse.containsMouse)
                    root.closeTrayMenu()
            }

            Column {
                id: trayMenuCol

                anchors.fill: parent
                anchors.margins: 8
                spacing: 3

                Text {
                    visible: root.trayCurrentItem !== null && String(root.trayCurrentItem.title ?? "") !== ""
                    text: String(root.trayCurrentItem?.title ?? "").toUpperCase()
                    color: Styles.Theme.textDim
                    font.family: Styles.Theme.fontFamily
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 2.2
                    leftPadding: 5
                    bottomPadding: 3
                }

                Flickable {
                    id: trayFlick

                    width: parent.width
                    height: Math.min(trayMenuList.implicitHeight, 400)
                    contentHeight: trayMenuList.implicitHeight
                    clip: true
                    interactive: trayMenuList.implicitHeight > 400
                    boundsBehavior: Flickable.StopAtBounds

                    Column {
                        id: trayMenuList

                        width: trayFlick.width
                        spacing: 1

                        Repeater {
                            model: root.trayMenuEntries

                            Item {
                                id: entryRoot

                                required property var modelData

                                readonly property var e: modelData

                                width: trayMenuList.width
                                height: e.isSeparator ? 9 : 34

                                Rectangle {
                                    visible: entryRoot.e.isSeparator
                                    anchors.centerIn: parent
                                    width: parent.width - 20
                                    height: 1
                                    color: Qt.rgba(1, 1, 1, 0.07)
                                }

                                Rectangle {
                                    visible: !entryRoot.e.isSeparator
                                    anchors.fill: parent
                                    radius: 9
                                    color: entryMa.containsMouse && entryRoot.e.enabled ? Styles.Theme.surfaceHover : "transparent"
                                    scale: entryMa.pressed ? 0.97 : 1
                                    opacity: entryRoot.e.enabled ? 1 : 0.38

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 100
                                        }
                                    }
                                    Behavior on scale {
                                        NumberAnimation {
                                            duration: 100
                                            easing.type: Easing.OutQuad
                                        }
                                    }

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 8
                                        anchors.rightMargin: 10
                                        spacing: 8

                                        // чекбокс / радиокнопка
                                        Rectangle {
                                            visible: entryRoot.e.buttonType === 1 || entryRoot.e.buttonType === 2
                                            Layout.preferredWidth: 14
                                            Layout.preferredHeight: 14
                                            Layout.alignment: Qt.AlignVCenter
                                            radius: entryRoot.e.buttonType === 2 ? 7 : 4
                                            color: "transparent"
                                            border.color: entryRoot.e.checkState === 2 ? Styles.Theme.accent2 : Styles.Theme.textDim
                                            border.width: 1

                                            Rectangle {
                                                anchors.centerIn: parent
                                                width: entryRoot.e.buttonType === 2 ? 8 : 6
                                                height: width
                                                radius: width / 2
                                                color: entryRoot.e.checkState === 2 ? Styles.Theme.green : entryRoot.e.checkState === 1 ? Styles.Theme.yellow : "transparent"
                                                visible: entryRoot.e.checkState !== 0
                                            }
                                        }

                                        IconImage {
                                            visible: String(entryRoot.e.icon ?? "") !== ""
                                            source: entryRoot.e.icon
                                            asynchronous: true
                                            Layout.preferredWidth: 15
                                            Layout.preferredHeight: 15
                                            Layout.alignment: Qt.AlignVCenter
                                        }

                                        Text {
                                            text: entryRoot.e.text
                                            color: Styles.Theme.text
                                            font.family: Styles.Theme.fontFamily
                                            font.pixelSize: 12
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }

                                        IconImage {
                                            visible: entryRoot.e.hasChildren
                                            source: Styles.Theme.icChevron
                                            asynchronous: true
                                            Layout.preferredWidth: 12
                                            Layout.preferredHeight: 12
                                            Layout.alignment: Qt.AlignVCenter
                                            opacity: 0.45
                                        }
                                    }

                                    MouseArea {
                                        id: entryMa

                                        anchors.fill: parent
                                        hoverEnabled: true
                                        enabled: entryRoot.e.enabled && !entryRoot.e.isSeparator
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (entryRoot.e.hasChildren) {
                                                // подменю — нативный dbusmenu-попап
                                                const p = mapToItem(null, width - 6, height / 2)
                                                entryRoot.e.display(QsWindow.window, Math.round(p.x), Math.round(p.y))
                                            } else {
                                                root.closeTrayMenu()
                                                entryRoot.e.triggered()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
