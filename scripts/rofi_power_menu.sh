#!/usr/bin/env bash

UPTIME=$(uptime -p)
OPTIONS=("   ${UPTIME}" "   Reboot system" "   Power-off system" "   Suspend system" "   Hibernate system" "   Lock system" "   Exit window manager")

LAUNCHER="rofi -dmenu -i -p POWER "
USE_LOCKER="true"
LOCKER="betterlockscreen -l"

option=$()

option=$(printf "%s\n" "${OPTIONS[@]}" | $LAUNCHER)
case $option in
  "   Exit window manager")
    i3-msg exit
    ;;
  "   Reboot system")
    systemctl reboot
    ;;
  "   Power-off system")
    systemctl poweroff
    ;;
  "   Suspend system")
    $($USE_LOCKER) && "$LOCKER"; systemctl suspend
    ;;
  "   Hibernate system")
    $($USE_LOCKER) && "$LOCKER"; systemctl hibernate
    ;;
  "   Lock system")
  $LOCKER
  ;;
  *)
    ;;
esac
