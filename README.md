# meta-quilter

Yocto layer for Quilter.ai embedded Linux customizations targeting NXP i.MX8M Mini.

## Description

This layer provides custom branding, configurations, and recipes for building a GNOME-based embedded Linux image for the Project Speedrun board.

## Dependencies

This layer depends on:

- poky (meta, meta-poky)
- meta-openembedded (meta-oe, meta-gnome, meta-multimedia, meta-python, meta-networking, meta-filesystems)
- meta-freescale
- meta-imx (meta-imx-bsp, meta-imx-sdk)

## Compatibility

- **Yocto Release**: Walnascar (6.12)
- **Target Machine**: imx8mmevk (Project Speedrun)

## Features

### Branding
- Custom U-Boot splash screen (Quilter logo)
- Custom model string ("Project Speedrun")

### Graphics
- GNOME desktop environment optimizations
- GSK Cairo renderer configuration for GPU compatibility
- Chromium kiosk mode support
- OpenGL ES environment utilities

### Audio
- PulseAudio configuration for WM8524 codec

### Gaming
- Quake SDL GLES1 port

## Layer Contents

```
recipes-browser/
└── chromium/            # Chromium patches and customizations

recipes-bsp/
└── u-boot/              # U-Boot customizations (splash, model string)

recipes-core/
├── locale-config/       # Locale configuration
├── psplash/             # Boot splash customizations
└── systemd/             # Systemd customizations

recipes-fsl/
└── images/              # Image recipe extensions

recipes-games/
└── zdoom/               # GZDoom + Freedoom 1/2 launchers

recipes-graphics/
├── alacritty/           # GPU-accelerated terminal (Wayland)
├── es2-info/            # OpenGL ES info utility
├── gles-env/            # GLES environment setup
└── gsk-cairo-config/    # GSK Cairo renderer config

recipes-multimedia/
└── pulseaudio/          # Audio configuration
```

## Usage

1. Clone this layer into your Yocto sources directory:
```bash
cd sources/
git clone https://github.com/quilter-ai/meta-quilter.git
```

2. Add the layer to your build:
```bash
bitbake-layers add-layer ../sources/meta-quilter
```

3. Build the image:
```bash
bitbake imx-image-multimedia
```

## License

MIT (unless otherwise specified in individual recipes)

## Maintainer

Quilter.ai
