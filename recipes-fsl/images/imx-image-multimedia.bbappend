# Remove tensorflow-dependent audio packages (ML layer not included)
IMAGE_INSTALL:remove = "packagegroup-fsl-tools-audio xterm"

# Exclude NXP packages that conflict or aren't needed
PACKAGE_EXCLUDE = "packagegroup-fsl-tools-audio nxp-afe-voiceseeker nxp-afe-voiceaec connman connman-tools packagegroup-core-tools-testapps"

# Plymouth boot splash (replaces psplash for seamless GDM handoff)
SPLASH = "plymouth"

# Include package manager in image (for deb installs on-device)
EXTRA_IMAGE_FEATURES += "package-management"

# GNOME desktop
IMAGE_INSTALL:append = " \
    packagegroup-gnome-desktop gnome-terminal nautilus gedit evince eog \
    gdm networkmanager htop \
"

# Vivante GLES workarounds
IMAGE_INSTALL:append = " gsk-cairo-config gles-env"

# Games
IMAGE_INSTALL:append = " gzdoom freedoom-1 freedoom-2"

# Dev tools
IMAGE_INSTALL:append = " glmark2 kmscube mesa-demos weston weston-examples git curl lsof alacritty"

# Browser + media player
IMAGE_INSTALL:append = " chromium-ozone-wayland mpv"

# SDR / GNU Radio
IMAGE_INSTALL:append = " gnuradio libhackrf gr-osmosdr rtl-sdr"

# Bluetooth (PulseAudio A2DP modules for speakers, tools)
IMAGE_INSTALL:append = " packagegroup-tools-bluetooth"

# Power management
IMAGE_INSTALL:append = " cpu-performance-mode disable-suspend resize-rootfs"

# Custom packages
IMAGE_INSTALL:append = " \
    locale-config cantarell-fonts pulseaudio pulseaudio-server \
    pulseaudio-misc pulseaudio-default-wm8524 es2-info fastfetch \
    tzdata \
"

# Create speedrun user account
inherit extrausers
EXTRA_USERS_PARAMS = "useradd -u 1000 -m -s /bin/bash -G video,audio,input,render -p '\$6\$4jmDOfNT27czQp9A\$BO2aTA/xoFDrWe0BRv1f28uXP69z93tKQhGfBBPbjQTASCRUBjCQjDI6ydramWYHTkkv7iBqidDd8ElKJP2dl.' speedrun;"

# Use GDM instead of Weston as the default display manager
SYSTEMD_DEFAULT_TARGET = "graphical.target"

disable_weston_enable_gdm() {
    # Disable weston service - remove enable symlinks
    rm -f ${IMAGE_ROOTFS}${sysconfdir}/systemd/system/graphical.target.wants/weston.service
    rm -f ${IMAGE_ROOTFS}${sysconfdir}/systemd/system/graphical.target.wants/weston@*.service
    rm -f ${IMAGE_ROOTFS}${sysconfdir}/systemd/system/multi-user.target.wants/weston*.service
    rm -f ${IMAGE_ROOTFS}${sysconfdir}/systemd/system/sockets.target.wants/weston.socket
    rm -f ${IMAGE_ROOTFS}${systemd_system_unitdir}/graphical.target.wants/weston*.service
    rm -f ${IMAGE_ROOTFS}${systemd_system_unitdir}/multi-user.target.wants/weston*.service

    # Mask weston so it can't be started
    ln -sf /dev/null ${IMAGE_ROOTFS}${sysconfdir}/systemd/system/weston.service
    ln -sf /dev/null ${IMAGE_ROOTFS}${sysconfdir}/systemd/system/weston@.service
    ln -sf /dev/null ${IMAGE_ROOTFS}${sysconfdir}/systemd/system/weston.socket

    # Enable GDM
    install -d ${IMAGE_ROOTFS}${sysconfdir}/systemd/system/graphical.target.wants
    ln -sf ${systemd_system_unitdir}/gdm.service ${IMAGE_ROOTFS}${sysconfdir}/systemd/system/graphical.target.wants/gdm.service
}

set_hostname() {
    echo "speedrun" > ${IMAGE_ROOTFS}${sysconfdir}/hostname
}

install_user_configs() {
    # Alacritty config (it only reads from ~/.config/alacritty/, not /etc/xdg/)
    install -d ${IMAGE_ROOTFS}/home/speedrun/.config/alacritty
    install -m 0644 ${IMAGE_ROOTFS}${sysconfdir}/xdg/alacritty/alacritty.toml \
        ${IMAGE_ROOTFS}/home/speedrun/.config/alacritty/

    chown -R 1000:1000 ${IMAGE_ROOTFS}/home/speedrun/.config

    # Also install to /etc/skel for any new users
    install -d ${IMAGE_ROOTFS}${sysconfdir}/skel/.config/alacritty
    install -m 0644 ${IMAGE_ROOTFS}${sysconfdir}/xdg/alacritty/alacritty.toml \
        ${IMAGE_ROOTFS}${sysconfdir}/skel/.config/alacritty/
}

ROOTFS_POSTPROCESS_COMMAND:append = " disable_weston_enable_gdm; set_hostname; install_user_configs;"
