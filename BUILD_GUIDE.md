# Project Speedrun - Build Guide

Reproducing the GNOME desktop build for i.MX8M Mini from scratch.

## Prerequisites

### Host System

- Debian Bookworm (12) or equivalent
- Minimum 200GB free disk space
- Minimum 16GB RAM (32GB recommended)
- If 16GB RAM, add 4-6GB swap

### Host Packages

Install Yocto build dependencies:

```bash
apt-get install -y \
    build-essential chrpath cpio diffstat gawk git lz4 \
    python3 python3-dev python3-pip python3-pexpect python3-git \
    python3-jinja2 python3-subunit python3-setuptools python3-wheel \
    socat texinfo unzip wget xz-utils zstd \
    locales file patch bzip2 make \
    ca-certificates openssh-client
```

Set up locale:

```bash
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
```

### Install repo tool

```bash
mkdir -p ~/bin
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo
export PATH=~/bin:$PATH
```

## Step 1: Fetch NXP BSP Sources

```bash
mkdir -p ~/yocto-imx && cd ~/yocto-imx
repo init -u https://github.com/nxp-imx/imx-manifest \
    -b imx-linux-walnascar \
    -m imx-6.12.49-2.2.0.xml
repo sync
```

## Step 2: Clone Additional Layers

```bash
cd ~/yocto-imx/sources

# meta-quilter (Project Speedrun customizations)
git clone <meta-quilter-url> meta-quilter

# meta-doom (GZDoom game engine - optional)
git clone https://github.com/JPEWdev/meta-doom.git meta-doom
```

## Step 2.5: Patch NXP Sources for GNOME Compatibility

NXP's BSP has two settings that break GNOME. Both use BitBake `:remove` which
cannot be overridden from a layer. These must be patched directly:

```bash
# 1. Re-enable pulseaudio (GNOME requires it)
sed -i 's/^DISTRO_FEATURES:remove = "pulseaudio"/# &/' \
    sources/meta-imx/meta-imx-sdk/conf/distro/include/fsl-imx-base.inc

# 2. Re-enable X11 in GTK3 (GNOME components need gtk+-x11-3.0 for XWayland)
sed -i 's/^PACKAGECONFIG:remove:imxgpu = "x11"/# &/' \
    sources/meta-imx/meta-imx-bsp/recipes-gnome/gtk+3/gtk+3_%.bbappend
```

## Step 3: Initialize Build Environment

```bash
cd ~/yocto-imx
MACHINE=imx8mmevk DISTRO=fsl-imx-xwayland source imx-setup-release.sh -b build-gnome
```

This creates `build-gnome/conf/local.conf` and `build-gnome/conf/bblayers.conf`.

**Note**: The script will print `BSPDIR=` (empty) at the end. This is a bug in NXP's
`imx-setup-release.sh` - it echoes a shell variable that only exists as a BitBake
variable in `bblayers.conf`. It's harmless and can be ignored.

## Step 3.5: Fix meta-doom Layer Compatibility (if needed)

meta-doom may not list `walnascar` in its LAYERSERIES_COMPAT. If you get a
compatibility error when adding the layer, update it:

```bash
sed -i 's/LAYERSERIES_COMPAT_doom.*/& walnascar/' ../sources/meta-doom/conf/layer.conf
```

## Step 4: Copy Configuration Files

meta-quilter ships ready-to-use config files. Copy them over the NXP defaults:

```bash
cp ../sources/meta-quilter/conf/build-gnome/local.conf conf/local.conf
cp ../sources/meta-quilter/conf/build-gnome/bblayers.conf conf/bblayers.conf
```

Verify layers:

```bash
bitbake-layers show-layers
```

meta-quilter should appear with priority 99.

## Step 5 (skip): Configure local.conf

**This step is not needed if you copied the config files in Step 4.** The reference
configs already include everything below. This section is kept for reference only.

Add the following to `build-gnome/conf/local.conf`:

