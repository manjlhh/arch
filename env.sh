#!/usr/bin/env sh

source ./plain_configuration || exit -1

ROOT_DEVICE=$(lsblk -p -n -o NAME -x NAME $DEVICE | tail -1)
ROOT_DEVICE_UUID=$(blkid -s UUID -o value "$ROOT_DEVICE")

CPU_VENDOR=$(cat /proc/cpuinfo | grep 'vendor' | uniq | awk '{ print $3 }')
case "$CPU_VENDOR" in
"GenuineIntel")
    UCODE="intel-ucode"
    ;;
"AuthenticAMD")
    UCODE="amd-ucode"
    ;;
*)
    echo "Unknown cpu vendor $CPU_VENDOR"
    exit -1
    ;;
esac

case "$DESKTOP_ENVIRONMENT" in
"PLASMA")
    DE_PKGS_LIST="plasma.lst"
    ;;
"GNOME")
    DE_PKGS_LIST="gnome.lst"
    ;;
*)
    echo "NO DE: $DESKTOP_ENVIRONMENT"
    exit -1
    ;;
esac
