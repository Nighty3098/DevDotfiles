#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/wallpapers/"

wallpapers=$(find "$WALLPAPER_DIR" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \))

choice=$(echo "$wallpapers" | wofi --dmenu --prompt "Change wallpaper")

if [[ -n "$choice" ]]; then
    focused_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')

    hyprctl hyprpaper preload "$choice"
    hyprctl hyprpaper wallpaper "$focused_monitor,$choice"
    hyprctl hyprpaper unload unused

    {
        echo "preload = $choice"
        echo "wallpaper = $focused_monitor,$choice"
    } >~/.config/hypr/hyprpaper.conf

    wal -s -i "$choice" --backend wal
    # bash ~/scripts/waybar_colors.sh
    # pkill waybar && waybar

    bash ~/scripts/wofi_colors.sh
    bash ~/scripts/waybar_colors.sh
    bash ~/scripts/restart_waybar.sh

    echo "Wallpaper changed to: $choice on monitor $focused_monitor"
else
    echo "No wallpaper selected."
fi
