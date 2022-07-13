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
dataDir="${BEE_DATA_DIR:-$scriptDir/data}"
beeImage="iotaledger/bee:$BEE_VERSION"
configFilename="config.chrysalis-${BEE_NETWORK:-mainnet}.json"
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
 if [[ -z $BEE_SSL_CERT || -z $BEE_SSL_KEY ]]; then
   echo "BEE_SSL_CERT and BEE_SSL_KEY must be set"
   exit -1
 fi
fi


# Prepare data directory
if [[ ! -z $BEE_NETWORK ]] && [[ "$BEE_NETWORK" != "mainnet" && "$BEE_NETWORK" != "devnet" ]]; then
  echo "Invalid BEE_NETWORK: $BEE_NETWORK"
  exit -1
fi

mkdir -p "${dataDir}"
mkdir -p "${dataDir}/config"
mkdir -p "${dataDir}/storage"
mkdir -p "${dataDir}/snapshots"
mkdir -p "${dataDir}/letsencrypt"

if [[ "$OSTYPE" != "darwin"* ]]; then
  chown -R 65532:65532 "${dataDir}"
fi


# Extract default config from image
if [ -z "$(docker images | grep iotaledger/bee | grep $BEE_VERSION)" ]; then
  echo "Pulling docker image $beeImage..."
  docker pull $beeImage >/dev/null 2>&1
fi

echo "Generating config..."
rm -Rf $(dirname "$configPath")/$configFilename
docker create --name iota-bee-tmp $beeImage >/dev/null 2>&1
docker cp iota-bee-tmp:/app/$configFilename "$configPath"
docker rm iota-bee-tmp >/dev/null 2>&1


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
  echo "  $1: $2"
  jq "$1=$2" "$configPath" > "$tmp" && mv "$tmp" "$configPath"
}

set_config_conditionally () {
  # param1: name of env variable containing value
  # param2: jsonpath to set value in configuration
  DEFAULT_VALUE=$(read_config "$2")
  if [ ! -z "${!1}" ]; then set_config "$2" "${!1:-$DEFAULT_VALUE}"; else echo "  $2: $DEFAULT_VALUE (default)"; fi
}

set_config ".network.bindAddress"         "\"/ip4/0.0.0.0/tcp/${BEE_GOSSIP_PORT:-15601}\""
set_config ".autopeering.bindAddress"     "\"0.0.0.0:${BEE_AUTOPEERING_PORT:-14636}\""
set_config ".autopeering.enabled"         "true"
set_config ".dashboard.auth.user"         "\"${DASHBOARD_USERNAME:-admin}\""
set_config ".dashboard.auth.passwordHash" "\"$DASHBOARD_PASSWORD\""
set_config ".dashboard.auth.passwordSalt" "\"$DASHBOARD_SALT\""
set_config ".pruning.delay"               "${BEE_PRUNING_DELAY:-60480}"
rm -f $tmp

echo "Finished"
