#!/bin/bash

beeImage="iotaledger/bee:latest"
configDevnet="config.chrysalis-devnet.json"
configMainnet="config.chrysalis-mainnet.json"
scriptDir=$(dirname "$0")
configPathMainnet="$scriptDir/data/config/$configMainnet"
configPathDevnet="$scriptDir/data/config/$configDevnet"


if [ ! -f .env ]; then
  cat README.md
  exit 0
fi

if [[ "$OSTYPE" != "darwin"* && "$EUID" -ne 0 ]]; then
  echo "Please run as root or with sudo"
  exit
fi


# Prepare db directory
mkdir -p data
mkdir -p data/config
mkdir -p data/storage
mkdir -p data/snapshots

if [[ "$OSTYPE" != "darwin"* ]]; then
  chown -R 65532:65532 data
fi


# Extract default config from image
rm -rf "$configPathMainnet" "$configPathDevnet"
containerId=$(docker create $beeImage)
docker cp $containerId:/app/$configDevnet "$configPathDevnet"
docker cp $containerId:/app/$configMainnet "$configPathMainnet"
docker rm $containerId


# Update extracted config with values from .env
source .env

tmp=/tmp/config.tmp
for configPath in $configPathMainnet $configPathDevnet; do
  jq ".network.bindAddress=\"/ip4/0.0.0.0/tcp/$BEE_GOSSIP_PORT\"" "$configPath" > "$tmp" && mv "$tmp" "$configPath"
  jq ".autopeering.bindAddress=\"0.0.0.0:$BEE_AUTOPEERING_PORT\"" "$configPath" > "$tmp" && mv "$tmp" "$configPath"
  jq ".autopeering.enabled=true" "$configPath" > "$tmp" && mv "$tmp" "$configPath"
  jq ".dashboard.auth.user=\"$DASHBOARD_USERNAME\"" "$configPath" > "$tmp" && mv "$tmp" "$configPath"
  jq ".dashboard.auth.passwordHash=\"$DASHBOARD_PASSWORD\"" "$configPath" > "$tmp" && mv "$tmp" "$configPath"
  jq ".dashboard.auth.passwordSalt=\"$DASHBOARD_SALT\"" "$configPath" > "$tmp" && mv "$tmp" "$configPath"
  rm -f $tmp
done
