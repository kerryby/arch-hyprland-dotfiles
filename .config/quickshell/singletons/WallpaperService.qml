import QtQml
import Quickshell
import Quickshell.Io

pragma Singleton

QtObject {
  id: wallpaperService

  property string currentWallpaper: ""
  property string wallpaperDir: "/home/kerry/Pictures/wallpapers"
  property var wallpaperList: []
  property int currentIndex: -1

  function scanWallpapers() {
    var proc = Process.createObject(wallpaperService, {
      command: ["bash", "-c",
        "find " + wallpaperDir + " -type f \\( -name '*.jpg' -o -name '*.png' -o -name '*.jpeg' -o -name '*.webp' \\) | sort"
      ],
      running: true,
      stdout: StdioCollector {
        onStreamFinished: function(data) {
          var items = data.trim().split("\n").filter(function(p) { return p.length > 0 })
          wallpaperService.wallpaperList = items
          if (items.length > 0 && wallpaperService.currentIndex < 0) {
            wallpaperService.currentIndex = 0
          }
        }
      }
    })
  }

  function setWallpaper(path) {
    currentWallpaper = path
    var proc = Process.createObject(wallpaperService, {
      command: ["swww", "img", path, "--transition-type", "fade", "--transition-duration", "2"],
      running: true
    })
    ThemeService.generateFromImage(path)
  }

  function next() {
    if (wallpaperList.length === 0) return
    currentIndex = (currentIndex + 1) % wallpaperList.length
    setWallpaper(wallpaperList[currentIndex])
  }

  function previous() {
    if (wallpaperList.length === 0) return
    currentIndex = (currentIndex - 1 + wallpaperList.length) % wallpaperList.length
    setWallpaper(wallpaperList[currentIndex])
  }

  function random() {
    if (wallpaperList.length === 0) return
    var idx = Math.floor(Math.random() * wallpaperList.length)
    currentIndex = idx
    setWallpaper(wallpaperList[idx])
  }
}