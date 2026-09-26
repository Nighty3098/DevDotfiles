#!/usr/bin/env bash
#
# DevDotfiles — universal installer
# Setups: 1) niri-noctalia  2) i3wm  3) hyprland
#
# What it does:
#  - asks which setup to install (or "programs only" to skip the shell setup)
#  - lets you pick components by index (e.g. 1,2,4-6 9):
#      * shared components (tmux, zsh, kitty, neofetch, ranger, yazi,
#        zed, VS Code, starship, nvim, wallpapers, ...)
#      * setup-specific components (niri/noctalia, i3/polybar/rofi/...,
#        hypr/waybar/wofi/..., helper scripts -> ~/scripts)
#      * system packages (shared + setup-specific, requires sudo)
#  - backs up existing user configs (~/.bak.<timestamp>)
#  - nvim config is cloned from https://github.com/nighty3098/nvim
#    straight into ~/.config/nvim
#  - installs TPM for tmux and oh-my-zsh + powerlevel10k
#
# Run: bash install.sh (from the repository root)

set -uo pipefail

# ---------- Colors & logging ----------
# ANSI-C quoting ($'...') stores real ESC bytes, so colors also work
# in read -p prompts (unlike echo -e interpreted sequences).
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
CYAN=$'\033[0;36m'
MAGENTA=$'\033[0;35m'
BOLD=$'\033[1m'
DIM=$'\033[2m'
RESET=$'\033[0m'

# Disable colors when output is piped/redirected (logs stay clean).
if [[ ! -t 1 ]]; then
    RED='' GREEN='' YELLOW='' BLUE='' CYAN='' MAGENTA='' BOLD='' DIM='' RESET=''
fi

log_info() { echo -e "${GREEN}[INFO]${RESET} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${RESET} $*" ; }
log_error() { echo -e "${RED}[ERROR]${RESET} $*" >&2; }
log_step() { echo -e "\n${BOLD}${BLUE}==> $*${RESET}"; }
log_ok() { echo -e "${GREEN}[ OK ]${RESET} $*"; }
log_skip() { echo -e "${DIM}[SKIP] $*${RESET}"; }

# ---------- Paths ----------
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_TS="$(date +%Y%m%d_%H%M%S)"
HOME_DIR="$HOME"
CONFIG_DIR="$HOME/.config"

NVIM_REPO="https://github.com/nighty3098/nvim"
TPM_REPO="https://github.com/tmux-plugins/tpm"
P10K_REPO="https://github.com/romkatv/powerlevel10k.git"
OMZ_REPO="https://github.com/ohmyzsh/ohmyzsh.git"

mkdir -p "$CONFIG_DIR"

# ---------- Backup ----------
# backup <path>: rename existing file/dir/symlink to <path>.bak.<timestamp>
backup() {
    local target="$1"
    if [[ -e "$target" || -L "$target" ]]; then
        local bak="${target}.bak.${BACKUP_TS}"
        log_warn "Backup: $target -> $bak"
        mv "$target" "$bak"
    fi
}

# ---------- Copy helpers ----------
install_dir() {
    local src="$1"   # source directory inside the repo (absolute path)
    local dst="$2"   # destination (e.g. ~/.config/kitty)
    if [[ ! -d "$src" ]]; then
        log_warn "Skip: source directory not found: $src"
        return 0
    fi
    backup "$dst"
    mkdir -p "$(dirname "$dst")"
    log_info "Copy dir: $src -> $dst"
    cp -r "$src" "$dst"
}

install_file() {
    local src="$1"   # source file inside the repo (absolute path)
    local dst="$2"   # destination path
    if [[ ! -f "$src" ]]; then
        log_warn "Skip: source file not found: $src"
        return 0
    fi
    backup "$dst"
    mkdir -p "$(dirname "$dst")"
    log_info "Copy file: $src -> $dst"
    cp "$src" "$dst"
}

# Check if a key is present in a list of selected keys.
# Usage: is_selected <key> "${SELECTED[@]}"
is_selected() {
    local needle="$1"
    shift
    local item
    for item in "$@"; do
        [[ "$item" == "$needle" ]] && return 0
    done
    return 1
}

