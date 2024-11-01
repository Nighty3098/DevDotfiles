#!/bin/bash

WALL_PATH=$(ls ~/wallpapers/ | rofi -show filebrowser -dmenu -p theme)

if [ -z "$WALL_PATH" ]; then
    WALL_PATH=$(ls ~/wallpapers/ | shuf -n 1)
fi

wal -s -i ~/wallpapers/${WALL_PATH}

rm ~/.current_wallpaper
ln -sf ~/wallpapers/${WALL_PATH} "$HOME/.current_wallpaper"

bash ~/scripts/wal_to_alacritty.sh ~/.config/alacritty/alacritty.toml
bash ~/scripts/reload_dunst.sh
bash ~/scripts/reload_conky.sh
bash ~/scripts/reload_obsidian.sh "$HOME/Notes"

notify-send "Wallpaper" "Wallpaper set to ${WALL_PATH}"
