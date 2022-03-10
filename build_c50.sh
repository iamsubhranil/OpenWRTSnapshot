#!/bin/bash

echo "Installing prerequisites.."

chmod +x ./prereq.sh
. ./prereq.sh

echo "Downloading image builder.."

rm -rf openwrt-imagebuilder-*

FILENAME=openwrt-ramips-mt76x8-tplink_archer-c50-v4-squashfs-sysupgrade

mkdir -p images
wget -q https://downloads.openwrt.org/snapshots/targets/ramips/mt76x8/openwrt-imagebuilder-ramips-mt76x8.Linux-x86_64.tar.xz
wget -q https://downloads.openwrt.org/snapshots/targets/ramips/mt76x8/version.buildinfo -O images/$FILENAME.version

echo "Extracting image builder.."
tar -J -x -f openwrt-imagebuilder-*.tar.xz

echo "Preparing package list.."

BASE_RM=$(cat c50/base_rm.list)
BASE_ADD=$(cat c50/base_add.list | tr '\n' ' ')

PACKAGES="$BASE_ADD $BASE_RM"

echo "Packages: " $PACKAGES

PROFILE="tplink_archer-c50-v4"
FILES="c50/files"

cd openwrt-imagebuilder-*/

echo "Running make.."

make image PACKAGES="$PACKAGES" PROFILE="$PROFILE" FILES="$FILES"

cd ..
cp openwrt-*/bin/targets/ramips/mt76x8/*.bin images/
sha256sum images/$FILENAME.bin | cut -f1 -d' ' > images/$FILENAME.sha256
