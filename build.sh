#!/bin/bash
set -e

OUTPUT_RED='\033[0;31m'
OUTPUT_RESET='\033[0m'

BUILD_DIR=./build
EXCLUSIONS="assets/traefik, build, data, .env, build.sh, .gitignore, .package_files"

NODES="iota-hornet iota-wasp iota-chronicle shimmer-hornet shimmer-wasp shimmer-chronicle dlt-green"
INSTALLER_SCRIPT="./node-installer.sh"

build_node () {
  local node=$1
  local updateHash=$2

  local dir=${node}
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
  if [[ ! -z "$(grep "copy_common_assets" ${BUILD_DIR}/${node}/*.sh)" ]]; then
    mkdir -p ${BUILD_DIR}/${node}/assets
    rsync -a ./common/assets/* ${BUILD_DIR}/${node}/assets ${rsyncExclusions}
    find ${BUILD_DIR}/${node} -type f -name 'prepare_docker.sh' -exec sed -i '/copy_common_assets/d' {} \;
  fi

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

build_wasp_cli_image () {
  local version=$1
  local skipDockerBuilder=${2:-false}

  if [[ "${version}" == "" ]]; then
    read -p "Which version should be downloaded and built? " version
  fi

  local waspCliUrlAmd64="https://github.com/iotaledger/wasp/releases/download/v${version}/wasp-cli_${version}_Linux_x86_64.tar.gz"
  local waspCliUrlArm64="https://github.com/iotaledger/wasp/releases/download/v${version}/wasp-cli_${version}_Linux_ARM64.tar.gz"

  local buildDirWaspCli=${BUILD_DIR}/wasp-cli
  rm -Rf ${buildDirWaspCli}
  for platform in "amd64" "arm64"; do
    local url=${waspCliUrlAmd64}
    if [[ "${platform}" == "arm64" ]]; then url=${waspCliUrlArm64}; fi

    mkdir -p ${buildDirWaspCli}/${platform}
    (cd ${buildDirWaspCli}/${platform}; curl -o wasp-cli.tar.gz -L ${url} && tar zxvf wasp-cli.tar.gz --strip 1 && rm -f wasp-cli.tar.gz)
    (cd ${buildDirWaspCli}/${platform}; mkdir ./app && mv wasp-cli ./app)
  done

  echo "FROM gcr.io/distroless/cc-debian11:nonroot" > ${buildDirWaspCli}/Dockerfile
  echo "ARG TARGETARCH" >> ${buildDirWaspCli}/Dockerfile
  echo "COPY --chown=nonroot:nonroot ./\${TARGETARCH}/app  /app" >> ${buildDirWaspCli}/Dockerfile
  echo "WORKDIR /app" >> ${buildDirWaspCli}/Dockerfile
  echo "USER nonroot" >> ${buildDirWaspCli}/Dockerfile
  echo "ENTRYPOINT [\"/app/wasp-cli\"]" >> ${buildDirWaspCli}/Dockerfile

  if [[ "${skipDockerBuilder}" != "true" ]]; then prepare_dockerx_builder; fi
  (cd $buildDirWaspCli; docker buildx build --platform linux/amd64,linux/arm64 -t dltgreen/wasp-cli:${version} --push .)
  if [[ "${skipDockerBuilder}" != "true" ]]; then shutdown_dockerx_builder; fi
  
  rm -Rf ${buildDirWaspCli}
}

prepare_dockerx_builder () {
  shutdown_dockerx_builder
  sudo apt-get install -y qemu qemu-user-static
  docker buildx create --name iota-builder
  docker buildx use iota-builder
  docker buildx inspect --bootstrap
}

shutdown_dockerx_builder () {
  if [ "$(docker buildx ls | grep iota-builder)" != "" ]; then
    docker buildx rm iota-builder
  fi
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
    echo "build_node ${node} ${updateHashes}"
    output=$(build_node ${node} ${updateHashes})
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
  print_menu "Node packages" "Docker images" "Build management" "Exit"
	read  -p '> ' n
	case ${n} in
	1) NodePackagesMenu ;;
	2) DockerImagesMenu ;;
	3) BuildManagementMenu ;;
	*) clear; exit ;;
	esac
}

NodePackagesMenu() {
  print_menu "all" "iota-hornet" "iota-wasp" "iota-chronicle" "shimmer-hornet" "shimmer-wasp" "shimmer-chronicle" "dlt-green" "Back"
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
     build_node "iota-wasp" "interactive"
     enter_to_continue
	   NodePackagesMenu
     ;;
  4) print_line
     build_node "iota-chronicle" "interactive"
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
  7) print_line
     build_node "shimmer-chronicle" "interactive"
     enter_to_continue
	   NodePackagesMenu
     ;;
  8) print_line
     build_node "dlt-green" "interactive"
     enter_to_continue
	   NodePackagesMenu
     ;;
	*) MainMenu ;;
	esac
}

DockerImagesMenu() {
  print_menu "wasp-cli" "Back"
	read  -p '> ' n
	case ${n} in
  1) print_line
     build_wasp_cli_image
     enter_to_continue
	   DockerImagesMenu
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
      --wasp-cli-image)
        waspCliImageVersion="$2"
        shift
        shift
        ;;
      --skip-docker-builder)
        skipDockerBuilder="true"
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
      build_node ${node} ${updateHash:false}
    done
  fi

  if [[ "${waspCliImageVersion}" != "" ]]; then
    build_wasp_cli_image ${waspCliImageVersion} ${skipDockerBuilder};
  fi
else
  MainMenu
fi
