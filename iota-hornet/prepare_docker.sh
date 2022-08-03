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
dataDir="${HORNET_DATA_DIR:-$scriptDir/data}"
hornetImage="dltgreen/iota-hornet:$HORNET_VERSION"
configFilenameInContainer="config.json"
if [[ "$HORNET_NETWORK" != "" && "$HORNET_NETWORK" != "mainnet" ]]; then
  configFilenameInContainer="config_${HORNET_NETWORK}.json"
fi
configFilename="config-${HORNET_NETWORK:-mainnet}.json"
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
 if [[ -z $HORNET_SSL_CERT || -z $HORNET_SSL_KEY ]]; then
   echo "HORNET_SSL_CERT and HORNET_SSL_KEY must be set"
   exit -1
 fi
fi


# Prepare data directory
if [[ ! -z $HORNET_NETWORK ]] && [[ "$HORNET_NETWORK" != "mainnet" && "$HORNET_NETWORK" != "devnet" ]]; then
  echo "Invalid HORNET_NETWORK: $HORNET_NETWORK"
  exit -1
fi

mkdir -p "${dataDir}"
mkdir -p "${dataDir}/config"
mkdir -p "${dataDir}/storage/${HORNET_NETWORK:-mainnet}"
mkdir -p "${dataDir}/p2pstore/${HORNET_NETWORK:-mainnet}"
mkdir -p "${dataDir}/snapshots/${HORNET_NETWORK:-mainnet}"
mkdir -p "${dataDir}/letsencrypt"

if [[ "$OSTYPE" != "darwin"* ]]; then
  chown -R 65532:65532 "${dataDir}"
fi


# Extract default config from image
if [ -z "$(docker images | grep dltgreen/iota-hornet | grep $HORNET_VERSION)" ]; then
  echo "Pulling docker image $hornetImage..."
  docker pull $hornetImage >/dev/null 2>&1
fi

echo "Generating config..."
rm -Rf $(dirname "$configPath")/$configFilename
docker rm -f iota-hornet-tmp >/dev/null 2>&1
docker create --name iota-hornet-tmp $hornetImage >/dev/null 2>&1
docker cp iota-hornet-tmp:/app/$configFilenameInContainer "$configPath"
docker rm -f iota-hornet-tmp >/dev/null 2>&1


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

set_config ".p2p.bindMultiAddresses"                 "[\"/ip4/0.0.0.0/tcp/${HORNET_GOSSIP_PORT:-15600}\", \"/ip6/::/tcp/${HORNET_GOSSIP_PORT:-15600}\"]"
set_config ".p2p.autopeering.bindAddress"            "\"0.0.0.0:${HORNET_AUTOPEERING_PORT:-14626}\""
set_config ".dashboard.bindAddress"                  "\"0.0.0.0:8081\""
set_config ".db.path"                                "\"/app/storage\""
set_config ".snapshots.fullPath"                     "\"/app/snapshots/full_snapshot.bin\""
set_config ".snapshots.deltaPath"                    "\"/app/snapshots/delta_snapshot.bin\""
set_config ".node.enablePlugins"                     "[\"autopeering\", \"participation\", \"mqtt\", \"prometheus\"]"
set_config ".dashboard.auth.username"                "\"${DASHBOARD_USERNAME:-admin}\""
set_config ".dashboard.auth.passwordHash"            "\"$DASHBOARD_PASSWORD\""
set_config ".dashboard.auth.passwordSalt"            "\"$DASHBOARD_SALT\""
set_config ".pruning.size.targetSize"                "\"${HORNET_PRUNING_TARGET_SIZE:-64GB}\""
set_config ".p2p.db.path"                            "\"/app/p2pstore\""

set_config_conditionally "HORNET_PRUNING_MAX_MILESTONES_TO_KEEP" ".pruning.milestones.maxMilestonesToKeep"
if [ ! -z "HORNET_PRUNING_MAX_MILESTONES_TO_KEEP" ]; then
  set_config ".pruning.milestones.enabled" "true"
fi
rm -f $tmp

echo "Finished"
