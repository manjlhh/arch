#!/usr/bin/env sh

source ./env.sh
sudo systemctl enable --now fstrim.timer bluetooth.service dnsmasq.service

. ./network_manager.sh

cat LST_BASE | sudo pacman --needed --noconfirm -Sy -
cat "LST_$CFG_DESKTOP_ENVIRONMENT" | sudo pacman --needed --noconfirm -S -
sudo systemctl enable ${CFG_DESKTOP_MANAGER}.service

timedatectl set-ntp true
