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
		CMD="cd /root/OpenWRTSnapshot; git pull; echo \"[$(date)] [ArcherC6UV1] Local ver: $LOCAL_VERSION, snapshot ver: $LATEST_SNAPSHOT\" >> build_requests.log; git add build_requests.log; git commit -m \"build: Build requested by ArcherC6UV1 at $(date)\"; git push;"
		log "Executing git push to trigger GitHub build.."
		eval "$CMD"
		cd "$DIR"
		log "Build triggered on GitHub by push!"
		while true
		do
			log "Checking build status on GitHub.."
			LATEST_GITHUB=$(wget -qO- $URL/$FILENAME.version)
			if [ "$LATEST_GITHUB" != "$LATEST_SNAPSHOT" ]; then
				log "Build yet not completed on GitHub, sleeping for 1min.."
				sleep 60
			else
				break
			fi
		done
		log "Build completed on GitHub!"
		break
	fi
done

log "Executing updater script.."
. ./autoupdate.sh
