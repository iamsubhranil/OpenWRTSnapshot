#!/bin/bash

echo "Installing prerequisites.."

chmod +x ./prereq.sh
. ./prereq.sh

echo "Downloading image builder.."

rm -rf openwrt-imagebuilder-*

FILENAME=openwrt-ramips-mt7621-tplink_archer-c6u-v1-squashfs-sysupgrade

mkdir -p images
wget -q https://downloads.openwrt.org/snapshots/targets/ramips/mt7621/openwrt-imagebuilder-ramips-mt7621.Linux-x86_64.tar.xz
wget -q https://downloads.openwrt.org/snapshots/targets/ramips/mt7621/version.buildinfo -O images/$FILENAME.version

echo "Extracting image builder.."
tar -J -x -f openwrt-imagebuilder-*.tar.xz
cp -R files openwrt-imagebuilder-*/

echo "Preparing package list.."

BASE_RM=$(cat c6u/base_rm.list)
BASE_ADD=$(cat c6u/base_add.list | tr '\n' ' ')

PACKAGES="$BASE_ADD $BASE_RM"

echo "Packages: " $PACKAGES

PROFILE="tplink_archer-c6u-v1"

FILES="c6u/files"

cd openwrt-imagebuilder-*/
mkdir files
cp -R ../$FILES/* files

echo "Running make.."

make image PACKAGES="$PACKAGES" PROFILE="$PROFILE" FILES="files" CONFIG_IPV6=n

cd ..
cp openwrt-*/bin/targets/ramips/mt7621/*.bin images/
sha256sum images/$FILENAME.bin | cut -f1 -d' ' > images/$FILENAME.sha256
