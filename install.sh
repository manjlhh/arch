#!/usr/bin/env sh

source ./plain_configuration

[ -z "$DEVICE" ] && echo "DEVICE" && exit -1
[ -z "$USERNAME" ] && echo "USERNAME" && exit -1
[ -z "$HOSTNAME" ] && echo "HOSTNAME" && exit -1
[ -z "$ROOT_PASSWORD" ] && echo "ROOT_PASSWORD" && exit -1
[ -z "$USER_PASSWORD" ] && echo "USER_PASSWORD" && exit -1
[ -z "$DESKTOP_ENVIRONMENT" ] && echo "DESKTOP_ENVIRONMENT" && exit -1

systemctl stop reflector.service
timedatectl set-ntp true

. ./partition.sh

echo 'Server = https://mirror.yandex.ru/archlinux/$repo/os/$arch
Server = https://mirror.truenetwork.ru/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist
sed -i '/ParallelDownloads/c\ParallelDownloads = 4' /etc/pacman.conf


git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -rs --noconfirm
