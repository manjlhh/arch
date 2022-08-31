#!/usr/bin/env bash

[ -z $MAN_KDBX ] && echo 'MAN_KDBX not set' && exit -1
[ -z $SANCTUM_SANCTORUM ] && echo 'SANCTUM_SANCTORUM not set' && exit -1

mkdir -p $(dirname $MAN_KDBX)

! type gnupg >/dev/null 2>&1 && APPS="$APPS gnupg"
! type curl >/dev/null 2>&1 && APPS="$APPS curl"
! type jq >/dev/null 2>&1 && APPS="$APPS jq"
[ -n "$APPS" ] && sudo pacman -Sy $APPS --noconfirm --needed

# printf 'text' | gpg --symmetric --cipher-algo AES256 --pinentry-mode=loopback --passphrase 'passphrase' | base64 | tr -d '\n'
# cat $SANCTUM_SANCTORUM | gpg --symmetric --cipher-algo AES256 --pinentry-mode=loopback --passphrase 'passphrase' | base64 | tr -d '\n'

if [ ! -f $MAN_KDBX ]; then
    ### main repo
    while : ; do
        test -z $passphrase && echo 'enter kdbx password:' && read -ers passphrase
        link=$(echo 'jA0ECQMCbFuRczxVj1T00mIBMmmRtwiaycErI9Wqx4F1H+81ZMKzsWnwSXEMn0+TyY0TvYEXtRTB3ugZWFma6mF45Iu3AC5tVLuLZ75xNpqTrL+SZ7CPS7ZXTQRt3d/V7is3ttEmrgjO5ZnZWKBvFnSUNg==' | base64 --decode | gpg --decrypt --batch --quiet --passphrase "$passphrase")
        [ $? -eq 0 ] && echo $link && break
        unset passphrase
        unset link
    done

    ### backup repo
    if [ -z $link ]; then
        test -z $passphrase && echo 'enter kdbx password:' && read -ers passphrase
        link=$(echo 'jA0ECQMCSfcT/Nh5o5r00nEB0pCiMS2BS65dIlnxNk70YPTKSB7TjatymYhHsMU3xNjan0iqwoDPt0rGC8B5kMWAfD7TOceXQcGDJ7T3imEx9nbkl0oPa2Gxaw7FiC/X1g2TrRUVWQ9OzISdYDvHIhRlZtVAyqmt0H/E+sx4lEKJ/A==' | base64 --decode | gpg --decrypt --batch --quiet --passphrase "$passphrase")
        [ $? -eq 0 ] && echo $link && break
        unset passphrase
        unset link
    fi

    ### download
    curl -sSL --output /tmp/kdbx $link
    echo "kdbx has been downloaded"

    ### decrypt kdbx
    while : ; do
        echo 'enter password for kdb archive:' && read -ers z
        gpg --passphrase "$z" --batch --quiet --decrypt /tmp/kdbx | xz -d > $MAN_KDBX
        [ $? -eq 0 ] && break
        rm -rf $MAN_KDBX
    done

    # content extraction
    while : ; do
        [ -z "$z" ] && echo "enter password for $SANCTUM_SANCTORUM:" && read -ers z
    done
    printf 'jA0ECQMCI1cek2kkr8b30kQBNbZ/buHKjKho+elNjkeWVTOwvLkJAdh4+idX8+hxLL89sHDO9QwEFIfn5wHgpnorBy4npqlYz0zfS0TYDKI14OunHQ==' | base64 --d | gpg --decrypt --batch --quiet --passphrase "$z" > $SANCTUM_SANCTORUM
fi

while : ; do
    hash=$([ -f $SANCTUM_SANCTORUM ] && sha512sum $SANCTUM_SANCTORUM | awk '{ print $1 }' || echo 0)
    hash=${hash:0:64}
    [ $hash = 'da78e04ead69bdff7f9a9d5eb12e8e9cc7439ac347c697b6093eba4f1b727c7a' ] && chmod 0400 $SANCTUM_SANCTORUM && break
    echo "enter $SANCTUM_SANCTORUM content:"
    sh -c "IFS= ;read -N 34 -s -a z; echo \$z > $SANCTUM_SANCTORUM"
done

### uncomment the next block if credentials are stored in dot files
# dots.secret
# if [ ! -f $HOME/.dots.secret ]; then
#     while : ; do
#         [ -z $passphrase ] && echo 'enter kdbx password:' && read -ers passphrase

#         yes $passphrase | keepassxc-cli attachment-export -k $SANCTUM_SANCTORUM $MAN_KDBX 'dots.secret' '.dots.secret' $HOME/.dots.secret
#         [ $? -eq 0 ] && break
#     done

#     hash=$([ -f $HOME/.dots.secret ] && sha512sum $HOME/.dots.secret | awk '{ print $1 }' || echo 0)
#     hash=${hash:0:64}
#     [ $hash != 'd5f37e719c1af84da39fbef77908b8fb1b8e14737f7c02aa2206cc3adeb4e8be' ] && echo 'wrong dots.secret file content' && exit -1
#     chmod 0400 $HOME/.dots.secret
# fi

# REPOSOTORIES
## kdbx
if [ ! -d $HOME/repo/kdbx ]; then
    [ -z $passphrase ] && echo 'enter kdbx password:' && read -ers passphrase
    token=([ -n "$token" ] && "$token" || $(yes $passphrase | keepassxc-cli show -q -a Password -s -k $SANCTUM_SANCTORUM $MAN_KDBX Repositories/GitHub/token))

    git clone https://devrtc0:${token}@github.com/devrtc0/kdbx.git $HOME/repo/kdbx
    sh -c 'cd $HOME/repo/kdbx; git remote set-url origin git@github.com:devrtc0/kdbx.git'
    sh -c 'cd $HOME/repo/kdbx; git remote add gitlab git@gitlab.com:devrtc0/kdbx.git'
    sh -c 'cd $HOME/repo/kdbx; git remote add flic git@gitflic.ru:devrtc0/kdbx.git'
    sh -c 'cd $HOME/repo/kdbx; git remote add codeberg git@codeberg.org:devrtc0/kdbx.git'
fi
# settings
if [ ! -d $HOME/repo/settings ]; then
    [ -z $passphrase ] && echo 'enter kdbx password:' && read -ers passphrase
    token=([ -n "$token" ] && "$token" || $(yes $passphrase | keepassxc-cli show -q -a Password -s -k $SANCTUM_SANCTORUM $MAN_KDBX Repositories/GitHub/token))

    git clone https://devrtc0:${token}@github.com/devrtc0/settings.git $HOME/repo/settings
    sh -c 'cd $HOME/repo/settings; git remote set-url origin git@github.com:devrtc0/settings.git'
fi
# this repo - arch
sh -c "cd $HOME/repo/arch; git remote set-url origin git@github.com:devrtc0/arch.git"
