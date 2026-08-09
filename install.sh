#!/usr/bin/env bash

set -euo pipefail

# ============================================================
# Dotfiles Installer
# Arch Linux + Niri
# Repository: https://github.com/thien0709/dotfile
# Branch: niri
# ============================================================

REPO_URL="https://github.com/thien0709/dotfile.git"
BRANCH="niri"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES="$SCRIPT_DIR"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# ============================================================
# Colors
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[ OK ]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# ============================================================
# Check Arch Linux
# ============================================================

if [[ ! -f /etc/arch-release ]]; then
    error "This installer is designed for Arch Linux."
    exit 1
fi

if [[ "$EUID" -eq 0 ]]; then
    error "Do not run this script with sudo."
    echo
    echo "Run:"
    echo "  ./install.sh"
    exit 1
fi

# ============================================================
# Repository
# ============================================================

if [[ ! -d "$DOTFILES/.git" ]]; then
    info "Dotfiles repository not found."
    info "Cloning branch: $BRANCH"

    DOTFILES="$HOME/.dotfile"

    if [[ -d "$DOTFILES" ]]; then
        warn "$DOTFILES already exists."
        read -rp "Remove it and clone again? [y/N] " answer

        if [[ "$answer" =~ ^[Yy]$ ]]; then
            rm -rf "$DOTFILES"
        else
            error "Cannot continue."
            exit 1
        fi
    fi

    git clone \
        --branch "$BRANCH" \
        --single-branch \
        "$REPO_URL" \
        "$DOTFILES"

    success "Repository cloned."
fi

# ============================================================
# Install yay
# ============================================================

install_yay() {
    if command -v yay >/dev/null 2>&1; then
        return
    fi

    warn "yay is not installed."

    read -rp "Install yay now? [Y/n] " answer
    answer="${answer:-Y}"

    if [[ ! "$answer" =~ ^[Yy]$ ]]; then
        error "yay is required for Nerd Fonts."
        exit 1
    fi

    info "Installing yay..."

    sudo pacman -S --needed --noconfirm git base-devel

    local tmp_dir
    tmp_dir="$(mktemp -d)"

    git clone https://aur.archlinux.org/yay.git "$tmp_dir/yay"

    (
        cd "$tmp_dir/yay"
        makepkg -si --noconfirm
    )

    rm -rf "$tmp_dir"

    success "yay installed."
}

# ============================================================
# Official packages
# ============================================================

PACMAN_PACKAGES=(
    # -------------------------
    # Niri
    # -------------------------
    niri
    xwayland-satellite
    xdg-desktop-portal
    xdg-desktop-portal-gnome
    xdg-desktop-portal-gtk

    # -------------------------
    # Wayland utilities
    # -------------------------
    waybar
    swaybg
    swaync
    rofi

    # -------------------------
    # Terminal / Shell
    # -------------------------
    alacritty
    zsh

    # -------------------------
    # File manager
    # -------------------------
    ranger
    nautilus

    # -------------------------
    # CLI utilities
    # -------------------------
    git
    curl
    wget
    jq
    ripgrep
    fd
    fzf
    bat
    eza
    tree
    htop
    fastfetch
    unzip
    p7zip

    # -------------------------
    # Audio
    # -------------------------
    pipewire
    pipewire-pulse
    wireplumber

    # -------------------------
    # Bluetooth
    # -------------------------
    bluez
    bluez-utils

    # -------------------------
    # Screenshot / Clipboard
    # -------------------------
    grim
    slurp
    wl-clipboard

    # -------------------------
    # Polkit
    # -------------------------
    polkit-gnome

    # -------------------------
    # Neovim
    # -------------------------
    neovim
)

# ============================================================
# Install official packages
# ============================================================

info "Updating system..."

sudo pacman -Syu --noconfirm

info "Installing required packages..."

sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"

success "Official packages installed."

# ============================================================
# Nerd Fonts
# ============================================================

install_yay

echo
echo "============================================================"
echo "                 Nerd Font Installation"
echo "============================================================"
echo

echo "Choose the Nerd Font you want to install:"
echo

NERD_FONTS=(
    "ttf-jetbrains-mono-nerd"
    "ttf-fira-code"
    "ttf-hack-nerd"
    "ttf-iosevka-nerd"
    "ttf-meslo-nerd"
    "ttf-ubuntu-mono-nerd"
    "ttf-cascadia-code-nerd"
)

NERD_FONT_NAMES=(
    "JetBrains Mono Nerd Font"
    "Fira Code Nerd Font"
    "Hack Nerd Font"
    "Iosevka Nerd Font"
    "Meslo Nerd Font"
    "Ubuntu Mono Nerd Font"
    "Cascadia Code Nerd Font"
)

for i in "${!NERD_FONTS[@]}"; do
    printf "  %d) %s\n" "$((i + 1))" "${NERD_FONT_NAMES[$i]}"
done

echo "  0) Skip"
echo

