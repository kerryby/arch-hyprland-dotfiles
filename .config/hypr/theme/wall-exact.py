#!/usr/bin/env python3
# Точные цвета из пикселей текущих обоев -> конфиги программ.
# Использование: wall-exact.py /путь/к/обоям.jpg
# Программы: alacritty, vscodium, opencode, quickshell, fastfetch.
# Никакого pywal: только ImageMagick-кластеризация реальных пикселей.

import colorsys
import json
import re
import subprocess
import sys
from pathlib import Path

HOME = Path.home()
WALL = sys.argv[1] if len(sys.argv) > 1 else ""


def hexs(r, g, b):
    return "#%02X%02X%02X" % (round(r * 255), round(g * 255), round(b * 255))


def clamp(v, lo=0.0, hi=1.0):
    return max(lo, min(hi, v))


def hls(h, l, s):
    r, g, b = colorsys.hls_to_rgb(h % 1.0, clamp(l), clamp(s))
    return (r, g, b)


def lum(c):
    return (max(c) + min(c)) / 2


def sat(c):
    mx, mn = max(c), min(c)
    return 0 if mx == 0 else (mx - mn) / mx


def lighten(c, k=1.3, add=0.04):
    h, l, s = colorsys.rgb_to_hls(*c)
    return hls(h, min(0.97, l * k + add), s)


def darken(c, k):
    return tuple(v * k for v in c[:3])


def mix(a, b, t):
    return tuple(a[i] + (b[i] - a[i]) * t for i in range(3))


# ---------------- извлечение кластеров ----------------
def clusters(wall, n=18):
    out = subprocess.run(
        ["magick", wall, "-resize", "400x400^", "-gravity", "center",
         "-extent", "400x400", "-colors", str(n), "-depth", "8",
         "-format", "%c", "histogram:info:"],
        capture_output=True, text=True, timeout=30).stdout
    res = []
    for m in re.finditer(r"(\d+)\s*:\s*\((\d+),\s*(\d+),\s*(\d+)\)", out):
        cnt = int(m.group(1))
        rgb = tuple(int(m.group(i)) / 255 for i in (2, 3, 4))
        if cnt > 0:
            res.append((cnt, rgb))
    res.sort(key=lambda t: -t[0])
    return res


def pick_hue(cl, target_h, used):
    """Кластер с минимальной круговой дистанцией по тону.
    Тёмные/пересвеченные штрафуются. Если подходящих нет — синтезируем
    цвет из самого частотного кластера обоев, подставляя целевой тон."""
    best, bi, bd = None, -1, 999
    for i, (cnt, c) in enumerate(cl):
        if i in used:
            continue
        h, l, s = colorsys.rgb_to_hls(*c)
        if s < 0.045:
            continue
        d = abs(h - target_h)
        d = min(d, 1 - d)
        score = d + abs(l - 0.48) * 0.4 + max(0.0, 0.12 - l) * 2.0
        if score < bd:
            bd, best, bi = score, c, i
    if best is not None:
        used.add(bi)
        return best
    # синтез из доминирующего кластера: светлотa/хроматика обоев + точный тон
    cnt, c = max(cl, key=lambda t: t[0])
    h, l, s = colorsys.rgb_to_hls(*c)
    return hls(target_h, clamp(l, 0.32, 0.68), max(s, 0.32))


def hue_of(c):
    return colorsys.rgb_to_hls(*c)[0]


