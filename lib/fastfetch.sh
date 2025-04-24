#!/bin/bash

# Initialize variables
IMAGES_DIR="$(pwd)/share/Images"

setup_fastfetch() {
    figlet "Fastfetch"

    if [ ! -d "$HOME/Images" ]; then
        echo "No Images folder detected"
        echo "Creating images folder"
        mkdir -p "$HOME/Images"
    fi

    echo "Copying logo for Fastfetch config"
    cp -r "$IMAGES_DIR/." "$HOME/Images"

    kitten icat -n --align=left --transfer-mode=stream "$HOME/Images/logo.png" > "$HOME/Images/logo.bin"
}
