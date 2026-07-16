#!/bin/bash
FLAG="/tmp/hypr-perf-mode"
SETTINGS="$HOME/.config/noctalia/settings.json"
CONFIG_TOML="$HOME/.config/noctalia/config.toml"

if [ -f "$FLAG" ]; then
    rm "$FLAG"
    jq '.general.animationDisabled = false | .desktopWidgets.enabled = true' "$SETTINGS" > "${SETTINGS}.tmp" && mv "${SETTINGS}.tmp" "$SETTINGS"
    sed -i 's/\(label.*=\).*"PERF ON"/\1 "PERF OFF"/' "$CONFIG_TOML"
    sed -i 's/\(glyph.*=\).*"zap"$/\1 "zap-off"/' "$CONFIG_TOML"
    noctalia msg desktop-widgets-show
    echo "Оптимизации ВЫКЛ — оригинальный конфиг"
else
    touch "$FLAG"
    jq '.general.animationDisabled = true | .desktopWidgets.enabled = false' "$SETTINGS" > "${SETTINGS}.tmp" && mv "${SETTINGS}.tmp" "$SETTINGS"
    sed -i 's/\(label.*=\).*"PERF OFF"/\1 "PERF ON"/' "$CONFIG_TOML"
    sed -i 's/\(glyph.*=\).*"zap-off"/\1 "zap"/' "$CONFIG_TOML"
    noctalia msg desktop-widgets-hide
    echo "Оптимизации ВКЛ — производительность"
fi

noctalia msg config-reload
noctalia msg bar-toggle "default" > /dev/null 2>&1
noctalia msg bar-toggle "default" > /dev/null 2>&1
hyprctl reload config-only
