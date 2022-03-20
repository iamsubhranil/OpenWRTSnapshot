#!/bin/sh

LOGGER_PROMPT="LiftOff"
. /root/updater/common.sh

VER=$(cat /etc/openwrt_version)
log "Upgrade successful!"
log "Current version: $VER"

ADDON="first_boot_extras.sh"

if [ -f "$ADDON" ];
then
    chmod +x ./$ADDON
    . ./$ADDON
fi
