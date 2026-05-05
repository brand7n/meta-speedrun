# Project Speedrun - Build Guide

Reproducing the GNOME desktop build for i.MX8M Mini from scratch.

## Prerequisites

### Host System

- Debian Bookworm (12) or equivalent
- Minimum 200GB free disk space on a **case-sensitive filesystem** (ext4, xfs, btrfs).
  Yocto refuses to build on case-insensitive filesystems — this rules out macOS
  HFS+/APFS shares, Windows/WSL `/mnt/c`, and many network mounts. If your only
  large disk is case-insensitive, use it for `downloads/` and `sstate-cache/`
  but keep `TMPDIR` (default: `<build>/tmp/`) on a case-sensitive volume.
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

The build references four layers that aren't part of the NXP BSP. All are required —
the build will fail to parse `bblayers.conf` if any are missing.

```bash
cd ~/yocto-imx/sources

# meta-quilter (Project Speedrun customizations)
git clone https://github.com/brand7n/meta-speedrun.git meta-quilter

# meta-qt5 (Qt5 framework - required by gnuradio-companion GUI)
git clone -b walnascar https://github.com/meta-qt5/meta-qt5.git meta-qt5

# meta-sdr (GNU Radio, gr-osmosdr, libhackrf, rtl-sdr)
git clone -b walnascar https://github.com/balister/meta-sdr.git meta-sdr

# meta-doom (GZDoom game engine)
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

`ACCEPT_FSL_EULA=1` must be exported **before** sourcing the setup script —
otherwise it stops to prompt for EULA acceptance interactively.

```bash
cd ~/yocto-imx
export ACCEPT_FSL_EULA=1
MACHINE=imx8mmevk DISTRO=fsl-imx-xwayland source imx-setup-release.sh -b build-gnome
```

This creates `build-gnome/conf/local.conf` and `build-gnome/conf/bblayers.conf`.

**Note**: The script will print `BSPDIR=` (empty) at the end. This is a bug in NXP's
`imx-setup-release.sh` - it echoes a shell variable that only exists as a BitBake
variable in `bblayers.conf`. It's harmless and can be ignored.

## Step 3.5: Fix meta-doom Layer Compatibility

meta-doom does not list `walnascar` in its LAYERSERIES_COMPAT, so bitbake
rejects the layer at parse time. Add `walnascar` to the compatible series
list (must be **inside** the quotes):

```bash
sed -i 's/^\(LAYERSERIES_COMPAT_doom = "[^"]*\)"/\1 walnascar"/' \
    sources/meta-doom/conf/layer.conf
