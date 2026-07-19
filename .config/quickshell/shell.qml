import Quickshell
import QtQuick
import "."
import Quickshell.Io

Scope {
    Bar {
        id: bar
        launcherActive: launcher.isOpen
        onOpenLauncher: launcher.toggle()
        onOpenWallpaper: wallpaper.toggle()
        onLockScreen: lockScreen.lock()
    }

    Binding {
        target: launcher
        property: "filterText"
        value: bar.launcherQuery
    }

    LockScreen {
        id: lockScreen
    }

    Launcher {
        id: launcher
        anchor.window: bar
        anchor.rect.x: bar.width / 2 - width / 2
        anchor.rect.y: bar.height
    }

    Wallpaper {
        id: wallpaper
        anchor.window: bar
        anchor.rect.x: bar.width / 2 - width / 2
        anchor.rect.y: bar.height
    }

    Shortcut {
        sequence: "Ctrl+Alt+L"
        onActivated: lockScreen.lock()
    }

    Shortcut {
        sequence: "Ctrl+Alt+Space"
        onActivated: launcher.toggle()
    }

    WalColors {
        id: walColors
    }

    Connections {
        target: wallpaper
        function onWallpaperChanged() {
            walColors.loadColors()
        }
    }

    IpcHandler {
        target: "qs"

        function toggleLauncher(): void { launcher.toggle(); }
        function toggleWallpaper(): void { wallpaper.toggle(); }
        function toggleLock(): void { lockScreen.lock(); }
    }
}