#!/bin/bash

chosen=$(printf "i3\ni3 status\npolybar\nranger\nkitty\ndunst\nhtop\nnano\nzsh\npicom\nneovim" | rofi -dmenu)

case "$chosen" in
	"i3")kitty -e nvim ~/.config/i3/;;
	"i3 status")kitty -e nvim ~/.config/i3status/;;
	"polybar")kitty -e nvim ~/.config/polybar/;;
	"ranger")kitty -e nvim ~/.config/ranger/;;
	"kitty")kitty -e nvim ~/.config/kitty/;;
	"dunst")kitty -e nvim ~/.config/dunst/;;
	"htop")kitty -e nvim ~/.config/htop/;;
	"nano")kitty -e nvim ~/.nanorc;;
	"zsh")kitty -e nvim ~/.zshrc;;
	"picom")kitty -e nvim ~/.config/picom/;;
	"neovim")kitty -e nvim ~/.config/nvim/;;
        *) exit 1 ;;
esac



