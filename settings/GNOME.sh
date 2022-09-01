#!/usr/bin/env sh

gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true

gsettings set org.gnome.desktop.media-handling autorun-never false
gsettings set org.gnome.desktop.media-handling automount false

gsettings set org.gnome.desktop.input-sources per-window true
gsettings set org.gnome.desktop.input-sources sources \[\(\'xkb\',\ \'us\'\),\ \(\'xkb\',\ \'ru\'\)\]

gsettings set org.gnome.desktop.interface show-battery-percentage true
