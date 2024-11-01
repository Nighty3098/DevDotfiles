#!/usr/bin/env bash

OPTIONS=("  Power menu" "  Theme changer" "  Config editor" "  SSH menu" "  Bluetooth menu" "  Volume mixer" "  System load")

LAUNCHER="rofi -dmenu -i -p tools"

option=$(printf "%s\n" "${OPTIONS[@]}" | $LAUNCHER)

case "$option" in
    "  Power menu")
        bash ~/scripts/rofi_power_menu.sh
        ;;
    "  Theme changer")
        bash ~/scripts/themechanger.sh
        ;;
    "  Config editor")
        bash ~/scripts/rofi_conf.sh
        ;;
    "  SSH menu")
        rofi -show ssh
        ;;
    "  Bluetooth menu")
        rofi-bluetooth
        ;;
    "  Volume mixer")
        bash ~/scripts/set_vol_output.sh
        ;;
    "  System load")
        bash ~/scripts/sys_stats.sh
        ;;
    *)
        ;;
esac
