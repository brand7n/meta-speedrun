# meta-speedrun

Yocto layer for Project Speedrun: a GNOME desktop embedded Linux image for the
NXP i.MX8M Mini EVK (Walnascar / 6.12 kernel). Provides Vivante GLES2
compatibility fixes, Chromium with V4L2 hardware video encode, GNU Radio SDR
stack with HackRF + RTL-SDR, custom branding, and system services.

## Compatibility

- **Yocto Release**: Walnascar (6.12)
- **Target Machine**: imx8mmevk
- **Distro**: fsl-imx-xwayland

## Layer Dependencies

- `core` (poky / meta, meta-poky)
- `meta-openembedded` (meta-oe, meta-gnome, meta-multimedia, meta-python,
  meta-networking, meta-filesystems)
- `meta-freescale` + `meta-imx` (BSP)
- `meta-arm`, `meta-clang`
- `meta-qt5` (required by gnuradio-companion GUI)
- `meta-browser/meta-chromium`
- `meta-sdr` (GNU Radio, gr-osmosdr, libhackrf, rtl-sdr)
- `meta-doom` (GZDoom + Freedoom 1/2)
- `meta-virtualization`, `meta-security`, `meta-nxp-connectivity` (BSP-pulled)

## Features

### Branding & Boot
- Custom U-Boot splash and "Project Speedrun" model string
- Plymouth boot splash (DRM/KMS) with Quilter watermark
- psplash with Quilter logo and white background
- Quiet kernel boot (cmdline + log levels)

### GNOME Desktop with Vivante GLES2 Workarounds
- GSK Cairo renderer (Vivante has no full desktop GL)
- mutter `eglmesaext.h` stub, gnome-session EGL-type fixes
- libdisplay-info bumped to 0.2.0 (mutter 48 requirement)
- GTK3 X11 backend re-enabled (NXP `:remove` workaround)
- GDM with Plymouth integration

### Browser
- Chromium with V4L2 MMAP hardware encode patches (Hantro H1)
- GLES 2.0 `glGetStringi` null-check fixes (chrome://gpu crash)
- Dawn/WebGPU fix; AV1 decoder disabled (no HW path)

### Multimedia
- PulseAudio configured for WM8524 headphone codec
- mpv with Vivante EGL fixes (no gbm, no Vulkan, OpenGL only)

### SDR Stack
- GNU Radio (Qt5 GUI), gr-osmosdr (HackRF + RTL-SDR), libhackrf
- gr-osmosdr ported to gnuradio 3.10 named-parameter `GR_REGISTER_COMPONENT` API
- RFNoC Fosphor (desktop GL) disabled — all other Qt plots use Qwt and work fine

### Games
- GZDoom + Freedoom 1 & 2 desktop launchers

### System Services
- First-boot rootfs partition expansion
- CPU performance governor on boot
- Suspend/hibernate disabled (i.MX8MM wake issues)
- en_US.UTF-8 locale, GDM as default session, "speedrun" hostname/user

### Tools
- Alacritty (GPU-accelerated terminal, Wayland)
- es2-info (GLES2/EGL capability query)
- fastfetch (system info)

## Layer Contents

```
conf/                                # Layer config and reference build configs
recipes-browser/chromium/            # Chromium HW encode + GLES2 patches
recipes-bsp/u-boot/                  # U-Boot splash, model string
recipes-core/
├── gnuradio/                        # Disable RFNoC Fosphor (GLES2 host)
├── locale-config/                   # en_US.UTF-8
├── plymouth/                        # DRM/KMS splash, watermark
├── psplash/                         # Quilter logo, white background
├── resize-rootfs/                   # First-boot partition expansion
└── systemd/                         # Drop incompatible binfmt patch
recipes-extended/libdisplay-info/    # Bump to 0.2.0
recipes-fsl/
├── images/                          # imx-image-multimedia bbappend
└── packagegroup/                    # Drop unreachable rtsp-server
recipes-games/zdoom/                 # GZDoom + Freedoom launchers
recipes-gnome/
├── gdm/                             # Plymouth integration
├── gnome-session/                   # Vivante EGL type fixes
├── gnome-tweaks/                    # Skip buildpaths QA
├── gtk+3/                           # X11 backend (NXP :remove note)
└── mutter/                          # eglmesaext.h stub
recipes-graphics/
├── alacritty/                       # GPU terminal (Rust, Wayland)
├── es2-info/                        # GLES2/EGL capability query
├── gles-env/                        # /etc/profile.d/ env vars
├── gsk-cairo-config/                # GSK_RENDERER=cairo
└── xorg-xserver/                    # Drop obsolete patch, add xshmfence
recipes-kernel/linux/                # Kernel cmdline, rfkill, quiet boot
recipes-multimedia/
├── mplayer/                         # mpv Vivante EGL fixes
└── pulseaudio/                      # WM8524 default sink
recipes-sato/webkit/                 # webkitgtk -j4 OOM workaround
recipes-support/
├── colord/                          # Relax sandbox for demo board
├── cpu-performance-mode/            # CPU governor service
├── disable-suspend/                 # Mask suspend/hibernate
├── fastfetch/                       # System info tool
├── gr-osmosdr/                      # HackRF/RTL-SDR + gnuradio 3.10 patches
├── libcanberra/                     # Disable GTK2
├── libhackrf/                       # Branch fix (master → main)
└── unicode-ucd/                     # License checksum update
```

## Usage

See [BUILD_GUIDE.md](BUILD_GUIDE.md) for full from-scratch reproduction
instructions. Quick summary:

```bash
cd ~/yocto-imx/sources
git clone https://github.com/brand7n/meta-speedrun.git meta-quilter
# (and meta-qt5, meta-sdr, meta-doom — see BUILD_GUIDE)
```

## License

MIT (unless otherwise specified in individual recipes)

## Maintainer

Quilter.ai — brandin@remodulate.com
