#!/bin/bash
set -e

OUTPUT_RED='\033[0;31m'
OUTPUT_RESET='\033[0m'

BUILD_DIR=./build
EXCLUSIONS="assets/traefik, build, data, .env, build.sh, .gitignore, .package_files"

NODES="iota-hornet iota-goshimmer iota-wasp shimmer-hornet shimmer-wasp"
INSTALLER_SCRIPT="./node-installer.sh"

build_node () {
  local node=$1
  local updateHash=$2

  local dir=${node}
  # network independent packages
  if [[ "${node}" == *"wasp"* ]]; then
    dir=$(echo ${dir} | sed 's/iota-//g' | sed 's/shimmer-//g')
  fi
  local sourceDir=./${dir}

  if [ ! -d ${sourceDir} ]; then
    echo "Please cd to root dir to run $(basename $0)"
    exit 255
  fi

  if [[ "${updateHash}" == "interactive" ]]; then
    read -p "Should the hash in installer be updated (y/n)? " input
    if [[ "${input}" == "y" ]]; then updateHash="true"; fi
    echo ""
  fi

  local rsyncExclusions=$(echo ${EXCLUSIONS} | sed 's/ //g' | sed 's/,/ --exclude /g' | sed 's/^/--exclude /')

  mkdir -p ${BUILD_DIR}
  rsync -a ${sourceDir} ${BUILD_DIR} ${rsyncExclusions}
  if [[ "${dir}" != "${node}" ]]; then mv ${BUILD_DIR}/${dir} ${BUILD_DIR}/${node}; fi
  
  # common assets
  mkdir -p ${BUILD_DIR}/${node}/assets
  rsync -a ./common/assets/* ${BUILD_DIR}/${node}/assets ${rsyncExclusions}
  find ${BUILD_DIR}/${node} -type f -name 'prepare_docker.sh' -exec sed -i '/copy_common_assets/d' {} \;

  # common scripts
  mkdir -p ${BUILD_DIR}/${node}/scripts
  rsync -a ./common/scripts/* ${BUILD_DIR}/${node}/scripts ${rsyncExclusions}
  find ${BUILD_DIR}/${node} -type f -name '*.sh' -exec sed -i 's/..\/common\/scripts/.\/scripts/g' {} \;

  # verify package content
  verify_package_content "${sourceDir}" "${BUILD_DIR}/${node}"

  find ${BUILD_DIR}/${node} -type f -exec sed -i 's/\r//' {} \;
  (cd ${BUILD_DIR}/${node}; tar -pcz -f ../${node}.tar.gz *)
  rm -Rf ${BUILD_DIR}/${node}

  local messageAddition=""
  if [[ "${updateHash}" == "true" ]]; then
    update_hash_in_installer ${node}
    messageAddition="(updated hash in installer)"
  fi

  echo "${node}.tar.gz built successfully ${messageAddition}"
}

# temporary workaround because we use different wasp versions for iota (older) and shimmer (current)
build_iota_wasp () {
  updateHash=$1
  node="iota-wasp"

  if [[ "${updateHash}" == "interactive" ]]; then
    read -p "Should the hash in installer be updated (y/n)? " input
    if [[ "${input}" == "y" ]]; then updateHash="true"; fi
    echo ""
  fi

  curl -L -s -o ${BUILD_DIR}/${node}.tar.gz https://github.com/dlt-green/node-installer-docker/releases/download/v.1.5.0/wasp_iota.tar.gz

  local messageAddition=""
  if [[ "${updateHash}" == "true" ]]; then
    update_hash_in_installer ${node}
    messageAddition="(updated hash in installer)"
  fi

  echo "${node}.tar.gz built successfully ${messageAddition}"
}

verify_package_content () {
  local sourceDir=$1
  local buildDir=$2

  if [[ -f "${sourceDir}/.package_files" ]]; then
    local expectedFiles=$(cat "${sourceDir}/.package_files" | sort)
    local actualFiles=$(cd ${buildDir}; find ./ -type f | sort)
    local diffResult=$(diff --strip-trailing-cr <(echo "$expectedFiles") <(echo "$actualFiles"))
    if [[ ! -z "${diffResult}" ]]; then
      >&2 echo -e ""
      >&2 echo -e "${OUTPUT_RED}FAILURE:${OUTPUT_RESET} Build dir ${buildDir} contains unwanted files (diff output follows)"
      >&2 echo -e ""
      >&2 echo -e "Diff:${sourceDir}/.package_files"
      >&2 echo -e "${diffResult}"
      >&2 echo -e ""
      >&2 echo -e "Expected files:"
      >&2 echo -e "${expectedFiles}"
      >&2 echo -e ""
      >&2 echo -e "Actual files:"
      >&2 echo -e "${actualFiles}"
      exit 255
    fi
  fi
}

update_hash_in_installer () {
  local node=$1

  local installerHashVarName=$(kebabToCamel "${node}" "true")Hash
  sed -i "s/${installerHashVarName}=.*/${installerHashVarName}='$(shasum -a 256 ./build/${node}.tar.gz | cut -d ' ' -f 1)'/g" ${INSTALLER_SCRIPT}
}

