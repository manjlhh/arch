#!/usr/bin/env sh

source ./env.sh
sudo systemctl enable --now fstrim.timer bluetooth.service dnsmasq.service

. ./network_manager.sh

cat base.lst | sudo pacman --needed --noconfirm -S -
cat $CFG_DESKTOP_ENVIRONMENT | sudo pacman --needed --noconfirm -S -
sudo systemctl enable ${CFG_DESKTOP_MANAGER}.service

timedatectl set-ntp true
