## Info
Dotfile for my Arch Hyprland setup managed by [GNU Stow](https://www.gnu.org/software/stow/)
Some scripts also helps you configuring those packages or other linux settings.

> **WARNING**  
> The script uses Stow to distribute the dotfiles into the system, DELETING ALREADY EXISTING FILES.
> Stow create symlinks so some packages or operations might have a problem with that.

Current stow helpers back up existing targets to `.backup.<timestamp>` before replacing them, but installer tasks still mutate user and system configuration. Use dry-run and read the target script before running a task that touches packages, boot config, desktop defaults, or services.

## Usage

Show available tasks and options:

```sh
./install.sh --help
```

Run a non-mutating preview:

```sh
./install.sh --dry pkg BASE
```

Open the interactive task picker:

```sh
./install.sh --menu
```

Run specific tasks:

```sh
./install.sh pkg BASE bluetooth theme xdg
```

Package categories are read from `#` headings in `package-list.txt`. The task scripts live in `runs/`, and most of them source `runs/lib.sh` for dry-run logging, package installation helpers, backups, and stow behavior.

Component        | Name
-----------------|------
OS               | [Arch Linux](https://archlinux.org)
WM               | [Hyprland](https://github.com/hyprwm/Hyprland)
AUR Helper       | [Yay](https://github.com/Jguer/yay)
Terminal         | [Kitty](https://github.com/kovidgoyal/kitty)
Shell            | [Zsh](https://www.zsh.org/) + [ohmyzsh](https://github.com/ohmyzsh/ohmyzsh)
Launcher         | [Rofi-wayland](https://github.com/in0ni/rofi-wayland)
Bar              | [Waybar](https://github.com/Alexays/Waybar)
Notifications    | [Dunst](https://github.com/dunst-project/dunst)
Font             | JetBrains Mono Nerd, Hack Nerd, Noto Emoji
Shutdown menu    | [nwg-bar](https://github.com/nwg-piotr/nwg-bar)
Clipboard manager| [nwg-clipman](https://github.com/nwg-piotr/nwg-clipman)
Theme manager    | `home/bin/theme-switch/theme-switch`
 

Other            | Scripts don't touch these
-----------------|----------------------
File Manager     | [Vifm](https://github.com/vifm/vifm)
Document Viewer  | [Zathura](https://github.com/pwmt/zathura) !!
Image Viewer     | [Imv](https://github.com/eXeC64/imv)
Video Player     | [mpv](https://mpv.io/)
Audio Player     | [Mpd](https://www.musicpd.org/)
Editor           | [Neovim](https://neovim.io/)
Theme manager    | 
System monitor   | [Btop](https://github.com/aristocratos/btop)

## Current Workflow Notes

The `xdg` task installs repo desktop entries and applies MIME/default-browser associations for Chrome, Thunar, imv, Neovim, and VLC. The older table above is useful as a component inventory, but it is not a guarantee that scripts never touch those applications.

The `theme` task installs theme dependencies, stows `theme-switch` plus the Kitty, Waybar, nwg-bar, and Rofi configs, copies the dark/light theme assets into `~/.local/state/dotfiles-arch/themes`, prepares the runtime links under `~/.config/dotfiles-arch/themes`, applies the dark theme once, and creates the Dunst startup config link. The default installer runs `theme` before the Rofi and Waybar tasks so configs that import `themes/current` have runtime state prepared first.

Theme assets live under:

```text
home/.config/dotfiles-arch/themes/dark
home/.config/dotfiles-arch/themes/light
```

Runtime state lives under:

```text
~/.local/state/dotfiles-arch
```

The active config files for Waybar, Rofi, Kitty, nwg-bar, and Dunst import, link, or reload from `dotfiles-arch/themes/current`. `theme-switch apply <dark|light>` and `theme-switch toggle` update every supported theme target: Waybar, Rofi, Kitty, Dunst, GTK/XDG settings, VS Code, Chromium/Chrome live repainting, Zsh, Codex, and Spicetify when configured.

```sh
theme-switch apply light
theme-switch toggle
```

Direct adapter writes back up changed files under `~/.local/state/dotfiles-arch/backups`, and runtime-owned theme assets stay under `~/.local/state/dotfiles-arch/themes` so the active links do not depend on the repo checkout remaining in place.

Waybar includes a `custom/theme` module backed by `home/.config/waybar/theme-widget.sh`; click it or press `SUPER+SHIFT+T` in Hyprland to run `theme-switch toggle`.

## Credits
[Waybar config](https://github.com/faizan-20/.dotfiles/)

[Catppuccin theme](https://github.com/catppuccin/catppuccin) (For sddm and dunst colors)

[Spotlight like theme for Rofi](https://github.com/newmanls)
