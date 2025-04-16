#!/bin/bash

exec > >(tee -a "$HOME/install.log") 2>&1

# -----------------------------------------------------
# Configurable paths
# -----------------------------------------------------
DOTFILES_DIR="$(pwd)/share/dotfiles"
SCRIPTS_DIR="$(pwd)/share/scripts"
WALLPAPERS_DIR="$(pwd)/share/wallpapers"
IMAGES_DIR="$(pwd)/share/Images"
SDDM_THEME_REPO="https://codeberg.org/minMelody/sddm-sequoia.git"
SDDM_THEME_NAME="sequoia"
SDDM_THEME_PATH="/usr/share/sddm/themes/$SDDM_THEME_NAME"
SDDM_ASSET_FOLDER="$SDDM_THEME_PATH/backgrounds"

# -----------------------------------------------------
# Error tracking
# -----------------------------------------------------
FAILED_STEPS=()

# -----------------------------------------------------
# Check prerequisites
# -----------------------------------------------------

_checkCommandExists() {
    command -v "$1" >/dev/null 2>&1
}

_isInstalled() {
    pacman -Qs --color always "$1" | grep "local" | grep -q "$1 "
}

# Remove duplicates from arrays
_dedup() {
    printf "%s\n" "$@" | awk '!seen[$0]++'
}

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
    "nvidia-settings"
    "nvidia-utils"
    "linux-headers"
    "figlet"
    "gnome-keyring"
    "libsecret"
    "seahorse"
)

# Required packages for hyprland
hyper_packages=(
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
    "noto-fonts"
    "noto-fonts-emoji"
    "noto-fonts-cjk"
    "noto-fonts-extra"
    "xdg-desktop-portal-hyprland"
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
)

# Required packages for my setup
setup_packages=(
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
)

# Required fonts
fonts=(
    "ttf-fira-code"
    "ttf-fira-sans"
    "ttf-dejavu"
    "otf-font-awesome"
    "ttf-firacode-nerd"
)

# Combine and deduplicate all package lists
all_packages=(
    "${installer_packages[@]}"
    "${hyper_packages[@]}"
    "${setup_packages[@]}"
    "${fonts[@]}"
)
all_packages=($(_dedup "${all_packages[@]}"))
_installPackages "${all_packages[@]}"

# Enable NetworkManager service
sudo systemctl enable NetworkManager.service

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
    "teamviewer"
    "postman-bin"
    "smile"
    "wormhole-rs"
)

# Check if required AUR packages are installed
_installAurPackages "${aurPackages[@]}"

# -----------------------------------------------------
# Nvidia + Hyprland configuration
# -----------------------------------------------------
figlet "Nvidia"

# Uninstall old Hyprland packages if present
AUR_HELPER=paru
if $AUR_HELPER -Qs hyprland >/dev/null; then
    echo "Uninstalling old Hyprland packages..."
    for pkg in hyprland-git hyprland-nvidia hyprland-nvidia-git hyprland-nvidia-hidpi-git; do
        $AUR_HELPER -R --noconfirm "$pkg" 2>/dev/null || true
    done
fi

