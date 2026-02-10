SUMMARY = "Disable System Suspend"
DESCRIPTION = "Systemd configuration and GNOME settings to disable suspend/hibernate on i.MX8MM"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit gsettings

SRC_URI = " \
    file://disable-suspend.conf \
    file://90_disable-suspend.gschema.override \
"

S = "${WORKDIR}/sources-unpack"

do_install() {
    # Install sleep.conf.d configuration
    install -d ${D}${sysconfdir}/systemd/sleep.conf.d
    install -m 0644 ${UNPACKDIR}/disable-suspend.conf ${D}${sysconfdir}/systemd/sleep.conf.d/

    # Mask suspend/sleep/hibernate targets
    install -d ${D}${sysconfdir}/systemd/system
    ln -sf /dev/null ${D}${sysconfdir}/systemd/system/sleep.target
    ln -sf /dev/null ${D}${sysconfdir}/systemd/system/suspend.target
    ln -sf /dev/null ${D}${sysconfdir}/systemd/system/hibernate.target
    ln -sf /dev/null ${D}${sysconfdir}/systemd/system/hybrid-sleep.target
    ln -sf /dev/null ${D}${sysconfdir}/systemd/system/suspend-then-hibernate.target

    # Install GNOME power settings override (disables suspend popup)
    install -d ${D}${datadir}/glib-2.0/schemas
    install -m 0644 ${UNPACKDIR}/90_disable-suspend.gschema.override ${D}${datadir}/glib-2.0/schemas/
}

FILES:${PN} = " \
    ${sysconfdir}/systemd/sleep.conf.d/disable-suspend.conf \
    ${sysconfdir}/systemd/system/sleep.target \
    ${sysconfdir}/systemd/system/suspend.target \
    ${sysconfdir}/systemd/system/hibernate.target \
    ${sysconfdir}/systemd/system/hybrid-sleep.target \
    ${sysconfdir}/systemd/system/suspend-then-hibernate.target \
    ${datadir}/glib-2.0/schemas/90_disable-suspend.gschema.override \
"
