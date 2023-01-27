#!/bin/bash
BUILD_DIR=./build
DEVSERVER_PORT=8040
PACKAGE_DIRS="iota-hornet iota-goshimmer iota-wasp shimmer-hornet shimmer-wasp pipe"

print_help () {
  echo "This variables must be set in .env"
  echo ""
  echo "  * TEST_INSTALLER_TARGET_DIR:      Directory the test installer uses to install nodes"
  echo "  * TEST_INSTALLER_DOMAIN:          Domain for the machine the devserver is running on"
  echo "  * TEST_INSTALLER_DOMAIN_SSL_CERT: Path to SSL certificate"
  echo "  * TEST_INSTALLER_DOMAIN_SSL_KEY:  Path to SSL key"
  echo ""
}

guard_env () {
  source .env
  if [[ -z "${TEST_INSTALLER_TARGET_DIR}" ]] || [[ -z "${TEST_INSTALLER_DOMAIN}" ]] || [[ -z "${TEST_INSTALLER_DOMAIN_SSL_CERT}" ]] || [[ -z "${TEST_INSTALLER_DOMAIN_SSL_KEY}" ]]; then
    print_help
    exit -1
  fi
}

prepare_test_installer () {
  echo "Create/update test-installer.sh..."
  source .env
  testInstaller="${BUILD_DIR}/test-installer.sh"
  cp -f ./node-installer.sh "${testInstaller}" && chmod u+x "${testInstaller}"

  # prepare target dir for test-installer
  sudo mkdir -p "${TEST_INSTALLER_TARGET_DIR}"
  sed -i "s/\/var\/lib/${TEST_INSTALLER_TARGET_DIR//\//\\\/}/g" "${testInstaller}"

  # prepare for SSL
  sudo mkdir -p "/etc/letsencrypt/live/${TEST_INSTALLER_DOMAIN}"
  sudo cp -f "${TEST_INSTALLER_DOMAIN_SSL_CERT}" "/etc/letsencrypt/live/${TEST_INSTALLER_DOMAIN}/fullchain.pem"
  sudo cp -f "${TEST_INSTALLER_DOMAIN_SSL_KEY}" "/etc/letsencrypt/live/${TEST_INSTALLER_DOMAIN}/privkey.pem"
  
  # fake iota-wasp
  if [[ ! -f "${BUILD_DIR}/iota-wasp.tar.gz" ]]; then
    mv "${BUILD_DIR}/wasp.tar.gz" "${BUILD_DIR}/shimmer-wasp.tar.gz"
    curl -L -o "${BUILD_DIR}/iota-wasp.tar.gz" https://github.com/dlt-green/node-installer-docker/releases/download/v.1.5.0/wasp_iota.tar.gz
  fi

  # disable auto-removing of installer script
  sed -i "s/sudo rm node-installer.sh -f/echo Skipped auto-remove/g" "${testInstaller}"

  # update VRSN and BUILD
  sed -i "s/^VRSN=.*/VRSN=\"dev-latest\"/g" "${testInstaller}"
  sed -i "s/^BUILD=.*/BUILD=\"$(TZ=CET date +%Y%m%d_%H%M%S)\"/g" "${testInstaller}"

  # enable mixed installs (iota and shimmer)
  sed -i "s/^CheckIota() {/CheckIota() { return 0;/g" "${testInstaller}"
  sed -i "s/^CheckShimmer() {/CheckShimmer() { return 0;/g" "${testInstaller}"

  # set package download url
  sed -i "s/https:\/\/github.com\/dlt-green\/node-installer-docker\/releases\/download\/\$VRSN/http:\/\/localhost:8040/g" "${testInstaller}"

  # update checksums
  sed -i "s/IotaGoshimmerHash=.*/IotaGoshimmerHash='$(shasum -a 256 ./build/iota-goshimmer.tar.gz | cut -d ' ' -f 1)'/g" "${testInstaller}"
  sed -i "s/IotaHornetHash=.*/IotaHornetHash='$(shasum -a 256 ./build/iota-hornet.tar.gz | cut -d ' ' -f 1)'/g" "${testInstaller}"
  sed -i "s/IotaWaspHash=.*/IotaWaspHash='$(shasum -a 256 ./build/iota-wasp.tar.gz | cut -d ' ' -f 1)'/g" "${testInstaller}"
  sed -i "s/ShimmerHornetHash=.*/ShimmerHornetHash='$(shasum -a 256 ./build/shimmer-hornet.tar.gz | cut -d ' ' -f 1)'/g" "${testInstaller}"
  sed -i "s/ShimmerWaspHash=.*/ShimmerWaspHash='$(shasum -a 256 ./build/shimmer-wasp.tar.gz | cut -d ' ' -f 1)'/g" "${testInstaller}"
  sed -i "s/PipeHash=.*/PipeHash='$(shasum -a 256 ./build/pipe.tar.gz | cut -d ' ' -f 1)'/g" "${testInstaller}"

  shasum -a 256 "${testInstaller}" | cut -d ' ' -f 1 > "${BUILD_DIR}/checksum.txt"

  # create alias to start test installer via dlt.green-test
  absoluteBuildDir=$(readlink -f "${BUILD_DIR}")
  testInstallerAliasLine=$(awk "/alias dlt.green-test/{ print NR; exit }" ~/.bash_aliases)
  if [[ ! -z "${testInstallerAliasLine}" ]]; then
    sed -i "/alias dlt.green-test/d" ~/.bash_aliases
  fi
  echo "alias dlt.green-test=\"(cd '${absoluteBuildDir}'; sudo sh test-installer.sh)\"" >> ~/.bash_aliases
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
  iwatch \
    -r \
    -e default \
    -t ".*\.(sh|yml|md|env)" \
    -X ".*(assets|data|\.git|build|build.sh).*" \
    -c "./devserver.sh '%f'; echo '---'" \
    .
}

guard_iwatch_installed () {
  if [ "$(dpkg -l | awk '/iwatch/ {print }'|wc -l)" -ge 1 ]; then
    echo "iWatch is installed"
  else
    sudo apt-get install iwatch
  fi
}

modifiedFile=$1

if [ ! -z "${modifiedFile}" ]; then
  nodes=$(echo ${modifiedFile} | cut -d '/' -f 2)
  if [[ $nodes == "common" ]]; then
    nodes="all"
  elif [[ "$nodes" == "wasp" ]]; then
    # network independent packages
    nodes="shimmer-wasp"
  elif [[ ! ${PACKAGE_DIRS} =~ ${nodes} ]]; then
    echo "Nothing to build for modified file: ${modifiedFile}"
    exit 0
  fi
else
  guard_env
  guard_iwatch_installed

  ./build.sh --all
  prepare_test_installer
  start_devserver
fi

if [ "${nodes}" == "all" ]; then
  ./build.sh --all
else
  for node in ${nodes//,/ }; do
    ./build.sh --nodes ${node};
  done
fi

prepare_test_installer