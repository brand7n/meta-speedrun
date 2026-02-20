SUMMARY = "Alacritty - A fast, cross-platform, OpenGL terminal emulator"
DESCRIPTION = "Alacritty is a modern terminal emulator with sensible defaults \
and GPU-accelerated rendering. Supports OpenGL ES 2.0 with automatic fallback."
HOMEPAGE = "https://alacritty.org"
SECTION = "x11/utils"
LICENSE = "Apache-2.0 & MIT"
LIC_FILES_CHKSUM = " \
    file://LICENSE-APACHE;md5=778c26cfcedd4cfbc3dd70d4aea420cd \
    file://LICENSE-MIT;md5=b377b220f43d747efdec40d69fcaa69d \
"

SRC_URI = "gitsm://github.com/alacritty/alacritty.git;protocol=https;nobranch=1 \
    file://alacritty.toml \
"
SRCREV = "0c405d53e74ace2980fc5e6c6d5b710c144bc075"

S = "${WORKDIR}/git"

# The binary crate is in the alacritty/ subdirectory of the workspace
CARGO_SRC_DIR = "alacritty"

require alacritty-crates.inc

inherit cargo cargo-update-recipe-crates pkgconfig

# Wayland-only, no X11 (i.MX8MM uses Wayland exclusively)
CARGO_BUILD_FLAGS += "--no-default-features --features=wayland"

DEPENDS = " \
    fontconfig \
    freetype \
    libxkbcommon \
    wayland \
    wayland-protocols \
    virtual/egl \
    virtual/libgles2 \
    cmake-native \
    python3-native \
"

do_install:append() {
    # Install desktop entry
    install -d ${D}${datadir}/applications
    install -m 0644 ${S}/extra/linux/Alacritty.desktop ${D}${datadir}/applications/

    # Install icon
    install -d ${D}${datadir}/pixmaps
    install -m 0644 ${S}/extra/logo/alacritty-term.svg ${D}${datadir}/pixmaps/Alacritty.svg

    # Install terminfo source (compiled at image time by ncurses)
    install -d ${D}${datadir}/terminfo
    if [ -f ${S}/extra/alacritty.info ]; then
        install -m 0644 ${S}/extra/alacritty.info ${D}${datadir}/terminfo/
    fi

    # Install default config with proper colors for GLES2
    install -d ${D}${sysconfdir}/xdg/alacritty
    install -m 0644 ${UNPACKDIR}/alacritty.toml ${D}${sysconfdir}/xdg/alacritty/
}

FILES:${PN} += " \
    ${datadir}/applications \
    ${datadir}/pixmaps \
    ${datadir}/terminfo \
    ${sysconfdir}/xdg/alacritty \
"

RDEPENDS:${PN} = "ncurses-terminfo-base"
