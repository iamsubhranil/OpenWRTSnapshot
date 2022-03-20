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

BUILD_URL=https://github.com/iamsubhranil/OpenWRTSnapshot/releases/latest/download/
. /root/updater/model.sh
