#!/bin/bash

setup_zsh() {
    figlet "ZSH"

    if ! _checkCommandExists zsh; then
        echo "Installing zsh"
        sudo pacman -S --noconfirm zsh
    fi

    if [ "$SHELL" != "/bin/zsh" ]; then
        chsh -s /bin/zsh
    fi

    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh
    else
        echo "Oh My Zsh is already installed"
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
}
