#!/bin/bash

WALLPAPER_DIR="$HOME/wallpapers"

wallpapers=$(find "$WALLPAPER_DIR" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \))

choice=$(echo "$wallpapers" | wofi --dmenu --prompt "Change wallpaper")


if [[ -n "$choice" ]]; then
    focused_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')
    hyprctl hyprpaper preload "$choice"
    hyprctl hyprpaper wallpaper "$focused_monitor,$choice"
    hyprctl hyprpaper unload unused

    echo "preload = $choice" > ~/.config/hypr/hyprpaper.conf
    echo "wallpaper = $focused_monitor, $choice" >> ~/.config/hypr/hyprpaper.conf
fi
