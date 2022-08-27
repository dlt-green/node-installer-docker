#!/bin/bash
set -e
source ../common/scripts/prepare_docker_functions.sh

check_env
elevate_to_root

source $(dirname "$0")/.env

scriptDir=$(dirname "$0")
dataDir="${GOSHIMMER_DATA_DIR:-$scriptDir/data}"
configFilename="config.json"
configPath="${dataDir}/config/$configFilename"

validate_ssl_config "GOSHIMMER_SSL_CERT" "GOSHIMMER_SSL_KEY"
copy_common_assets

prepare_data_dir "$dataDir" "config" "mainnetdb" "peerdb" "letsencrypt" "snapshots"

if [ ! -e "$dataDir/snapshots/snapshot.bin" ]; then
  extract_file_from_image "iotaledger/goshimmer" "v$GOSHIMMER_VERSION" "/app/snapshot.bin" "$dataDir/snapshots/snapshot.bin"
fi

if [[ "$OSTYPE" != "darwin"* ]]; then
  chown -R 65532:65532 "${dataDir}"
fi

# Generate config
extract_file_from_image "iotaledger/goshimmer" "v$GOSHIMMER_VERSION" "/app/$configFilename" "$configPath"

echo "Adapting config with values from .env..."
set_config $configPath ".autoPeering.bindAddress"   "\"0.0.0.0:${GOSHIMMER_AUTOPEERING_PORT:-14646}\""
set_config $configPath ".gossip.bindAddress"        "\"0.0.0.0:${GOSHIMMER_GOSSIP_PORT:-14666}\""
set_config $configPath ".dashboard.bindAddress"     "\"0.0.0.0:8081\""
set_config $configPath ".profiling.bindAddress"     "\"0.0.0.0:6061\""
set_config $configPath ".prometheus.bindAddress"    "\"0.0.0.0:9311\""
set_config $configPath ".webapi.bindAddress"        "\"0.0.0.0:8080\""
set_config $configPath ".broadcast.bindAddress"     "\"0.0.0.0:5050\""
set_config $configPath ".database.directory"        "\"/app/mainnetdb\""
set_config $configPath ".node.peerDBDirectory"      "\"/app/peerdb\""
set_config $configPath ".node.enablePlugins"        "[\"prometheus\", \"txstream\"]"
set_config $configPath ".node.disablePlugins"       "[\"portcheck\"]"
set_config $configPath ".logger.disableEvents"      "false"
set_config $configPath ".manaInitializer.FaucetAPI" "\"http://faucet-01.devnet.shimmer.iota.cafe:8080\""

if [ ! -z "$DASHBOARD_PASSWORD" ]; then
  set_config $configPath ".dashboard.basicAuth.enabled"  "true"
  set_config $configPath ".dashboard.basicAuth.username" "\"${DASHBOARD_USERNAME:-admin}\""
  set_config $configPath ".dashboard.basicAuth.password" "\"${DASHBOARD_PASSWORD}\""
fi
rm -f $tmp

echo "Finished"
