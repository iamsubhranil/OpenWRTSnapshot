#!/bin/bash

set -e
set -o pipefail

BASEDIR=/root/updater

if [ ! -f "files$BASEDIR/model.sh" ];
then
    echo "model.sh cannot be found in current folder!"
    echo "Run the following commands, and then try executing the script again:"
    echo
    echo "mkdir -p files$BASEDIR"
    echo "MODEL=files$BASEDIR/model.sh"
    echo "echo \"#!/bin/sh\" >> \$MODEL"
    echo "echo \"TARGET=<target>\" >> \$MODEL"
    echo "echo \"SUBTARGET=<subtarget>\" >> \$MODEL"
    echo "echo \"PROFILE=<profile>\" >> \$MODEL"
    echo "echo \"DEVICE=<device>\" >> \$MODEL"
    echo "chmod +x \$MODEL"
    exit 1
fi

echo "Getting device info.."
chmod +x ./files$BASEDIR/model.sh
. ./files$BASEDIR/model.sh

echo "TARGET=$TARGET"
echo "SUBTARGET=$SUBTARGET"
echo "PROFILE=$PROFILE"
echo "DEVICE=$DEVICE"

if [ -z "${TARGET}" ] || [ -z "${SUBTARGET}" ] || [ -z "${PROFILE}" ] || [ -z "${DEVICE}" ];
then
    echo "One of TARGET, SUBTARGET, PROFILE or DEVICE is not defined!"
    echo "Set the corresponding value in model.sh and try again!"
    exit 1
fi

echo "Installing prerequisites.."
chmod +x ../prereq.sh
. ../prereq.sh

BUILDER=openwrt-imagebuilder-$TARGET-$SUBTARGET.Linux-x86_64
FILENAME=openwrt-$TARGET-$SUBTARGET-$PROFILE-squashfs-sysupgrade
IMAGE_DIR=../images
COMMON_FILE_DIR=../common

rm -rf $BUILDER $BUILDER.tar.xz

echo "Downloading image builder.."

mkdir -p $IMAGE_DIR
wget -q https://downloads.openwrt.org/snapshots/targets/$TARGET/$SUBTARGET/$BUILDER.tar.zst
wget -q https://downloads.openwrt.org/snapshots/targets/$TARGET/$SUBTARGET/version.buildinfo -O $IMAGE_DIR/$FILENAME.version

echo "Extracting image builder.."
unzstd $BUILDER.tar.zst
tar -xvf $BUILDER.tar

echo "Copying custom files.."
# copy specific files
cp -R files $BUILDER/
# copy common files
rsync -avh $COMMON_FILE_DIR/ $BUILDER/files/

sed -i "2 i BASEDIR=$BASEDIR" $BUILDER/files$BASEDIR/common.sh
find $BUILDER/files -type f ! -name '*common.sh*' ! -name '*model.sh*' ! -name '*.list' -exec sed -i "2 i . $BASEDIR/common.sh" {} \;

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
