#!/usr/bin/env sh

type yay >/dev/null 2>&1 && return

git clone https://aur.archlinux.org/yay-bin.git /tmp/yay
sh -c 'cd /tmp/yay && makepkg -ris --noconfirm'
