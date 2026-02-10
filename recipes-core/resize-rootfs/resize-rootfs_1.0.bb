SUMMARY = "First-boot rootfs partition resize"
DESCRIPTION = "Expands the rootfs partition and ext4 filesystem to fill the SD card on first boot, then disables itself."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
    file://resize-rootfs.sh \
    file://resize-rootfs.service \
"

inherit systemd

SYSTEMD_SERVICE:${PN} = "resize-rootfs.service"
SYSTEMD_AUTO_ENABLE = "enable"

RDEPENDS:${PN} = "e2fsprogs-resize2fs parted util-linux-sfdisk"

do_install() {
    install -d ${D}${sbindir}
    install -m 0755 ${UNPACKDIR}/resize-rootfs.sh ${D}${sbindir}/resize-rootfs.sh

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${UNPACKDIR}/resize-rootfs.service ${D}${systemd_system_unitdir}/resize-rootfs.service
}
