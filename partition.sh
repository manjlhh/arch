#!/usr/bin/env sh

sgdisk --zap-all $DEVICE || exit -1
sgdisk -o $DEVICE
sgdisk -n 1:0:+256M -t 1:ef00 -N 2 -t 2:8300 $DEVICE

sync

BOOT_DEVICE=$(lsblk -p -n -o NAME -x NAME $DEVICE | head -2 | tail -1)
ROOT_DEVICE=$(lsblk -p -n -o NAME -x NAME $DEVICE | tail -1)

yes | mkfs.fat -F32 "$BOOT_DEVICE"
yes | mkfs.ext4 -L system "$ROOT_DEVICE"

sync

mount "$ROOT_DEVICE" /mnt
mkdir -p /mnt/boot
mount "$BOOT_DEVICE" /mnt/boot
