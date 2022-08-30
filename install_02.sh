#!/usr/bin/env sh

timedatectl set-ntp true

source ./plain_configuration

cat base.lst | pacman --needed --noconfirm -Sy -
cat $CFG_DE_PKGS_LIST | pacman --needed --noconfirm -S -
