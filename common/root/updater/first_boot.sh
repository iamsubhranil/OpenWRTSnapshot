#!/bin/sh

LOGGER_PROMPT="LiftOff"

VER=$(cat /etc/openwrt_version)
log "Upgrade successful!"
log "Current version: $VER"

# explicitly set the scripts as executable
chmod +x $BASEDIR/*
chmod +x $HOOKSDIR/*

executeHook post-update-early
