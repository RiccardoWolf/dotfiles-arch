#!/usr/bin/env bash
set -euo pipefail

STOW_DIR="$HOME/dotfiles-arch/home"
CONFIG_HOME="$XDG_CONFIG_HOME"
PKGS=(kitty waybar nwg-bar)

# Rename/replace style files created by stow so final filename is style.css
if [[ -e "$STOW_DIR/.config/waybar/style-light.css" ]]; then
  rm -f "$CONFIG_HOME/waybar/style.css"
  ln -s "$STOW_DIR/.config/waybar/style-light.css" "$CONFIG_HOME/waybar/style.css"
  systemctl --user kill -s SIGUSR2 --kill-who=main waybar.service
  echo "waybar: linked style.css -> $STOW_DIR/.config/waybar/style-light.css"
fi

# NWG-bar
if [[ -e "$STOW_DIR/.config/nwg-bar/style-light.css" ]]; then
  rm -f "$CONFIG_HOME/nwg-bar/style.css"
  ln -s "$STOW_DIR/.config/nwg-bar/style-light.css" "$CONFIG_HOME/nwg-bar/style.css"
  echo "nwg-bar: linked style.css -> $STOW_DIR/.config/nwg-bar/style-light.css"
fi

# Kitty: if repo keeps a kitty-light.conf, expose it as kitty.conf
if [[ -e "$STOW_DIR/.config/kitty/kitty-light.conf" ]]; then
  rm -fr "$CONFIG_HOME/kitty/kitty.conf"
  ln -s "$STOW_DIR/.config/kitty/kitty-light.conf" "$CONFIG_HOME/kitty/kitty.conf"
  echo "kitty: linked kitty.conf -> $STOW_DIR/.config/kitty/kitty-light.conf"
fi

# Vim
sed -E "s/(flavour[[:space:]]*=[[:space:]]*')[^']+/\1latte/" /$HOME/.config/nvim/lua/kickstart/plugins/catppuccin.lua > /tmp/catppuccin.lua.tmp && mv /tmp/catppuccin.lua.tmp /$HOME/.config/nvim/lua/kickstart/plugins/catppuccin.lua

# zsh
#sed -E 's/^(ZSH_THEME=)".*"/\1"light-zsh"/' ~/.zshrc > ~/.zshrc.tmp && mv ~/.zshrc.tmp ~/.zshrc

# Rofi
sed -i 's|spotlight-blurred\.rasi|spotlight-blurred-light.rasi|g' ~/.config/rofi/config.rasi