local f = io.open("/tmp/hypr-perf-mode", "r")
if not f then return end
f:close()

hl.env("LIBGL_ALWAYS_SOFTWARE", "false")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")

hl.config({
    decoration = {
        rounding       = 3,
        rounding_power = 1,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        shadow = { enabled = false },
        blur = { enabled = false },
    },
    animations = { enabled = false },
    misc = {
        disable_autoreload = true,
        disable_hyprland_logo = true,
        disable_xdg_env_checks = true,
        mouse_move_enables_dpms = false,
        key_press_enables_dpms = false,
        vrr = 0,
    },
    debug = {
        disable_logs = false,
        overlay = false,
        damage_blink = false,
    },
    render = { direct_scanout = true },
    xwayland = {
        force_zero_scaling = true,
        use_nearest_neighbor = false,
    },
    general = { no_focus_fallback = true },
})

hl.animation({ leaf = "global", enabled = false })
