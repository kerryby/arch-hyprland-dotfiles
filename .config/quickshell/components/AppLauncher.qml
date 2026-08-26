import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Shapes
import "../styles" as Styles

// Контент лаунчера приложений: поиск + сетка.
// Размещается внутри своего PanelWindow (см. shell.qml).
Item {
    id: root

    property bool shown: false
    property string query: ""
    property var apps: []
    property int launchIndex: 0

    readonly property bool pointerInside: hoverTrack.hovered

    readonly property var filtered: {
        const q = query.trim().toLowerCase()
        if (q === "")
            return apps
        return apps.filter(a => a.name.toLowerCase().includes(q) || a.exec.toLowerCase().includes(q))
    }

    signal dismissed()

    readonly property QtObject cardScale: QtObject {
        property real value: 1
    }

    function openUp() {
        query = ""
        launchIndex = 0
        shown = true
        searchField.forceActiveFocus()
    }

    function closeDown() {
        shown = false
        searchField.focus = false
    }

    function launch(app) {
        if (!app)
            return
        const cmd = app.term ? "alacritty -e " + app.exec : app.exec
        spawnProc.cmd = cmd
        spawnProc.running = true
        dismissed()
    }

    onShownChanged: if (shown) {
        pop.restart()
        searchField.forceActiveFocus()
    }

    SequentialAnimation {
        id: pop

        NumberAnimation {
            target: cardScale
            property: "value"
            from: 0.92
            to: 1.04
            duration: 150
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: cardScale
            property: "value"
            to: 1
            duration: 320
            easing.type: Easing.OutElastic
            easing.period: 0.42
            easing.amplitude: 0.7
        }
    }

    Process {
        id: spawnProc

        property string cmd: ""

        command: ["bash", "-c", "setsid bash -c 'exec " + spawnProc.cmd + " >/dev/null 2>&1' &"]
    }

    // парсинг .desktop
    readonly property string scanSh: [
        'resolve_icon() {',
        '  local icon="$1"',
        '  [[ -z "$icon" ]] && { echo ""; return; }',
        '  if [[ "$icon" = /* ]]; then echo "$icon"; return; fi',
        '  local f d s ext',
        '  for f in "/usr/share/pixmaps/$icon.png" "/usr/share/pixmaps/$icon.xpm" "/usr/share/icons/hicolor/scalable/apps/$icon.svg"; do',
        '    [[ -f "$f" ]] && { echo "$f"; return; }',
        '  done',
        '  for s in 512x512 256x256 128x128 96x96 64x64 48x48 32x32 scalable 48 22; do',
        '    for d in "$HOME/.local/share/icons" /usr/share/icons/hicolor /usr/share/icons/breeze-dark; do',
        '      for ext in png svg xpm; do',
        '        f="$d/$s/apps/$icon.$ext";      [[ -f "$f" ]] && { echo "$f"; return; }',
        '        f="$d/apps/$s/$icon.$ext";      [[ -f "$f" ]] && { echo "$f"; return; }',
        '        f="$d/$s/mimetypes/$icon.$ext"; [[ -f "$f" ]] && { echo "$f"; return; }',
        '      done',
        '    done',
        '  done',
        '  echo ""',
        '}',
        'declare -A SEEN',
        'for d in "$HOME/.local/share/applications" /usr/local/share/applications /usr/share/applications /var/lib/flatpak/exports/share/applications "$HOME/.local/share/flatpak/exports/share/applications"; do',
        '  [[ -d "$d" ]] || continue',
        '  for f in "$d"/*.desktop; do',
        '    [[ -f "$f" ]] || continue',
        '    grep -qiE "^NoDisplay=true" "$f" 2>/dev/null && continue',
        '    grep -qiE "^Hidden=true" "$f" 2>/dev/null && continue',
        '    name="$(grep -m1 "^Name=" "$f")";   name="${name#Name=}"',
        '    exec="$(grep -m1 "^Exec=" "$f")";   exec="${exec#Exec=}"',
        '    icon="$(grep -m1 "^Icon=" "$f")";   icon="${icon#Icon=}"',
        '    term="$(grep -cm1 "^Terminal=true" "$f")"',
        '    [[ -n "$name" && -n "$exec" ]] || continue',
        '    exec="$(printf \'%s\' "$exec" | sed -e \'s/ %[fFuUdDnNickvm]//g\' -e \'s/[[:space:]]*$//\')"',
        '    key="$name|$exec"',
        '    [[ -z "${SEEN[$key]:-}" ]] || continue',
        '    SEEN[$key]=1',
        '    printf \'%s\\x1f%s\\x1f%s\\x1f%s\\n\' "$name" "$exec" "$(resolve_icon "$icon")" "$term"',
        '  done',
        'done | sort -t$\'\\x1f\' -k1,1f'
    ].join("\n")

    Process {
        id: scanRunner

        command: ["bash", "-c", root.scanSh]

        stdout: StdioCollector {
            onStreamFinished: {
                const rows = text.split("\n")
                const list = []
                for (let i = 0; i < rows.length; i++) {
                    const p = rows[i].split("\u001f")
                    if (p.length >= 4 && p[0] !== "")
                        list.push({
                            name: p[0],
                            exec: p[1],
                            icon: p[2],
                            term: p[3] === "1"
                        })
                }
                root.apps = list
            }
        }
    }

    Component.onCompleted: scanRunner.running = true

    Item {
        id: pad

        anchors.fill: parent

        // пассивный трекер курсора: не конфликтует с MouseArea плиток
        HoverHandler {
            id: hoverTrack
        }

        // карточка: прижата к низу экрана, нижние углы «ножками» расходятся в стороны
        Item {
            id: card

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            width: Math.min(820, pad.width)
            height: Math.min(600, pad.height)

            opacity: root.shown ? 1 : 0
            scale: cardScale.value * (root.shown ? 1 : 0.94)
            transformOrigin: Item.Bottom

            Behavior on opacity {
                NumberAnimation {
                    duration: 140
                }
            }

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#000000"
                shadowBlur: 0.8
                shadowOpacity: 0.6
                shadowVerticalOffset: -4
            }

            Shape {
                id: cardShape

                anchors.fill: parent
                antialiasing: true
                asynchronous: false

                // радиус верхних углов, отступ тела от краёв окна, высота и длина подгиба
                readonly property real tr: 24
                readonly property real inset: 10
                readonly property real fh: 18
                readonly property real fl: 80

                ShapePath {
                    strokeWidth: 0
                    strokeColor: "transparent"
                    fillColor: Styles.Theme.bgTop

                    startX: cardShape.inset + cardShape.tr
                    startY: 0

                    PathLine {
                        x: cardShape.width - cardShape.inset - cardShape.tr
                        y: 0
                    }
                    PathArc {
                        x: cardShape.width - cardShape.inset
                        y: cardShape.tr
                        radiusX: cardShape.tr
                        radiusY: cardShape.tr
                    }
                    PathLine {
                        x: cardShape.width - cardShape.inset
                        y: cardShape.height - cardShape.fh
                    }
                    // правый угол: вогнуто подгибается внутрь, к центру дна
                    PathCubic {
                        control1X: cardShape.width - cardShape.inset
                        control1Y: cardShape.height - 3
                        control2X: cardShape.width - cardShape.inset - cardShape.fl + 28
                        control2Y: cardShape.height
                        x: cardShape.width - cardShape.inset - cardShape.fl
                        y: cardShape.height
                    }
                    // дно вплотную к экрану
                    PathLine {
                        x: cardShape.inset + cardShape.fl
                        y: cardShape.height
                    }
                    // левый угол: симметричный подгиб вверх к телу карточки
                    PathCubic {
                        control1X: cardShape.inset + cardShape.fl - 28
                        control1Y: cardShape.height
                        control2X: cardShape.inset
                        control2Y: cardShape.height - 3
                        x: cardShape.inset
                        y: cardShape.height - cardShape.fh
                    }
                    PathLine {
                        x: cardShape.inset
                        y: cardShape.tr
                    }
                    PathArc {
                        x: cardShape.inset + cardShape.tr
                        y: 0
                        radiusX: cardShape.tr
                        radiusY: cardShape.tr
                    }
                    PathLine {
                        x: cardShape.inset + cardShape.tr
                        y: 0
                    }
                }
            }

            ColumnLayout {
                anchors {
                    fill: parent
                    leftMargin: 28
                    rightMargin: 28
                    topMargin: 18
                    bottomMargin: 16
                }
                spacing: 12

                // список приложений
                ListView {
                    id: list

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: root.filtered
                    currentIndex: root.launchIndex
                    boundsBehavior: Flickable.StopAtBounds
                    spacing: 2

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }

                    delegate: Item {
                        id: rowItem

                        required property var modelData
                        required property int index

                        width: list.width
                        height: 36

                        Rectangle {
                            anchors.fill: parent
                            radius: 10
                            color: rowMa.containsMouse || list.currentIndex === rowItem.index ? Styles.Theme.surfaceHover : "transparent"
                            border.color: list.currentIndex === rowItem.index ? Qt.alpha(Styles.Theme.accent2, 0.5) : "transparent"
                            border.width: 1
                            scale: rowMa.pressed ? 0.98 : 1

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
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 12
                            spacing: 11

                            Rectangle {
                                width: 24
                                height: 24
                                radius: 7
                                color: Qt.alpha(Styles.Theme.accent2, rowMa.containsMouse ? 0.22 : 0.12)

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 120
                                    }
                                }

                                IconImage {
                                    anchors.centerIn: parent
                                    source: rowItem.modelData.icon !== "" ? "file://" + rowItem.modelData.icon : Styles.Theme.icMenu
                                    asynchronous: true
                                    width: 16
                                    height: 16
                                    mipmap: true
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                text: rowItem.modelData.name
                                color: Styles.Theme.text
                                font.family: Styles.Theme.fontFamily
                                font.pixelSize: 12
                                elide: Text.ElideRight
                                maximumLineCount: 1
                            }

                            IconImage {
                                visible: rowMa.containsMouse
                                source: Styles.Theme.icChevron
                                width: 12
                                height: 12
                                opacity: 0.45
                            }
                        }

                        MouseArea {
                            id: rowMa

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.launch(rowItem.modelData)
                            onEntered: root.launchIndex = rowItem.index
                        }
                    }
                }

                Text {
                    visible: root.filtered.length === 0
                    text: "Ничего не найдено"
                    color: Styles.Theme.textDim
                    font.family: Styles.Theme.fontFamily
                    font.pixelSize: 13
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 20
                }

                // строка поиска (снизу)
                Rectangle {
                    id: searchBox

                    Layout.fillWidth: true
                    height: 46
                    radius: 15
                    color: Styles.Theme.surface
                    border.color: searchField.activeFocus ? Qt.alpha(Styles.Theme.accent2, 0.55) : Styles.Theme.outline
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 10

                        IconImage {
                            source: Styles.Theme.icSearch
                            width: 16
                            height: 16
                            opacity: 0.7
                        }

                        TextInput {
                            id: searchField

                            Layout.fillWidth: true
                            color: Styles.Theme.text
                            font.family: Styles.Theme.fontFamily
                            font.pixelSize: 14
                            clip: true
                            verticalAlignment: TextInput.AlignVCenter
                            cursorVisible: activeFocus

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                visible: searchField.text === "" && !searchField.activeFocus
                                text: "Поиск приложений…"
                                color: Styles.Theme.textDim
                                font.family: Styles.Theme.fontFamily
                                font.pixelSize: 13
                            }

                            onTextChanged: {
                                root.query = text
                                root.launchIndex = 0
                            }

                            Keys.onEscapePressed: root.dismissed()
                            Keys.onReturnPressed: root.launch(root.filtered[root.launchIndex])
                            Keys.onEnterPressed: root.launch(root.filtered[root.launchIndex])
                            Keys.onDownPressed: root.launchIndex = Math.min(root.filtered.length - 1, root.launchIndex + 1)
                            Keys.onUpPressed: root.launchIndex = Math.max(0, root.launchIndex - 1)
                        }

                        Text {
                            visible: root.filtered.length > 0
                            text: root.filtered.length + ""
                            color: Styles.Theme.textDim
                            font.family: Styles.Theme.fontFamily
                            font.pixelSize: 11
                        }
                    }
                }
            }
        }
    }
}
