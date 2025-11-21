#!/usr/bin/env bash

UPTIME=$(uptime -p)
OPTIONS=("UPTIME: ${UPTIME}" "Reboot system" "Power-off system" "Suspend system" "Hibernate system" "Lock system" "Exit window manager")

LAUNCHER="wofi -dmenu -i -p POWER "
USE_LOCKER="true"
LOCKER="hyprlock"

option=$()

option=$(printf "%s\n" "${OPTIONS[@]}" | $LAUNCHER)
case $option in
"Exit window manager")
    hyprctl dispatch exit
    ;;
"Reboot system")
    systemctl reboot
    ;;
"Power-off system")
    systemctl poweroff
    ;;
"Suspend system")
    $($USE_LOCKER) && "$LOCKER"
    systemctl suspend
    ;;
"Hibernate system")
    $($USE_LOCKER) && "$LOCKER"
    systemctl hibernate
    ;;
"Lock system")
    $LOCKER
    ;;
*) ;;
esac
