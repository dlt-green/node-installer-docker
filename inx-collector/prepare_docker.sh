#!/bin/bash
set -e
source ../common/scripts/prepare_docker_functions.sh

check_env
elevate_to_root

source $(dirname "${0}")/.env

scriptDir=$(dirname "${0}")
dataDir="${INX_COLLECTOR_DATA_DIR:-$scriptDir/data}"
configFilename="config-${INX_COLLECTOR_LEDGER_NETWORK}.json"
configPath="${dataDir}/config/${configFilename}"

validate_ssl_config "INX_COLLECTOR_SSL_CERT" "INX_COLLECTOR_SSL_KEY"
copy_common_assets

# Validate HORNET_NETWORK config
if [[ "${INX_COLLECTOR_LEDGER_NETWORK}" != "iota" ]] && [[ "${INX_COLLECTOR_LEDGER_NETWORK}" != "shimmer" ]]; then
  echo "Invalid INX_COLLECTOR_LEDGER_NETWORK: ${INX_COLLECTOR_LEDGER_NETWORK}"
  exit 255
fi

prepare_data_dir "${dataDir}" "config" "storage"

create_docker_network "${INX_COLLECTOR_LEDGER_NETWORK}"

# Generate config
extract_file_from_image "giordyfish/inx-collector" "${INX_COLLECTOR_VERSION}" "/app/config.json" "${configPath}"

echo "Adapting config with values from .env..."
set_config "${configPath}" ".inx.address"                         "\"hornet:9029\""
set_config "${configPath}" ".restAPI.bindAddress"                 "\"inx-collector:9030\""
set_config "${configPath}" ".storage.endpoint"                    "\"${INX_COLLECTOR_STORAGE_ENDPOINT:-minio:9000}\""
set_config "${configPath}" ".storage.accessKeyId"                 "\"${INX_COLLECTOR_STORAGE_ACCESS_ID:-}\""
set_config "${configPath}" ".storage.secretAccessKey"             "\"${INX_COLLECTOR_STORAGE_SECRET_KEY:-}\""
set_config "${configPath}" ".storage.region"                      "\"${INX_COLLECTOR_STORAGE_REGION:-eu-south-1}\""
set_config "${configPath}" ".storage.objectExtension"             "\"${INX_COLLECTOR_STORAGE_EXTENSION:-}\""
set_config "${configPath}" ".storage.secure"                      "\"${INX_COLLECTOR_STORAGE_SECURE:-false}\""
set_config "${configPath}" ".storage.defaultBucketName"           "\"shimmer-${HORNET_NETWORK:-mainnet}-default\""
set_config "${configPath}" ".storage.defaultBucketExpirationDays" "\"${INX_COLLECTOR_STORAGE_DEFAULT_EXPIRATION:-30}\""
set_config "${configPath}" ".POI.hostUrl"                         "\"${NX_COLLECTOR_POI_URL:-http://inx-poi:9687}\""
set_config "${configPath}" ".POI.isPlugin"                        "\"${INX_COLLECTOR_POI_PLUGIN:-true}\""
set_config "${configPath}" ".listener.filters"                    "\"${INX_COLLECTOR_LISTENER_FILTERS:-}\""

echo "Finished"
