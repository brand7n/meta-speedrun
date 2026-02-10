# Relax sandboxing for embedded i.MX8MM — PrivateUsers and ProtectProc
# can fail on kernels without full user-namespace or /proc restrictions.
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += "file://relax-sandbox.conf"

do_install:append() {
    install -d ${D}${systemd_system_unitdir}/colord.service.d
    install -m 0644 ${UNPACKDIR}/relax-sandbox.conf \
        ${D}${systemd_system_unitdir}/colord.service.d/relax-sandbox.conf
}

FILES:${PN} += "${systemd_system_unitdir}/colord.service.d"
