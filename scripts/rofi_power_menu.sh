#!/usr/bin/env bash

OPTIONS="Reboot system\nPower-off system\nSuspend system\nHibernate system\nLock system\nExit window manager"

LAUNCHER="rofi -dmenu -i -p power"
USE_LOCKER="true"
LOCKER="betterlockscreen -l"

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

