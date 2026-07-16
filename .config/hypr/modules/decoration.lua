-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in  = 8,
        gaps_out = 10,

        border_size = 2,

        col = {
            active_border   = { colors = {"rgba(ffffff80)"}, angle = 45 },
            inactive_border = "rgba(59595940)",
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing = false,

        layout = "dwindle",
    },

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
            enabled   = false,
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

-- Default curves and animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })
hl.curve("custom",	   { type = "bezier", points = { {0, 0.6},     {0.5, 1}     } })
-- Default springs
hl.curve("easy",           { type = "spring", mass = 2, stiffness = 50, dampening = 50 })

hl.animation({ leaf = "global",        enabled = true,  speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true,  speed = 10,   bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true,  speed = 10,   spring = "easy" })
hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 10,   spring = "easy",         style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 10,   bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 2.5,  bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 2.5,  bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true,  speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true,  speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true,  speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true,  speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 1,    bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 1,    bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true,  speed = 1,    bezier = "almostLinear", style = "slide" })
hl.animation({ leaf = "workspacesIn",  enabled = true,  speed = 9,    bezier = "custom", style = "slidefade 60%" })
hl.animation({ leaf = "workspacesOut", enabled = true,  speed = 9,    bezier = "custom", style = "slidefade 60%" })
hl.animation({ leaf = "zoomFactor",    enabled = true,  speed = 7,    bezier = "quick" })

-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
hl.window_rule({
	name = "no-gaps-f1",
	match = {float = false, workspace = "f[1]" },
	border_size = 0,
	rounding     = 0,
})
-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
    dwindle = {
        preserve_split = true, -- You probably want this
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
    master = {
        new_status = "master",
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/ for more
hl.config({
    scrolling = {
        fullscreen_on_one_column = true,
    },
})