# ---------------- построение схемы ----------------
def build_scheme(wall):
    cl = clusters(wall)
    if not cl:
        print("нет кластеров", file=sys.stderr)
        sys.exit(1)

    by_lum = sorted([c for _, c in cl], key=lum)
    dark = by_lum[0]
    bg = dark if lum(dark) < 0.14 else darken(dark, 0.45)
    bg_bottom = darken(bg, 0.72)

    light = by_lum[-1]
    fg = light if lum(light) > 0.62 else lighten(light, 1.6, 0.25)

    used = set()
    # тон цели: red, green, yellow, blue, magenta, cyan
    ansi_t = {"red": 0.0, "green": 0.36, "yellow": 0.13,
              "blue": 0.63, "magenta": 0.85, "cyan": 0.5}
    picks = {}
    for name, th in ansi_t.items():
        c = pick_hue(cl, th, used)
        if c:
            picks[name] = c
    # акценты: фиолет и второй контрастный
    picks["accent"] = pick_hue(cl, 0.78, used)
    picks["accent2"] = pick_hue(cl, 0.58, used)

    def an(name, default):
        c = picks.get(name)
        return c if c else default

    def fit(c):
        """Тон обоев сохраняем, светлоту держим в рабочем диапазоне."""
        h, l, s = colorsys.rgb_to_hls(*c)
        return hls(h, min(0.78, max(0.30, l)), s)

    red, green, yellow = fit(an("red", (0.8, 0.3, 0.35))), fit(an("green", (0.35, 0.7, 0.4))), fit(an("yellow", (0.85, 0.7, 0.35)))
    blue, magenta, cyan = fit(an("blue", (0.4, 0.55, 0.85))), fit(an("magenta", (0.75, 0.45, 0.75))), fit(an("cyan", (0.35, 0.75, 0.75)))
    accent, accent2 = fit(an("accent", magenta)), fit(an("accent2", blue))
    if accent == accent2 or min(abs(hue_of(accent) - hue_of(accent2)), 1 - abs(hue_of(accent) - hue_of(accent2))) < 0.09:
        # слишком близки — разводим по светлоте и возвращаем в рамки
        if lum(accent) >= lum(accent2):
            accent2 = fit(lighten(accent, 1.45))
        else:
            accent = fit(lighten(accent2, 1.45))

    dim = mix(fg, bg, 0.48)
    s = {
        "bgTop": hexs(*bg), "bgBottom": hexs(*bg_bottom),
        "text": hexs(*fg), "textDim": hexs(*dim),
        "accent": hexs(*accent), "accent2": hexs(*accent2),
        "green": hexs(*green), "yellow": hexs(*yellow), "red": hexs(*red),
        "_raw": {
            "bg": bg, "bg2": darken(bg, 0.85), "fg": fg, "dim": dim,
            "black": bg, "bright_black": lighten(bg, 1.9, 0.07),
            "red": red, "green": green, "yellow": yellow,
            "blue": blue, "magenta": magenta, "cyan": cyan,
            "white": fg, "bright_white": lighten(fg, 1.08, 0.03),
            "accent": accent, "accent2": accent2,
        },
    }
    return s


# ---------------- писатели ----------------
def w_quickshell(p, s):
    data = {k: s[k] for k in ("bgTop", "bgBottom", "text", "textDim",
                              "accent", "accent2", "green", "yellow", "red")}
    p.write_text(json.dumps(data, indent=2) + "\n")


def w_alacritty(p, raw):
    b, f = raw["bg"], raw["fg"]
    lines = [
        "[colors.primary]", f'background = "{hexs(*b)}"', f'foreground = "{hexs(*f)}"',
        "", "[colors.cursor]",
        f'cursor = "{hexs(*f)}"',
        f'text = "{hexs(*b)}"', "", "[colors.normal]",
    ]
    normal = ["black", "red", "green", "yellow", "blue", "magenta", "cyan", "white"]
    # у alacritty ключи bright-секции называются как у normal
    bright_vals = [raw["bright_black"], raw["red"], raw["green"], raw["yellow"],
                   raw["blue"], raw["magenta"], raw["cyan"], raw["bright_white"]]
    for n in normal:
        lines.append(f'{n} = "{hexs(*raw[n])}"')
    lines += ["", "[colors.bright]"]
    for n, v in zip(normal, bright_vals):
        lines.append(f'{n} = "{hexs(*v)}"')
    p.write_text("\n".join(lines) + "\n")

    cfg = HOME / ".config/alacritty/alacritty.toml"
    txt = cfg.read_text() if cfg.exists() else ""
    mine = '"/home/%s/.config/alacritty/colors-wall.toml"' % HOME.name
    if "colors-wall.toml" not in txt:
        old = '"~/.cache/wal/colors-alacritty.toml"'
        if old in txt:
            txt = txt.replace(old, '"~/.config/alacritty/colors-wall.toml"')
        elif "import = [" in txt:
            txt = re.sub(r"(import\s*=\s*\[)", r"\1\n  \"~/.config/alacritty/colors-wall.toml\",", txt, count=1)
        else:
            txt += '[general]\nimport = ["~/.config/alacritty/colors-wall.toml"]\n'
        cfg.write_text(txt)


