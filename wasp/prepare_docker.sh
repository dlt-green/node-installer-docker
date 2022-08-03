#!/bin/bash
set -e

if [[ ! -f .env ]] || [[ "$1" == "--help" ]]; then
  cat README.md
  exit 0
fi

if [[ "$OSTYPE" != "darwin"* && "$EUID" -ne 0 ]]; then
  echo "Elevating to root privileges..."
  sudo "$0" "$@"
  exit $?
fi

source $(dirname "$0")/.env

scriptDir=$(dirname "$0")
dataDir="${WASP_DATA_DIR:-$scriptDir/data}"
image="dltgreen/wasp:$WASP_VERSION"
configFilename="config.json"
configPath="${dataDir}/config/$configFilename"


# Prepare for SSL
if [[ ! -z $SSL_CONFIG ]] && [[ "$SSL_CONFIG" != "certs" && "$SSL_CONFIG" != "letsencrypt" ]]; then
  echo "Invalid SSL_CONFIG: $SSL_CONFIG"
  exit -1
fi

if [[ -z $SSL_CONFIG ]] || [[ "$SSL_CONFIG" == "letsencrypt" ]]; then
 if [[ -z $ACME_EMAIL ]]; then
   echo "ACME_EMAIL must be set to use letsencrypt"
   exit -1
 fi
fi

if [[ "$SSL_CONFIG" == "certs" ]]; then
 if [[ -z $WASP_SSL_CERT || -z $WASP_SSL_KEY ]]; then
   echo "WASP_SSL_CERT and WASP_SSL_KEY must be set"
   exit -1
 fi
fi


# Prepare data directory
mkdir -p "${dataDir}"
mkdir -p "${dataDir}/config"
mkdir -p "${dataDir}/waspdb"

if [[ "$OSTYPE" != "darwin"* ]]; then
  chown -R 65532:65532 "${dataDir}"
fi


# Extract default config from image
imageWithoutTag=$(echo $image | cut -d ':' -f 1)
echo $imageWithoutTag
if [ -z "$(docker images | grep $imageWithoutTag | grep $WASP_VERSION)" ]; then
  echo "Pulling docker image $image..."
  docker pull $image >/dev/null 2>&1
fi

echo "Generating config..."
rm -Rf $(dirname "$configPath")/$configFilename
docker rm -f iota-wasp-tmp >/dev/null 2>&1
docker create --name iota-wasp-tmp $image >/dev/null 2>&1
docker cp iota-wasp-tmp:/etc/wasp_config.json "$configPath"
docker rm -f iota-wasp-tmp >/dev/null 2>&1


# Update extracted config with values from .env
tmp=/tmp/config.tmp
read_config () {
  # param1:  jsonpath to read value from configuration
  local value=$(jq "$1" "$configPath")
  echo "$value"
}

set_config () {
  # param1: jsonpath to set value in configuration
  # param2: configuration value
  if [[ ! "$1" =~ .*"password".* ]]; then echo "  $1: $2"; else echo "  $1: *****"; fi
  jq "$1=$2" "$configPath" > "$tmp" && mv "$tmp" "$configPath"
}

set_config_conditionally () {
  # param1: name of env variable containing value
  # param2: jsonpath to set value in configuration
  DEFAULT_VALUE=$(read_config "$2")
  if [ ! -z "${!1}" ]; then set_config "$2" "${!1:-$DEFAULT_VALUE}"; else echo "  $2: $DEFAULT_VALUE (default)"; fi
}

set_config ".database.directory"      "\"/app/waspdb\""
set_config ".nanomsg.port"            "${WASP_NANO_MSG_PORT:-5550}"
set_config ".peering.port"            "${WASP_PEERING_PORT:-4000}"
set_config ".dashboard.auth.username" "\"${DASHBOARD_USERNAME:-wasp}\""
set_config ".dashboard.auth.password" "\"${DASHBOARD_PASSWORD:-wasp}\""
set_config ".nodeconn.address"        "\"${WASP_LEDGER_CONNECTION:?WASP_LEDGER_CONNECTION is mandatory}\""
set_config ".logger.outputPaths"      "[\"stdout\"]"
rm -f $tmp

echo "Finished"
