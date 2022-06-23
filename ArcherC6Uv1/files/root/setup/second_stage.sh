#!/bin/sh

LOGGER_PROMPT="SecondStage"
. /root/updater/common.sh

set -e
set -o pipefail

# save stdout and stderr to file 
# descriptors 3 and 4, 
# then redirect them to upgrade.log
exec 3>&1 4>&2 >>/root/upgrade_output.log 2>&1

# log "Sleeping for 2mins.."
# sleep 120

# log "Starting second stage.."

PACKAGES=$(cat /root/setup/second_stage_packages | tr '\n' ' ')
log "Installing packages: $PACKAGES"
opkg update
opkg install $PACKAGES

log "Enabling openssh.."
/etc/init.d/dropbear disable
/etc/init.d/sshd enable

log "Enabling vnstat_backup.."
/etc/init.d/vnstat_backup restore
/etc/init.d/vnstat_backup enable

log "Disabling second stage.."
/etc/init.d/z_setup_second_stage disable
rm /etc/init.d/z_setup_second_stage
rm -f /rwm/upper/etc/rc.d/S99z_setup_second_stage
rm -f /rwm/upper/etc/init.d/z_setup_second_stage

log "Enabling final stage.."
chmod +x /root/setup/z_setup_final_stage
cp /root/setup/z_setup_final_stage /etc/init.d/
/etc/init.d/z_setup_final_stage enable

sync

log "Rebooting.."
reboot
