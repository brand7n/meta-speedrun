/*
 * Simple GLES2 info utility (Wayland/native compatible)
 * Based on mesa-demos es2_info.c but without X11 dependency
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <EGL/egl.h>
#include <GLES2/gl2.h>

static void print_extensions(const char *ext, const char *prefix)
{
    if (!ext || !ext[0]) {
        printf("%s(none)\n", prefix);
        return;
    }

    char *copy = strdup(ext);
    char *token = strtok(copy, " ");
    while (token) {
        printf("%s%s\n", prefix, token);
        token = strtok(NULL, " ");
    }
    free(copy);
}

int main(int argc, char *argv[])
{
    EGLDisplay dpy;
    EGLContext ctx;
    EGLConfig config;
    EGLint num_configs;
    EGLint major, minor;

    static const EGLint config_attribs[] = {
        EGL_SURFACE_TYPE, EGL_PBUFFER_BIT,
        EGL_RED_SIZE, 8,
        EGL_GREEN_SIZE, 8,
        EGL_BLUE_SIZE, 8,
        EGL_RENDERABLE_TYPE, EGL_OPENGL_ES2_BIT,
        EGL_NONE
    };

    static const EGLint ctx_attribs[] = {
        EGL_CONTEXT_CLIENT_VERSION, 2,
        EGL_NONE
    };

    static const EGLint pbuffer_attribs[] = {
        EGL_WIDTH, 1,
        EGL_HEIGHT, 1,
        EGL_NONE
    };

    /* Try to get a display - prefer Wayland if available */
    dpy = eglGetDisplay(EGL_DEFAULT_DISPLAY);
    if (dpy == EGL_NO_DISPLAY) {
        fprintf(stderr, "Error: eglGetDisplay failed\n");
        return 1;
    }

    if (!eglInitialize(dpy, &major, &minor)) {
        fprintf(stderr, "Error: eglInitialize failed\n");
        return 1;
    }

    printf("EGL Information:\n");
    printf("  EGL API version: %d.%d\n", major, minor);
    printf("  EGL vendor: %s\n", eglQueryString(dpy, EGL_VENDOR));
    printf("  EGL version: %s\n", eglQueryString(dpy, EGL_VERSION));
    printf("  EGL client APIs: %s\n", eglQueryString(dpy, EGL_CLIENT_APIS));

    printf("\nEGL extensions:\n");
    print_extensions(eglQueryString(dpy, EGL_EXTENSIONS), "  ");

    if (!eglChooseConfig(dpy, config_attribs, &config, 1, &num_configs) || num_configs < 1) {
        fprintf(stderr, "Error: eglChooseConfig failed\n");
        eglTerminate(dpy);
        return 1;
    }

    eglBindAPI(EGL_OPENGL_ES_API);

    ctx = eglCreateContext(dpy, config, EGL_NO_CONTEXT, ctx_attribs);
    if (ctx == EGL_NO_CONTEXT) {
        fprintf(stderr, "Error: eglCreateContext failed (0x%x)\n", eglGetError());
        eglTerminate(dpy);
        return 1;
    }

    /* Create a pbuffer surface for context activation */
    EGLSurface surf = eglCreatePbufferSurface(dpy, config, pbuffer_attribs);
    if (surf == EGL_NO_SURFACE) {
        fprintf(stderr, "Error: eglCreatePbufferSurface failed (0x%x)\n", eglGetError());
        eglDestroyContext(dpy, ctx);
        eglTerminate(dpy);
        return 1;
    }

    if (!eglMakeCurrent(dpy, surf, surf, ctx)) {
        fprintf(stderr, "Error: eglMakeCurrent failed (0x%x)\n", eglGetError());
        eglDestroySurface(dpy, surf);
        eglDestroyContext(dpy, ctx);
        eglTerminate(dpy);
        return 1;
    }

    printf("\nOpenGL ES 2.0 Information:\n");
    printf("  GL_VENDOR: %s\n", glGetString(GL_VENDOR));
    printf("  GL_RENDERER: %s\n", glGetString(GL_RENDERER));
    printf("  GL_VERSION: %s\n", glGetString(GL_VERSION));
    printf("  GL_SHADING_LANGUAGE_VERSION: %s\n", glGetString(GL_SHADING_LANGUAGE_VERSION));

    printf("\nGL extensions:\n");
    print_extensions((const char *)glGetString(GL_EXTENSIONS), "  ");

    /* Print some limits */
    GLint val;
    printf("\nGL Limits:\n");
    glGetIntegerv(GL_MAX_TEXTURE_SIZE, &val);
    printf("  GL_MAX_TEXTURE_SIZE: %d\n", val);
    glGetIntegerv(GL_MAX_CUBE_MAP_TEXTURE_SIZE, &val);
    printf("  GL_MAX_CUBE_MAP_TEXTURE_SIZE: %d\n", val);
    glGetIntegerv(GL_MAX_RENDERBUFFER_SIZE, &val);
    printf("  GL_MAX_RENDERBUFFER_SIZE: %d\n", val);
    glGetIntegerv(GL_MAX_VERTEX_ATTRIBS, &val);
    printf("  GL_MAX_VERTEX_ATTRIBS: %d\n", val);
    glGetIntegerv(GL_MAX_VERTEX_UNIFORM_VECTORS, &val);
    printf("  GL_MAX_VERTEX_UNIFORM_VECTORS: %d\n", val);
    glGetIntegerv(GL_MAX_FRAGMENT_UNIFORM_VECTORS, &val);
    printf("  GL_MAX_FRAGMENT_UNIFORM_VECTORS: %d\n", val);
    glGetIntegerv(GL_MAX_VARYING_VECTORS, &val);
    printf("  GL_MAX_VARYING_VECTORS: %d\n", val);
    glGetIntegerv(GL_MAX_TEXTURE_IMAGE_UNITS, &val);
    printf("  GL_MAX_TEXTURE_IMAGE_UNITS: %d\n", val);
    glGetIntegerv(GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS, &val);
    printf("  GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS: %d\n", val);
    glGetIntegerv(GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS, &val);
    printf("  GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS: %d\n", val);

    /* Cleanup */
    eglMakeCurrent(dpy, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
    eglDestroySurface(dpy, surf);
    eglDestroyContext(dpy, ctx);
    eglTerminate(dpy);

    return 0;
}
