#!/usr/bin/env sh

type yay >/dev/null && return

git clone https://aur.archlinux.org/yay-bin.git /tmp/yay
pushd
cd /tmp/yay
makepkg -ris --noconfirm
popd
