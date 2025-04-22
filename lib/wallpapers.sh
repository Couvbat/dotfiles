#!/bin/bash

setup_wallpapers() {
    figlet "Wallpapers"

    if [ ! -d "$HOME/wallpaper" ]; then
        mkdir -p "$HOME/wallpaper"
    fi

    if [ -d "$WALLPAPERS_DIR" ]; then
        cp -r "$WALLPAPERS_DIR"/* "$HOME/wallpaper/"
        echo ":: Wallpapers copied to $HOME/wallpaper/"
    else
        echo "Wallpapers directory not found: $WALLPAPERS_DIR"
        FAILED_STEPS+=("Wallpapers copy failed")
    fi

    default_wallpaper="$HOME/wallpaper/Solitary-Glow.png"
    mkdir -p "$HOME/.config/ml4w/cache"
    echo "$default_wallpaper" > "$HOME/.config/ml4w/cache/current_wallpaper"
    echo ":: Default wallpaper set to $default_wallpaper"

    if ! _checkCommandExists wal; then
        echo "Installing pywal"
        sudo pacman -S --noconfirm python-pywal
    fi

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

    if [ ! -f ~/.cache/wal/colors-hyprland.conf ]; then
        wal -i "$default_wallpaper" -t
        echo ":: Pywal and templates activated."
    else
        echo ":: Pywal already activated."
    fi
}
