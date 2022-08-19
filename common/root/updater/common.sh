#!/bin/sh

LOGFILE=/root/upgrade.log
REPO_URL=https://github.com/iamsubhranil/OpenWRTSnapshot
BUILD_URL=$REPO_URL/releases/latest/download/
# BASEDIR will be written by build_common.sh
HOOKSDIR=$BASEDIR-hooks
NEEDSREBOOT=/tmp/.updater-needs-reboot

. $BASEDIR/model.sh

log() {
    str="[$(date)] [$LOGGER_PROMPT] $*"
    echo "$str" >> $LOGFILE
    if [ "$SILENT" == "" ];
    then
        echo "$str"
    fi
}

# pre-update-early  # before checking on github
# pre-update        # after github check
# pre-update-late   # right before flash
# post-update-early # at uci-defaults
# post-update       # at init.d

executeHook() { 
    SCRIPTLOC="$HOOKSDIR/$1"
    if [ -f "$SCRIPTLOC" ]; then
        chmod +x "$SCRIPTLOC"
        log "Running $1 hook.."
        # switch to the script directory before exec
        CURDIR=$(pwd)
        CANONPATH=$(readlink -f "$SCRIPTLOC")
        SCRIPTDIR=$(dirname "$CANONPATH")
        SCRIPTNAME=$(basename "$CANONPATH")
        cd "$SCRIPTDIR"
        sh ./$SCRIPTNAME
        # switch back to the original directory
        cd "$CURDIR"
    fi
}

scheduleReboot() {
    log "Scheduling reboot.."
    touch $NEEDSREBOOT
}

rebootIfNeeded() {
    if [ -e "$NEEDSREBOOT" ]; then
        log "Scheduling reboot after 10s.."
        reboot -n 10
    fi
}
