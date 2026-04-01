SUMMARY = "Fast system information tool"
DESCRIPTION = "Fastfetch is a neofetch-like tool for fetching system \
information and displaying it prettily. It is written mainly in C, with \
performance and customizability in mind."
HOMEPAGE = "https://github.com/fastfetch-cli/fastfetch"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=2090e7d93df7ad5a3d41f6fb4226ac76"

SRC_URI = "git://github.com/fastfetch-cli/fastfetch.git;protocol=https;branch=master"
SRCREV = "b81c4a04db151d67a38b95f641b58e9ac8e23d5b"

S = "${WORKDIR}/git"

inherit cmake pkgconfig

DEPENDS = "yyjson"

EXTRA_OECMAKE = " \
    -DENABLE_VULKAN=OFF \
    -DENABLE_OPENCL=OFF \
    -DENABLE_EGL=OFF \
    -DENABLE_GLX=OFF \
    -DENABLE_IMAGEMAGICK7=OFF \
    -DENABLE_IMAGEMAGICK6=OFF \
    -DENABLE_CHAFA=OFF \
    -DENABLE_DDCUTIL=OFF \
    -DENABLE_RPM=OFF \
    -DENABLE_XCB_RANDR=OFF \
    -DENABLE_XRANDR=OFF \
"

FILES:${PN} += " \
    ${datadir}/bash-completion \
    ${datadir}/fish \
    ${datadir}/zsh \
    ${datadir}/licenses \
"

RDEPENDS:${PN} = "yyjson"
