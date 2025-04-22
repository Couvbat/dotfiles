#!/bin/bash

copy_dotfiles() {
    figlet "Dotfiles"

    if [ ! -d "$DOTFILES_DIR" ]; then
        echo "Error: dotfiles directory not found at $DOTFILES_DIR"
        FAILED_STEPS+=("Dotfiles copy failed")
    else
        mkdir -p "$HOME/.config"
        if cp -r "$DOTFILES_DIR/." "$HOME/"; then
            echo ":: Dotfiles successfully copied"
        else
            echo "Error: Failed to copy dotfiles"
            FAILED_STEPS+=("Dotfiles copy failed")
        fi
    fi
}
