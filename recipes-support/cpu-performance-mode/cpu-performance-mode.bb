SUMMARY = "CPU Performance Mode Service"
DESCRIPTION = "Systemd service to set CPU governor to performance mode on boot"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit systemd

SRC_URI = "file://cpu-performance.service"

S = "${WORKDIR}/sources-unpack"

SYSTEMD_SERVICE:${PN} = "cpu-performance.service"
SYSTEMD_AUTO_ENABLE = "enable"

do_install() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${UNPACKDIR}/cpu-performance.service ${D}${systemd_system_unitdir}/
}

FILES:${PN} = "${systemd_system_unitdir}/cpu-performance.service"
