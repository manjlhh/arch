#!/usr/bin/env sh

systemctl stop reflector.service
timedatectl set-ntp true

pacman --noconfirm --needed -Sy aria2

source ./cfg_envs.sh

. ./partition.sh

cp -f ./configurations/etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist
sed -i '/ParallelDownloads/c\ParallelDownloads = 4' /etc/pacman.conf

yes | pacstrap /mnt base
genfstab -U /mnt >> /mnt/etc/fstab
sed -i 's/relatime/noatime/' /mnt/etc/fstab

source ./env.sh

ENV_SUBST=$(printf '${%s} ' $(env | cut -d'=' -f1 | grep '^CFG_'))

# ----------------------------------
cat init.lst | envsubst "$ENV_SUBST" | pacman --needed --sysroot /mnt -Sp - | sed '/^file/d' | aria2c -x 4 -d /mnt/var/cache/pacman/pkg -i -
cat init.lst | envsubst "$ENV_SUBST" | arch-chroot /mnt pacman --needed --noconfirm -Sy -

cat base.lst | pacman --needed --sysroot /mnt -Sp - | sed '/^file/d' | aria2c -x 4 -d /mnt/var/cache/pacman/pkg -i -

cat $CFG_DESKTOP_ENVIRONMENT | pacman --needed --sysroot /mnt -Sp - | sed '/^file/d' | aria2c -x 4 -d /mnt/var/cache/pacman/pkg -i -
# ----------------------------------

find configurations/ -type f -print | xargs dirname | sort | uniq | sed 's/^configurations/\/mnt/' | xargs mkdir -p
for conf in $(find configurations/ -type f); do
    cat $conf | envsubst "$ENV_SUBST" > "/mnt${conf#configurations}"
done

cat finish | envsubst "$ENV_SUBST" | arch-chroot /mnt /bin/bash

cat repo | arch-chroot -u ${CFG_USERNAME} /mnt /bin/bash
