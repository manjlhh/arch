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
arch-chroot /mnt pacman --needed --noconfirm -Sy

cat LST_INIT LST_BASE "LST_$CFG_DESKTOP_ENVIRONMENT" | envsubst "$ENV_SUBST" | pacman --needed --sysroot /mnt -Sp - | sed '/^file/d' | sed '/$/{p;s/$/.sig/}' > /tmp/DL_LST
while : ; do
    aria2c -d /mnt/var/cache/pacman/pkg -i /tmp/DL_LST -c --save-session /tmp/DL_SES
    has_error=`wc -l < /tmp/DL_SES`
    [ $has_error -eq 0 ] && break;
done
cat LST_INIT | envsubst "$ENV_SUBST" | arch-chroot /mnt pacman --needed --noconfirm -S -

# ----------------------------------

find configurations/ -type f -print | xargs dirname | sort | uniq | sed 's/^configurations/\/mnt/' | xargs mkdir -p
for conf in $(find configurations/ -type f); do
    cat $conf | envsubst "$ENV_SUBST" > "/mnt${conf#configurations}"
done

cat finish | envsubst "$ENV_SUBST" | arch-chroot /mnt /bin/bash

echo "mkdir -p /home/${CFG_USERNAME}/repo && git clone https://github.com/devrtc0/arch.git /home/${CFG_USERNAME}/repo/arch" | arch-chroot /mnt sudo -u ${CFG_USERNAME} sh
