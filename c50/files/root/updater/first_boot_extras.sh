#!/bin/sh

. /root/updater/common.sh

log "Pushing upgrade logs.."
dbclient -i /etc/dropbear/dropbear_rsa_host_key root@192.168.1.1 "/root/updater/push_logs.sh"
