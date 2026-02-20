INSANE_SKIP:${PN}-src += "buildpaths"

# Desktop launcher files and icon
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += " \
    file://freedoom1.desktop \
    file://freedoom2.desktop \
    file://gzdoom.png \
"

do_install:append() {
    install -d ${D}${datadir}/applications
    install -m 0644 ${UNPACKDIR}/freedoom1.desktop ${D}${datadir}/applications/freedoom1.desktop
    install -m 0644 ${UNPACKDIR}/freedoom2.desktop ${D}${datadir}/applications/freedoom2.desktop

    install -d ${D}${datadir}/icons/hicolor/128x128/apps
    install -m 0644 ${UNPACKDIR}/gzdoom.png ${D}${datadir}/icons/hicolor/128x128/apps/gzdoom.png
}

FILES:${PN} += "${datadir}/applications ${datadir}/icons"
