# Vivante EGL native types differ from Mesa's typedefs
# gnome-session-check-accelerated-gles-helper.c passes X11 types
# to EGL functions - functionally correct but type-incompatible
CFLAGS:append = " -Wno-error=incompatible-pointer-types -Wno-error=int-conversion"
