# Force mutter/clutter to use OpenGL ES 2.0 (Vivante-accelerated)
# This is the critical fix for ARM GPUs - forces GLES2 over desktop GL
export CLUTTER_DRIVER=gles2

# Force GTK4 to use Cairo renderer (workaround for Vivante GLES 3.0 issues)
# Vivante's eglGetProcAddress doesn't return GLES 3.0 core functions
export GSK_RENDERER=cairo

# Force triple buffering always (Ubuntu patch)
export MUTTER_DEBUG_TRIPLE_BUFFERING=always
