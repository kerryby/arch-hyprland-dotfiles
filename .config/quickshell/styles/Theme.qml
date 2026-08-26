pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: theme

    // Палитра из pywal: ~/.config/quickshell/styles/palette.json (хот-релоад через FileView)
    property var _pal: ({})

    function _col(key, fallback) {
        const v = _pal[key]
        return (v !== undefined && v !== "") ? v : fallback
    }

    function _readPal() {
        try {
            const t = palFile.text()
            _pal = (t && t.trim() !== "") ? JSON.parse(t) : {}
        } catch (e) {
            _pal = {}
        }
    }

    FileView {
        id: palFile

        path: Qt.resolvedUrl("palette.json")
        watchChanges: true

        onLoaded: theme._readPal()
        onFileChanged: {
            reload()
            theme._readPal()
        }
        Component.onCompleted: theme._readPal()
    }

    readonly property color bgTop: _col("bgTop", "#201f30")
    readonly property color bgBottom: _col("bgBottom", "#14141c")
    readonly property color surface: Qt.rgba(1, 1, 1, 0.06)
    readonly property color surfaceHover: Qt.rgba(1, 1, 1, 0.1)
    readonly property color text: _col("text", "#c8d3f5")
    readonly property color textDim: _col("textDim", "#7981ad")
    readonly property color accent: _col("accent", "#bb9af7")
    readonly property color accent2: _col("accent2", "#7aa2f7")
    readonly property color green: _col("green", "#9ece6a")
    readonly property color yellow: _col("yellow", "#e0af68")
    readonly property color red: _col("red", "#f7768e")
    readonly property color outline: Qt.rgba(1, 1, 1, 0.09)
    readonly property color groove: Qt.rgba(1, 1, 1, 0.08)

    readonly property string fontFamily: "BigBlueTermPlus Nerd Font Mono"

    // иконки — прямые ссылки на breeze-dark (тема Qt может быть не настроена)
    readonly property string _i: "file:///usr/share/icons/breeze-dark"
    readonly property string icPlay: _i + "/actions/22/media-playback-start.svg"
    readonly property string icPause: _i + "/actions/22/media-playback-pause.svg"
    readonly property string icNext: _i + "/actions/22/media-skip-forward.svg"
    readonly property string icPrev: _i + "/actions/22/media-skip-backward.svg"
    readonly property string icVolHi: _i + "/status/22/audio-volume-high.svg"
    readonly property string icVolLo: _i + "/status/22/audio-volume-low.svg"
    readonly property string icVolMute: _i + "/status/22/audio-volume-muted.svg"
    readonly property string icMic: _i + "/status/22/microphone-sensitivity-high.svg"
    readonly property string icMicOff: _i + "/status/22/microphone-sensitivity-muted.svg"
    readonly property string icMusic: _i + "/mimetypes/22/audio-x-generic.svg"
    readonly property string icClose: _i + "/actions/22/window-close.svg"
    readonly property string icShutdown: _i + "/actions/22/system-shutdown.svg"
    readonly property string icReboot: _i + "/actions/22/system-reboot.svg"
    readonly property string icBell: _i + "/actions/22/notification-active.svg"
    readonly property string icBellOff: _i + "/actions/22/notifications-disabled.svg"
    readonly property string icMenu: _i + "/actions/22/application-menu.svg"
    readonly property string icChevron: _i + "/actions/22/go-next.svg"
    readonly property string icChevronL: _i + "/actions/22/go-previous.svg"

    // трей / лаунчер / меню
    readonly property string icLock: _i + "/actions/22/system-lock-screen.svg"
    readonly property string icLogout: _i + "/actions/22/system-log-out.svg"
    readonly property string icShot: _i + "/devices/22/camera-photo.svg"
    readonly property string icSearch: _i + "/actions/22/edit-find.svg"
    readonly property string icShuffle: _i + "/actions/22/media-playlist-shuffle.svg"
    readonly property string icRepeat: _i + "/actions/22/media-playlist-repeat.svg"
    readonly property string icRepeatOne: _i + "/actions/22/media-playlist-repeat-song.svg"
    readonly property string icBrightness: _i + "/actions/22/brightness-high.svg"
    readonly property string icWifi: _i + "/devices/22/network-wireless.svg"
    readonly property string icWifiOff: _i + "/status/22/network-wireless-0.svg"
    readonly property string icBt: _i + "/devices/22/network-bluetooth.svg"
    readonly property string icBattery: _i + "/status/22/battery-full.svg"
    readonly property string icBatteryCharging: _i + "/status/22/battery-full-charging.svg"
    readonly property string icCalendar: _i + "/actions/22/view-calendar-month.svg"
    readonly property string icClock2: _i + "/actions/22/clock.svg"
    readonly property string icHeadphones: _i + "/devices/22/audio-headphones.svg"
    readonly property string icSpeedometer: _i + "/actions/22/speedometer.svg"
    readonly property string icPerfBalanced: _i + "/actions/22/speedometer.svg"
    readonly property string icPerfFast: _i + "/status/22/battery-100-profile-performance.svg"
    readonly property string icPerfSave: _i + "/status/22/battery-000-profile-powersave.svg"

    // пункты системного меню
    readonly property string icFolder: _i + "/actions/22/document-open-folder.svg"
    readonly property string icNetWired: _i + "/devices/22/network-wired.svg"
    readonly property string icMixer: _i + "/status/22/audio-volume-high.svg"
    readonly property string icStats: _i + "/actions/22/view-statistics.svg"
    readonly property string icWallpaper: _i + "/preferences/22/preferences-desktop-wallpaper.svg"

    // ---------- желе-анимации ----------
    // пружина для размеров/позиций
    readonly property int jellyDur: 520
    readonly property real jellyPeriod: 0.5
    readonly property real jellyAmp: 0.75
    // «отдача» для нажатий/появлений
    readonly property int popDur: 160
    readonly property real popOvershoot: 1.6

    function volumeIcon(value, muted) {
        if (muted || value <= 0.001)
            return icVolMute
        if (value < 0.45)
            return icVolLo
        return icVolHi
    }

    function fmtSeconds(total) {
        const s = Math.max(0, Math.floor(total || 0))
        const m = Math.floor(s / 60)
        const r = s % 60
        return m + ":" + (r < 10 ? "0" : "") + r
    }
}
