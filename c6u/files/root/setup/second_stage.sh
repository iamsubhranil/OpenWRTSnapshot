#!/bin/sh

log() {
    # logger -t "Second Stage" $*
	echo "[$(date)] [SecondStage] $*" >> /root/upgrade.log
}

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

log "Copying setup complete notifier to uci-defaults.."
chmod +x /root/setup/setup_notify.sh
cp /root/setup/setup_notify.sh /etc/uci-defaults/

log "Removing setup scripts.."
rm -rf /root/setup
rm -rf /rwm/upper/root/setup

log "Rebooting.."
reboot
