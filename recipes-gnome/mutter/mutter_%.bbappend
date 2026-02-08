# Vivante EGL does not provide eglmesaext.h (Mesa-specific header)
# Mutter 48 unconditionally includes it - provide a stub
do_configure:prepend() {
    # Create stub eglmesaext.h in sysroot for Vivante GPU
    if [ ! -f ${RECIPE_SYSROOT}/usr/include/EGL/eglmesaext.h ]; then
        cat > ${RECIPE_SYSROOT}/usr/include/EGL/eglmesaext.h << 'EOFSTUB'
/* Stub eglmesaext.h for non-Mesa EGL implementations (e.g. Vivante) */
#ifndef __eglmesaext_h_
#define __eglmesaext_h_
#endif
EOFSTUB
    fi
}
