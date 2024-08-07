#!/bin/bash

cp -r scripts ~/

mv ~/.config/conky ~/.config/conky_old
mv ~/.config/htop ~/.config/htop_old
mv ~/.config/i3 ~/.config/i3_old
mv ~/.cofig/kitty ~/.config/kitty_old
mv ~/.config/neofetch ~/.config/neofetch_old
mv ~/.config/nvim ~/.config/nvim_old
mv ~/.config/polybar ~/.config/polybar_old
mv ~/.config/ranger ~/.config/ranger_old
mv ~/.config/rofi ~/.config/rofi_old

cd .config

cp -r conky ~/.config/
cp -r htop ~/.config/
cp -r i3 ~/.config/
cp -r kitty ~/.config/
cp -r neofetch ~/.config/
cp -r nvim ~/.config/
cp -r polybar ~/.config/
cp -r ranger ~/.config/
cp -r rofi ~/.config/

cp starship ~/.config/

cd ..

cp -r .themes/WhiteSur-custom-panel ~/.themes/

mv ~/.zshrc ~/.zshrc_old
mv ~/.tmux.conf ~/.tmux.conf_old
mv ~/.p10k.zsh ~/.p10k.zsh_old

cp .zshrc ~/
cp .tmux.conf ~/
cp .p10k.zsh ~/

echo "Done!"
