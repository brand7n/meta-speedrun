FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://rfkill.cfg"
SRC_URI += "file://plymouth.cfg"

# NXP's do_copy_defconfig overwrites .config after do_kernel_configme,
# so standard kernel config fragments are ignored. Must use
# DELTA_KERNEL_DEFCONFIG which runs in do_merge_delta_config after the copy.
DELTA_KERNEL_DEFCONFIG:append = " rfkill.cfg plymouth.cfg"

# Change device tree model string so /proc/device-tree/model shows our name
do_compile:prepend() {
    if [ -f ${S}/arch/arm64/boot/dts/freescale/imx8mm-evk.dts ]; then
        sed -i 's/model = ".*"/model = "Project Speedrun"/' ${S}/arch/arm64/boot/dts/freescale/imx8mm-evk.dts
    fi
}
