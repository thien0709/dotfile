#!/usr/bin/env bash
set -e

DOTFILES_DIR="$HOME/.dotfiles"
CONFIG_DIR="$HOME/.config"

echo "[1] Cài đặt base-devel và git..."
sudo pacman -S --needed base-devel git

echo "[2] Cài đặt yay nếu chưa có..."
if ! command -v yay &> /dev/null; then
    cd ~
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
else
    echo "✔ yay đã được cài đặt."
fi

REQUIRED_PACKAGES=(
    "alacritty" "picom" "rofi" "dunst" "polybar" "nvim" "eww"
    "ranger" "feh" "tmux"
    "ttf-daddytime-mono-nerd" "ttf-firacode-nerd"
    "ttf-jetbrains-mono-nerd" "ttf-nerd-fonts-symbols"
    "ttf-nerd-fonts-symbols-mono" "ttf-sourcecodepro-nerd"
    "ttf-space-mono-nerd"
)

is_installed() {
    pacman -Qi "$1" &>/dev/null
}

install_package() {
    local pkg="$1"
    if is_installed "$pkg"; then
        echo "✔ $pkg đã được cài"
    else
        echo "➤ Đang cài $pkg..."
        yay -S --noconfirm "$pkg"
    fi
}

echo "[3] Cài các gói cần thiết..."
for pkg in "${REQUIRED_PACKAGES[@]}"; do
    install_package "$pkg"
done

echo "[4] Sao chép icon/fonts/themes (nếu có)..."
for folder in icon fonts themes; do
    SRC_PATH="$DOTFILES_DIR/$folder"
    DEST_PATH="/usr/share/$folder"
    if [ -d "$SRC_PATH" ]; then
        echo " - Copy $folder → $DEST_PATH"
        sudo cp -r "$SRC_PATH" "$DEST_PATH"
    else
        echo " - Bỏ qua $folder (không tồn tại trong repo)"
    fi
done

CONFIGS=("alacritty" "picom" "rofi" "dunst" "polybar" "nvim" "eww" "ranger" "feh" "tmux")

echo "[5] Sao chép config vào ~/.config..."
for name in "${CONFIGS[@]}"; do
    SRC="$DOTFILES_DIR/$name"
    DEST="$CONFIG_DIR/$name"

    if [ -e "$DEST" ] || [ -L "$DEST" ]; then
        echo " - Xóa $DEST cũ"
        rm -rf "$DEST"
    fi

    if [ -d "$SRC" ]; then
        echo " + Copy $name → ~/.config"
        cp -r "$SRC" "$DEST"
    else
        echo " ! Bỏ qua $name (không có trong repo)"
    fi
done

echo -e "\n[✅] Hoàn tất! Bạn có thể xóa repo dotfile nếu muốn."
