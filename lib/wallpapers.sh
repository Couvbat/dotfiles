#!/bin/bash

# Initialize variables
WALLPAPER_REPO="https://github.com/couvbat/wallpapers.git"
TMP_DIR="~/tmp/wallpapers"
WALLPAPERS_DIR="$TMP_DIR/share"
TARGET_DIR="~/Wallpapers"

setup_wallpapers() {
    figlet "Wallpapers"

    # Ensure the temporary directory is clean
    if [ -d "$TMP_DIR" ]; then
        echo ":: Cleaning up existing temporary directory"
        rm -rf "$TMP_DIR"
    fi

    # Clone the wallpapers repository into a temporary directory
    echo ":: Cloning wallpapers repository"
    git clone "$WALLPAPER_REPO" "$TMP_DIR"

    # Ensure the target wallpaper directory exists
    if [ ! -d "$TARGET_DIR" ]; then
        mkdir -p "$TARGET_DIR"
    fi

    # Copy wallpapers from the cloned repository
    if [ -d "$WALLPAPERS_DIR" ]; then
        cp -r "$WALLPAPERS_DIR"/* "$TARGET_DIR/"
        echo ":: Wallpapers copied to $TARGET_DIR/"
    else
        echo "Wallpapers directory not found in the repository: $WALLPAPERS_DIR"
        FAILED_STEPS+=("Wallpapers copy failed")
    fi

    # Clean up the temporary directory
    if [ -d "$TMP_DIR" ]; then
        rm -rf "$TMP_DIR"
        echo ":: Deleted temporary wallpapers repository"
    else
        echo "Temporary wallpapers repository not found: $TMP_DIR"
        FAILED_STEPS+=("Temporary repo deletion failed")
    fi

    # Set the default wallpaper
    default_wallpaper="$TARGET_DIR/Solitary-Glow.png"
    mkdir -p "$HOME/.config/ml4w/cache"
    echo "$default_wallpaper" > "$HOME/.config/ml4w/cache/current_wallpaper"
    echo ":: Default wallpaper set to $default_wallpaper"

    # Check and install pywal if not available
    if ! _checkCommandExists wal; then
        echo "Installing pywal"
        sudo pacman -S --noconfirm python-pywal
    fi

    # Create the Hyprland color template
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

    # Activate pywal with the default wallpaper
    if [ ! -f ~/.cache/wal/colors-hyprland.conf ]; then
        wal -i "$default_wallpaper" -t
        echo ":: Pywal and templates activated."
    else
        echo ":: Pywal already activated."
    fi
}
