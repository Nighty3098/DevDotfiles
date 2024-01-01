#!/usr/bin/env bash

# bdelphin's rofi-power fork
# Use rofi to call systemctl for shutdown, reboot, etc


OPTIONS="Reboot system\nPower-off system\nSuspend system\nHibernate system\nLock system\nExit window manager"

LAUNCHER="rofi -dmenu -i -p rofi-power  --config /home/shadow31/.config/rofi/config_powermenu"
USE_LOCKER="true"
#LOCKER="betterlockscreen -l"
LOCKER="bash /home/shadow/scripts/custom-i3lock/v3lock"

option=`echo -e $OPTIONS | $LAUNCHER | awk '{print $1}' | tr -d '\r\n'`
if [ ${#option} -gt 0 ]
then
    case $option in
      Exit)
        i3-msg exit
        ;;
      Reboot)
        systemctl reboot
        ;;
      Power-off)
        systemctl poweroff
        ;;
      Suspend)
        $($USE_LOCKER) && "$LOCKER"; systemctl suspend
        ;;
      Hibernate)
        $($USE_LOCKER) && "$LOCKER"; systemctl hibernate
        ;;
      Lock)
	$LOCKER
	;;
      *)
        ;;
    esac
fi
