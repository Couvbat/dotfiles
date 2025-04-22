#!/bin/bash

# Function to check if a command exists
_checkCommandExists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if a package is installed
_isInstalled() {
    pacman -Qs --color always "$1" | grep "local" | grep -q "$1 "
}

# Function to install AUR packages
_installAurPackages() {
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
        echo ":: Installing required AUR packages..."
        if ! paru -S --noconfirm --skipreview "${toInstall[@]}"; then
            FAILED_STEPS+=("AUR: ${toInstall[*]}")
        fi
    else
        echo ":: No AUR packages need to be installed."
    fi
}

install_aur_packages() {
    aurPackages=(
        "checkupdates-with-aur"
        "nautilus-open-any-terminal"
        "bibata-cursor-theme-bin"
        "grimblast-git"
        "pinta"
        "hyprshade"
        "pacseek"
        "python-screeninfo"
        "python-pywalfox"
        "wlogout"
        "waypaper"
        "vesktop-bin"
        "spotube-bin"
        "visual-studio-code-bin"
        "zen-browser-bin"
        "asusctl"
        "rog-control-center"
        "teamviewer"
        "postman-bin"
        "smile"
        "wormhole-rs"
    )
    _installAurPackages "${aurPackages[@]}"
}
