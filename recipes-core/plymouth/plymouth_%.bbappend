# Enable DRM/KMS backend for ARM (only enabled for x86 by default)
# Required for proper display on i.MX8MM with Wayland/KMS
PACKAGECONFIG:append = " drm"

# Disable initrd support (requires dracut which is not available)
PACKAGECONFIG:remove = "initrd"

# Use spinner theme (GNOME default, seamless handoff to GDM)
PLYMOUTH_DEFAULT_THEME ?= "spinner"

# Custom watermark logo for spinner theme
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += "file://watermark.png"

do_install:append() {
    if [ -e ${D}${datadir}/plymouth/plymouthd.defaults ]; then
        sed -i 's/^Theme=.*/Theme=${PLYMOUTH_DEFAULT_THEME}/' \
            ${D}${datadir}/plymouth/plymouthd.defaults
    fi

    # Install custom watermark logo into the spinner theme
    install -m 0644 ${UNPACKDIR}/watermark.png \
        ${D}${datadir}/plymouth/themes/spinner/watermark.png
}
