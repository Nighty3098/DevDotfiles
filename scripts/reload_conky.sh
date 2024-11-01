#!/usr/bin/env bash

# Загружаем цвета из файла colors.sh
. "${HOME}/.cache/wal/colors.sh"

# Указываем файл, в который будем записывать
FILE="$HOME/.config/conky/i3.conf"

sed -i "43s/.*/    \${color $foreground}/" "$FILE"
