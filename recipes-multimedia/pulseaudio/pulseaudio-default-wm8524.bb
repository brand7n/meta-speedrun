# Audio configuration for i.MX8MM EVK
# - Sets WM8524 (headphone jack) as default PulseAudio sink
# - Hides unwanted audio devices (SPDIF, PDM mic, BT SCO) from PulseAudio

SUMMARY = "PulseAudio and audio device configuration for i.MX8MM"
DESCRIPTION = "Sets the WM8524 headphone output as the default PulseAudio sink \
and hides unwanted audio devices via udev rules"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
    file://default-sink.pa \
    file://90-pulseaudio-ignore.rules \
"

S = "${WORKDIR}/sources-unpack"

do_install() {
    # PulseAudio default sink config
    install -d ${D}${sysconfdir}/pulse/default.pa.d
    install -m 0644 ${S}/default-sink.pa ${D}${sysconfdir}/pulse/default.pa.d/

    # udev rules to hide unwanted audio devices from PulseAudio
    install -d ${D}${sysconfdir}/udev/rules.d
    install -m 0644 ${S}/90-pulseaudio-ignore.rules ${D}${sysconfdir}/udev/rules.d/
}

FILES:${PN} = " \
    ${sysconfdir}/pulse/default.pa.d/default-sink.pa \
    ${sysconfdir}/udev/rules.d/90-pulseaudio-ignore.rules \
"

RDEPENDS:${PN} = "pulseaudio"
