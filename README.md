# Arch Hyprland Dotfiles

Мои конфиги для Arch Linux с Hyprland (Lua-конфиг).

## Состав

| Компонент | Конфиг |
|---|---|
| **Hyprland** | `.config/hypr/` — полноценная Lua-конфигурация |
| **Alacritty** | `.config/alacritty/` |
| **Btop** | `.config/btop/` |
| **Fastfetch** | `.config/fastfetch/` |
| **Fish** | `.config/fish/` |
| **GTK3/GTK4** | `.config/gtk-3.0/`, `.config/gtk-4.0/` |
| **Micro** | `.config/micro/` (настройки + темы) |
| **Neovim** | `.config/nvim/` |
| **Pavucontrol** | `.config/pavucontrol.ini` |
| **Shell** | `.zshrc`, `.bashrc` |

## Установка

```bash
git clone git@github.com:kerryby/arch-hyprland-dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

Скрипт создаст симлинки в `$HOME`.