while true; do
    read -rp "Enter your choice: " font_choice

    if [[ "$font_choice" == "0" ]]; then
        info "Skipping Nerd Font installation."
        break
    fi

    if [[ "$font_choice" =~ ^[1-7]$ ]]; then
        selected_font="${NERD_FONTS[$((font_choice - 1))]}"
        selected_name="${NERD_FONT_NAMES[$((font_choice - 1))]}"

        info "Installing $selected_name..."

        yay -S --needed --noconfirm "$selected_font"

        success "$selected_name installed."
        break
    fi

    warn "Invalid choice. Please enter 0-7."
done

# ============================================================
# Backup existing configuration
# ============================================================

info "Creating configuration backup..."

mkdir -p "$BACKUP_DIR"

CONFIGS=(
    niri
    waybar
    swaync
    rofi
    alacritty
    fastfetch
    ranger
    nvim
)

for config in "${CONFIGS[@]}"; do
    if [[ -e "$HOME/.config/$config" ]]; then
        cp -a "$HOME/.config/$config" "$BACKUP_DIR/"
        info "Backed up: ~/.config/$config"
    fi
done

for file in \
    "$HOME/.zshrc" \
    "$HOME/.bashrc" \
    "$HOME/.profile"
do
    if [[ -e "$file" ]]; then
        cp -a "$file" "$BACKUP_DIR/"
    fi
done

success "Backup created:"
echo "  $BACKUP_DIR"

# ============================================================
# Create ~/.config
# ============================================================

mkdir -p "$HOME/.config"

# ============================================================
# Copy configuration
# ============================================================

copy_config() {
    local name="$1"
    local source="$DOTFILES/$name"
    local target="$HOME/.config/$name"

    if [[ ! -d "$source" ]]; then
        return
    fi

    info "Installing ~/.config/$name"

    mkdir -p "$target"
    cp -a "$source/." "$target/"

    success "$name"
}

for config in \
    niri \
    waybar \
    swaync \
    rofi \
    alacritty \
    fastfetch \
    ranger \
    nvim
do
    copy_config "$config"
done

# ============================================================
# Copy shell configuration
# ============================================================

copy_file() {
    local file="$1"

    if [[ -f "$DOTFILES/$file" ]]; then
        info "Installing ~/$file"
        cp -a "$DOTFILES/$file" "$HOME/$file"
        success "$file"
    fi
}

copy_file ".zshrc"
copy_file ".bashrc"
copy_file ".profile"

# ============================================================
# Make scripts executable
# ============================================================

info "Setting executable permissions..."

find "$HOME/.config" \
    -type f \
    \( -name "*.sh" -o -name "*.py" \) \
    -exec chmod +x {} \; \
    2>/dev/null || true

# ============================================================
# Enable audio services
# ============================================================

info "Enabling PipeWire..."

systemctl --user enable pipewire.service 2>/dev/null || true
systemctl --user enable pipewire-pulse.service 2>/dev/null || true
systemctl --user enable wireplumber.service 2>/dev/null || true

# ============================================================
# Bluetooth
# ============================================================

info "Enabling Bluetooth..."

sudo systemctl enable --now bluetooth.service 2>/dev/null || true

# ============================================================
# Zsh
# ============================================================

if command -v zsh >/dev/null 2>&1; then
    CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7)"
    ZSH_PATH="$(command -v zsh)"

    if [[ "$CURRENT_SHELL" != "$ZSH_PATH" ]]; then
        info "Changing default shell to zsh..."
        chsh -s "$ZSH_PATH"
        success "Default shell changed to zsh."
    fi
fi

# ============================================================
# Font cache
# ============================================================

if command -v fc-cache >/dev/null 2>&1; then
    info "Updating font cache..."
    fc-cache -f >/dev/null 2>&1 || true
fi

# ============================================================
# Neovim
# ============================================================

if command -v nvim >/dev/null 2>&1 &&
   [[ -d "$HOME/.config/nvim" ]]; then

    info "Installing Neovim plugins..."

    nvim --headless \
        "+Lazy! sync" \
        "+qa" \
        2>/dev/null \
        || warn "Neovim plugin installation failed."
fi

# ============================================================
# Final message
# ============================================================

echo
echo "============================================================"
echo -e "${GREEN}       Dotfiles installation completed!${NC}"
echo "============================================================"
echo

echo -e "${CYAN}Repository:${NC}"
echo "  $REPO_URL"
echo

echo -e "${CYAN}Branch:${NC}"
echo "  $BRANCH"
echo

echo -e "${CYAN}Backup:${NC}"
echo "  $BACKUP_DIR"
echo

echo -e "${CYAN}Installed configs:${NC}"

for config in \
    niri \
    waybar \
    swaync \
    rofi \
    alacritty \
    fastfetch \
    ranger \
    nvim
do
    if [[ -d "$HOME/.config/$config" ]]; then
        echo "  ~/.config/$config"
    fi
done

echo
echo "Please log out and select:"
echo
echo "  Niri"
echo
echo "Then start a new session."
echo