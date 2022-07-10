#!/bin/bash
BUILD_DIR=./build
EXCLUSIONS="build, data, .env, build.sh, .gitignore"

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
  find $BUILD_DIR -type f -exec sed -i 's/\r//' {} \;
  (cd $BUILD_DIR/$node; tar -pcz -f ../$node.tar.gz *)
  rm -Rf $BUILD_DIR/$node
  echo "$node.tar.gz built successfully"
}

upload () {
  envFile=$(dirname "$0")/.env
  if [ ! -e "$envFile" ]; then
    echo "Missing .env!"
    echo "Please create .env with UPLOAD_USER, UPLOAD_HOST and UPLOAD_PATH if you would like to upload files."
  else
    source "$envFile"
    echo "Uploading *.tar.gz files in $BUILD_DIR to $UPLOAD_HOST:$UPLOAD_PATH"
    rsync -rzP --include="*.tar.gz" $BUILD_DIR/* $UPLOAD_USER@$UPLOAD_HOST:$UPLOAD_PATH
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
  select opt in iota-bee iota-goshimmer upload clean quit; do
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
