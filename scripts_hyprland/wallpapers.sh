#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/wallpapers/"

wallpapers=$(find "$WALLPAPER_DIR" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \))

choice=$(echo "$wallpapers" | wofi --dmenu --prompt "Change wallpaper")

if [[ -n "$choice" ]]; then
    monitors=$(hyprctl monitors -j | jq -r '.[] | .name')

    >~/.config/hypr/hyprpaper.conf

    echo "preload = $choice" >>~/.config/hypr/hyprpaper.conf

    for monitor in $monitors; do
        hyprctl hyprpaper wallpaper "$monitor,$choice"
        echo "wallpaper = $monitor,$choice" >>~/.config/hypr/hyprpaper.conf
    done

    echo "splash = false" >>~/.config/hypr/hyprpaper.conf

    wal -s -i "$choice" --backend wal
    bash ~/scripts/waybar_colors.sh
    bash ~/scripts/restart_waybar.sh

    echo "Wallpaper changed to: $choice"
else
    echo "No wallpaper selected."
fi
