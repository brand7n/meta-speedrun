# Quilter customizations for Chromium
# V4L2 HW encode patches for Hantro H1 on i.MX8MM

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# V4L2 MMAP encode support + stride fix (core HW encode functionality)
SRC_URI += "file://chromium-v4l2-hw-encode-129.patch"

# Codec filter debug flags (--webrtc-disable-vp8, --webrtc-disable-h264, etc.)
SRC_URI += "file://chromium-v4l2-hw-encode-codec-filter-129.patch"

# Fix chrome://gpu crash on GLES 2.0 drivers (Vivante GC NanoUltra)
# NULL glGetStringi function pointer causes SIGSEGV during extension enumeration
SRC_URI += "file://chromium-gles2-glgetstringi-null-check-129.patch"

# Fix Dawn WebGPU chrome://gpu crash on GLES 2.0 (separate GL dispatch from ui/gl/)
SRC_URI += "file://dawn-gles2-glgetstringi-null-check-129.patch"

# Remove IS_CHROMEOS gate from V4L2 encoder factory + BUILD.gn
SRC_URI += "file://chromium-v4l2-encode-remove-chromeos-gate-129.patch"

# Enable kVaapiVideoEncodeLinux by default (gates HW encode on Linux)
# Previous version also forced NV12 GBM support — REMOVED, that caused OOM
SRC_URI += "file://chromium-v4l2-webrtc-nv12-force-129.patch"

# Disable AV1 — no hardware decoder on i.MX8MM, software decode is too slow
# Matches Scarthgap 117 recipe settings
GN_ARGS += " \
    enable_dav1d_decoder=false \
    enable_libaom=false \
    rtc_include_dav1d_in_internal_decoder_factory=false \
"
