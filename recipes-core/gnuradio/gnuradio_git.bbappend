# meta-sdr patches predate Upstream-Status requirement
ERROR_QA:remove = "patch-status"
WARN_QA:remove = "patch-status"

# i.MX8MM has GLES2 only — no desktop OpenGL.
# Disable the GL-accelerated RFNoC Fosphor display (uses legacy glBegin/glEnd).
# All other Qt GUI plots (FFT, waterfall, constellation, etc.) use Qwt and work fine.
# Force Qt5OpenGL as not found so CMake skips the OpenGL::GL link.
EXTRA_OECMAKE += "-DQt5OpenGL_FOUND=FALSE"
