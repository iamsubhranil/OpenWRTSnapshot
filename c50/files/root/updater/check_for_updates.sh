#!/bin/sh

log() {
        echo "[$(date)] [Ignition] $*" >> /root/upgrade.log
}

set -e
set -o pipefail

LOCAL_VERSION=$(cat /etc/openwrt_version)
FILENAME=openwrt-ramips-mt76x8-tplink_archer-c50-v4-squashfs-sysupgrade
URL=https://github.com/iamsubhranil/OpenWRTSnapshot/releases/latest/download/

while true
do
	log "Checking snapshot version on downloads.openwrt.org.."
	LATEST_SNAPSHOT=$(wget -qO- https://downloads.openwrt.org/snapshots/targets/ramips/mt76x8/version.buildinfo)
	if [ "$LATEST_SNAPSHOT" == "$LOCAL_VERSION" ] || [ "$LATEST_SNAPSHOT" == "" ] ; then
		log "No new version found!"
		log "Sleeping for 30mins!"
		sleep 1800
	else
        log "New version found: $LATEST_SNAPSHOT!"
		LATEST_GITHUB=$(wget -qO- $URL/$FILENAME.version)
		if [ "$LATEST_GITHUB" != "$LATEST_SNAPSHOT" ]; then
            CMD="cd /root/updater/; LOCAL_VERSION=$LOCAL_VERSION; LATEST_SNAPSHOT=$LATEST_SNAPSHOT; DEVICE=ArcherC50v6; ./trigger_build.sh"
            log "Executing git push on C6U to trigger GitHub build.."
            dbclient -i /etc/dropbear/dropbear_rsa_host_key root@192.168.1.1 "$CMD"
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
