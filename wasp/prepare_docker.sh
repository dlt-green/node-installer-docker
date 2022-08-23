#!/bin/bash
set -e
source ../common/prepare_docker_functions.sh

check_env
elevate_to_root

source $(dirname "$0")/.env

scriptDir=$(dirname "$0")
dataDir="${WASP_DATA_DIR:-$scriptDir/data}"
configFilename="config.json"
configPath="${dataDir}/config/$configFilename"

# image="dltgreen/wasp:$WASP_VERSION"

validate_ssl_config "WASP_SSL_CERT" "WASP_SSL_KEY"
create_common_assets

# Validate HORNET_NETWORK config
if [[ "$WASP_LEDGER_NETWORK" != "iota" ]] && [[ "$WASP_LEDGER_NETWORK" != "shimmer" ]]; then
  echo "Invalid WASP_LEDGER_NETWORK: $WASP_LEDGER_NETWORK"
  exit -1
fi

prepare_data_dir "$dataDir" "config" "waspdb"

# Generate config
extract_file_from_image "dltgreen/wasp" "$WASP_VERSION" "/etc/wasp_config.json" "$configPath"

echo "Adapting config with values from .env..."
set_config $configPath ".database.directory"      "\"/app/waspdb\""
set_config $configPath ".nanomsg.port"            "${WASP_NANO_MSG_PORT:-5550}"
set_config $configPath ".peering.port"            "${WASP_PEERING_PORT:-4000}"
set_config $configPath ".logger.outputPaths"      "[\"stdout\"]"

# wasp 0.2.5
set_config_if_field_exists $configPath ".dashboard.auth.username" "\"${DASHBOARD_USERNAME:-wasp}\""
set_config_if_field_exists $configPath ".dashboard.auth.password" "\"${DASHBOARD_PASSWORD:-wasp}\""
# wasp 0.3.0
move_rename_config         $configPath ".users.wasp"                                      ".users[\"${DASHBOARD_USERNAME:-wasp}\"]"
set_config_if_field_exists $configPath ".users[\"${DASHBOARD_USERNAME:-wasp}\"].password" "\"${DASHBOARD_PASSWORD:-wasp}\""
set_config_if_field_exists $configPath ".webapi.auth.basic.username"                      "\"${DASHBOARD_USERNAME:-wasp}\""
set_config_if_field_exists $configPath ".webapi.auth.scheme"                              "\"basic\""
set_config_if_field_exists $configPath ".dashboard.auth.basic.username"                   "\"${DASHBOARD_USERNAME:-wasp}\""
set_config_if_field_exists $configPath ".nodeconn.address"                                "\"${WASP_LEDGER_CONNECTION:?WASP_LEDGER_CONNECTION is mandatory}\""
set_config_if_field_exists $configPath ".l1.apiAddress"                                   "\"${WASP_LEDGER_CONNECTION:?WASP_LEDGER_CONNECTION is mandatory}\""
rm -f $tmp

echo "Finished"
