SUMMARY = "Vivante GPU workarounds for GNOME/GTK4"
DESCRIPTION = "Configure rendering for Vivante GPU compatibility with GNOME: \
1) CLUTTER_DRIVER=gles2 - Force mutter to use GLES2 (critical for ARM GPUs) \
2) GSK_RENDERER=cairo - Force GTK4 Cairo renderer (GLES 3.0 function issues)"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://gsk-renderer.sh"

S = "${WORKDIR}/sources-unpack"

inherit allarch

do_install() {
    install -d ${D}${sysconfdir}/profile.d
    install -m 0644 ${S}/gsk-renderer.sh ${D}${sysconfdir}/profile.d/
}

FILES:${PN} = "${sysconfdir}/profile.d/gsk-renderer.sh"
