FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# Port GR_REGISTER_COMPONENT calls to gnuradio 3.10 named-parameter API
SRC_URI += "file://0001-Port-GR_REGISTER_COMPONENT-to-gnuradio-3.10-API.patch \
            file://0002-Port-root-GR_REGISTER_COMPONENT-to-gnuradio-3.10.patch"

# Enable HackRF support
PACKAGECONFIG = "rtl-sdr hackrf"

# Python binding links to libgnuradio-osmosdr.so.0.2.0 which is already
# in the same package via gnuradio-oot class; QA just can't see it.
INSANE_SKIP:${PN} += "file-rdeps"

# meta-sdr patches predate Upstream-Status requirement
ERROR_QA:remove = "patch-status"
WARN_QA:remove = "patch-status"
