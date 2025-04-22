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
        "xdg-user-dirs"
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
    )
    _installPackages "${installer_packages[@]}"
    sudo systemctl enable NetworkManager.service
}
