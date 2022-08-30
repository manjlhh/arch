#!/usr/bin/env sh

# openssl passwd -6 <password>

if [ $# -ne 2 ]; then
    echo 'wrong arguments number'
    echo 'usage: ./create_configuration.sh <password> <profile name to save in profiles directory>'
    exit -1
fi

CONF_DIR=$(dirname "$0")
PROFILES_DIR="$CONF_DIR/profiles"

HASH=$(printf "$1" | sha512sum - | awk '{ print $1 }')
echo $HASH
HASH=${HASH:0:64}
if [ $HASH != 'c0724f8a39315e4b8ea14b5a0ae51ac532ac7255cad4e72b839c3bb055c20f99' ]; then
    echo "wrong password: $1"
    exit -1
fi

cat "$CONF_DIR/plain_configuration" | gpg --symmetric --cipher-algo AES256 --pinentry-mode=loopback --passphrase "$1" | base64 | tr -d '\n' > "$PROFILES_DIR/$2"
