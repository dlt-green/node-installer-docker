#!/bin/bash
set -e
source ../common/scripts/prepare_docker_functions.sh

check_env
elevate_to_root

source $(dirname "$0")/.env

scriptDir=$(dirname "$0")
dataDir="${BEE_DATA_DIR:-$scriptDir/data}"
configFilename="config.chrysalis-${BEE_NETWORK:-mainnet}.json"
configPath="${dataDir}/config/$configFilename"

validate_ssl_config "BEE_SSL_CERT" "BEE_SSL_KEY"
copy_common_assets

# Validate BEE_NETWORK config
if [[ ! -z $BEE_NETWORK ]] && [[ "$BEE_NETWORK" != "mainnet" && "$BEE_NETWORK" != "devnet" ]]; then
  echo "Invalid BEE_NETWORK: $BEE_NETWORK"
  exit 255
fi

prepare_data_dir "$dataDir" "config" "storage" "snapshots" "letsencrypt"

# Generate config
extract_file_from_image "iotaledger/bee" "$BEE_VERSION" "/app/$configFilename" $configPath

echo "Adapting config with values from .env..."
set_config $configPath ".network.bindAddress"         "\"/ip4/0.0.0.0/tcp/${BEE_GOSSIP_PORT:-15601}\""
set_config $configPath ".autopeering.bindAddress"     "\"0.0.0.0:${BEE_AUTOPEERING_PORT:-14636}\""
set_config $configPath ".autopeering.enabled"         "true"
set_config $configPath ".dashboard.auth.user"         "\"${DASHBOARD_USERNAME:-admin}\""
set_config $configPath ".dashboard.auth.passwordHash" "\"$DASHBOARD_PASSWORD\""
set_config $configPath ".dashboard.auth.passwordSalt" "\"$DASHBOARD_SALT\""
set_config $configPath ".pruning.delay"               "${BEE_PRUNING_DELAY:-60480}"
set_config $configPath ".restApi.featureProofOfWork"  "${BEE_POW_ENABLED:-false}"
rm -f $tmp

echo "Finished"
