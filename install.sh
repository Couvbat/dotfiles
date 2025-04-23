#!/bin/bash

exec > >(tee -a "$HOME/install.log") 2>&1

# -----------------------------------------------------
# Error tracking
# -----------------------------------------------------
FAILED_STEPS=()

# -----------------------------------------------------
# Load sub-scripts
# -----------------------------------------------------
source "$(pwd)/lib/packages.sh"
source "$(pwd)/lib/aur.sh"
source "$(pwd)/lib/nvidia.sh"
source "$(pwd)/lib/wallpapers.sh"
source "$(pwd)/lib/sddm.sh"
source "$(pwd)/lib/zsh.sh"
source "$(pwd)/lib/fastfetch.sh"
source "$(pwd)/lib/dotfiles.sh"
source "$(pwd)/lib/node.sh"
source "$(pwd)/lib/mongodb.sh"

# -----------------------------------------------------
# Execute sub-scripts
# -----------------------------------------------------
install_packages
install_aur_packages
# configure_nvidia
setup_wallpapers
setup_sddm
setup_zsh
setup_fastfetch
copy_dotfiles
install_node
install_mongodb

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