#!/usr/bin/env sh

source ./plain_configuration

cat base.lst | pacman --needed --noconfirm -Sy -
cat $DE_PKGS_LIST | pacman --needed --noconfirm -S -
