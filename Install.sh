#!/usr/bin/env bash
set -e

REPO_URL="https://github.com/thien0709/dotfile.git"
BRANCH="refactor"
DOTFILES_DIR="$HOME/.dotfiles"
CONFIG_DIR="$HOME/.config"

echo "[1] Cloning dotfiles repo..."
if [ ! -d "$DOTFILES_DIR" ]; then
    git clone --branch "$BRANCH" "$REPO_URL" "$DOTFILES_DIR"
else
    echo "Dotfiles repo already exists, pulling latest changes..."
    cd "$DOTFILES_DIR"
    git checkout "$BRANCH"
    git pull
fi

echo "[2] Symlinking UI config files to ~/.config..."

echo "[3] Install git base-devel"
sudo pacman -S --needed base-devel git

echo "[4] Install yay "
if ! command -v yay &> /dev/null; then
    cd ~
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
fi




REQUIRED_PACKAGES=("alacritty" "picom" "rofi" "dunst" "polybar" "nvim" "eww" "ranger" "feh" "tmux" "ttf-daddytime-mono-nerd" "ttf-firacode-nerd" "ttf-jetbrains-mono-nerd" "ttf-nerd-fonts-symbols" "ttf-nerd-fonts-symbols-mono" "ttf-sourcecodepro-nerd" "ttf-space-mono-nerd")

# Hàm kiểm tra package đã được cài chưa
is_installed() {
    pacman -Qi "$1" &>/dev/null
}

# Hàm cài đặt package
install_package() {
    local pkg="$1"
    if is_installed "$pkg"; then
        echo "✔ $pkg đã được cài"
    else
        if command -v yay &>/dev/null; then
            echo "➤ Cài $pkg bằng yay..."
            yay -S --noconfirm "$pkg"
        else
            echo "➤ Cài $pkg bằng pacman..."
            sudo pacman -S --noconfirm "$pkg"
        fi
    fi
}

for pkg in "${REQUIRED_PACKAGES[@]}"; do
    install_package "$pkg"
done

# 

for folder in icon fonts themes; do
    SRC_PATH="$DOTFILES_DIR/$folder"
    DEST_PATH="/usr/share/$folder"
    if [ -d "$SRC_PATH" ]; then
        echo "Moving $folder to $DEST_PATH"
        sudo mv "$SRC_PATH" "$DEST_PATH"
    else
        echo "Folder $SRC_PATH not found, skipping..."
    fi
done

# Danh sách config cần di chuyển
CONFIGS=("alacritty" "picom" "rofi" "dunst" "polybar" "nvim" "eww" "ranger" "feh" "tmux")

echo "[4] Moving config folders to ~/.config ..."
for name in "${CONFIGS[@]}"; do
    SRC="$DOTFILES_DIR/$name"
    DEST="$CONFIG_DIR/$name"
    
    if [ -e "$DEST" ] || [ -L "$DEST" ]; then
        echo " - Removing existing $DEST"
        rm -rf "$DEST"
    fi
    
    if [ -d "$SRC" ]; then
        echo " + Moving $name config"
        mv "$SRC" "$DEST"
    else
        echo " ! Skipping $name (not found in repo)"
    fi
done

echo "[✔️] Config folders have been moved successfully!"
