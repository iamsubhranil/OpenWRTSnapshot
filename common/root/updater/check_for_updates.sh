#!/bin/sh

LOGGER_PROMPT="Ignition"

set -e
set -o pipefail

LOCAL_VERSION=$(cat /etc/openwrt_version)

if [ "$1" ==  "-h" ] || [ "$1" == "--help" ];
then
    echo "OpenWRT updater scripts, written by Subhranil Mukherjee."
    echo
    echo "By default, these collection of scripts check the existence of a new"
    echo "snapshot on OpenWRT servers, trigger a build action on GitHub if"
    echo "there exists one, and finally, flash the generated firmware when"
    echo "the build action is complete. Moreover, they also provide hooks"
    echo "to run setup scripts after the first boot. Their output is saved"
    echo "in a specified logfile, which is currently $LOGFILE."
    echo
    echo "The scripts also provide the following flags to customize their"
    echo "behaviour."
    echo "          -f | --force    Skip the version checks, and force a new build"
    echo "                          followed by a flash whether or not there is a"
    echo "                          newer version actually available on OpenWRT"
    echo "                          servers."
    echo
    echo "          -r | --reflash  Skip the build if no new snapshot exists on"
    echo "                          OpenWRT servers, however, force the flash of the"
    echo "                          last available firmware from GitHub releases."
    echo "                          If there is a new build available, follow the"
    echo "                          normal build and flash behaviour."
    echo
    echo "          -u | --update   Update the updater scripts without the need of"
    echo "                          building and flashing a new firmware."
    echo
    echo "          -h | --help     Show this help."
    exit
elif [ "$1" == "-f" ] || [ "$1" == "--force" ];
then
    LOCAL_VERSION=$LOCAL_VERSION-forced
    LOGGER_PROMPT="ForcedIgnition"
elif [ "$1" == "-u" ] || [ "$1" == "--update" ];
then
    LOGGER_PROMPT="Update"
    log "Updating updater scripts.."
    log "Generating temporary filename.."
    RANDOM_NAME=$(mktemp /tmp/updater.XXXXXX)
    REPO_FOLDERNAME=OpenWRTSnapshot-main
    REPO_FILENAME=$RANDOM_NAME.tar.gz
    log "Downloading current repo.."
    wget $REPO_URL/archive/master.tar.gz -O $REPO_FILENAME
    cd /tmp
    log "Ungzipping the archive.."
    gzip -d $REPO_FILENAME
    log "Extracting the ungzipped archive.."
    tar x -C /tmp -f $RANDOM_NAME.tar
    log "Backing up current files.."
    mv $BASEDIR $BASEDIR-old
    mkdir -p $BASEDIR
    log "Copying new files to $BASEDIR.."
    cp -R /tmp/$REPO_FOLDERNAME/common$BASEDIR/* $BASEDIR/
    cp -R /tmp/$REPO_FOLDERNAME/$DEVICE/files$BASEDIR/* $BASEDIR/
    chmod +x $BASEDIR/*
    log "Updating BASEDIR.."
    sed -i "2 i BASEDIR=$BASEDIR" $BASEDIR/common.sh
    find $BASEDIR -type f ! -name '*common.sh*' ! -name '*model.sh*' -exec sed -i "2 i . $BASEDIR/common.sh" {} \;
    log "Removing backup and temporary files.."
    rm -rf $BASEDIR-old
    rm -rf /tmp/$REPO_FOLDERNAME
    rm -f $RANDOM_NAME.tar
    rm -f $RANDOM_NAME
    log "Update successful!"
    exit
elif [ "$1" == "-r" ] || [ "$1" == "--reflash" ];
then
    LOGGER_PROMPT="ReIgnition"
elif [ "$1" != "" ];
then
    echo "Wrong option chosen, please use '-h' to view available choices!"
    exit 1
fi

# if the flag is -r, we don't need to change anything here,
# since we won't build anything if the latest version is
# already available

FILENAME=openwrt-$TARGET-$SUBTARGET-$PROFILE-squashfs-sysupgrade
OPENWRT_SNAPSHOT_URL=https://downloads.openwrt.org/snapshots/targets/$TARGET/$SUBTARGET

executeHook pre-update-early

while true
do
	log "Checking snapshot version on downloads.openwrt.org.."
	LATEST_SNAPSHOT=$(wget -qO- $OPENWRT_SNAPSHOT_URL/version.buildinfo)
	if [ "$LATEST_SNAPSHOT" == "$LOCAL_VERSION" ] || [ "$LATEST_SNAPSHOT" == "" ] ; then
		log "No new version found!"
		if [ "$1" == "-r" ] || [ "$1" == "--reflash" ];
        then
            log "Proceeding with reflash.."
        else
		    log "Sleeping for 30mins!"
		    sleep 1800
        fi
	else
	    log "New version found: $LATEST_SNAPSHOT!"
		LATEST_GITHUB=$(wget -qO- $BUILD_URL/$FILENAME.version)
		if [ "$LATEST_GITHUB" != "$LATEST_SNAPSHOT" ]; then
            log "Executing git push to trigger GitHub build.."
            chmod +x trigger_build.sh
            . ./trigger_build.sh
            log "Build triggered on GitHub by push.."
            executeHook pre-update
            log "Waiting for build completion.."
            while [ "$LATEST_GITHUB" != "$LATEST_SNAPSHOT" ];
            do
                sleep 10
                LATEST_GITHUB=$(wget -qO- $BUILD_URL/$FILENAME.version)
            done
            log "Build completed on GitHub!"
        else
            log "New build already available in GitHub!"
            executeHook pre-update
        fi
        break
	fi
done

log "Executing updater script.."
chmod +x $BASEDIR/autoupdate.sh
sh $BASEDIR/autoupdate.sh "$1"