# Install NVIDIA and related packages for each kernel
nvidia_pkgs=(nvidia-dkms nvidia-settings nvidia-utils libva libva-nvidia-driver-git)
if [ -d /usr/lib/modules ]; then
    for krnl in $(cat /usr/lib/modules/*/pkgbase 2>/dev/null); do
        for pkg in "${krnl}-headers" "${nvidia_pkgs[@]}"; do
            $AUR_HELPER -S --noconfirm --needed "$pkg"
        done
    done
fi

# Ensure MODULES in /etc/mkinitcpio.conf contains NVIDIA modules
mkinitcpio_conf="/etc/mkinitcpio.conf"
if [ -f "$mkinitcpio_conf" ]; then
    if ! grep -qE '^MODULES=.*nvidia.*nvidia_modeset.*nvidia_uvm.*nvidia_drm' "$mkinitcpio_conf"; then
        sudo sed -Ei 's/^(MODULES=\([^)]+)\)/\1 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' "$mkinitcpio_conf"
        echo "Nvidia modules added to $mkinitcpio_conf"
    fi
else
    echo "Warning: $mkinitcpio_conf not found!"
    FAILED_STEPS+=("mkinitcpio.conf not found")
fi

# Ensure /etc/modprobe.d/nvidia.conf has correct options
nvidia_conf="/etc/modprobe.d/nvidia.conf"
if [ ! -f "$nvidia_conf" ]; then
    echo "options nvidia_drm modeset=1 fbdev=1" | sudo tee "$nvidia_conf"
else
    if ! grep -q "options nvidia_drm modeset=1 fbdev=1" "$nvidia_conf"; then
        echo "options nvidia_drm modeset=1 fbdev=1" | sudo tee -a "$nvidia_conf"
    fi
fi

# Rebuild initramfs
sudo mkinitcpio -P

# Add NVIDIA kernel params to GRUB if present
if [ -f /etc/default/grub ]; then
    sudo sed -i -e '/GRUB_CMDLINE_LINUX_DEFAULT=/ s/"$/ nvidia-drm.modeset=1 nvidia_drm.fbdev=1"/' /etc/default/grub
    sudo grub-mkconfig -o /boot/grub/grub.cfg
fi

# Add NVIDIA kernel params to systemd-boot if present
if [ -f /boot/loader/loader.conf ]; then
    if [ $(ls -l /boot/loader/entries/*.conf.ml4w.bkp 2>/dev/null | wc -l) -ne $(ls -l /boot/loader/entries/*.conf 2>/dev/null | wc -l) ]; then
        find /boot/loader/entries/ -type f -name "*.conf" | while read imgconf; do
            sudo cp ${imgconf} ${imgconf}.ml4w.bkp
            sdopt=$(grep -w "^options" ${imgconf} | sed 's/\\b quiet\\b//g' | sed 's/\\b splash\\b//g' | sed 's/\\b nvidia-drm.modeset=.\\b//g' | sed 's/\\b nvidia_drm.fbdev=.\\b//g')
            sudo sed -i "/^options/c${sdopt} quiet splash nvidia-drm.modeset=1 nvidia_drm.fbdev=1" ${imgconf}
        done
    else
        echo -e "\033[0;33m[SKIP]\033[0m systemd-boot is already configured..."
    fi
fi

echo "NVIDIA configuration complete!"

# -----------------------------------------------------
# Configure SDDM theme and wallpaper
# -----------------------------------------------------
figlet "SDDM"

# Create SDDM configuration directories if they don't exist
if [ ! -d "/etc/sddm.conf.d" ]; then
    echo ":: Creating SDDM configuration directory"
    sudo mkdir -p "/etc/sddm.conf.d"
fi

# Clone and install the Sequoia SDDM theme
echo ":: Installing Sequoia SDDM theme"
if [ -d "$SDDM_THEME_PATH" ]; then
    echo ":: Sequoia theme already exists, removing old version"
    sudo rm -rf "$SDDM_THEME_PATH"
fi

git clone "$SDDM_THEME_REPO" ~/sequoia && rm -rf ~/sequoia/.git
sudo mv ~/sequoia "$SDDM_THEME_PATH"

# Create the backgrounds directory in the theme if it doesn't exist
if [ -d "$SDDM_ASSET_FOLDER" ]; then
    echo ":: Sequoia theme backgrounds directory already exists, removing old version"
    sudo rm -rf "$SDDM_ASSET_FOLDER"
fi

echo ":: Creating SDDM theme backgrounds directory"
sudo mkdir -p "$SDDM_ASSET_FOLDER"

# Copy the wallpaper from our share directory to SDDM theme
echo ":: Copying wallpaper to SDDM theme"
sudo cp "$WALLPAPERS_DIR/Solitary-Glow.png" "$SDDM_ASSET_FOLDER/current_wallpaper.jpg"
echo ":: Default wallpaper copied to SDDM theme folder"

# Copy our SDDM configurations
echo ":: Copying SDDM configuration files"
sudo cp share/sddm/sddm.conf /etc/sddm.conf.d/
sudo cp share/sddm/theme.conf "$SDDM_THEME_PATH/theme.conf"

# Enable SDDM service
sudo systemctl enable sddm.service
echo ":: SDDM service enabled"

# -----------------------------------------------------
# Install NVM and Node.js
# -----------------------------------------------------
figlet "Node.js"

# Install Node Version Manager (NVM)
if ! _checkCommandExists nvm; then
    echo "Installing NVM"
    if ! curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash; then
        FAILED_STEPS+=("NVM install failed")
    fi
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
fi
if _checkCommandExists nvm; then
    nvm install --lts || FAILED_STEPS+=("Node.js install failed")
fi

# -----------------------------------------------------
# Install MongoDB
# -----------------------------------------------------
figlet "MongoDB"

if ! _checkCommandExists mongod; then
    echo "Installing MongoDB"
    paru -S --noconfirm mongodb-bin
    sudo systemctl enable mongodb
    sudo systemctl start mongodb
fi

# -----------------------------------------------------
# Install qemu and virt-manager #TODO
# -----------------------------------------------------

# -----------------------------------------------------
# Shell configuration
# -----------------------------------------------------
figlet "ZSH"

# check if zsh is installed
if ! _checkCommandExists zsh; then
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
    echo "Oh My Zsh is already a directory"
fi

if [ ! -d "$HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting"
fi

if [ ! -d "$HOME/.oh-my-zsh/plugins/fast-syntax-highlighting" ]; then
    git clone https://github.com/zdharma-continuum/fast-syntax-highlighting "$HOME/.oh-my-zsh/plugins/fast-syntax-highlighting"
fi

if [ ! -d "$HOME/.oh-my-zsh/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.oh-my-zsh/plugins/zsh-autosuggestions"
fi

# -----------------------------------------------------
# Copy scripts from repo to home directory
# -----------------------------------------------------
# figlet "Scripts"

# if [ ! -d "$HOME/.local/bin" ]; then
#     mkdir -p "$HOME/.local/bin"
# fi

# # Copy scripts
# if [ -d "$SCRIPTS_DIR" ]; then
#     cp -r "$SCRIPTS_DIR"/* "$HOME/.local/bin/"
#     chmod +x "$HOME/.local/bin/"*
# else
#     echo "Scripts directory not found: $SCRIPTS_DIR"
#     FAILED_STEPS+=("Scripts copy failed")
# fi

# -----------------------------------------------------
# Fastfetch
# -----------------------------------------------------
figlet "Fastfetch"

if [ ! -d "$HOME/Images" ]; then
    echo "No Images folder detected"
    echo "Creating images folder"
    mkdir -p "$HOME/Images"
fi

echo "Copying logo for fastfetch config"
cp -r "$IMAGES_DIR/." "$HOME/Images"

kitten icat -n --align=left --transfer-mode=stream "$HOME/Images/logo.png" > "$HOME/Images/logo.bin"

# -----------------------------------------------------
# Dotfiles
# -----------------------------------------------------
figlet "Dotfiles"

# Check if dotfiles directory exists
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Error: dotfiles directory not found at $DOTFILES_DIR"
    FAILED_STEPS+=("Dotfiles copy failed")
else
    # Create config directory if needed
    if [ ! -d "$HOME/.config" ]; then
        mkdir -p "$HOME/.config"
    fi

    # Copy dotfiles with verbose output and error handling
    echo "Copying dotfiles from $DOTFILES_DIR to $HOME"
    if cp -r "$DOTFILES_DIR/." "$HOME/"; then
        echo ":: Dotfiles successfully copied"
    else
        echo "Error: Failed to copy dotfiles (exit code $?)"
        FAILED_STEPS+=("Dotfiles copy failed")
    fi
fi

# -----------------------------------------------------
# Copy wallpapers folder
# -----------------------------------------------------
figlet "Wallpapers"

# Create wallpaper directory if it doesn't exist
if [ ! -d "$HOME/wallpaper" ]; then
    mkdir -p "$HOME/wallpaper"
fi

# Copy wallpapers
if [ -d "$WALLPAPERS_DIR" ]; then
    cp -r "$WALLPAPERS_DIR"/* "$HOME/wallpaper/"
    echo ":: Wallpapers copied to $HOME/wallpaper/"
else
    echo "Wallpapers directory not found: $WALLPAPERS_DIR"
    FAILED_STEPS+=("Wallpapers copy failed")
fi

# Set default wallpaper
default_wallpaper="$HOME/wallpaper/Solitary-Glow.png"
mkdir -p "$HOME/.config/ml4w/cache"
echo "$default_wallpaper" > "$HOME/.config/ml4w/cache/current_wallpaper"
echo ":: Default wallpaper set to $default_wallpaper"

if ! _checkCommandExists wal; then
    echo "Installing pywal"
    sudo pacman -S --noconfirm python-pywal
fi

# Create pywal Hyprland template
mkdir -p "$HOME/.config/wal/templates"
echo '# Auto generated color theme for Hyprland
$background = rgb({background.strip})
$foreground = rgb({foreground.strip})
$color0 = rgb({color0.strip})
$color1 = rgb({color1.strip})
$color2 = rgb({color2.strip})
$color3 = rgb({color3.strip})
$color4 = rgb({color4.strip})
$color5 = rgb({color5.strip})
$color6 = rgb({color6.strip})
$color7 = rgb({color7.strip})
$color8 = rgb({color8.strip})
$color9 = rgb({color9.strip})
$color10 = rgb({color10.strip})
$color11 = rgb({color11.strip})
$color12 = rgb({color12.strip})
$color13 = rgb({color13.strip})
$color14 = rgb({color14.strip})
$color15 = rgb({color15.strip})' > "$HOME/.config/wal/templates/colors-hyprland.conf"
echo ":: Created Hyprland color template for pywal"

# Generate initial colors
if [ ! -f ~/.cache/wal/colors-hyprland.conf ]; then
    wal -i "$default_wallpaper" -t
    echo ":: Pywal and templates activated."
else
    echo ":: Pywal already activated."
fi

# -----------------------------------------------------
# END
# -----------------------------------------------------

clear && figlet "Setup complete !"
echo ":: Please restart your system for all changes to take effect."
echo ":: Enjoy your new setup!"
echo ":: If you encounter any issues, please check the ~/install.log file for more information."

# Print summary
if [ ${#FAILED_STEPS[@]} -gt 0 ]; then
    echo "====================="
    echo "Some steps failed:"
    for step in "${FAILED_STEPS[@]}"; do
        echo "- $step"
    done
    echo "Check ~/install.log for details."
else
    echo "All steps completed successfully!"
fi