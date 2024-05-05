#!/bin/bash

# This command will close all active conky
killall conky
sleep 2s
		
# Only the config listed below will be avtivated
# if you want to combine with another theme, write the command here
conky -c $HOME/.config/conky/conky.conf &> /dev/null &

exit
