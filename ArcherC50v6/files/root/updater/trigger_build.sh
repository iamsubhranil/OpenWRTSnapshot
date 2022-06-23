#!/bin/sh

CMD="cd /root/updater/; LOCAL_VERSION=$LOCAL_VERSION; LATEST_SNAPSHOT=$LATEST_SNAPSHOT; DEVICE=ArcherC50v6; . ./trigger_build.sh"
ssh root@192.168.1.1 "$CMD"
