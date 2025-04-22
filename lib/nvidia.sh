#!/bin/bash

configure_nvidia() {
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
                sdopt=$(grep -w "^options" ${imgconf} | sed 's/\b quiet\b//g' | sed 's/\b splash\b//g' | sed 's/\b nvidia-drm.modeset=.\b//g' | sed 's/\b nvidia_drm.fbdev=.\b//g')
                sudo sed -i "/^options/c${sdopt} quiet splash nvidia-drm.modeset=1 nvidia_drm.fbdev=1" ${imgconf}
            done
        else
            echo -e "\033[0;33m[SKIP]\033[0m systemd-boot is already configured..."
        fi
    fi

    echo "NVIDIA configuration complete!"
}
