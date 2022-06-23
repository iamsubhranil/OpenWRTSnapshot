#!/bin/sh

. /root/updater/common.sh

log "Pushing upgrade logs.."
ssh root@192.168.1.1 "/root/updater/push_logs.sh"
