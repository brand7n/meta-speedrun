SUMMARY = "GLES2 environment settings for Vivante GPU"
DESCRIPTION = "Sets COGL/Clutter/GDK to use GLES2 for Vivante GPU compatibility"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://gles-environment"

S = "${WORKDIR}/sources-unpack"

do_install() {
    # Use profile.d to avoid conflict with pam-plugin-env's /etc/environment
    install -d ${D}${sysconfdir}/profile.d
    install -m 0644 ${S}/gles-environment ${D}${sysconfdir}/profile.d/gles-env.sh
}

FILES:${PN} = "${sysconfdir}/profile.d/gles-env.sh"
