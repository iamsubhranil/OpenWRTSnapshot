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

log "Setting up argon.."
cd /tmp
opkg install luci-compat
wget --no-check-certificate https://github.com/jerrykuku/luci-theme-argon/releases/download/v2.2.9/luci-theme-argon_2.2.9-20211016-1_all.ipk
wget --no-check-certificate https://github.com/jerrykuku/luci-theme-argon/releases/download/v2.2.9/luci-app-argon-config_0.9-20210309_all.ipk
opkg install luci-theme-argon*.ipk luci-app-argon*.ipk

log "Rebooting.."
reboot
