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

_installParu() {
    _installPackages "base-devel"
    SCRIPT=$(realpath "$0")
    temp_path=$(dirname "$SCRIPT")
    git clone https://aur.archlinux.org/paru.git "${temp_path}/paru"
    cd "${temp_path}/paru" || exit
    makepkg -si --noconfirm
    cd .. && rm -rf paru
}

install_aur_packages() {
    # Ensure paru is installed
    if ! _checkCommandExists "paru"; then
        _installParu
        echo ":: paru has been installed successfully."
    else
        echo ":: paru is already installed."
    fi

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
