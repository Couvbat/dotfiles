#!/bin/bash

# Initialize variables
SDDM_THEME_REPO="https://codeberg.org/minMelody/sddm-sequoia.git"
SDDM_THEME_NAME="sequoia"
SDDM_THEME_PATH="/usr/share/sddm/themes/$SDDM_THEME_NAME"
SDDM_ASSET_FOLDER="$SDDM_THEME_PATH/backgrounds"
SDDM_WALLPAPERS_DIR="$HOME/Wallpapers"

setup_sddm() {
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
}
