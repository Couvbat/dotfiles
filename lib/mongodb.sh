#!/bin/bash

install_mongodb() {
    figlet "MongoDB"

    if ! _checkCommandExists mongod; then
        echo "Installing MongoDB"
        paru -S --noconfirm mongodb-bin
        sudo systemctl enable mongodb
        sudo systemctl start mongodb
    fi
}