```bitbake
# Accept NXP EULA
ACCEPT_FSL_EULA = "1"

# GNOME desktop
IMAGE_INSTALL:append = " packagegroup-gnome-desktop gnome-terminal nautilus gedit evince eog gdm networkmanager htop"

# Vivante GLES workarounds (from meta-quilter)
IMAGE_INSTALL:append = " gsk-cairo-config gles-env"

# Chromium (optional - comment out for initial mutter testing)
#IMAGE_INSTALL:append = " chromium-ozone-wayland"

# Games (optional)
IMAGE_INSTALL:append = " gzdoom freedoom-1 freedoom-2"

# Dev tools
IMAGE_INSTALL:append = " glmark2 kmscube mesa-demos weston weston-examples"

# Custom packages from meta-quilter
IMAGE_INSTALL:append = " locale-config pulseaudio-default-wm8524 es2-info quakesdlgles1"

# GNOME requires these distro features
# NXP removes pulseaudio, we need to add it back
DISTRO_FEATURES:append = " polkit systemd gobject-introspection-data pulseaudio"
DISTRO_FEATURES_BACKFILL_CONSIDERED:remove = "pulseaudio"
VIRTUAL-RUNTIME_init_manager = "systemd"
VIRTUAL-RUNTIME_initscripts = "systemd-compat-units"

# Exclude conflicting packages
PACKAGE_EXCLUDE = "packagegroup-fsl-tools-audio nxp-afe-voiceseeker nxp-afe-voiceaec"
```

## Step 6: Build

```bash
bitbake imx-image-multimedia
```

The build will take several hours depending on hardware. On an 8-core ARM64 system with 16GB RAM, expect 6-10 hours.

### Memory Considerations

WebKitGTK is the most memory-intensive package. meta-quilter limits it to `-j 4` parallel compile jobs to avoid OOM on 16GB systems. If you have 32GB+ RAM, you can remove `recipes-sato/webkit/webkitgtk_%.bbappend` from meta-quilter.

## Build Output

Images are written to:

```
build-gnome/tmp/deploy/images/imx8mmevk/
```

Flash to SD card:

```bash
zstdcat imx-image-multimedia-imx8mmevk.wic.zst | dd of=/dev/sdX bs=1M conv=fsync
```

## What meta-quilter Provides

### Bug Fixes for Walnascar + GNOME

These bbappends fix issues in the Walnascar BSP when building with GNOME:

| Recipe | Fix |
|--------|-----|
| `systemd_%.bbappend` | Remove incompatible binfmt patch for systemd 257.6 |
| `unicode-ucd_%.bbappend` | Updated license checksum (upstream changed) |
| `libcanberra_%.bbappend` | Disable GTK modules requiring X11 headers |
| `xserver-xorg_%.bbappend` | Remove obsolete GL_BGRA_EXT patch (now upstream), add xshmfence dep for DRI3 |
| `gtk+3_%.bbappend` | Re-enable X11 backend (NXP incorrectly removes it, breaking GNOME) |
| `webkitgtk_%.bbappend` | Limit parallel compile to -j 4 (OOM prevention on 16GB systems) |
| `imx-image-multimedia.bbappend` | Remove NXP packages with broken dependencies |

### Custom Packages

| Recipe | Purpose |
|--------|---------|
| `gles-env` | Set GLES environment variables for Vivante GPU |
| `gsk-cairo-config` | Force GSK Cairo renderer (Vivante doesn't support full GL) |
| `es2-info` | GLES2 capability query tool |
| `locale-config` | Set system locale to en_US.UTF-8 |
| `pulseaudio-default-wm8524` | PulseAudio config for i.MX8MM EVK audio codec |
| `quakesdlgles1` | Quake port using GLES1 |
| `chromium-kiosk` | Chromium kiosk mode session (optional) |
| `psplash` (bbappend) | Custom boot splash with Quilter logo |

### U-Boot Customizations

| Recipe | Purpose |
|--------|---------|
| `u-boot-imx_%.bbappend` | Quilter splash logo, "Project Speedrun" model string |

## Layer Dependencies

meta-quilter requires:
- `core` (poky/meta)
- `freescale-layer` (meta-freescale)
- `fsl-bsp-release` (meta-imx/meta-imx-bsp)

Compatible with: Walnascar, Scarthgap

## Troubleshooting

### OOM during WebKitGTK compile

Reduce parallel jobs in `meta-quilter/recipes-sato/webkit/webkitgtk_%.bbappend`:
```bitbake
PARALLEL_MAKE = "-j 2"
```

Or add swap:
```bash
fallocate -l 4G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
```

### Disk space

A full build with GNOME uses approximately 120-150GB in the tmp directory. Use `INHERIT += "rm_work"` in local.conf to automatically clean work directories after each package completes (saves ~50-80GB but prevents incremental rebuilds).

### bitbake server won't start

Remove stale locks:
```bash
rm -f build-gnome/bitbake.lock build-gnome/bitbake.sock
```
