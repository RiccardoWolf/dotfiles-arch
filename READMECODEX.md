# dotfiles-arch

Automate your Arch Linux configuration with GNU Stow and a package bootstrap script.

## Overview

This repository provides:

- **User configurations** under `home/` (symlinked to `$HOME`, including `.config` and `.local`)
- **System configurations** under `system/` (symlinked to `/`, requires `sudo`)
- **Package lists** for official repos (`packages/pacman.txt`) and AUR (`packages/aur.txt`)
- **Bootstrap script** (`install.sh`) to install packages and deploy configs

## Quickstart

```bash
git clone https://github.com/RiccardoWolf/dotfiles-arch.git ~/dotfiles-arch
cd ~/dotfiles-arch
./install.sh
```

## Adding or updating packages

1. Edit `packages/pacman.txt` for official repository packages (one per line).
2. Edit `packages/aur.txt` for AUR packages (one per line).
3. Rerun `./install.sh` to apply changes.

## Managing configurations

- Add your **user** configuration files and folders under `home/` (e.g., `home/.config/kitty`, `home/.local/share/fonts`).
- Add your **system** configuration under `system/` (paths relative to `/`, e.g., `system/usr/share/sddm/themes/catppuccin-macchiato`).
- `install.sh` uses GNU Stow to symlink these into place.

## License

MIT (see [LICENSE](LICENSE))