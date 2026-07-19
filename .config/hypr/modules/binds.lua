-- ==============================================================
-- 9. ГОРЯЧИЕ КЛАВИШИ (KEYBINDS)
-- Программы, привязки клавиш, медиакнопки, мышь
-- ==============================================================

local terminal    = "alacritty"
local fileManager = "nautilus"
local menu        = "noctalia msg panel-toggle launcher"
local browser     = "google-chrome-stable"

local mainMod = "SUPER"

-- Терминал
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))

-- Закрыть окно
local closeWindowBind = hl.bind(mainMod .. " + C", hl.dsp.window.close())

-- Выход из Hyprland
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("hyprctl dispatch exit"))

-- Файловый менеджер
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))

-- Переключение плавающего режима окна
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))

-- Лаунчер Quickshell
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("qs ipc call qs toggleLauncher"))

-- Блокировка Quickshell
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("qs ipc call qs toggleLock"))

-- Обои Quickshell
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("qs ipc call qs toggleWallpaper"))

-- Псевдо-раскладка (dwindle only)
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())

-- Переключение режима разделения (dwindle only)
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

-- Браузер
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(browser))

-- Скриншот области (grim + slurp)
hl.bind(mainMod .. " + CTRL + S", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy"))

-- Cloudflare WARP: подключение
hl.bind(mainMod .. " + F12", hl.dsp.exec_cmd("warp-cli connect"))

-- Cloudflare WARP: отключение
hl.bind(mainMod .. " + F11", hl.dsp.exec_cmd("warp-cli disconnect"))

-- Фокус по стрелкам
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Переключение рабочих столов и перемещение окон по [0-9]
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

-- Специальный workspace (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Пролистывание рабочих столов колёсиком мыши
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Перетаскивание и изменение размера окон мышью
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Мультимедиа клавиши: громкость
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })

-- Мультимедиа клавиши: яркость
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- Мультимедиа клавиши: треки (playerctl)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
