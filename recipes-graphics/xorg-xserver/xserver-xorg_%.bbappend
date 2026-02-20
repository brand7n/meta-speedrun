# Remove obsolete NXP patch - fix already integrated upstream in xserver 21.1.18
# The GL_BGRA_EXT format fix is now part of mainline glamor code
SRC_URI:remove:imxgpu = "file://0001-glamor-Fix-fbo-pixmap-format-with-GL_BGRA_EXT.patch"

# Fix missing libxshmfence dependency for DRI3 (upstream poky bug)
PACKAGECONFIG[dri3] = "-Ddri3=true,-Ddri3=false,libxshmfence"
