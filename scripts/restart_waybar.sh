#!/bin/bash

# Простой скрипт для перезапуска Waybar

# Убиваем Waybar
pkill waybar

# Ждем завершения процессов
sleep 1

# Запускаем Waybar снова
waybar &

echo "Waybar перезапущен"