upload_build_artefacts () {
  local envFile=$(dirname "$0")/.env
  if [ ! -e "${envFile}" ]; then
    echo "Missing .env!"
    echo "Please create .env with UPLOAD_USER, UPLOAD_HOST and UPLOAD_PATH if you would like to upload files."
  else
    source "${envFile}"
    echo "Uploading files in ${BUILD_DIR} to ${UPLOAD_HOST}:${UPLOAD_PATH}"
    rsync -rzP --include="*.tar.gz" --include="*.tar" ${BUILD_DIR}/* ${UPLOAD_USER}@${UPLOAD_HOST}:${UPLOAD_PATH}
  fi
}

clean_build_dir () {
  sudo rm -Rf ${BUILD_DIR} && mkdir -p ${BUILD_DIR}
  echo "${BUILD_DIR} cleaned"
}

build_all_nodes () {
  local updateHashes=$1
  if [[ "${updateHashes}" == "interactive" ]]; then
    read -p "Should the hashes in installer be updated? (y/n) " input
    if [[ "${input}" == "y" ]]; then updateHashes="true"; else updateHashes="false"; fi
    echo ""
  fi

  echo "Building all nodes..."
  for node in ${NODES}; do
    if [[ "${node}" == "iota-wasp" ]]; then
      output=$(build_iota_wasp ${updateHashes})
    else
      output=$(build_node ${node} ${updateHashes})
    fi
    echo "  * ${output}"
  done
}

kebabToCamel() {
  local input=$1
  local firstLetterUpperCase=$2

  local output=""
  for word in $(echo ${input} | tr "-" " "); do
    if [[ -z "${output}" ]] && [[ "${firstLetterUpperCase}" != "true" ]]; then
      output="${word}"
    else
      output="${output}$(echo "${word:0:1}" | tr "[:lower:]" "[:upper:]")${word:1}"
    fi
  done
  echo "${output}"
}

enter_to_continue () {
  print_line
  echo ${fl}; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo ${xx}
}

print_line () {
  local columns="$1"
  printf '%*s\n' "${columns:-$(tput cols)}" '' | tr ' ' -
}

print_menu () {
  local longestArgumentLength=0
  for item in "$@"; do
      if [ ${#item} -gt ${longestArgumentLength} ]; then
        longestArgumentLength=${#item}
      fi
  done

  local argumentsCount=${#@}
  local longestInput=$((${argumentsCount} - 1))
  local menuInnerWidth=$((${longestArgumentLength} + 20 + 2 + ${#longestInput}))
  local innerLine=$(seq 1 ${menuInnerWidth} | sed 's/.*/═/' | tr -d '\n')
  local innerBlanks=$(seq 1 ${menuInnerWidth} | sed 's/.*/ /' | tr -d '\n')

	clear
	echo ""
  echo "╔${innerLine}╗"
  echo "║${innerBlanks}║"

  local iterator=1
  for item in "$@"; do
    local input="${iterator}"
    if [ $# -eq ${iterator} ]; then
      input="X"
      echo "║${innerBlanks}║"
    fi

    local paddingLeftNum=$((${#longestInput} - ${#input}))
    local paddingLeft=$(seq 1 $((10 + ${paddingLeftNum})) | sed 's/.*/ /' | tr -d '\n')
    local paddingRight=$(seq 1 $((${menuInnerWidth} - 10 - ${paddingLeftNum} - ${#input} - 2 - ${#item})) | sed 's/.*/ /' | tr -d '\n')

    echo "║${paddingLeft}${input}. ${item}${paddingRight}║"
    iterator=$((${iterator} + 1))
  done

  echo "║${innerBlanks}║"
  echo "╚${innerLine}╝"
  echo ""
	echo "Select menu item: "
	echo ""
}

MainMenu() {
  print_menu "Node packages" "Build management" "Exit"
	read  -p '> ' n
	case ${n} in
	1) NodePackagesMenu ;;
	2) BuildManagementMenu ;;
	*) clear; exit ;;
	esac
}

NodePackagesMenu() {
  print_menu "all" "iota-hornet" "iota-goshimmer" "iota-wasp" "shimmer-hornet" "shimmer-wasp" "Back"
	read  -p '> ' n
	case ${n} in
  1) print_line
     build_all_nodes "interactive"
     enter_to_continue
	   NodePackagesMenu
     ;;
	2) print_line
     build_node "iota-hornet" "interactive"
     enter_to_continue
	   NodePackagesMenu
     ;;
  3) print_line
     build_node "iota-goshimmer""interactive"
     enter_to_continue
	   NodePackagesMenu
     ;;
  4) print_line
     build_iota_wasp "interactive"
     enter_to_continue
	   NodePackagesMenu
     ;;
  5) print_line
     build_node "shimmer-hornet" "interactive"
     enter_to_continue
	   NodePackagesMenu
     ;;
  6) print_line
     build_node "shimmer-wasp" "interactive"
     enter_to_continue
	   NodePackagesMenu
     ;;
	*) MainMenu ;;
	esac
}

BuildManagementMenu() {
  print_menu "Clean build dir" "Upload build artefacts" "Back"
	read  -p '> ' n
	case ${n} in
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
      --update-hash)
        updateHash="true"
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

  if [ "${clean}" == "true" ]; then clean_build_dir; fi
  if [ "${nodes}" == "all" ]; then
    build_all_nodes ${updateHash:false}
  else
    for node in ${nodes//,/ }; do
      build_node ${node} ${updateHash:false};
    done
  fi
else
  MainMenu
fi