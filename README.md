# Arch Hyprland Dotfiles

My configuration files for Arch Linux with Hyprland (Lua config).

## Contents

| Component | Config |
|---|---|
| **Hyprland** | `.config/hypr/` — full Lua configuration |
| **Alacritty** | `.config/alacritty/` |
| **Btop** | `.config/btop/` |
| **Fastfetch** | `.config/fastfetch/` |
| **Fish** | `.config/fish/` |
| **GTK3/GTK4** | `.config/gtk-3.0/`, `.config/gtk-4.0/` |
| **Micro** | `.config/micro/` (settings + themes) |
| **Neovim** | `.config/nvim/` |
| **Pavucontrol** | `.config/pavucontrol.ini` |
| **Shell** | `.zshrc`, `.bashrc` |

## Installation

```bash
git clone git@github.com:kerryby/arch-hyprland-dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The script creates symlinks in `$HOME`.
