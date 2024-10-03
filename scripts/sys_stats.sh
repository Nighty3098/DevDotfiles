#!/bin/bash

round_value() {
  printf "%.1f" "$1" | awk '{print int($1+0.5)}'
}

current_date_time=$(date "+%Y-%m-%d   %H:%M:%S")
cpu_load=$(awk '{u=$2+$4; t=$2+$4+$5; if (NR==1){u1=u; t1=t;} else print ($2+$4-u1) * 100 / (t-t1)}' <(grep 'cpu ' /proc/stat) <(sleep 1; grep 'cpu ' /proc/stat))
memory_usage=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
temperature=$(sensors | grep 'Package id 0' | awk '{print $4}')

text="${current_date_time}\n───────────────────\nCPU: $(round_value "$cpu_load")%\nRAM: $(round_value "$memory_usage")%\nTEMP: ${temperature}"

notify-send "    System Status    " "$text" -w
