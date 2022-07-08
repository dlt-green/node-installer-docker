#!/bin/bash

if [[ ! -f .env ]] || [[ "$1" == "--help" ]]; then
  cat README.md
  exit 0
fi

if [[ "$OSTYPE" != "darwin"* && "$EUID" -ne 0 ]]; then
  echo "Please run as root or with sudo"
  exit
fi

source $(dirname "$0")/.env

scriptDir=$(dirname "$0")
dataDir="${GOSHIMMER_DATA_DIR:-$scriptDir/data}"
image="iotaledger/goshimmer:v$GOSHIMMER_VERSION"
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
 if [[ -z $GOSHIMMER_SSL_CERT || -z $GOSHIMMER_SSL_KEY ]]; then
   echo "GOSHIMMER_SSL_CERT and GOSHIMMER_SSL_KEY must be set"
   exit -1
 fi
fi


# Prepare data directory
mkdir -p "${dataDir}"
mkdir -p "${dataDir}/config"
mkdir -p "${dataDir}/mainnetdb"
mkdir -p "${dataDir}/peerdb"
mkdir -p "${dataDir}/letsencrypt"

if [[ "$OSTYPE" != "darwin"* ]]; then
  chown -R 65532:65532 "${dataDir}"
fi


# Extract default config from image
imageWithoutTag=$(echo $image | cut -d ':' -f 1)
echo $imageWithoutTag
if [ -z "$(docker images | grep $imageWithoutTag | grep $GOSHIMMER_VERSION)" ]; then
  echo "Pulling docker image $image..."
  docker pull $image >/dev/null 2>&1
fi

echo "Generating config..."
rm -Rf $(dirname "$configPath")/$configFilename
docker create --name iota-goshimmer-tmp $image >/dev/null 2>&1
docker cp iota-goshimmer-tmp:/app/$configFilename "$configPath"
docker rm iota-goshimmer-tmp >/dev/null 2>&1


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

set_config ".autoPeering.bindAddress"   "\"0.0.0.0:${GOSHIMMER_AUTOPEERING_PORT:-14646}\""
set_config ".gossip.bindAddress"        "\"0.0.0.0:${GOSHIMMER_GOSSIP_PORT:-14666}\""
set_config ".dashboard.bindAddress"     "\"0.0.0.0:8081\""
set_config ".profiling.bindAddress"     "\"0.0.0.0:6061\""
set_config ".prometheus.bindAddress"    "\"0.0.0.0:9311\""
set_config ".webapi.bindAddress"        "\"0.0.0.0:8080\""
set_config ".broadcast.bindAddress"     "\"0.0.0.0:5050\""
set_config ".database.directory"        "\"/app/mainnetdb\""
set_config ".node.peerDBDirectory"      "\"/app/peerdb\""
set_config ".node.enablePlugins"        "[\"prometheus\"]"
set_config ".logger.disableEvents"      "false"
set_config ".manaInitializer.FaucetAPI" "\"http://faucet-01.devnet.shimmer.iota.cafe:8080\""

if [ ! -z "$DASHBOARD_PASSWORD" ]; then
  set_config ".dashboard.basicAuth.enabled"  "true"
  set_config ".dashboard.basicAuth.username" "\"${DASHBOARD_USERNAME:-admin}\""
  set_config ".dashboard.basicAuth.password" "\"${DASHBOARD_PASSWORD}\""
fi
rm -f $tmp

echo "Finished"