```

Verify the result reads `LAYERSERIES_COMPAT_doom = "mickledore nanbield walnascar"`
(or similar with `walnascar` *inside* the quotes).

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

## Step 5: Build

```bash
bitbake imx-image-multimedia
```

The build will take several hours depending on hardware. On an 8-core ARM64
system with 16GB RAM, expect 6-10 hours from cold cache.

The two heaviest recipes by far are **chromium-ozone-wayland** (3-6 h, ~22GB
RAM+swap during the final ThinLTO link) and **webkitgtk** (1-2 h). Plan disk
and memory accordingly.

If you want to verify the chromium patches in this layer apply cleanly to a
clean source tree (rather than relying on cached state), force a fresh
chromium rebuild before the image build:

```bash
bitbake -c cleansstate chromium-ozone-wayland
bitbake imx-image-multimedia
```

### Memory Considerations

WebKitGTK is memory-intensive but bounded: meta-quilter limits it to `-j 4`
parallel compile jobs to avoid OOM on 16GB systems. If you have 32GB+ RAM,
you can remove `recipes-sato/webkit/webkitgtk_%.bbappend` from meta-quilter.

Chromium's final ThinLTO link is the single most demanding step in the whole
build — it needs ~22GB RAM+swap. On a 16GB host, add 8GB+ swap before
starting the image build:

```bash
fallocate -l 8G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
```

## Build Output

Images are written to:

```
build-gnome/tmp/deploy/images/imx8mmevk/
```

Flash to SD card (note the `.rootfs.` in the filename):

```bash
zstdcat imx-image-multimedia-imx8mmevk.rootfs.wic.zst | dd of=/dev/sdX bs=1M conv=fsync
```

Or with bmaptool for faster flashing:

```bash
bmaptool copy imx-image-multimedia-imx8mmevk.rootfs.wic.zst /dev/sdX
```

## What meta-quilter Provides

### Bug Fixes for Walnascar + GNOME

| Recipe | Fix |
|--------|-----|
| `systemd_%.bbappend` | Remove incompatible binfmt patch for systemd 257.6 |
| `unicode-ucd_%.bbappend` | Updated license checksum (upstream changed) |
| `libcanberra_%.bbappend` | Disable GTK2 module (GTK3 kept for gnome-settings-daemon) |
| `xserver-xorg_%.bbappend` | Remove obsolete GL_BGRA_EXT patch, add xshmfence dep for DRI3 |
| `gtk+3_%.bbappend` | Note: NXP `:remove` of X11 must be patched directly (Step 2.5) |
| `webkitgtk_%.bbappend` | Limit parallel compile to -j 4 (OOM prevention on 16GB) |
| `libdisplay-info_git.bbappend` | Bump to 0.2.0 (mutter 48 requires it) |
| `mutter_%.bbappend` | Stub `eglmesaext.h` for Vivante (Mesa-only header) |
| `gnome-session_%.bbappend` | Suppress Vivante EGL pointer-type errors |
| `gnome-tweaks_%.bbappend` | Skip buildpaths QA (Python bytecode) |
| `gdm_%.bbappend` | Plymouth integration for seamless splash → login |
| `imx-image-multimedia.bbappend` | Drop NXP audio packages with broken deps |
| `packagegroup-fsl-gstreamer1.0.bbappend` | Drop unreachable rtsp-server fetch |

### Vivante GLES2 / Embedded Customizations

| Recipe | Purpose |
|--------|---------|
| `gsk-cairo-config` | Force GSK Cairo renderer + CLUTTER_DRIVER=gles2 |
| `gles-env` | GLES2 / EGL environment variables in `/etc/profile.d/` |
| `es2-info` | GLES2 / EGL capability query tool |
| `mpv_%.bbappend` | Disable gbm/Vulkan, force OpenGL API for Vivante EGL |
| `gnuradio_git.bbappend` | Disable RFNoC Fosphor (uses desktop GL) |

### Branding / Boot

| Recipe | Purpose |
|--------|---------|
| `u-boot-imx_%.bbappend` | Quilter splash logo, "Project Speedrun" model |
| `psplash_git.bbappend` | Quilter logo, white background, systemd services |
| `plymouth_%.bbappend` | DRM/KMS spinner theme + watermark |
| `linux-imx_%.bbappend` | Quiet boot cmdline, rfkill, kernel logo off |

### Browser / SDR

| Recipe | Purpose |
|--------|---------|
| `chromium-ozone-wayland_%.bbappend` | V4L2 HW encode (Hantro H1), GLES2 + Dawn fixes, AV1 disabled |
| `gr-osmosdr_git.bbappend` | gnuradio 3.10 API patches, HackRF + RTL-SDR enabled |
| `libhackrf_git.bbappend` | Fix repo branch rename (master → main) |

### System Services / User Setup

| Recipe | Purpose |
|--------|---------|
| `resize-rootfs` | First-boot rootfs partition expansion |
| `cpu-performance-mode` | CPU governor → performance on boot |
| `disable-suspend` | Mask suspend / hibernate (i.MX8MM wake issues) |
| `locale-config` | en_US.UTF-8 |
| `pulseaudio-default-wm8524` | WM8524 headphone codec as default sink |
| `pulseaudio_%.bbappend` | Default sink config, hide unused devices |
| `colord.bbappend` | Relaxed sandbox for demo board |

### Tools

| Recipe | Purpose |
|--------|---------|
| `alacritty` | GPU-accelerated terminal (Wayland, Solarized Dark) |
| `fastfetch` | System info (neofetch alternative) |

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
