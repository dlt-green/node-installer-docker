#!/bin/bash
set -e

BUILD_DIR=./build
EXCLUSIONS="build, data, .env, build.sh, .gitignore"
WASP_VERSION=v0.2.5

build_node () {
  # param1: node to build
  node=$1
  sourceDir=./$node

  if [ ! -d $sourceDir ]; then
    echo "Please cd to tools dir to run build.sh"
    exit -1
  fi

  rsyncExclusions=$(echo $EXCLUSIONS | sed 's/ //g' | sed 's/,/ --exclude /g' | sed 's/^/--exclude /')

  mkdir -p $BUILD_DIR
  rsync -a $sourceDir $BUILD_DIR $rsyncExclusions
  find $BUILD_DIR/$node -type f -exec sed -i 's/\r//' {} \;
  (cd $BUILD_DIR/$node; tar -pcz -f ../$node.tar.gz *)
  rm -Rf $BUILD_DIR/$node
  echo "$node.tar.gz built successfully"
}

build_wasp_image () {
  IMAGE_TAG=dlt.green/iota-wasp:$WASP_VERSION
  BUILD_DIR_WASP=$BUILD_DIR/tmp_wasp

  mkdir -p $BUILD_DIR_WASP
  (cd $BUILD_DIR_WASP; curl -L -o wasp.tar.gz https://github.com/iotaledger/wasp/archive/refs/tags/$WASP_VERSION.tar.gz; tar -xvf wasp.tar.gz --strip 1)

  if [ -f $BUILD_DIR_WASP/Dockerfile ]; then
    (cd $BUILD_DIR_WASP; docker build -t $IMAGE_TAG .)
  fi

  docker save $IMAGE_TAG > $BUILD_DIR/iota-wasp-$WASP_VERSION.tar
  rm -Rf $BUILD_DIR_WASP
}

upload () {
  envFile=$(dirname "$0")/.env
  if [ ! -e "$envFile" ]; then
    echo "Missing .env!"
    echo "Please create .env with UPLOAD_USER, UPLOAD_HOST and UPLOAD_PATH if you would like to upload files."
  else
    source "$envFile"
    echo "Uploading files in $BUILD_DIR to $UPLOAD_HOST:$UPLOAD_PATH"
    rsync -rzP --include="*.tar.gz" --include="*.tar" $BUILD_DIR/* $UPLOAD_USER@$UPLOAD_HOST:$UPLOAD_PATH
  fi
}

print_line () {
  echo "--------------------------------------------------------------------------------"
}

print_menu () {
  print_line
  read -p 'Press [Enter] key to continue...' W
  clear
  menu
}

menu () {
  PS3="Enter a number: "
  select opt in iota-bee iota-goshimmer iota-wasp iota-wasp-dockerimage upload clean quit; do
    case $opt in
      iota-bee)
        print_line
        build_node $opt
        print_menu
        ;;
      iota-goshimmer)
        print_line
        build_node $opt
        print_menu
        ;;
      iota-wasp)
        print_line
        build_node $opt
        print_menu
        ;;
      iota-wasp-dockerimage)
        print_line
        build_wasp_image
        print_menu
        ;;
      upload)
        print_line
        upload
        print_menu
        ;;
      clean)
        print_line
        rm -Rf $BUILD_DIR
        echo "$BUILD_DIR deleted"
        print_menu
        ;;
      quit)
        exit 0
        ;;
      *) 
        echo "Invalid option $REPLY"
        ;;
    esac
  done
}

clear
menu
