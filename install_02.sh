#!/usr/bin/env sh

source ./env.sh

cat LST_BASE "LST_$CFG_DESKTOP_ENVIRONMENT" | sudo pacman --needed --noconfirm -S -
sudo systemctl enable ${CFG_DESKTOP_MANAGER}.service

timedatectl set-ntp true

. ./network_manager.sh
sudo systemctl enable fstrim.timer bluetooth.service dnsmasq.service

[ -n "$CFG_PACKAGES" ] && sudo pacman --needed --noconfirm -S $CFG_PACKAGES
[ -n "$CFG_SYSTEMD" ] && sudo systemctl enable $CFG_SYSTEMD
[ -n "$CFG_GROUPS" ] && sudo usermod -a -G $CFG_GROUPS $CFG_USERNAME