def w_opencode(p, raw):
    bg, bg2, fg, dim = raw["bg"], raw["bg2"], raw["fg"], raw["dim"]
    ac, ac2 = raw["accent"], raw["accent2"]
    g, y, r = raw["green"], raw["yellow"], raw["red"]
    cy, mg = raw["cyan"], raw["magenta"]
    t = {
        "primary": hexs(*ac), "secondary": hexs(*ac2), "accent": hexs(*lighten(ac, 1.25)),
        "error": hexs(*r), "warning": hexs(*y), "success": hexs(*g), "info": hexs(*ac2),
        "text": hexs(*fg), "textMuted": hexs(*dim),
        "background": hexs(*bg), "backgroundPanel": hexs(*darken(bg, 0.9)),
        "backgroundElement": hexs(*mix(bg, fg, 0.12)),
        "border": hexs(*darken(bg, 0.85)), "borderActive": hexs(*ac), "borderSubtle": hexs(*bg2),
        "diffAdded": hexs(*g), "diffRemoved": hexs(*r), "diffContext": hexs(*dim),
        "diffHunkHeader": hexs(*dim), "diffHighlightAdded": hexs(*lighten(g, 1.2)),
        "diffHighlightRemoved": hexs(*lighten(r, 1.2)),
        "diffAddedBg": hexs(*mix(bg, g, 0.10)), "diffRemovedBg": hexs(*mix(bg, r, 0.10)),
        "diffContextBg": hexs(*bg), "diffLineNumber": hexs(*dim),
        "markdownText": hexs(*fg), "markdownHeading": hexs(*lighten(ac, 1.2)),
        "markdownLink": hexs(*ac2), "markdownLinkText": hexs(*lighten(ac, 1.25)),
        "markdownCode": hexs(*g), "markdownBlockQuote": hexs(*dim),
        "markdownEmph": hexs(*mix(fg, dim, 0.4)), "markdownStrong": hexs(*fg),
        "markdownHorizontalRule": hexs(*dim), "markdownListItem": hexs(*lighten(ac, 1.2)),
        "markdownListEnumeration": hexs(*lighten(ac, 1.25)),
        "markdownImage": hexs(*ac2), "markdownImageText": hexs(*lighten(ac, 1.25)),
        "markdownCodeBlock": hexs(*fg),
        "syntaxComment": hexs(*dim), "syntaxKeyword": hexs(*lighten(ac, 1.25)),
        "syntaxFunction": hexs(*lighten(ac2, 1.15)), "syntaxVariable": hexs(*fg),
        "syntaxString": hexs(*g), "syntaxNumber": hexs(*y),
        "syntaxType": hexs(*cy), "syntaxOperator": hexs(*mg),
        "syntaxPunctuation": hexs(*mix(fg, dim, 0.25)),
    }
    p.write_text(json.dumps({"$schema": "https://opencode.ai/theme.json", "theme": t}, indent=2) + "\n")


