#!/usr/bin/env bash
# Автосмена темы через pywal + awww
# Использование:
#   switch.sh            — одна случайная смена
#   switch.sh <секунды>  — цикл со сменой каждые N секунд
#   switch.sh /путь.jpg  — установить конкретную тему

WALL_DIR="${THEME_WALL_DIR:-$HOME/Pictures/wallpapers}"
STATE="$HOME/.cache/hypr-theme-last"
CONF="$HOME/.cache/wal/colors-hyprland.conf"
CACHE="$HOME/.cache/wal"

notify() { command -v notify-send >/dev/null && notify-send -t 3000 "Тема" "$1"; }

pick_wallpaper() {
    mapfile -t walls < <(find "$WALL_DIR" -maxdepth 1 -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | sort)
    ((${#walls[@]})) || { echo "Нет обоев в $WALL_DIR" >&2; exit 1; }
    local last=""
    [[ -f $STATE ]] && last=$(<"$STATE")
    # случайный, но не тот же, что прошлый
    while :; do
        wall=${walls[RANDOM % ${#walls[@]}]}
        [[ $wall != "$last" ]] && break
        ((${#walls[@]} > 1)) || break
    done
}

set_theme() {
    wall=$1

    wal -i "$wall" -n -q || return 1

    # обои
    pgrep -x awww-daemon >/dev/null && awww img "$wall"
    [[ -f $wall ]] && echo "$wall" >"$STATE"

    # точные цвета из пикселей обоев -> alacritty/vscodium/opencode/quickshell/fastfetch
    command -v python3 >/dev/null && \
        python3 "$HOME/.config/hypr/theme/wall-exact.py" "$wall" >/dev/null 2>&1 || true

    # раскладка палитры по приложениям (quickshell подхватывает файл хот-релоадом)
    [[ -f $CACHE/colors-opencode.json ]] && \
        cp "$CACHE/colors-opencode.json" "$HOME/.config/opencode/themes/pywal.json"
    [[ -f $CACHE/colors-quickshell.json ]] && \
        cp "$CACHE/colors-quickshell.json" "$HOME/.config/quickshell/styles/palette.json"
    [[ -f $CACHE/colors-fastfetch.jsonc ]] && \
        cp "$CACHE/colors-fastfetch.jsonc" "$HOME/.config/fastfetch/config.jsonc"

    # цвета Hyprland из сгенерированного pywal конфига
    [[ -f $CONF ]] || return 0
    declare -A c=()
    while IFS='=' read -r k v; do
        k=$(xargs <<<"${k#\$}"); v=$(xargs <<<"$v")
        [[ -n $k && -n $v ]] && c[$k]=$v
    done <"$CONF"

    hyprctl keyword general:col:active_border   "${c[active_border]}"   >/dev/null
    hyprctl keyword general:col:inactive_border "${c[inactive_border]}" >/dev/null
    hyprctl keyword decoration:shadow:color     "0x${c[shadow_color]#rgb(}" >/dev/null

    notify "$(basename "$wall")"
}

case ${1:-} in
''|*[!0-9]*)
    if [[ -f ${1:-} ]]; then
        set_theme "$1"
    else
        pick_wallpaper; set_theme "$wall"
    fi
    ;;
*)
    interval=$1
    pick_wallpaper; set_theme "$wall"
    while sleep "$interval"; do
        pick_wallpaper; set_theme "$wall"
    done
    ;;
esac
