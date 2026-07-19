<p align="center">
  <img src="https://raw.githubusercontent.com/hyprwm/Hyprland/main/assets/header.svg" alt="Hyprland" width="100%">
</p>

<h1 align="center">
  <img src="https://raw.githubusercontent.com/archlinux/archlinux/master/logo/archlinux-icon-crystal-64.svg" width="28" alt="Arch">
  Arch Hyprland Dotfiles
</h1>

<p align="center">
  <b>✦ Hyprland Lua configuration for Arch Linux ✦</b>
</p>

<p align="center">
  <a href="https://archlinux.org">
    <img src="https://img.shields.io/badge/OS-Arch%20Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white" alt="Arch Linux">
  </a>
  <a href="https://hyprland.org">
    <img src="https://img.shields.io/badge/WM-Hyprland-ffb4ab?style=for-the-badge&logo=hyprland&logoColor=white" alt="Hyprland">
  </a>
  <a href="https://github.com/kerryby/arch-hyprland-dotfiles">
    <img src="https://img.shields.io/github/repo-size/kerryby/arch-hyprland-dotfiles?style=for-the-badge&logo=github&color=eebe8a" alt="Repo Size">
  </a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Editor-Neovim-57A143?logo=neovim&logoColor=white" alt="Neovim">
  <img src="https://img.shields.io/badge/Terminal-Alacritty-F46D01?logo=alacritty&logoColor=white" alt="Alacritty">
  <img src="https://img.shields.io/badge/Shell-Fish-149EC2?logo=fish&logoColor=white" alt="Fish">
  <img src="https://img.shields.io/badge/GTK-GTK4-7F5AB6?logo=gtk&logoColor=white" alt="GTK">
</p>

<br>

---

### ✦ Gallery

> _Screenshots coming soon_

<br>

### ✦ Features

- **Full Lua-based Hyprland configuration** — modular, clean, and maintainable
- **Dark theme** — cohesive color scheme across all apps
- **Blazing fast terminal** — Alacritty + Fish with custom theme
- **Minimal Neovim** — lightweight Lua config

<br>

### ✦ Structure

```
~
├── .zshrc
├── .bashrc
└── .config/
    ├── alacritty/        # Terminal emulator config
    ├── btop/             # System monitor
    ├── fastfetch/        # System info fetch
    ├── fish/             # Shell configuration
    ├── gtk-3.0/          # GTK3 theme & settings
    ├── gtk-4.0/          # GTK4 theme & settings
    ├── hypr/             # Window manager (Lua config)
    │   ├── hyprland.lua  # Entry point
    │   ├── modules/      # Modular configs
    │   └── scripts/      # Utility scripts
    ├── micro/            # Terminal editor
    │   ├── settings.json
    │   └── colorschemes/
    ├── nvim/             # Neovim config
    └── pavucontrol.ini   # Audio settings
```

<br>

### ✦ Installation

```bash
# Clone the repository
git clone git@github.com:kerryby/arch-hyprland-dotfiles.git ~/dotfiles

# Create symlinks
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

The script creates symbolic links from `~/dotfiles` to your `$HOME` directory.  
Existing files will be overwritten by the symlinks.

<br>

### ✦ Keybinds

| Key | Action |
|---|---|
| `SUPER + Q` | Close focused window |
| `SUPER + F` | Toggle fullscreen |
| `SUPER + L` | Lock screen |
| `SUPER + A` | Toggle wallpaper |
| `SUPER + F11` | Disconnect WARP |

> _Full keybind list: [`.config/hypr/modules/binds.lua`](./.config/hypr/modules/binds.lua)_

<br>

### ✦ Color Palette

Colors are dynamically generated and change with your wallpaper.

<br>

### ✦ Acknowledgements

- **[Hyprland](https://hyprland.org)** — the incredible Wayland compositor
- **[CachyOS](https://cachyos.org)** — optimized Arch-based distribution

<br>

---

<p align="center">
  <sub>Made with ❤️ on Arch Linux</sub>
  <br>
  <img src="https://img.shields.io/badge/maintained-yes-success?style=flat-square">
  <img src="https://img.shields.io/github/last-commit/kerryby/arch-hyprland-dotfiles?style=flat-square&color=8b5cf6">
</p>
