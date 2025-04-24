#!/bin/bash

# Function to check if a package is installed
_isInstalled() {
    pacman -Qs --color always "$1" | grep "local" | grep -q "$1 "
}

# Function to install system packages
_installPackages() {
    local toInstall=()
    for pkg in "$@"; do
        if _isInstalled "$pkg"; then
            echo ":: $pkg is already installed."
        else
            toInstall+=("$pkg")
            echo ":: $pkg will be installed."
        fi
    done
    if [ ${#toInstall[@]} -gt 0 ]; then
        echo ":: Installing required packages..."
        if ! sudo pacman -S --needed --noconfirm "${toInstall[@]}"; then
            FAILED_STEPS+=("pacman: ${toInstall[*]}")
        fi
    else
        echo ":: No packages need to be installed."
    fi
}

install_packages() {
    installer_packages=(
        "pacman-contrib"
        "git"
        "base-devel"
        "wget"
        "gcc"
        "sed"
        "xdg-desktop-portal-gtk"
        "xdg-desktop-portal-hyprland"
        "python-pip"
        "python-gobject"
        "networkmanager"
        "pipewire"
        "pipewire-pulse"
        "wireplumber"
        "nvidia-open-dkms"
        "nvidia-settings"
        "nvidia-utils"
        "linux-headers"
        "figlet"
        "gnome-keyring"
        "libsecret"
        "seahorse"
        "xorg"
        "egl-wayland"
        "xorg-xwayland"
        "hyprland"
        "hyprpaper"
        "hyprlock"
        "hypridle"
        "hyprpicker"
        "swaync"
        "gvfs"
        "libnotify"
        "kitty"
        "qt5-wayland"
        "qt6-wayland"
        "sddm"
        "qt5-graphicaleffects"
        "qt5-quickcontrols2"
        "qt5-svg"
        "qt6ct"
        "brightnessctl"
        "nm-connection-editor"
        "network-manager-applet"
        "cliphist"
        "polkit-gnome"
        "xclip"
        "waybar"
        "rofi-wayland"
        "nwg-dock-hyprland"
        "nwg-look"
        "libadwaita"
        "slurp"
        "grim"
        "papirus-icon-theme"
        "breeze"
        "fuse2"
        "pavucontrol"
        "python-pywal"
        "fastfetch"
        "superfile"
        "discover"
        "flatpak"
        "blueman"
        "bluez-utils"
        "zsh"
        "zsh-completions"
        "eza"
        "fzf"
        "fd"
        "atuin"
        "zoxide"
        "btop"
        "bat"
        "jq"
        "gping"
        "dog"
        "imagemagick"
        "neovim"
        "nautilus"
        "gnome-calculator"
        "tldr"
        "onefetch"
        "ttf-fira-code"
        "ttf-fira-sans"
        "ttf-dejavu"
        "otf-font-awesome"
        "ttf-firacode-nerd"
        "noto-fonts"
        "noto-fonts-emoji"
        "noto-fonts-cjk"
        "noto-fonts-extra"
        "cmatrix"
    )
    _installPackages "${installer_packages[@]}"
    sudo systemctl enable NetworkManager.service
}
