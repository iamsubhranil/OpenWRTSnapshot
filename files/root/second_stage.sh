#!/bin/sh /etc/rc.common

log() {
    logger -t "Second Stage" $*
}

log "Sleeping for 2mins.."
sleep 120

log "Starting second stage.."

log "Installing packages.."
opkg install $(cat second_stage_packages | tr '\n' ' ')

log "Disabling second stage.."
service setup_second_stage disable
rm /etc/init.d/setup_second_stage

log "Enabling openssh.."
service dropbear disable
service sshd enable

log "Enabling vnstat_backup"
service vnstat_backup enable

log "Rebooting.."
reboot
