	-- ==============================================================
-- 6. АВТОЗАПУСК (AUTOSTART)
-- Программы и команды, выполняемые при старте Hyprland
-- ==============================================================

hl.on("hyprland.start", function ()
   hl.exec_cmd("awww-daemon")

   hl.exec_cmd("hyprctl setcursor AOSP-cursors 16")

   hl.exec_cmd("quickshell")

   -- Автосмена темы: случайные обои каждые 30 минут (1800 сек)
   hl.exec_cmd("awww restore")
   hl.exec_cmd("~/.config/hypr/theme/switch.sh 1800")

   -- Автозапуск в определенных рабочих столах

   hl.exec_cmd("[workspace 1 silent] /home/kerry/Applications/YandexMusic.AppImage")
   hl.exec_cmd("[workspace 2 silent] vscodium")
   hl.exec_cmd("[workspace 3 silent] google-chrome-stable")
end)

