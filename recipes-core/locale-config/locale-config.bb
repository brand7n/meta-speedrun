SUMMARY = "System locale configuration"
DESCRIPTION = "Sets default UTF-8 locale for GNOME terminal compatibility"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://locale.conf"

S = "${WORKDIR}/sources-unpack"

do_install() {
    install -d ${D}${sysconfdir}
    install -m 0644 ${S}/locale.conf ${D}${sysconfdir}/locale.conf
}

FILES:${PN} = "${sysconfdir}/locale.conf"
