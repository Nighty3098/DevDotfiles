#!/bin/bash

sinks=$(pactl list short sinks)

choices=$(echo "$sinks" | awk '{print $2}')

selected_sink=$(echo "$choices" | wofi --dmenu --prompt="Select Audio Output:")

if [ -n "$selected_sink" ]; then
  pactl set-default-sink "$selected_sink"

  pactl list short sink-inputs | awk '{print $1}' | while read -r stream; do
    pactl move-sink-input "$stream" "$selected_sink"
  done
fi
