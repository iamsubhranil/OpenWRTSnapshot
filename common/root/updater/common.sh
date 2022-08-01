#!/bin/sh

LOGFILE=/root/upgrade.log

log() {
    str="[$(date)] [$LOGGER_PROMPT] $*"
    echo "$str" >> $LOGFILE
    if [ "$SILENT" == "" ];
    then
        echo "$str"
    fi
}

REPO_URL=https://github.com/iamsubhranil/OpenWRTSnapshot
BUILD_URL=$REPO_URL/releases/latest/download/
. /root/updater/model.sh
