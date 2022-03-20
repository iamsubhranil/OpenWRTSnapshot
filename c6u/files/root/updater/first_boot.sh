#!/bin/sh

LOGGER_PROMPT="LiftOff"
. /root/updater/logger.sh

VER=$(cat /etc/openwrt_version)
log "Upgrade successful!"
log "Current version: $VER"
