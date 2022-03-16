#!/bin/bash

# Required variables: TARGET, SUBTARGET, PROFILE

echo "Installing prerequisites.."

chmod +x ../prereq.sh
. ../prereq.sh

BUILDER=openwrt-imagebuilder-$TARGET-$SUBTARGET.Linux-x86_64
FILENAME=openwrt-$TARGET-$SUBTARGET-$PROFILE-squashfs-sysupgrade
IMAGE_DIR=../images

rm -rf $BUILDER $BUILDER.tar.xz

echo "Downloading image builder.."

mkdir -p $IMAGE_DIR
wget -q https://downloads.openwrt.org/snapshots/targets/$TARGET/$SUBTARGET/$BUILDER.tar.xz
wget -q https://downloads.openwrt.org/snapshots/targets/$TARGET/$SUBTARGET/version.buildinfo -O $IMAGE_DIR/$FILENAME.version

echo "Extracting image builder.."
tar -J -x -f $BUILDER.tar.xz

echo "Copying custom files.."
cp -R files $BUILDER/

echo "Preparing package list.."

BASE_RM=$(cat base_rm.list)
BASE_ADD=$(cat base_add.list | tr '\n' ' ')

PACKAGES="$BASE_ADD $BASE_RM"

echo "Packages: " $PACKAGES

cd $BUILDER

echo "Running make.."

make image PACKAGES="$PACKAGES" PROFILE="$PROFILE" FILES="files" CONFIG_IPV6=n

echo "Build complete! Copying firmware to images/.."
cd ..
cp $BUILDER/bin/targets/$TARGET/$SUBTARGET/$FILENAME.bin $IMAGE_DIR

echo "Calculating sha256.."
sha256sum $IMAGE_DIR/$FILENAME.bin | cut -f1 -d' ' > $IMAGE_DIR/$FILENAME.sha256

echo "$FILENAME.bin build successful!"
