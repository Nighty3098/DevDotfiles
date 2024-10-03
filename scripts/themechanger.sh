WALL_PATH=$(ls ~/wallpapers/ | rofi -dmenu -p theme)

wal -s -i ~/wallpapers/${WALL_PATH}
betterlockscreen -u ~/wallpapers/${WALL_PATH}

notify-send "Wallpaper" "Wallpaper set to ${WALL_PATH}"
