# GTK3 X11 support is needed for GNOME on XWayland builds.
# NXP's meta-imx-bsp removes x11 with PACKAGECONFIG:remove:imxgpu = "x11"
# which breaks gnome-settings-daemon, gnome-shell, etc.
# This cannot be overridden from a layer (BitBake :remove is persistent).
# The NXP source must be patched directly - see BUILD_GUIDE.md Step 2.5.
