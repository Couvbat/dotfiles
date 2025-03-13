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
        sudo pacman -S --needed --noconfirm "${toInstall[@]}"
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
    "nvidia-utils"
    "nvidia-settings"
    "figlet"
)

# Check if required packages are installed
_installPackages "${installer_packages[@]}"

# -----------------------------------------------------
# Install paru
# -----------------------------------------------------
figlet "AUR"

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
figlet "Hyprland"

# Required packages for hyprland
hyper_packages=(
    "xorg"
    "xwayland"
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

# Check if required hyper packages are installed
_installPackages "${hyper_packages[@]}"

# Enable services
systemctl enable NetworkManager.service
systemctl enable sddm.service

# copy sddm conf and theme
if [ ! -d "/etc/sddm.conf.d" ]; then
    mkdir -p "/etc/sddm.conf.d"
fi


cp share/sddm/sddm.conf /etc/sddm.conf.d/
cp share/sddm/theme.conf /etc/sddm.conf.d/theme.conf

# -----------------------------------------------------
# Install required packages for my setup
# -----------------------------------------------------
figlet "Packages"    

# Required packages for my setup
setup_packages=(
    "fastfetch"
    "discover"
    "flatpak"
    "blueman"
    "bluez-utils"
    "zsh"
    "zsh-completions"
    "zsh-autosuggestions"
    "zsh-syntax-highlighting"
    "fast-syntax-highlighting"
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

# Check if required packages are installed
_installPackages "${setup_packages[@]}"

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
    "asusctl"
    "rog-control-center"
)

# Check if required AUR packages are installed
_installAurPackages "${aurPackages[@]}"

# -----------------------------------------------------
# Install NVM and Node.js
# -----------------------------------------------------
figlet "Node.js"

# Install Node Version Manager (NVM)
if ! command_exists nvm; then
    echo "Installing NVM"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi

# -----------------------------------------------------
# Install MongoDB
# -----------------------------------------------------
figlet "MongoDB"

if ! command_exists mongod; then
    echo "Installing MongoDB"
    paru -S --noconfirm mongodb-bin
    sudo systemctl enable mongodb
    sudo systemctl start mongodb
fi

# -----------------------------------------------------
# Install required fonts
# -----------------------------------------------------
figlet "Fonts"

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
# Install qemu and virt-manager
# -----------------------------------------------------

# -----------------------------------------------------
# Copy wallpapers folder
# -----------------------------------------------------
figlet "Wallpapers"

# Copy wallpapers folder
if [ ! -d "$HOME/Wallpaper" ]; then
    mkdir -p "$HOME/Wallpaper"
    cp -r share/wallpapers/* "$HOME/wallpapers"
fi

if [ ! -f ~/.cache/wal/colors-hyprland.conf ]; then
    wal -ei ~/wallpapers/default.jpg
    echo "Pywal and templates activated."
else
    echo "Pywal already activated."
fi

# -----------------------------------------------------
# Copy scripts from repo to home directory
# -----------------------------------------------------
figlet "Scripts"

if [ ! -d "$HOME/.local/bin" ]; then
    mkdir -p "$HOME/.local/bin"
fi

# Copy scripts


# -----------------------------------------------------
# Shell configuration
# -----------------------------------------------------
figlet "ZSH"

# check if zsh is installed
if ! command_exists zsh; then
    echo "Installing zsh"
    sudo pacman -S --noconfirm zsh
fi

# Check if zsh is the default shell
if [ "$SHELL" != "/bin/zsh" ]; then
    chsh -s /bin/zsh
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    # Install oh-my-zsh
    wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh
else
    echo "Oh My Zsh is already installed."
fi

# -----------------------------------------------------
# Copy dotfiles from repo to home directory
# -----------------------------------------------------
figlet "Dotfiles"

if [ ! -d "$HOME/.config" ]; then
    mkdir -p "$HOME/.config"
fi

# Copy dotfiles
cp -r share/dotfiles/. "$HOME/"
