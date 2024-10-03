#!/bin/bash

# Set the progress bar counter
counter=0
total_commands=20

# Move old config files to backup
echo "Moving old config files to backup..."
for file in ~/.tmux ~/.tmux.conf ~/.zshrc ~/.p10k.zsh ~/.config/i3 ~/.config/kitty ~/.config/neofetch ~/.config/nvim ~/.config/polybar ~/.config/ranger ~/.config/rofi ~/.config/starship.toml; do
  ((counter++))
  echo -ne "\rProgress: $counter/$total_commands"
  if [ -f "$file" ]; then
    mv "$file" "${file}.old" || echo "Error moving $file to backup"
  else
    echo "File $file not found, skipping..."
  fi
done
echo ""

# Copy new config files
echo "Copying new config files..."
for file in .config/i3 .config/kitty .config/neofetch .config/nvim .config/polybar .config/ranger .config/rofi .config/starship.conf; do
  ((counter++))
  echo -ne "\rProgress: $counter/$total_commands"
  if [ -d "$file" ]; then
    cp -r "$file" ~/"${file##*/}" || echo "Error copying $file"
  else
    echo "File $file not found, skipping..."
  fi
done
echo ""

# Move old tmux config to backup and copy new one
((counter++))
echo -ne "\rProgress: $counter/$total_commands"
if [ -f ~/.tmux ]; then
  mv ~/.tmux ~/.tmux.old || echo "Error moving ~/.tmux to backup"
fi
cp .tmux ~/

# Move old scripts to backup and copy new ones
((counter++))
echo -ne "\rProgress: $counter/$total_commands"
if [ -d ~/scripts ]; then
  mv ~/scripts ~/scripts.old || echo "Error moving ~/scripts to backup"
fi
cp -r scripts ~/scripts

# Copy remaining files
((counter++))
echo -ne "\rProgress: $counter/$total_commands"
cp .p10k.zsh ~/.config/.p10k.zsh || echo "Error copying .p10k.zsh"
((counter++))
echo -ne "\rProgress: $counter/$total_commands"
cp .tmux.conf ~/.config/.tmux.conf || echo "Error copying .tmux.conf"
((counter++))
echo -ne "\rProgress: $counter/$total_commands"
cp .zshrc ~/.zshrc || echo "Error copying .zshrc"

echo "DONE"
