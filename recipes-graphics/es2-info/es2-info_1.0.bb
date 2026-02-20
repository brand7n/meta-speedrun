SUMMARY = "Simple GLES2/EGL info utility"
DESCRIPTION = "Prints OpenGL ES 2.0 and EGL information without X11 dependency"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://es2_info.c"

S = "${WORKDIR}/sources-unpack"

DEPENDS = "virtual/egl virtual/libgles2"

do_compile() {
    ${CC} ${CFLAGS} ${LDFLAGS} -o es2_info ${S}/es2_info.c -lEGL -lGLESv2
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 es2_info ${D}${bindir}/
}
