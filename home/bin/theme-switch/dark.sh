#!/usr/bin/env bash
set -euo pipefail

STOW_DIR="$HOME/dotfiles-arch/home"
CONFIG_HOME="$XDG_CONFIG_HOME"
PKGS=(kitty waybar nwg-bar)

# Waybar
if [[ -e "$STOW_DIR/.config/waybar/style.css" ]]; then
  rm -f "$CONFIG_HOME/waybar/style.css"
  ln -s "$STOW_DIR/.config/waybar/style.css" "$CONFIG_HOME/waybar/style.css"
  systemctl --user kill -s SIGUSR2 --kill-who=main waybar.service
  echo "waybar: linked style.css -> $STOW_DIR/.config/waybar/style.css"
fi

# NWG-bar
if [[ -e "$STOW_DIR/.config/nwg-bar/style.css" ]]; then
  rm -f "$CONFIG_HOME/nwg-bar/style.css"
  ln -s "$STOW_DIR/.config/nwg-bar/style.css" "$CONFIG_HOME/nwg-bar/style.css"
  echo "nwg-bar: linked style.css -> $STOW_DIR/.config/nwg-bar/style.css"
fi

# Kitty
if [[ -e "$STOW_DIR/.config/kitty/kitty.conf" ]]; then
  rm -f "$CONFIG_HOME/kitty/kitty.conf"
  ln -s "$STOW_DIR/.config/kitty/kitty.conf" "$CONFIG_HOME/kitty/kitty.conf"
  echo "kitty: linked kitty.conf -> $STOW_DIR/.config/kitty/kitty.conf"
fi

# Vim
#sed -E "s/(flavour[[:space:]]*=[[:space:]]*')[^']+/\1macchiato/" /$HOME/.config/nvim/lua/kickstart/plugins/catppuccin.lua > /tmp/catppuccin.lua.tmp && mv /tmp/catppuccin.lua.tmp /$HOME/.config/nvim/lua/kickstart/plugins/catppuccin.lua

# zsh
sed -E 's/^(ZSH_THEME=)".*"/\1"robbyrussell"/' ~/.zshrc > ~/.zshrc.tmp && mv ~/.zshrc.tmp ~/.zshrc

# Rofi
sed -i 's|spotlight-blurred\.rasi|spotlight-blurred-light.rasi|g' ~/dotfiles-arch/home/.config/rofi/config.rasi