#!/bin/sh

log() {
	echo "[$(date)] [Orbiter] $*" >> /root/upgrade.log
}

log "Setup completed successfully!"
