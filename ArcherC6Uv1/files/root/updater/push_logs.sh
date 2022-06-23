#!/bin/sh

REPO_DIR="/tmp/RouterBackup"

echo "Checking git dir.."
if [ ! -d $REPO_DIR ]; then
    mkdir -p $REPO_DIR
    git clone git@github.com:iamsubhranil/RouterBackup.git $REPO_DIR
fi

cd $REPO_DIR
git pull
# copy the root gitconfig since running git as a service
# somehow does not take the config from root automatically
cp /root/.gitconfig $REPO_DIR/
mkdir -p logs

cp /root/upgrade.log logs/c6uv1_upgrade.log
cp /root/upgrade_output.log logs/c6uv1_upgrade_output.log
scp root@192.168.1.2:/root/upgrade.log logs/c50v6_upgrade.log

git add logs/*
git commit -m "updt: new logs"
git push
