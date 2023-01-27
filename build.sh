#!/bin/bash
set -e

BUILD_DIR=./build
EXCLUSIONS="assets/traefik, build, data, .env, build.sh, .gitignore"

NODES="iota-hornet iota-goshimmer wasp shimmer-hornet"

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
  for node in $NODES; do
    output=$(build_node $node)
    echo "  * $output"
  done
}

enter_to_continue () {
  print_line
  echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx
}

print_line () {
  local columns="$1"
  printf '%*s\n' "${columns:-$(tput cols)}" '' | tr ' ' -
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
  print_menu "Node packages" "Build management" "Exit"
	read  -p '> ' n
	case $n in
	1) NodePackagesMenu ;;
	2) BuildManagementMenu ;;
	*) clear; exit ;;
	esac
}

NodePackagesMenu() {
  print_menu "all" "iota-hornet" "iota-goshimmer" "shimmer-hornet" "wasp" "Back"
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
     build_node "iota-goshimmer"
     enter_to_continue
	   NodePackagesMenu
     ;;
  4) print_line
     build_node "shimmer-hornet"
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

  if [ "$clean" == "true" ]; then clean_build_dir; fi
  if [ "$nodes" == "all" ]; then
    build_all_nodes
  else
    for node in ${nodes//,/ }; do
      build_node $node;
    done
  fi
else
  MainMenu
fi