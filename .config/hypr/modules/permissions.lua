-- ==============================================================
-- 5. РАЗРЕШЕНИЯ (PERMISSIONS)
-- Разрешает приложениям захват экрана (screencopy)
-- ==============================================================

hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
