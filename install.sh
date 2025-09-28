#!/bin/bash

mv ~/.tmux ~/.tmux.old
mv ~/.tmux.conf ~/.tmux.conf-old
mv ~/.zshrc ~/.zshrc.old
mv ~/.p10k.zsh ~/.p10k.zsh.old
mv ~/.config/i3 ~/.config/i3.old
mv ~/.config/kitty ~/.config/kitty.old
mv ~/.config/neofetch ~/.config/neofetch.old
mv ~/.config/nvim ~/.config/nvim.old
mv ~/.config/polybar ~/.config/polybar.old
mv ~/.config/ranger ~/.config/ranger.old
mv ~/.config/rofi ~/.config/rofi.old

cp -r .config/i3 ~/.config/i3
cp -r .config/kitty ~/.config/kitty
cp -r .config/neofetch ~/.config/neofetch
cp -r .config/nvim ~/.config/nvim
cp -r .config/polybar ~/.config/polybar
cp -r .config/ranger ~/.config/ranger
cp -r .config/rofi ~/.config/rofi

mv ~/.tmux ~/.tmux.old
cp .tmux ~/

mv ~/scripts ~/scripts.old
cp -r scripts ~/scripts

cp .p10k.zsh ~/.config/.p10k.zsh
cp .tmux.conf ~/.tmux.conf
cp .zshrc ~/.zshrc


echo "DONE"
