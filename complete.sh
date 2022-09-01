#!/usr/bin/env sh

source ./env.sh

. ./yay.sh

cat LST_BASE "LST_$CFG_DESKTOP_ENVIRONMENT" | yay --sudoloop --needed --noconfirm -S -
sudo systemctl enable ${CFG_DESKTOP_MANAGER}.service

timedatectl set-ntp true

. ./network_manager.sh
sudo systemctl enable --now fstrim.timer bluetooth.service dnsmasq.service

[ -n "$CFG_PACKAGES" ] && yay --sudoloop --needed --noconfirm -S $CFG_PACKAGES
[ -n "$CFG_SYSTEMD" ] && sudo systemctl enable $CFG_SYSTEMD
[ -n "$CFG_GROUPS" ] && sudo usermod -a -G $CFG_GROUPS $CFG_USERNAME

MAN_KDBX="$HOME/repo/man.kdbx"
SANCTUM_SANCTORUM="$HOME/.sanctum.sanctorum"
. ./sanctum.sanctorum.sh

# dots
if [ ! -d "$(chezmoi source-path)" ]; then
    git clone https://github.com/devrtc0/dots.git "$(chezmoi source-path)"
    chmod 0700 $(chezmoi source-path)
    ### uncomment the next line if credentials are stored in dot files
    # sh -c "cd $(chezmoi source-path); git crypt unlock $HOME/.dots.secret"

    sh -c 'cd $(chezmoi source-path); git remote set-url origin git@github.com:devrtc0/dots.git'
    branch=$(printf "$CFG_DESKTOP_ENVIRONMENT" | tr '[:upper:]' '[:lower:]')
    sh -c "cd $(chezmoi source-path); git switch $branch;" && chezmoi apply
fi

. ./"${CFG_DESKTOP_ENVIRONMENT}.sh"
