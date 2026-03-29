<div align="center">
    <img src="header.png" width="90%"/>
    <br><br>
    <a href="https://github.com/Nighty3098/nFetch"><kbd> Custom system fetch </kbd></a>  
    <a href="https://github.com/Nighty3098/nvim"><kbd> Neovim config </kbd></a>
    <br><br>
</div>

Hello there! 👋 Welcome to my collection of **i3wm** and **hyprland** dotfiles, designed for a sleek and functional Linux desktop experience. I hope you find something useful here! 😺

## 📋 Environment Setup

Here's a breakdown of my current setup:

- **Window Manager**: [i3wm](https://github.com/i3/i3) and [Hyprland](https://github.com/hyprwm/Hyprland) 🖼️
- **Shell**: [zsh](https://wiki.archlinux.org/index.php/zsh) 🐚 powered by [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh) and [p10k](https://github.com/romkatv/powerlevel10k)
- **Terminal**: [kitty](https://github.com/kovidgoyal/kitty) 😺
- **Panel**: [polybar](https://github.com/polybar/polybar) and [waybar](https://github.com/Alexays/Waybar) 📊 with [Iosevka NF](https://github.com/be5invis/Iosevka) for icons
- **Compositor**: [picom](https://github.com/chjj/compton) on i3wm ✨
- **Notifications**: [dunst](https://wiki.archlinux.org/index.php/Dunst) 🔔
- **File Manager**: [ranger](https://github.com/ranger/ranger) 📂
- **Editor**: [neovim](https://github.com/Nighty3098/nvim) ✍️
- **Application Launcher**: [rofi](https://github.com/davatorium/rofi) and [wofi](https://github.com/SimplyCEO/wofi) 🚀
- **System Fetch**: [mFetch](https://github.com/Nighty3098/mFetch) 📈

## ⚠️ **Powerlevel10k Common Issues & Fixes** ⚠️

> **🚨 PROBLEM**: `[oh-my-zsh] theme 'powerlevel10k/powerlevel10k' not found` or `zsh: command not found: p10k`
>
> **💡 CAUSE**: Powerlevel10k theme missing from Oh My Zsh directories or **AUR `oh-my-zsh-git` package installed incorrectly** (missing `oh-my-zsh.sh`)
>
> **🔧 QUICK FIX**:
> ```bash
> # 1. Install Powerlevel10k (if missing)
> git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
> 
> # 2. Direct load in ~/.zshrc (END of file):
> echo 'source ~/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc
> 
> # 3. Reload
> source ~/.zshrc
> ```
>
> **✅ Result**: Beautiful p10k prompt loads instantly! `p10k configure` now works.**

## 📥 Installation

⚠️ **Warning**: These scripts will overwrite existing configuration files. **Back up your current configs** before proceeding.

### Prerequisites

```bash
git clone --depth=1 https://github.com/Nighty3098/DevDotfiles.git ~/DevDotfiles && cd ~/DevDotfiles
```

### Install Dependencies

1. Install the Tmux Plugin Manager (TPM):
```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

2. **Install Powerlevel10k** (critical for zsh theme):
```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
```

3. Run the installation script:
```bash
bash install.sh
```

## 🔗 Links and Resources

- **Custom System Fetch**: [mFetch](https://github.com/Nighty3098/mFetch)
- **Neovim Config**: [nvim](https://github.com/Nighty3098/nvim)
- **Discord Community**: [Join us!](https://discord.gg/6xEc5WFK)

## 🖼️ Desktop Environment Preview

<img alt="1" src="https://github.com/user-attachments/assets/8665fdc2-3842-47f5-a133-cb16cd6270d3" />
<img alt="2" src="https://github.com/user-attachments/assets/8a09e54f-f18c-4781-83e0-5e10ddd85855" />
<img alt="3" src="https://github.com/user-attachments/assets/103eaf1d-ebf3-4dd6-8bc3-9e4ee9156f4d" />
<img alt="4" src="https://github.com/user-attachments/assets/45cb11b5-4eb9-4eed-a198-de744663b57b" />
<img alt="5" src="https://github.com/user-attachments/assets/8644079b-c992-40b0-aa8f-d53bc3ff98a3" />
<img alt="hyprland" src="https://github.com/user-attachments/assets/f951e77b-22fb-4528-9efb-c4c2fc95dbab" />
<img alt="hyprland_2" src="https://github.com/user-attachments/assets/814b35ff-6812-485d-a545-2806d2fb732b" />

## 🛠️ Contributing

Feel free to open issues or submit pull requests to improve this setup. Check out the [GitHub Issues](https://github.com/Nighty3098/DevDotfiles/issues) for current tasks and ideas.

**Happy ricing! 🎨**
