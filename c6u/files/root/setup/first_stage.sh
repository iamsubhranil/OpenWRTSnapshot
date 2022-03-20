#!/bin/sh

LOGGER_PROMPT="FirstStage"
. /root/updater/common.sh

set -e
set -o pipefail

# save stdout and stderr to file 
# descriptors 3 and 4, 
# then redirect them to upgrade.log
exec 3>&1 4>&2 >>/root/upgrade_output.log 2>&1

# log "Sleeping for 2mins.."
# sleep 120

log "Configuring rootfs_data.."
DEVICE="$(sed -n -e "/\s\/overlay\s.*$/s///p" /etc/mtab)"
uci -q delete fstab.rwm
uci set fstab.rwm="mount"
uci set fstab.rwm.device="${DEVICE}"
uci set fstab.rwm.target="/rwm"
uci commit fstab

DEVICE="/dev/sda1"
log "Formatting ${DEVICE}.."
mkfs.ext4 ${DEVICE}

log "Setting up new /overlay.."
eval $(block info ${DEVICE} | grep -o -e "UUID=\S*")
uci -q delete fstab.overlay
uci set fstab.overlay="mount"
uci set fstab.overlay.uuid="${UUID}"
uci set fstab.overlay.target="/overlay"

log "Setting up shared_data.."
DEVICE="/dev/sda2"
mkdir -p /mnt/sda2
uci set fstab.shared_data="mount"
eval $(block info ${DEVICE} | grep -o -e "UUID=\S*")
uci set fstab.shared_data.uuid="${UUID}"
uci set fstab.shared_data.target="/mnt/sda2"
uci commit fstab

log "Setting up swap.."
uci -q delete fstab.swap
uci set fstab.swap="swap"
uci set fstab.swap.device="/dev/sda3"
uci commit fstab

log "Preparing second stage.."
chmod +x /root/setup/z_setup_second_stage
cp /root/setup/z_setup_second_stage /etc/init.d/z_setup_second_stage
/etc/init.d/z_setup_second_stage enable

log "Disabling and removing first stage.."
/etc/init.d/z_setup_first_stage disable
rm /etc/init.d/z_setup_first_stage

DEVICE="/dev/sda1"
log "Transferring data to new /overlay.."
mkdir -p /tmp/cproot
mkdir -p /mnt/sda1
mount --bind /overlay /tmp/cproot
mount ${DEVICE} /mnt/sda1
tar -C /tmp/cproot -cvf - . | tar -C /mnt/sda1 -xf -
umount /tmp/cproot /mnt/sda1
rm -rf /mnt/sda1

log "Rebooting.."
reboot
