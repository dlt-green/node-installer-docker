#!/bin/bash
SOURCE_DIR=../../iota-goshimmer
BUILD_DIR=../build
EXCLUSIONS="build, data, .env, build.sh, .gitignore"

if [ ! -d $SOURCE_DIR ]; then
  echo "Please cd to tools dir to run build.sh"
  exit -1
fi

rsyncExclusions=$(echo $EXCLUSIONS | sed 's/ //g' | sed 's/,/ --exclude /g' | sed 's/^/--exclude /')

rm -Rf $BUILD_DIR && mkdir -p $BUILD_DIR
rsync -a $SOURCE_DIR $BUILD_DIR $rsyncExclusions
find $BUILD_DIR -type f -exec sed -i 's/\r//' {} \;
(cd $BUILD_DIR/iota-goshimmer; tar -pcz -f ../install.tar.gz *)
rm -Rf $BUILD_DIR/iota-goshimmer
echo "install.tar.gz built successfully (../build/install.tar.gz)"