#!/usr/bin/env bash

all_sinks=$(pactl list short sinks | cut -f 2)

default_sink=$(pactl info | grep 'Default Sink' | cut -d : -f 2)

active_sink=$(echo "$all_sinks" | grep -n $default_sink | cut -d : -f 1)

selected_sink=$(echo "$all_sinks" | rofi -dmenu -i -a $(($active_sink - 1)) -p 'Select a device: ')

pactl set-default-sink $selected_sink
