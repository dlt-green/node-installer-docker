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


# Prepare db directory
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
echo "Generating config..."
rm -f $(dirname "$configPath")/$configFilename
containerId=$(docker create $beeImage)
docker cp $containerId:/app/$configFilename "$configPath"
docker rm $containerId


# Update extracted config with values from .env
tmp=/tmp/config.tmp
jq ".network.bindAddress=\"/ip4/0.0.0.0/tcp/${BEE_GOSSIP_PORT:-15601}\"" "$configPath" > "$tmp" && mv "$tmp" "$configPath"
jq ".autopeering.bindAddress=\"0.0.0.0:${BEE_AUTOPEERING_PORT:-14636}\"" "$configPath" > "$tmp" && mv "$tmp" "$configPath"
jq ".autopeering.enabled=true" "$configPath" > "$tmp" && mv "$tmp" "$configPath"
jq ".dashboard.auth.user=\"${DASHBOARD_USERNAME:-admin}\"" "$configPath" > "$tmp" && mv "$tmp" "$configPath"
jq ".dashboard.auth.passwordHash=\"$DASHBOARD_PASSWORD\"" "$configPath" > "$tmp" && mv "$tmp" "$configPath"
jq ".dashboard.auth.passwordSalt=\"$DASHBOARD_SALT\"" "$configPath" > "$tmp" && mv "$tmp" "$configPath"
rm -f $tmp

echo "Finished"
