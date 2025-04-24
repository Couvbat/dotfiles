#!/bin/bash

install_node() {
    figlet "Node.js"

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
}
