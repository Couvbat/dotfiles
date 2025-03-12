#!/bin/bash

# -----------------------------------------------------
# Check prerequisites
# -----------------------------------------------------

# Check if command exists
_checkCommandExists() {
    package="$1"
    if ! command -v $package >/dev/null; then
        return 1
    else
        return 0
    fi
}

# Check if package is installed
_isInstalled() {
    package="$1"
    check="$(sudo pacman -Qs --color always "${package}" | grep "local" | grep "${package} ")"
    if [ -n "${check}" ]; then
        echo 0 #'0' means 'true' in Bash
        return #true
    fi
    echo 1 #'1' means 'false' in Bash
    return #false
}

# Check if required packages are installed
_installPackages() {
    toInstall=()
    for pkg; do
        if [[ $(_isInstalled "${pkg}") == 0 ]]; then
            echo ":: ${pkg} is already installed."
        else
            toInstall+=("${pkg}")
            echo ":: ${pkg} will be installed."
        fi
    done

    if [ ${#toInstall[@]} -gt 0 ]; then
        echo ":: Installing required packages..."
        sudo pacman -S --noconfirm "${toInstall[@]}"
    else
        echo ":: No packages need to be installed."
    fi
}

_installAurPackages() {
    toInstall=()
    for pkg; do
        if [[ $(_isInstalled "${pkg}") == 0 ]]; then
            echo ":: ${pkg} is already installed."
        else
            toInstall+=("${pkg}")
            echo ":: ${pkg} will be installed."
        fi
    done

    if [ ${#toInstall[@]} -gt 0 ]; then
        echo ":: Installing required AUR packages..."
        paru -S --noconfirm "${toInstall[@]}"
    else
        echo ":: No AUR packages need to be installed."
    fi
}

# Required packages for the installer
packages=(
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
    "nvidia-utils"
    "nvidia-settings"
    "asusctl"
    "rog-control-center"
)

# Check if required packages are installed
_installPackages "${packages[@]}"

# -----------------------------------------------------
# Install paru
# -----------------------------------------------------

# Install paru if needed
_installParu() {
    _installPackages "base-devel"
    SCRIPT=$(realpath "$0")
    temp_path=$(dirname "$SCRIPT")
    git clone https://aur.archlinux.org/paru.git "${temp_path}/paru"
    cd "${temp_path}/paru" || exit
    makepkg -si --noconfirm
    cd .. && rm -rf paru
}

# Check if paru is installed and install it if needed
if ! _checkCommandExists "paru"; then
    _installParu
    echo ":: paru has been installed successfully."
else
    echo ":: paru is already installed."
fi

# -----------------------------------------------------
# Install required packages for hyprland
# -----------------------------------------------------

# Required packages for hyprland
packages=(
    "hyprland"
    "hyprpaper"
    "hyprlock"
    "hypridle"
    "hyprpicker"
    "swaync"
    "gvfs"
    "noto-fonts"
    "noto-fonts-emoji"
    "noto-fonts-cjk"
    "noto-fonts-extra"
    "xdg-desktop-portal-hyprland"
    "libnotify"
    "alacritty"
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
    "ttf-fira-code"
    "libadwaita"
    "slurp"
    "grim"
    "papirus-icon-theme"
    "breeze"
    "fuse2"
    "pavucontrol"
    "python-pywal"
)

# Check if required packages are installed
_installPackages "${packages[@]}"

# -----------------------------------------------------
# Install required packages for my setup
# -----------------------------------------------------

# Required packages for my setup
packages=(
    "fastfetch"
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
)

# Make zsh default shell
chsh -s /bin/zsh

# Install oh-my-zsh
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Check if required packages are installed
_installPackages "${packages[@]}"

# AUR packages for my setup
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
)

# Check if required AUR packages are installed
_installAurPackages "${aurPackages[@]}"

# -----------------------------------------------------
# Install qemu and virt-manager
# -----------------------------------------------------




# -----------------------------------------------------
# Install required fonts
# -----------------------------------------------------

# Required fonts
fonts=(
    "ttf-fira-code"
    "ttf-fira-sans"
    "ttf-dejavu"
    "otf-font-awesome"
    "ttf-firacode-nerd"
)

# Check if required fonts are installed
_installPackages "${fonts[@]}"

# -----------------------------------------------------
# Copy wallpapers folder
# -----------------------------------------------------

# Copy wallpapers folder
if [ ! -d "$HOME/Wallpaper" ]; then
    mkdir -p "$HOME/Wallpaper"
    cp -r share/wallpapers/* "$HOME/Wallpaper"
fi

# -----------------------------------------------------
# Copy dotfiles from repo to home directory
# -----------------------------------------------------
if [ ! -d "$HOME/.config" ]; then
    mkdir -p "$HOME/.config"
fi

# Copy dotfiles
cp -r share/dotfiles/* "$HOME/.config"

# -----------------------------------------------------
# Copy scripts from repo to home directory
# -----------------------------------------------------
if [ ! -d "$HOME/.local/bin" ]; then
    mkdir -p "$HOME/.local/bin"
fi

