#!/bin/sh
# Expand the rootfs partition and filesystem to fill the SD card.
# Runs once on first boot, then disables itself.

PART=/dev/mmcblk1p2
DISK=/dev/mmcblk1
PARTNUM=2

# Get current and max possible size
CURRENT=$(cat /sys/block/mmcblk1/mmcblk1p2/size)
TOTAL=$(cat /sys/block/mmcblk1/size)

# Only resize if partition is significantly smaller than disk
# (leave some margin for boot partition + alignment)
if [ "$CURRENT" -lt "$((TOTAL - 1000000))" ]; then
    echo "resize-rootfs: Expanding partition ${PART} to fill disk..."

    # Grow the partition using sfdisk
    echo ", +" | sfdisk --no-reread -N ${PARTNUM} ${DISK}

    # Force kernel to re-read partition table
    partprobe ${DISK}

    # Wait for partition device to settle
    sleep 1

    # Resize the ext4 filesystem
    resize2fs ${PART}

    echo "resize-rootfs: Done."
else
    echo "resize-rootfs: Partition already fills disk, skipping."
fi

# Disable this service after first run
systemctl disable resize-rootfs.service
