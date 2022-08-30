#!/usr/bin/env sh
set -x

systemctl stop reflector.service
timedatectl set-ntp true

pacman --noconfirm --needed -Sy aria2

source ./plain_configuration

[ -z "$DEVICE" ] && echo "DEVICE" && exit -1
[ -z "$USERNAME" ] && echo "USERNAME" && exit -1
[ -z "$HOSTNAME" ] && echo "HOSTNAME" && exit -1
[ -z "$ROOT_PASSWORD" ] && echo "ROOT_PASSWORD" && exit -1
[ -z "$USER_PASSWORD" ] && echo "USER_PASSWORD" && exit -1
[ -z "$DESKTOP_ENVIRONMENT" ] && echo "DESKTOP_ENVIRONMENT" && exit -1

. ./partition.sh

cp -f ./configurations/etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist
sed -i '/ParallelDownloads/c\ParallelDownloads = 4' /etc/pacman.conf

yes | pacstrap /mnt base
genfstab -U /mnt >> /mnt/etc/fstab
sed -i 's/relatime/noatime/' /mnt/etc/fstab

source ./env.sh

find configurations/ -type f -print | xargs dirname | sort | uniq | sed 's/^configurations/\/mnt/' | xargs mkdir -p

for conf in $(find configurations/ -type f); do
    envsubst $conf > "/mnt${conf#configurations}"
done

envsubst finish | arch-chroot /mnt /bin/bash

# ----------------------------------
envsubst init.lst | pacman --needed --sysroot /mnt -Sp - | sed '/^file/d' | aria2c -x 4 -d /mnt/var/cache/pacman/pkg -i -
envsubst init.lst | arch-chroot /mnt pacman --needed --noconfirm -S -

cat base.lst | pacman --needed --sysroot /mnt -Sp - | sed '/^file/d' | aria2c -x 4 -d /mnt/var/cache/pacman/pkg -i -

cat $DE_PKGS_LIST | pacman --needed --sysroot /mnt -Sp - | sed '/^file/d' | aria2c -x 4 -d /mnt/var/cache/pacman/pkg -i -