# ---------- Index-based selection menu (pure bash, no dependencies) ----------
# Usage: index_menu "<prompt>" OPTIONS_ARRAY RESULT_ARRAY
#   OPTIONS_ARRAY: entries formatted as "key|Human readable label"
#   RESULT_ARRAY:  filled with keys of the selected entries (in listed order)
# Input formats: "1,2,4" | "1 2 4" | "1-4 7 9" | "all" | "none" | Enter (= all)
index_menu() {
    local prompt="$1"
    local -n _idx_opts="$2"
    local -n _idx_result="$3"

    # Non-interactive fallback (piped input): select everything.
    if [[ ! -t 0 ]]; then
        log_warn "Non-interactive terminal detected, selecting all."
        _idx_result=()
        local i
        for i in "${!_idx_opts[@]}"; do
            _idx_result+=("${_idx_opts[$i]%%|*}")
        done
        return 0
    fi

    local input tok
    local total=${#_idx_opts[@]}
    while true; do
        echo ""
        echo -e "${BOLD}${CYAN}${prompt}${RESET}"
        local i
        for i in "${!_idx_opts[@]}"; do
            printf "   ${YELLOW}%2d)${RESET} %s\n" "$((i + 1))" "${_idx_opts[$i]#*|}"
        done
        echo -e "${DIM}  [e.g. 1,2,4-6 9 | all = everything | none = nothing | Enter = everything]${RESET}"
        read -rp "${CYAN}Enter numbers:${RESET} " input
        input="${input,,}"        # lowercase
        input="${input//,/ }"     # commas -> spaces

        if [[ "$input" =~ ^[[:space:]]*$ || "$input" == "all" || "$input" == "a" ]]; then
            _idx_result=()
            for i in "${!_idx_opts[@]}"; do
                _idx_result+=("${_idx_opts[$i]%%|*}")
            done
            return 0
        elif [[ "$input" == "none" || "$input" == "n" ]]; then
            _idx_result=()
            return 0
        fi

        local -A seen=()
        local nums=()
        local ok=1 n lo hi
        for tok in $input; do
            if [[ "$tok" =~ ^([0-9]+)-([0-9]+)$ ]]; then
                lo=$((10#${BASH_REMATCH[1]}))
                hi=$((10#${BASH_REMATCH[2]}))
                if (( lo < 1 || hi < 1 || lo > total || hi > total )); then
                    ok=0; break
                fi
                if (( lo > hi )); then local t=$lo; lo=$hi; hi=$t; fi
                for (( n = lo; n <= hi; n++ )); do
                    [[ -z "${seen[$n]:-}" ]] && { seen[$n]=1; nums+=("$n"); }
                done
            elif [[ "$tok" =~ ^[0-9]+$ ]]; then
                n=$((10#$tok))
                if (( n < 1 || n > total )); then ok=0; break; fi
                [[ -z "${seen[$n]:-}" ]] && { seen[$n]=1; nums+=("$n"); }
            else
                ok=0; break
            fi
        done

        if (( ok )) && (( ${#nums[@]} > 0 )); then
            IFS=$'\n' nums=($(sort -n <<<"${nums[*]}"))
            unset IFS
            _idx_result=()
            for n in "${nums[@]}"; do
                _idx_result+=("${_idx_opts[$((n - 1))]%%|*}")
            done
            return 0
        fi
        echo -e "${RED}Invalid input. Example: 1,2,4-6 9 (valid range: 1-${total})${RESET}"
    done
}

# ---------- Package manager ----------
PKG_MGR=""    # pacman | apt | dnf | unknown
AUR_HELPER="" # yay | paru | none

detect_pkg_mgr() {
    if command -v pacman &>/dev/null; then
        PKG_MGR="pacman"
        if command -v yay &>/dev/null; then
            AUR_HELPER="yay"
        elif command -v paru &>/dev/null; then
            AUR_HELPER="paru"
        else
            AUR_HELPER="none"
        fi
    elif command -v apt &>/dev/null; then
        PKG_MGR="apt"
    elif command -v dnf &>/dev/null; then
        PKG_MGR="dnf"
    else
        PKG_MGR="unknown"
    fi
    log_info "Package manager: $PKG_MGR (AUR helper: ${AUR_HELPER:-none})"
}

# ---------- Package lists ----------
COMMON_PACMAN=(git curl wget zsh tmux kitty neofetch ranger yazi zed
    starship lsd fzf ripgrep fd bat jq zoxide wl-clipboard brightnessctl
    playerctl network-manager-applet pipewire wireplumber polkit gnome-keyring
    ttf-iosevka-nerd noto-fonts)
COMMON_APT=(git curl wget zsh tmux kitty neofetch ranger yazi zed starship
    lsd fzf ripgrep fd-find bat jq zoxide wl-clipboard brightnessctl playerctl
    network-manager pipewire wireplumber policykit-1 gnome-keyring)
COMMON_DNF=(git curl wget zsh tmux kitty neofetch ranger yazi zed starship
    lsd fzf ripgrep fd bat jq zoxide wl-clipboard brightnessctl playerctl
    NetworkManager pipewire wireplumber polkit gnome-keyring)

NIRI_PACMAN=(niri quickshell xwayland-satellite firefox nautilus
    nm-applet python-pywal jq grim slurp)
NIRI_AUR=(noctalia-shell capitaine-cursors)
NIRI_APT=(firefox nautilus python3-pywal jq grim slurp)
NIRI_DNF=(firefox nautilus jq grim slurp)

I3_PACMAN=(i3-wm polybar rofi dunst picom dex pulseaudio pavucontrol
    copyq python-pywal conky nm-applet xorg-xrandr xorg-setxkbmap flameshot
    scrot alacritty feh nitrogen betterlockscreen xorg-xset xss-lock)
I3_AUR=()
I3_APT=(i3 polybar rofi dunst picom dex pulseaudio pavucontrol copyq
    conky-all network-manager-gnome x11-xserver-utils flameshot scrot
    alacritty feh nitrogen i3lock x11-xkb-utils)
I3_DNF=(i3 polybar rofi dunst picom dex pulseaudio pavucontrol copyq
    conky NetworkManager-tui flameshot scrot alacritty feh nitrogen i3lock)

HYPR_PACMAN=(hyprland hyprpaper hyprlock waybar wofi dunst dolphin
    grim slurp swappy python-pywal jq polkit-kde-agent nm-applet)
HYPR_AUR=()
HYPR_APT=(waybar wofi dunst grim slurp swappy python3-pywal jq)
HYPR_DNF=(hyprland hyprpaper hyprlock waybar wofi dunst dolphin
    grim slurp swappy jq)

install_packages_pacman() {
    # $1 = array name (nameref), $2 = description
    local -n pkg_list="$1"
    local desc="$2"
    [[ ${#pkg_list[@]} -eq 0 ]] && return 0
    log_step "Installing packages ($desc): ${pkg_list[*]}"
    sudo pacman -S --needed --noconfirm "${pkg_list[@]}"
}

install_packages_aur() {
    local -n pkg_list="$1"
    local desc="$2"
    [[ ${#pkg_list[@]} -eq 0 ]] && return 0
    if [[ "$AUR_HELPER" == "none" || -z "$AUR_HELPER" ]]; then
        log_warn "No AUR helper (yay/paru) found. Install AUR packages manually ($desc): ${pkg_list[*]}"
        log_warn "Install yay: https://github.com/Jguer/yay and re-run."
        return 0
    fi
    log_step "Installing AUR packages ($desc): ${pkg_list[*]}"
    "$AUR_HELPER" -S --needed --noconfirm "${pkg_list[@]}"
}

install_packages_apt() {
    local -n pkg_list="$1"
    local desc="$2"
    [[ ${#pkg_list[@]} -eq 0 ]] && return 0
    log_step "Installing apt packages ($desc): ${pkg_list[*]}"
    sudo apt update
    # shellcheck disable=SC2068
    sudo apt install -y ${pkg_list[@]}
}

install_packages_dnf() {
    local -n pkg_list="$1"
    local desc="$2"
    [[ ${#pkg_list[@]} -eq 0 ]] && return 0
    log_step "Installing dnf packages ($desc): ${pkg_list[*]}"
    # shellcheck disable=SC2068
    sudo dnf install -y ${pkg_list[@]}
}

# Install shared packages only.
install_common_packages() {
    case "$PKG_MGR" in
        pacman) install_packages_pacman COMMON_PACMAN "shared" ;;
        apt) install_packages_apt COMMON_APT "shared" ;;
        dnf) install_packages_dnf COMMON_DNF "shared" ;;
        *) log_error "Unknown package manager. Install packages manually."; return 1 ;;
    esac
}

# Install packages for the given setup: niri-noctalia | i3wm | hyprland
install_setup_packages() {
    local setup="$1"
    case "$PKG_MGR" in
        pacman)
            case "$setup" in
                niri-noctalia)
                    install_packages_pacman NIRI_PACMAN "niri-noctalia"
                    install_packages_aur NIRI_AUR "niri-noctalia (AUR)"
                    ;;
                i3wm)
                    install_packages_pacman I3_PACMAN "i3wm"
                    install_packages_aur I3_AUR "i3wm (AUR)"
                    ;;
                hyprland)
                    install_packages_pacman HYPR_PACMAN "hyprland"
                    install_packages_aur HYPR_AUR "hyprland (AUR)"
                    ;;
            esac
            ;;
        apt)
            case "$setup" in
                niri-noctalia)
                    install_packages_apt NIRI_APT "niri-noctalia"
                    log_warn "niri and noctalia-shell are not in Debian/Ubuntu repos — install them manually (see niri/noctalia wiki)."
                    ;;
                i3wm) install_packages_apt I3_APT "i3wm" ;;
                hyprland)
                    install_packages_apt HYPR_APT "hyprland"
                    log_warn "hyprland in apt may be missing/outdated — build from source or use backports if needed."
                    ;;
            esac
            ;;
        dnf)
            case "$setup" in
                niri-noctalia)
                    install_packages_dnf NIRI_DNF "niri-noctalia"
                    log_warn "niri and noctalia-shell may be missing in Fedora repos — install them manually."
                    ;;
                i3wm) install_packages_dnf I3_DNF "i3wm" ;;
                hyprland) install_packages_dnf HYPR_DNF "hyprland" ;;
            esac
            ;;
        *)
            log_error "Unknown package manager. Install packages manually."
            return 1
            ;;
    esac
}

# ---------- Shared components ----------
install_comp_tmux() {
    log_step "Component: tmux"
    install_file "$DOTFILES_DIR/.tmux.conf" "$HOME_DIR/.tmux.conf"
    local tpm_dir="$HOME_DIR/.tmux/plugins/tpm"
    if [[ -d "$tpm_dir" ]]; then
        log_info "TPM already installed: $tpm_dir (skipped)"
        return 0
    fi
    if command -v git &>/dev/null; then
        mkdir -p "$(dirname "$tpm_dir")"
        if git clone "$TPM_REPO" "$tpm_dir"; then
            log_info "TPM installed into $tpm_dir"
            log_info "Press <prefix> + I inside tmux to install plugins."
        else
            log_error "Failed to clone TPM."
        fi
    else
        log_error "git not found — TPM was not installed."
    fi
}

install_comp_zsh() {
    log_step "Component: zsh"
    install_file "$DOTFILES_DIR/.zshrc" "$HOME_DIR/.zshrc"
    install_file "$DOTFILES_DIR/.p10k.zsh" "$HOME_DIR/.p10k.zsh"
    if [[ ! -d "$HOME_DIR/.oh-my-zsh" ]]; then
        if command -v curl &>/dev/null; then
            log_info "Installing oh-my-zsh..."
            # RUNZSH=no keeps the current shell, KEEP_ZSHRC=yes preserves our .zshrc
            RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || \
                log_warn "oh-my-zsh auto-install failed — install manually: $OMZ_REPO"
        elif command -v git &>/dev/null; then
            git clone --depth=1 "$OMZ_REPO" "$HOME_DIR/.oh-my-zsh" || log_warn "Failed to clone oh-my-zsh."
        else
            log_warn "Neither curl nor git found — install oh-my-zsh manually."
        fi
    else
        log_info "oh-my-zsh already installed (skipped)."
    fi
    local p10k_dir="$HOME_DIR/.oh-my-zsh/custom/themes/powerlevel10k"
    if [[ ! -d "$p10k_dir" ]]; then
        if command -v git &>/dev/null; then
            log_info "Installing powerlevel10k..."
            mkdir -p "$(dirname "$p10k_dir")"
            git clone --depth=1 "$P10K_REPO" "$p10k_dir" || log_warn "Failed to clone powerlevel10k."
        else
            log_warn "git not found — install powerlevel10k manually."
        fi
    else
        log_info "powerlevel10k already installed (skipped)."
    fi
}

install_comp_kitty() {
    log_step "Component: kitty"
    install_dir "$DOTFILES_DIR/.config/kitty" "$CONFIG_DIR/kitty"
}

install_comp_neofetch() {
    log_step "Component: neofetch"
    install_dir "$DOTFILES_DIR/.config/neofetch" "$CONFIG_DIR/neofetch"
}

install_comp_ranger() {
    log_step "Component: ranger"
    install_dir "$DOTFILES_DIR/.config/ranger" "$CONFIG_DIR/ranger"
}

install_comp_yazi() {
    log_step "Component: yazi"
    install_dir "$DOTFILES_DIR/.config/yazi" "$CONFIG_DIR/yazi"
}

install_comp_zed() {
    log_step "Component: zed"
    install_dir "$DOTFILES_DIR/.config/zed" "$CONFIG_DIR/zed"
}

install_comp_vscode() {
    log_step "Component: VS Code / Code - OSS"
    install_dir "$DOTFILES_DIR/.config/Code" "$CONFIG_DIR/Code"
    install_dir "$DOTFILES_DIR/.config/Code - OSS" "$CONFIG_DIR/Code - OSS"
}

install_comp_starship() {
    log_step "Component: starship"
    install_file "$DOTFILES_DIR/.config/starship.toml" "$CONFIG_DIR/starship.toml"
}

# nvim config is cloned from its own repository straight into ~/.config/nvim
install_comp_nvim() {
    log_step "Component: neovim (clone from $NVIM_REPO)"
    if [[ -e "$CONFIG_DIR/nvim" || -L "$CONFIG_DIR/nvim" ]]; then
        backup "$CONFIG_DIR/nvim"
    fi
    if command -v git &>/dev/null; then
        if git clone --depth=1 "$NVIM_REPO" "$CONFIG_DIR/nvim"; then
            log_info "nvim config cloned into $CONFIG_DIR/nvim"
        else
            log_error "Failed to clone $NVIM_REPO"
            # Fallback: use the local copy (submodule) if it is populated.
            if [[ -d "$DOTFILES_DIR/.config/nvim" && -n "$(ls -A "$DOTFILES_DIR/.config/nvim" 2>/dev/null)" ]]; then
                log_warn "Falling back to the local .config/nvim copy from this repo."
                cp -r "$DOTFILES_DIR/.config/nvim" "$CONFIG_DIR/nvim"
            fi
        fi
    else
        log_error "git not found — nvim config was not installed."
    fi
}

install_comp_wallpapers() {
    log_step "Component: wallpapers"
    if [[ ! -d "$DOTFILES_DIR/wallpapers" ]]; then
        log_warn "wallpapers/ directory not found in the repo — skipped."
        return 0
    fi
    local wp_dst="$HOME_DIR/Pictures/wallpapers"
    log_info "Copy wallpapers: $DOTFILES_DIR/wallpapers -> $wp_dst"
    mkdir -p "$wp_dst"
    # Back up only on filename collisions, then copy everything.
    local f base
    for f in "$DOTFILES_DIR"/wallpapers/*; do
        [[ -e "$f" ]] || continue
        base="$(basename "$f")"
        [[ -e "$wp_dst/$base" ]] && backup "$wp_dst/$base"
        cp -r "$f" "$wp_dst/"
    done
}

# ---------- Setup-specific components ----------
install_comp_niri() {
    log_step "Component: niri"
    install_dir "$DOTFILES_DIR/.config/niri" "$CONFIG_DIR/niri"
}

install_comp_noctalia() {
    log_step "Component: noctalia-shell"
    install_dir "$DOTFILES_DIR/.config/noctalia" "$CONFIG_DIR/noctalia"
    log_info "Full noctalia reference config is available in the repo: noctalia-full-config.toml"
}

install_comp_i3() {
    log_step "Component: i3wm"
    install_dir "$DOTFILES_DIR/.config/i3" "$CONFIG_DIR/i3"
}

install_comp_polybar() {
    log_step "Component: polybar"
    install_dir "$DOTFILES_DIR/.config/polybar" "$CONFIG_DIR/polybar"
}

install_comp_rofi() {
    log_step "Component: rofi"
    install_dir "$DOTFILES_DIR/.config/rofi" "$CONFIG_DIR/rofi"
}

install_comp_dunst() {
    log_step "Component: dunst"
    install_dir "$DOTFILES_DIR/.config/dunst" "$CONFIG_DIR/dunst"
}

install_comp_picom() {
    log_step "Component: picom"
    install_file "$DOTFILES_DIR/.config/picom.conf" "$CONFIG_DIR/picom.conf"
    install_file "$DOTFILES_DIR/.config/picom-animations.conf" "$CONFIG_DIR/picom-animations.conf"
}

install_comp_hypr() {
    log_step "Component: hyprland"
    install_dir "$DOTFILES_DIR/.config/hypr" "$CONFIG_DIR/hypr"
}

install_comp_waybar() {
    log_step "Component: waybar"
    install_dir "$DOTFILES_DIR/.config/waybar" "$CONFIG_DIR/waybar"
}

install_comp_wofi() {
    log_step "Component: wofi"
    install_dir "$DOTFILES_DIR/.config/wofi" "$CONFIG_DIR/wofi"
}

# $1 = source folder inside the repo (scripts | scripts_hyprland),
#     always installed as ~/scripts
install_comp_scripts() {
    local src="$DOTFILES_DIR/$1"
    local dst="$HOME_DIR/scripts"
    log_step "Component: helper scripts ($1 -> ~/scripts)"
    if [[ ! -d "$src" ]]; then
        log_warn "Folder $1 not found — scripts skipped."
        return 0
    fi
    backup "$dst"
    log_info "Copy $src -> $dst"
    cp -r "$src" "$dst"
    chmod +x "$dst"/*.sh 2>/dev/null || true
}

# ---------- Menus ----------
choose_setup() {
    # NOTE: everything user-facing goes to stderr, because the caller
    # captures stdout via $(choose_setup) to get the result.
    echo "" >&2
    echo -e "${BOLD}${CYAN}Which setup do you want to install?${RESET}" >&2
    echo -e "  ${YELLOW}1)${RESET} niri-noctalia  ${DIM}(niri + noctalia-shell)${RESET}" >&2
    echo -e "  ${YELLOW}2)${RESET} i3wm           ${DIM}(i3 + polybar + rofi + dunst + picom)${RESET}" >&2
    echo -e "  ${YELLOW}3)${RESET} hyprland       ${DIM}(hypr + waybar + wofi + dunst)${RESET}" >&2
    echo -e "  ${YELLOW}4)${RESET} programs only  ${DIM}(skip shell setup, install shared programs)${RESET}" >&2
    echo "" >&2
    local choice=""
    while true; do
        read -rp "${CYAN}Enter a number [1-4]: ${RESET}" choice
        case "$choice" in
            1) echo "niri-noctalia"; return 0 ;;
            2) echo "i3wm"; return 0 ;;
            3) echo "hyprland"; return 0 ;;
            4) echo "shared-only"; return 0 ;;
            *) echo -e "${RED}Invalid input. Enter 1, 2, 3 or 4.${RESET}" >&2 ;;
        esac
    done
}

ask_yes_no() {
    # $1 = question. Default answer is Yes.
    local prompt="$1"
    local answer=""
    read -rp "${CYAN}${prompt} [Y/n]: ${RESET}" answer
    case "${answer,,}" in
        ""|"y"|"yes") return 0 ;;
        *) return 1 ;;
    esac
}

# Print the DevDotfiles ASCII banner in red.
print_banner() {
    echo -e "${RED}"
    cat <<'BANNER'
________             __   ___________.__ .__
\______ \    ____  _/  |_ \_   _____/|__||  |    ____    ______
 |    |  \  /  _ \ \   __\ |    __)  |  ||  |  _/ __ \  /  ___/
 |    `   \(  <_> ) |  |   |     \   |  ||  |__\  ___/  \___ \
/_______  / \____/  |__|   \___  /   |__||____/ \___  >/____  >
        \/                     \/                   \/      \/
BANNER
    echo -e "${RESET}"
}

# ---------- main ----------
main() {
    print_banner
    echo -e "${DIM}==============================================${RESET}"
    echo -e "  ${CYAN}Repository:${RESET} $DOTFILES_DIR"
    echo -e "  ${CYAN}Backups:${RESET} *.bak.${BACKUP_TS}"
    echo -e "${DIM}==============================================${RESET}"

    detect_pkg_mgr

    local setup
    setup="$(choose_setup)"
    if [[ "$setup" == "shared-only" ]]; then
        log_info "Mode: ${BOLD}${MAGENTA}shared programs only${RESET} (shell setup skipped)"
    else
        log_info "Selected setup: ${BOLD}${MAGENTA}${setup}${RESET}"
    fi

    # ---- Step 1: shared components (by index) ----
    local SHARED_OPTS=(
        "tmux|tmux (~/.tmux.conf + TPM plugin manager)"
        "zsh|zsh (~/.zshrc + ~/.p10k.zsh + oh-my-zsh + powerlevel10k)"
        "kitty|kitty terminal (~/.config/kitty)"
        "neofetch|neofetch (~/.config/neofetch)"
        "ranger|ranger file manager (~/.config/ranger)"
        "yazi|yazi file manager (~/.config/yazi)"
        "zed|zed editor (~/.config/zed)"
        "vscode|VS Code / Code - OSS (~/.config/Code...)"
        "starship|starship prompt (~/.config/starship.toml)"
        "nvim|Neovim (clone github.com/nighty3098/nvim into ~/.config/nvim)"
        "wallpapers|wallpapers (~/Pictures/wallpapers)"
    )
    local SELECTED_SHARED=()
    index_menu "Select SHARED components to install (used by every setup):" \
        SHARED_OPTS SELECTED_SHARED

    # ---- Step 2: setup-specific components (skipped in shared-only mode) ----
    local SETUP_OPTS=()
    local SELECTED_SETUP=()
    local setup_title="shared programs"
    if [[ "$setup" == "shared-only" ]]; then
        log_skip "Shell setup skipped — going straight to shared programs."
    else
        case "$setup" in
            niri-noctalia)
                setup_title="niri-noctalia"
                SETUP_OPTS=(
                    "niri|niri compositor (~/.config/niri)"
                    "noctalia|noctalia-shell (~/.config/noctalia)"
                )
                ;;
            i3wm)
                setup_title="i3wm"
                SETUP_OPTS=(
                    "i3|i3 window manager (~/.config/i3)"
                    "polybar|polybar status bar (~/.config/polybar)"
                    "rofi|rofi launcher (~/.config/rofi)"
                    "dunst|dunst notifications (~/.config/dunst)"
                    "picom|picom compositor (~/.config/picom*.conf)"
                    "scripts|helper scripts (scripts/ -> ~/scripts)"
                )
                ;;
            hyprland)
                setup_title="hyprland"
                SETUP_OPTS=(
                    "hypr|hyprland compositor (~/.config/hypr)"
                    "waybar|waybar status bar (~/.config/waybar)"
                    "wofi|wofi launcher (~/.config/wofi)"
                    "dunst|dunst notifications (~/.config/dunst)"
                    "scripts_hypr|helper scripts (scripts_hyprland/ -> ~/scripts)"
                )
                ;;
        esac
        index_menu "Select '$setup_title' components to install:" \
            SETUP_OPTS SELECTED_SETUP
    fi

    # ---- Step 3: system packages (requires sudo) ----
    local PKG_OPTS=(
        "pkg_common|Shared system packages (git, zsh, tmux, kitty, ...)"
    )
    if [[ "$setup" != "shared-only" ]]; then
        PKG_OPTS+=("pkg_setup|$setup_title system packages")
    fi
    local SELECTED_PKG=()
    index_menu "Select system packages to install (requires sudo):" \
        PKG_OPTS SELECTED_PKG

    # ---- Nothing selected at all? ----
    if [[ ${#SELECTED_SHARED[@]} -eq 0 && ${#SELECTED_SETUP[@]} -eq 0 && ${#SELECTED_PKG[@]} -eq 0 ]]; then
        log_warn "Nothing selected — nothing to do. Exiting."
        exit 0
    fi

    echo ""
    echo -e "${CYAN}To install:${RESET} ${BOLD}${#SELECTED_SHARED[@]}${RESET} shared + ${BOLD}${#SELECTED_SETUP[@]}${RESET} setup + ${BOLD}${#SELECTED_PKG[@]}${RESET} package groups."
    if ! ask_yes_no "Proceed with installation?"; then
        log_info "Installation cancelled by user."
        exit 0
    fi

    # ---- Install packages ----
    if is_selected "pkg_common" "${SELECTED_PKG[@]}"; then
        install_common_packages || log_warn "Shared package installation finished with errors — continuing with configs."
    else
        log_skip "Shared packages skipped."
    fi
    if [[ "$setup" != "shared-only" ]] && is_selected "pkg_setup" "${SELECTED_PKG[@]}"; then
        install_setup_packages "$setup" || log_warn "Setup package installation finished with errors — continuing with configs."
    else
        log_skip "Setup packages skipped."
    fi

    # ---- Install shared components ----
    is_selected "tmux" "${SELECTED_SHARED[@]}" && install_comp_tmux || log_skip "tmux skipped."
    is_selected "zsh" "${SELECTED_SHARED[@]}" && install_comp_zsh || log_skip "zsh skipped."
    is_selected "kitty" "${SELECTED_SHARED[@]}" && install_comp_kitty || log_skip "kitty skipped."
    is_selected "neofetch" "${SELECTED_SHARED[@]}" && install_comp_neofetch || log_skip "neofetch skipped."
    is_selected "ranger" "${SELECTED_SHARED[@]}" && install_comp_ranger || log_skip "ranger skipped."
    is_selected "yazi" "${SELECTED_SHARED[@]}" && install_comp_yazi || log_skip "yazi skipped."
    is_selected "zed" "${SELECTED_SHARED[@]}" && install_comp_zed || log_skip "zed skipped."
    is_selected "vscode" "${SELECTED_SHARED[@]}" && install_comp_vscode || log_skip "VS Code skipped."
    is_selected "starship" "${SELECTED_SHARED[@]}" && install_comp_starship || log_skip "starship skipped."
    is_selected "nvim" "${SELECTED_SHARED[@]}" && install_comp_nvim || log_skip "nvim skipped."
    is_selected "wallpapers" "${SELECTED_SHARED[@]}" && install_comp_wallpapers || log_skip "wallpapers skipped."

    # ---- Install setup-specific components ----
    is_selected "niri" "${SELECTED_SETUP[@]}" && install_comp_niri || log_skip "niri skipped."
    is_selected "noctalia" "${SELECTED_SETUP[@]}" && install_comp_noctalia || log_skip "noctalia skipped."
    is_selected "i3" "${SELECTED_SETUP[@]}" && install_comp_i3 || log_skip "i3 skipped."
    is_selected "polybar" "${SELECTED_SETUP[@]}" && install_comp_polybar || log_skip "polybar skipped."
    is_selected "rofi" "${SELECTED_SETUP[@]}" && install_comp_rofi || log_skip "rofi skipped."
    is_selected "dunst" "${SELECTED_SETUP[@]}" && install_comp_dunst || log_skip "dunst skipped."
    is_selected "picom" "${SELECTED_SETUP[@]}" && install_comp_picom || log_skip "picom skipped."
    is_selected "scripts" "${SELECTED_SETUP[@]}" && install_comp_scripts "scripts" || log_skip "scripts skipped."
    is_selected "hypr" "${SELECTED_SETUP[@]}" && install_comp_hypr || log_skip "hypr skipped."
    is_selected "waybar" "${SELECTED_SETUP[@]}" && install_comp_waybar || log_skip "waybar skipped."
    is_selected "wofi" "${SELECTED_SETUP[@]}" && install_comp_wofi || log_skip "wofi skipped."
    is_selected "scripts_hypr" "${SELECTED_SETUP[@]}" && install_comp_scripts "scripts_hyprland" || log_skip "scripts skipped."

    # For niri-noctalia there is no scripts folder: management is done via 'noctalia msg'.
    if [[ "$setup" == "niri-noctalia" ]]; then
        log_info "Note: niri-noctalia needs no helper scripts (managed via 'noctalia msg')."
    fi

    echo ""
    echo -e "${DIM}==============================================${RESET}"
    if [[ "$setup" == "shared-only" ]]; then
        echo -e "${BOLD}${GREEN}DONE. Shared programs installed (no shell setup).${RESET}"
    else
        echo -e "${BOLD}${GREEN}DONE. Setup '${MAGENTA}${setup}${GREEN}' installed.${RESET}"
    fi
    echo -e "  ${CYAN}-${RESET} Old configs were backed up with the .bak.${BACKUP_TS} suffix"
    if is_selected "nvim" "${SELECTED_SHARED[@]}"; then
        echo -e "  ${CYAN}-${RESET} nvim: $CONFIG_DIR/nvim (from $NVIM_REPO)"
    fi
    if is_selected "tmux" "${SELECTED_SHARED[@]}"; then
        echo -e "  ${CYAN}-${RESET} TPM: ~/.tmux/plugins/tpm (press ${BOLD}<prefix> + I${RESET} inside tmux)"
    fi
    echo -e "  ${CYAN}-${RESET} Restart your shell (or run ${BOLD}'source ~/.zshrc'${RESET}) and log into the selected session."
    echo -e "${DIM}==============================================${RESET}"
}

main "$@"