def w_vscodium(raw):
    p = HOME / ".config/VSCodium/User/settings.json"
    if not p.exists():
        return
    try:
        st = json.loads(re.sub(r"^\s*//.*$", "", p.read_text(), flags=re.M))
    except Exception:
        return
    raw_ = raw
    bg, bg2, fg, dim = raw_["bg"], raw_["bg2"], raw_["fg"], raw_["dim"]
    ac, ac2 = raw_["accent"], raw_["accent2"]
    g, y, r, cy, mg = raw_["green"], raw_["yellow"], raw_["red"], raw_["cyan"], raw_["magenta"]
    st["workbench.colorTheme"] = "Default Dark Modern"
    st["workbench.colorCustomizations"] = {
        "editor.background": hexs(*bg),
        "editor.foreground": hexs(*fg),
        "editor.lineHighlightBackground": hexs(*mix(bg, fg, 0.05)) + "",
        "editorLineNumber.foreground": hexs(*dim),
        "editorLineNumber.activeForeground": hexs(*fg),
        "editorCursor.foreground": hexs(*lighten(ac, 1.2)),
        "editor.selectionBackground": hexs(*mix(bg, ac, 0.45)),
        "editorIndentGuide.background1": hexs(*mix(bg, fg, 0.09)),
        "sideBar.background": hexs(*bg2),
        "sideBarSectionHeader.background": hexs(*mix(bg2, fg, 0.06)),
        "activityBar.background": hexs(*bg2),
        "activityBar.foreground": hexs(*fg),
        "titleBar.activeBackground": hexs(*bg2),
        "titleBar.activeForeground": hexs(*fg),
        "statusBar.background": hexs(*bg2),
        "statusBar.noFolderBackground": hexs(*bg2),
        "statusBar.foreground": hexs(*fg),
        "panel.background": hexs(*bg),
        "terminal.background": hexs(*bg),
        "terminal.foreground": hexs(*fg),
        "tab.activeBackground": hexs(*bg),
        "tab.activeForeground": hexs(*fg),
        "tab.inactiveBackground": hexs(*bg2),
        "input.background": hexs(*mix(bg, fg, 0.05)),
        "dropdown.background": hexs(*bg2),
        "list.hoverBackground": hexs(*mix(bg, fg, 0.07)),
        "list.activeSelectionBackground": hexs(*mix(bg, ac, 0.30)),
        "scrollbarSlider.background": hexs(*mix(bg, fg, 0.14)) + "88",
        "minimapGutter.addedBackground": hexs(*g),
        "gitDecoration.modifiedResourceForeground": hexs(*y),
        "gitDecoration.untrackedResourceForeground": hexs(*g),
        "gitDecoration.deletedResourceForeground": hexs(*r),
    }
    st["editor.tokenColorCustomizations"] = {
        "comments": hexs(*dim),
        "strings": hexs(*g),
        "keywords": hexs(*lighten(mg, 1.15)),
        "numbers": hexs(*y),
        "types": hexs(*cy),
        "functions": hexs(*lighten(ac2, 1.15)),
        "variables": hexs(*fg),
    }
    p.write_text(json.dumps(st, indent=4) + "\n")


def w_fastfetch(raw):
    p = HOME / ".config/fastfetch/config.jsonc"
    if not p.exists():
        return
    txt = p.read_text()
    try:
        data = json.loads(txt)
    except Exception:
        data = json.loads(re.sub(r"^\s*//.*$", "", txt, flags=re.M))
    disp_colors = [raw["accent"], raw["fg"], raw["fg"], raw["dim"]]
    dc = data.get("display", {}).get("color")
    if isinstance(dc, dict):
        order = ["keys", "title", "output", "separator"]
        for i, k in enumerate(order):
            if k in dc:
                dc[k] = hexs(*disp_colors[i % len(disp_colors)])
    # все ключи модулей — один цвет, без радуги
    key_col = hexs(*raw["accent"])
    for mod in data.get("modules", []):
        if isinstance(mod, dict) and "keyColor" in mod:
            mod["keyColor"] = key_col
    p.write_text(json.dumps(data, indent=2) + "\n")


# ---------------- main ----------------
if not WALL or not Path(WALL).exists():
    print("usage: wall-exact.py <wallpaper>", file=sys.stderr)
    sys.exit(1)

scheme = build_scheme(WALL)
raw = scheme["_raw"]

w_quickshell(HOME / ".config/quickshell/styles/palette.json", scheme)
w_alacritty(HOME / ".config/alacritty/colors-wall.toml", raw)
w_opencode(HOME / ".config/opencode/themes/pywal.json", raw)
w_vscodium(raw)
w_fastfetch(raw)
print("ok:", WALL)
