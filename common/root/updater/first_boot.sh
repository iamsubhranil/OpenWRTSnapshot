#!/bin/sh

LOGGER_PROMPT="LiftOff"
. /root/updater/common.sh

VER=$(cat /etc/openwrt_version)
log "Upgrade successful!"
log "Current version: $VER"

# explicitly set the scripts as executable
chmod +x /root/updater/*

ADDON="/root/updater/first_boot_extras.sh"

if [ -f "$ADDON" ];
then
    chmod +x $ADDON
    . $ADDON
fi
