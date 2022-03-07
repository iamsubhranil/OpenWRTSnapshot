#!/bin/sh

log() {
	echo "[$(date)] [LiftOff] $*" >> /root/upgrade.log
}

set -e
set -o pipefail

# save stdout and stderr to file 
# descriptors 3 and 4, 
# then redirect them to upgrade.log
exec 3>&1 4>&2 >>/root/upgrade.log 2>&1

FILENAME=openwrt-ramips-mt7621-tplink_archer-c6u-v1-squashfs-sysupgrade
URL=https://github.com/iamsubhranil/OpenWRTSnapshot/releases/latest/download/
LOCAL_FILE=/tmp/$FILENAME
VER=$(cat /etc/openwrt_version)

log "Starting upgrade.."
log "Current version: $VER"

log "Checking remote version.."
NEWVER=$(wget $URL/$FILENAME.version -qO-)
log "Remote version: $NEWVER"

if [ "$VER" == "$NEWVER" ]; then
	log "Both versions are the same!"
	log "Skipping upgrade!"
	exit
fi
log "Current and remote versions differ!"

log "Downloading new firmware.."
rm -rf $LOCAL_FILE.bin
wget $URL/$FILENAME.bin -q -O $LOCAL_FILE.bin

log "Downloading sha256 of the firmware.."
REMOTE_SHA=$(wget $URL/$FILENAME.sha256 -qO-)

log "Calculating sha256 of the downloaded firmware.."
LOCAL_SHA=$(sha256sum $LOCAL_FILE.bin | cut -f1 -d' ')

log "Verifying downloaded firmware.."
if [ "$LOCAL_SHA" != "$REMOTE_SHA" ]; then
	log "File verification failed!"
	log "Local: $LOCAL_SHA"
	log "Remote: $REMOTE_SHA"
	log "Skipping upgrade!"
	rm -rf $LOCAL_FILE.bin
	exit
fi

log "Firmware verification completed successfully!"
log "Copying first_boot notifier to uci-defaults.."
cp first_boot.sh /etc/uci-defaults/

# the new firmware will contain some version of the updater
# scripts anyway, so we don't need to preserve them for now
rm -rf /root/updater
rm -rf /rwm/upper/root/updater

log "Starting upgrade.."
sysupgrade -v $LOCAL_FILE.bin
