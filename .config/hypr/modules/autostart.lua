-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function () 
   hl.exec_cmd("awww-daemon")
   hl.exec_cmd("noctalia")
   hl.exec_cmd("hyprctl setcursor Remus-Dark 16")

   -- Запуск приложений по рабочим столам
   hl.exec_cmd("[workspace 1 silent] /home/kerry/YandexMusicMod-5.86.0-2.2.0.linux_c2d683fdf06202026a8eda40d5774569.AppImage")
   hl.exec_cmd("[workspace 2 silent] vscodium")
   hl.exec_cmd("[workspace 3 silent] google-chrome-stable")
end)
