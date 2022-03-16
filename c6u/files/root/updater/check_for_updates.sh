#!/bin/sh

log() {
        echo "[$(date)] [Ignition] $*" >> /root/upgrade.log
}

set -e
set -o pipefail

LOCAL_VERSION=$(cat /etc/openwrt_version)
FILENAME=openwrt-ramips-mt7621-tplink_archer-c6u-v1-squashfs-sysupgrade
URL=https://github.com/iamsubhranil/OpenWRTSnapshot/releases/latest/download/
DIR=$(pwd)

while true
do
	log "Checking snapshot version on downloads.openwrt.org.."
	LATEST_SNAPSHOT=$(wget -qO- https://downloads.openwrt.org/snapshots/targets/ramips/mt7621/version.buildinfo)
	if [ "$LATEST_SNAPSHOT" == "$LOCAL_VERSION" ] || [ "$LATEST_SNAPSHOT" == "" ] ; then
		log "No new version found!"
		log "Sleeping for 30mins!"
		sleep 1800
	else
		log "New version found: $LATEST_SNAPSHOT!"
		LATEST_GITHUB=$(wget -qO- $URL/$FILENAME.version)
		if [ "$LATEST_GITHUB" != "$LATEST_SNAPSHOT" ]; then
		    DEVICE="ArcherC6Uv1"
            log "Executing git push to trigger GitHub build.."
            . ./trigger_build.sh
            cd "$DIR"
            log "Build triggered on GitHub by push, waiting for completion.."
            while [ "$LATEST_GITHUB" != "$LATEST_SNAPSHOT" ];
            do
                sleep 10
                LATEST_GITHUB=$(wget -qO- $URL/$FILENAME.version)
            done
            log "Build completed on GitHub!"
        else
            log "New build already available in GitHub!"
        fi
        break
	fi
done

log "Executing updater script.."
. ./autoupdate.sh
