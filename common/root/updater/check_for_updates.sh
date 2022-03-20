#!/bin/sh

LOGGER_PROMPT="Ignition"
. /root/updater/common.sh

set -e
set -o pipefail

LOCAL_VERSION=$(cat /etc/openwrt_version)
FILENAME=openwrt-$TARGET-$SUBTARGET-$PROFILE-squashfs-sysupgrade
OPENWRT_SNAPSHOT_URL=https://downloads.openwrt.org/snapshots/targets/$TARGET/$SUBTARGET

while true
do
	log "Checking snapshot version on downloads.openwrt.org.."
	LATEST_SNAPSHOT=$(wget -qO- $OPENWRT_SNAPSHOT_URL/version.buildinfo)
	if [ "$LATEST_SNAPSHOT" == "$LOCAL_VERSION" ] || [ "$LATEST_SNAPSHOT" == "" ] ; then
		log "No new version found!"
		log "Sleeping for 30mins!"
		sleep 1800
	else
	    log "New version found: $LATEST_SNAPSHOT!"
		LATEST_GITHUB=$(wget -qO- $BUILD_URL/$FILENAME.version)
		if [ "$LATEST_GITHUB" != "$LATEST_SNAPSHOT" ]; then
            log "Executing git push to trigger GitHub build.."
            chmod +x trigger_build.sh
            . ./trigger_build.sh
            log "Build triggered on GitHub by push, waiting for completion.."
            while [ "$LATEST_GITHUB" != "$LATEST_SNAPSHOT" ];
            do
                sleep 10
                LATEST_GITHUB=$(wget -qO- $BUILD_URL/$FILENAME.version)
            done
            log "Build completed on GitHub!"
        else
            log "New build already available in GitHub!"
        fi
        break
	fi
done

log "Executing updater script.."
chmod +x /root/updater/autoupdate.sh
sh /root/updater/autoupdate.sh
