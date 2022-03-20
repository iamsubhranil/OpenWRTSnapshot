#!/bin/sh

# Requires DEVICE, LOCAL_VERSION, LATEST_SNAPSHOT

DIR=$(pwd)
REPO_DIR="/tmp/OpenWRTSnapshot"

echo "Checking git dir.."
if [ ! -d $REPO_DIR ]; then
        mkdir -p $REPO_DIR
        git clone git@github.com:iamsubhranil/OpenWRTSnapshot.git $REPO_DIR
fi

cd $REPO_DIR
git pull
BUILD_MESSAGE="[$(date)] [$DEVICE] Local ver: $LOCAL_VERSION, snapshot ver: $LATEST_SNAPSHOT"
COMMIT_MESSAGE="Build requested by $DEVICE at $(date)"
echo "$BUILD_MESSAGE" >> build_requests.log
git add build_requests.log
git commit -m "build: $COMMIT_MESSAGE"
git push

cd "$DIR"
