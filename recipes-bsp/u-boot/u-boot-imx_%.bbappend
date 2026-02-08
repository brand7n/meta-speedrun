# Quilter customizations for U-Boot
# - Custom splash logo
# - Custom model string

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://splash.bmp"

do_compile:prepend() {
    # Replace DENX logo with Quilter logo
    if [ -f ${UNPACKDIR}/splash.bmp ]; then
        if [ -f ${S}/tools/logos/denx.bmp ]; then
            cp ${UNPACKDIR}/splash.bmp ${S}/tools/logos/denx.bmp
        fi
        # Also try the alternate location
        if [ -f ${S}/drivers/video/u_boot_logo.bmp ]; then
            cp ${UNPACKDIR}/splash.bmp ${S}/drivers/video/u_boot_logo.bmp
        fi
    fi

    # Change model string to "Project Speedrun"
    if [ -f ${S}/arch/arm/dts/imx8mm-evk.dts ]; then
        sed -i 's/model = ".*"/model = "Project Speedrun"/' ${S}/arch/arm/dts/imx8mm-evk.dts
    fi
    # Also check for u-boot specific dts
    if [ -f ${S}/arch/arm/dts/imx8mm-evk-u-boot.dtsi ]; then
        if grep -q 'model = ' ${S}/arch/arm/dts/imx8mm-evk-u-boot.dtsi; then
            sed -i 's/model = ".*"/model = "Project Speedrun"/' ${S}/arch/arm/dts/imx8mm-evk-u-boot.dtsi
        fi
    fi
}
