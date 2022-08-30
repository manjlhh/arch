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
cat LST_INIT | envsubst "$ENV_SUBST" | pacman --needed --sysroot /mnt -Sp - | sed '/^file/d' > /tmp/INIT
while : ; do
    aria2c -d /mnt/var/cache/pacman/pkg -i /tmp/INIT -c --save-session /tmp/INIT_S
    has_error=`wc -l < /tmp/INIT_S`
    [ $has_error -eq 0 ] && break;
done
cat LST_INIT | envsubst "$ENV_SUBST" | arch-chroot /mnt pacman --needed --noconfirm -Sy -

cat LST_BASE | pacman --needed --sysroot /mnt -Sp - | sed '/^file/d' > /tmp/BASE
while : ; do
    aria2c -d /mnt/var/cache/pacman/pkg -i /tmp/BASE -c --save-session /tmp/BASE_S
    has_error=`wc -l < /tmp/BASE_S`
    [ $has_error -eq 0 ] && break;
done

cat "LST_$CFG_DESKTOP_ENVIRONMENT" | pacman --needed --sysroot /mnt -Sp - | sed '/^file/d' > /tmp/DE
while : ; do
    aria2c -d /mnt/var/cache/pacman/pkg -i /tmp/DE -c --save-session /tmp/DE_S
    has_error=`wc -l < /tmp/DE_S`
    [ $has_error -eq 0 ] && break;
done
# ----------------------------------

find configurations/ -type f -print | xargs dirname | sort | uniq | sed 's/^configurations/\/mnt/' | xargs mkdir -p
for conf in $(find configurations/ -type f); do
    cat $conf | envsubst "$ENV_SUBST" > "/mnt${conf#configurations}"
done

cat finish | envsubst "$ENV_SUBST" | arch-chroot /mnt /bin/bash

cat repo | arch-chroot -u ${CFG_USERNAME} /mnt /bin/bash
