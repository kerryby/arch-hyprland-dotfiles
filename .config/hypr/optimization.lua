-------------------------------
----  PERFORMANCE TWEAKS   ----
----  для Intel HD 2000     ----
-------------------------------

hl.config({
    misc = {
        disable_autoreload = true,
        disable_hyprland_logo = true,
        disable_xdg_env_checks = true,
        mouse_move_enables_dpms = false,
        key_press_enables_dpms = false,
        vfr = true,
        vrr = 0,
    },
    debug = {
        disable_logs = false,
        overlay = false,
        damage_blink = false,
    },
    render = {
        direct_scanout = true,
        explicit_sync = 0,
    },
    xwayland = {
        force_zero_scaling = true,
        use_nearest_neighbor = false,
    },
    general = {
        no_cursor_warps = true,
        no_focus_fallback = true,
    },
})

hl.animation({ leaf = "global", enabled = false })

    decoration = {
        rounding       = 7,
        rounding_power = 3,

        -- Change transparency of focused and unfocused windows
        active_opacity   = 0.9,
        inactive_opacity = 0.7,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled   = true,
            size      = 2,
            passes    = 3,
	    vibrancy = 0.14,
	    new_optimizations = true
        },
    },

    animations = {
        enabled = true,
    },
})
