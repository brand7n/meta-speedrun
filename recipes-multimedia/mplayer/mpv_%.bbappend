# Vivante EGL headers define EGLNativeWindowType as struct wl_egl_window *
# (Wayland-specific), which is incompatible with GBM surfaces.
# Disable gbm AND drm from PACKAGECONFIG to prevent the recipe's
# __anonymous() from auto-enabling egl-drm (which requires gbm).
# Then re-enable drm manually via meson args so dmabuf-wayland VO
# is available for zero-copy V4L2 M2M hardware decode.
PACKAGECONFIG:remove = "gbm drm"
DEPENDS += "libdrm"
EXTRA_OEMESON:append = " -Ddrm=enabled -Degl-drm=disabled"

# Install system-wide config to force OpenGL API (auto-detect tries Vulkan first
# and crashes on Vivante's broken Vulkan ICD)
do_install:append() {
    install -d ${D}${sysconfdir}/mpv
    printf "gpu-api=opengl\nhwdec=auto\ngpu-dumb-mode=yes\n" > ${D}${sysconfdir}/mpv/mpv.conf
}
