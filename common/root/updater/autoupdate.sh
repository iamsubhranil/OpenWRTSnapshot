#!/bin/sh

LOGGER_PROMPT="LiftOff"

set -e
set -o pipefail

FILENAME=openwrt-$TARGET-$SUBTARGET-$PROFILE-squashfs-sysupgrade
LOCAL_FILE=/tmp/$FILENAME
VER=$(cat /etc/openwrt_version)

if [ "$1" == "-f" ] || [ "$1" == "--force" ];
then
    VER=$VER-forced
fi

log "Starting upgrade.."
log "Current version: $VER"

log "Checking remote version.."
NEWVER=$(wget $BUILD_URL/$FILENAME.version -qO-)
log "Remote version: $NEWVER"

if [ "$VER" == "$NEWVER" ]; then
	log "Both versions are the same!"
	if [ "$1" == "-r" ] || [ "$1" == "--reflash" ];
	then
	    log "Reflashing the firmware.."
	else
	    log "Skipping upgrade!"
	    exit
    fi
else
    log "Current and remote versions differ!"
fi

log "Downloading new firmware.."
rm -rf $LOCAL_FILE.bin
wget $BUILD_URL/$FILENAME.bin -q -O $LOCAL_FILE.bin

log "Downloading sha256 of the firmware.."
REMOTE_SHA=$(wget $BUILD_URL/$FILENAME.sha256 -qO-)

log "Calculating sha256 of the downloaded firmware.."
LOCAL_SHA=$(sha256sum $LOCAL_FILE.bin | cut -f1 -d' ')

log "Verifying downloaded firmware.."
if [ "$LOCAL_SHA" != "$REMOTE_SHA" ];
then
	log "File verification failed!"
	log "Local: $LOCAL_SHA"
	log "Remote: $REMOTE_SHA"
	log "Skipping upgrade!"
	rm -rf $LOCAL_FILE.bin
	exit
fi

log "Firmware verification completed successfully!"

log "Copying first_boot notifier to uci-defaults.."
chmod +x first_boot.sh
cp first_boot.sh /etc/uci-defaults/

executeHook pre-update-late

# the new firmware will contain some version of the updater
# scripts anyway, so we don't need to preserve them for now
rm -rf $BASEDIR
rm -rf /rwm/upper$BASEDIR

log "Starting upgrade.."
sysupgrade -v $LOCAL_FILE.bin
