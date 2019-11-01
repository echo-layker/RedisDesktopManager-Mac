#!/bin/bash

SHELL_FOLDER=$(cd "$(dirname "$0")";pwd)

echo '=======================Clone RDM repository======================='
rm -rf rdm
git clone --recursive https://github.com/uglide/RedisDesktopManager.git rdm
echo "=======================Switch to latest tag: ${TAG}===================="
cd $SHELL_FOLDER/rdm
TAG=$(git describe --tags `git rev-list --tags --max-count=1`)
echo 'switch to latest tag: '$TAG
cd $SHELL_FOLDER/rdm
git checkout -b $TAG $TAG
echo '=======================Build CrashReporter======================='
cd $SHELL_FOLDER/rdm/3rdparty/crashreporter
# errors on latest version of crashrepoter, build version 7ec6f00 instead.
git checkout 7ec6f00
qmake DESTDIR=./bin CONFIG-=debug
make -s -j 8
mkdir -p $SHELL_FOLDER/rdm/bin/osx/release
mv $SHELL_FOLDER/rdm/3rdparty/crashreporter/bin/crashreporter $SHELL_FOLDER/rdm/bin/osx/release


echo '=======================Modify RDM version======================='
cd $SHELL_FOLDER/rdm/src
echo 'copy Info.plist'
cp resources/Info.plist.sample resources/Info.plist
echo 'modify rdm.pro'
sed -i '' "s/2019.3/$TAG/g" rdm.pro
sed -i '' 's/debug: CONFIG-=app_bundle/#debug: CONFIG-=app_bundle/g' rdm.pro


echo "=======================Build RDM ${TAG}======================="
cd $SHELL_FOLDER/rdm/src
./configure
qmake CONFIG-=debug
make -s -j 8

echo "=======================Copy QT Framework(optional)======================="
cd $SHELL_FOLDER/rdm/bin/osx/release
macdeployqt rdm.app -qmldir=../../../src/qml

echo "=======================SUCCESS======================="
echo 'App file is:'$SHELL_FOLDER/rdm/bin/osx/release/rdm.app
