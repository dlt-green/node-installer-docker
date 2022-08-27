#!/bin/bash
set -e

BUILD_DIR=./build
EXCLUSIONS="assets/traefik, build, data, .env, build.sh, .gitignore"

NODES="iota-hornet iota-bee iota-goshimmer wasp shimmer-hornet"
HORNET_VERSION=1.2.1
WASP_VERSION=0.2.5
WASP_DEV_BRANCH="develop"

DEVSERVER_PORTDEVSERVER_PORT=8040

build_node () {
  node=$1
  sourceDir=./$node

  if [ ! -d $sourceDir ]; then
    echo "Please cd to root dir to run $(basename $0)"
    exit 255
  fi

  rsyncExclusions=$(echo $EXCLUSIONS | sed 's/ //g' | sed 's/,/ --exclude /g' | sed 's/^/--exclude /')

  mkdir -p $BUILD_DIR
  rsync -a $sourceDir $BUILD_DIR $rsyncExclusions
  
  # common assets
  mkdir -p $BUILD_DIR/$node/assets
  rsync -a ./common/assets/* $BUILD_DIR/$node/assets $rsyncExclusions
  find $BUILD_DIR/$node -type f -name 'prepare_docker.sh' -exec sed -i '/copy_common_assets/d' {} \;

  # common scripts
  mkdir -p $BUILD_DIR/$node/scripts
  rsync -a ./common/scripts/* $BUILD_DIR/$node/scripts $rsyncExclusions
  find $BUILD_DIR/$node -type f -name '*.sh' -exec sed -i 's/..\/common\/scripts/.\/scripts/g' {} \;

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

clean_build_dir () {
  sudo rm -Rf $BUILD_DIR && mkdir -p $BUILD_DIR
  echo "$BUILD_DIR cleaned"
}

build_all_nodes () {
  echo "Building all nodes..."
  print_line
  for node in $NODES; do
    build_node $node
    print_line
  done
  echo "Finished"
}

start_devserver () {
  echo "Starting devserver..."
  docker rm -f devserver >/dev/null 2>&1
  docker run \
    -d \
    --name devserver \
    -p ${DEVSERVER_PORT}:80 \
    -v $PWD/build/:/usr/share/caddy/ \
    caddy:alpine >/dev/null 2>&1

  echo "Listening for changes to rebuild packages..."
  trap 'echo "" && echo "Stopping devserver..." && docker rm -f devserver >/dev/null 2>&1 && echo "Finished"' SIGINT
  sudo iwatch \
    -r \
    -e create,delete,modify,move \
    -t ".*\.(sh|yml|md|env)" \
    -X ".*(assets|data|\.git|build.sh).*" \
    -c "./build.sh --onmodification '%f'" \
    .
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
  print_menu "iota-hornet ($HORNET_VERSION)" "wasp ($WASP_VERSION)" "wasp (dev)" "Back"
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
     build_wasp_image "$WASP_DEV_BRANCH" "wasp" "dev"
     enter_to_continue
     DockerImagesMenu
     ;;
	*) MainMenu ;;
	esac
}

NodePackagesMenu() {
  print_menu "all" "iota-hornet" "iota-bee" "iota-goshimmer" "wasp" "shimmer-hornet" "Back"
	read  -p '> ' n
	case $n in
  1) print_line
     build_all_nodes
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
  6) print_line
     build_node "shimmer-hornet"
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
     clean_build_dir
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

# Show menu if no argument is given
if [ ! $# -eq 0 ]; then
  POSITIONAL_ARGS=()
  while [[ $# -gt 0 ]]; do
    case $1 in
      --clean)
        clean=true
        shift
        ;;
      --nodes)
        nodes="$2"
        shift
        shift
        ;;
      --all)
        nodes="all"
        shift
        ;;
      --devserver)
        devserver="true"
        shift
        ;;
      --onmodification)
        modifiedFile="$2"
        shift
        shift
        ;;
      --help)
        shift
        ;;
      -*|--*)
        echo "Unknown option $1"
        exit 1
        ;;
      *)
        POSITIONAL_ARGS+=("$1")
        shift
        ;;
    esac
  done

  set -- "${POSITIONAL_ARGS[@]}"

  if [ ! -z "$modifiedFile" ]; then
    nodes=$(echo $modifiedFile | cut -d '/' -f 2)
    if [ $nodes == "common" ]; then
      nodes="all"
    elif [[ ! $NODES =~ $nodes ]]; then
      echo "Nothing to build for modified file: $modifiedFile"
      exit 0
    fi
  fi

  if [ "$devserver" == "true" ]; then start_devserver; fi
  if [ "$clean" == "true" ]; then clean_build_dir; fi
  if [ "$nodes" == "all" ]; then
    build_all_nodes
  else
    for node in ${nodes//,/ }; do
      if [ -f "$BUILD_DIR/$node.tar.gz" ] && [ "$(date -r $BUILD_DIR/$node.tar.gz)" == "$(date)" ]; then
        echo "Skipped build of $node.tar.gz (has already been built less than a second ago)"
        continue
      fi

      build_node $node;
    done
  fi
else
  MainMenu
fi