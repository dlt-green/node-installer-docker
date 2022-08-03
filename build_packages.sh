#!/bin/bash
set -e

BUILD_DIR=./build
EXCLUSIONS="build, data, .env, build.sh, .gitignore"
HORNET_VERSION=1.2.1
WASP_VERSION=0.2.5

build_node () {
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

build_hornet_image () {
  imageName=dltgreen/iota-hornet:$HORNET_VERSION
  buildDirHornet=$BUILD_DIR/tmp_hornet

  mkdir -p $buildDirHornet
  #(cd $buildDirHornet; curl -L -o hornet.tar.gz https://github.com/iotaledger/hornet/archive/refs/tags/v${HORNET_VERSION}.tar.gz; tar -xvf hornet.tar.gz --strip 1)
  (cd $BUILD_DIR; git clone https://github.com/iotaledger/hornet.git tmp_hornet; cd tmp_hornet; git checkout v${HORNET_VERSION})

  if [ -f $buildDirHornet/docker/Dockerfile ]; then
    (cd $buildDirHornet; docker build --no-cache -f docker/Dockerfile -t $imageName .)
  fi

  docker save $imageName > $BUILD_DIR/iota-hornet-$HORNET_VERSION.tar
  rm -Rf $buildDirHornet

  push_docker_image $imageName
}

build_wasp_image () {
  local repoTag=$1
  local name=$2
  local imageTag=$3

  local imageName=dltgreen/$name:$imageTag
  local buildDirWasp=$BUILD_DIR/tmp_wasp

  rm -Rf $buildDirWasp && mkdir -p $buildDirWasp
  (cd $BUILD_DIR; git clone https://github.com/iotaledger/wasp.git tmp_wasp; cd tmp_wasp; git checkout $repoTag)

  if [ -f $buildDirWasp/Dockerfile ]; then
    # temporary fix to display correct version on wasp ui (because we also build an image from master branch)
    if [ "$repoTag" == "master" ]; then sed -i "s/Version.*=.*/Version = \"${imageTag}\"/g" $buildDirWasp/packages/wasp/constants.go; fi
    (cd $buildDirWasp; docker build --no-cache -t $imageName .)
  fi

  docker save $imageName > $BUILD_DIR/wasp-$imageTag.tar
  rm -Rf $buildDirWasp

  push_docker_image $imageName
}

push_docker_image () {
  local imageName=$1
  
  print_line
  read -p "Push docker image to dockerhub? (y/n) " yn
  echo ""
  case $yn in 
    y) docker push $imageName
       ;;
    *) echo "Image has not been pushed"
       ;;
  esac
}

upload_build_artefacts () {
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

enter_to_continue () {
  print_line
  echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx
}

print_menu () {
  local longestArgumentLength=0
  for item in "$@"; do
      if [ ${#item} -gt $longestArgumentLength ]; then
        longestArgumentLength=${#item}
      fi
  done

  local argumentsCount=${#@}
  local longestInput=$(($argumentsCount - 1))
  local menuInnerWidth=$(($longestArgumentLength + 20 + 2 + ${#longestInput}))
  local innerLine=$(seq 1 $menuInnerWidth | sed 's/.*/═/' | tr -d '\n')
  local innerBlanks=$(seq 1 $menuInnerWidth | sed 's/.*/ /' | tr -d '\n')

	clear
	echo ""
  echo "╔$innerLine╗"
  echo "║$innerBlanks║"

  local iterator=1
  for item in "$@"; do
    local input="$iterator"
    if [ $# -eq $iterator ]; then
      input="X"
      echo "║$innerBlanks║"
    fi

    local paddingLeftNum=$((${#longestInput} - ${#input}))
    local paddingLeft=$(seq 1 $((10 + $paddingLeftNum)) | sed 's/.*/ /' | tr -d '\n')
    local paddingRight=$(seq 1 $(($menuInnerWidth - 10 - $paddingLeftNum - ${#input} - 2 - ${#item})) | sed 's/.*/ /' | tr -d '\n')

    echo "║${paddingLeft}${input}. ${item}${paddingRight}║"
    iterator=$(($iterator + 1))
  done

  echo "║$innerBlanks║"
  echo "╚$innerLine╝"
  echo ""
	echo "Select menu item: "
	echo ""
}

MainMenu() {
  print_menu "Docker images" "Node packages" "Build management" "Exit"
	read  -p '> ' n
	case $n in
	1) DockerImagesMenu ;;
	2) NodePackagesMenu ;;
	3) BuildManagementMenu ;;
	*) clear; exit ;;
	esac
}

DockerImagesMenu() {
  print_menu "iota-hornet ($HORNET_VERSION)" "wasp ($WASP_VERSION)" "wasp (master)" "Back"
	read  -p '> ' n
	case $n in
	1) print_line
     build_hornet_image
     enter_to_continue
     DockerImagesMenu
     ;;
	2) print_line
     build_wasp_image "v$WASP_VERSION" "wasp" "$WASP_VERSION"
     enter_to_continue
     DockerImagesMenu
     ;;
	3) print_line
     build_wasp_image "master" "wasp" "dev"
     enter_to_continue
     DockerImagesMenu
     ;;
	*) MainMenu ;;
	esac
}

NodePackagesMenu() {
  print_menu "all" "iota-hornet" "iota-bee" "iota-goshimmer" "wasp" "Back"
	read  -p '> ' n
	case $n in
  1) print_line
     for node in "iota-hornet" "iota-bee" "iota-goshimmer" "wasp"; do
       build_node $node
       print_line
     done
     enter_to_continue
	   NodePackagesMenu
     ;;
	2) print_line
     build_node "iota-hornet"
     enter_to_continue
	   NodePackagesMenu
     ;;
	3) print_line
     build_node "iota-bee"
     enter_to_continue
	   NodePackagesMenu
     ;;
  4) print_line
     build_node "iota-goshimmer"
     enter_to_continue
	   NodePackagesMenu
     ;;
  5) print_line
     build_node "wasp"
     enter_to_continue
	   NodePackagesMenu
     ;;
	*) MainMenu ;;
	esac
}

BuildManagementMenu() {
  print_menu "Clean build dir" "Upload build artefacts" "Back"
	read  -p '> ' n
	case $n in
	1) print_line
     rm -Rf $BUILD_DIR && mkdir -p $BUILD_DIR
     echo "$BUILD_DIR cleaned"
     enter_to_continue
     BuildManagementMenu
     ;;
	2) print_line
     upload_build_artefacts
     enter_to_continue
     BuildManagementMenu
     ;;
	*) MainMenu ;;
	esac
}

MainMenu