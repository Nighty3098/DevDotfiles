#!/bin/bash

# Опции powermenu
options="Lock\nSuspend\nReboot\nPoweroff\nExit"

# Выбор пользователя
selected=$(echo -e "$options" | wofi --dmenu --prompt "Power" --insensitive -W 500 -H 500)

case "$selected" in
"Lock") hyprlock ;; # или swaylock
"Suspend") systemctl suspend ;;
"Reboot") systemctl reboot ;;
"Poweroff") systemctl poweroff ;;
"Exit") hyprctl dispatch exit ;; # или killall Hyprland
esac
