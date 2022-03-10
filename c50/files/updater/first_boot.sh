#!/bin/sh

log() {
        echo "[$(date)] [LiftOff] $*" >> /root/upgrade.log
}

VER=$(cat /etc/openwrt_version)
log "Upgrade successful!"
log "Current version: $VER"
