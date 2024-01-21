#!/bin/bash
set -e
source ../common/scripts/prepare_docker_functions.sh

check_env
elevate_to_root

source $(dirname "${0}")/.env

scriptDir=$(dirname "${0}")
dataDir="${INX_GROUPFI_DATA_DIR:-$scriptDir/data}"
configFilenameInContainer="config.json"
configFilename="config-${INX_GROUPFI_NETWORK:-mainnet}.json"
configPath="${dataDir}/config/${configFilename}"

validate_ssl_config "INX_GROUPFI_SSL_CERT" "INX_GROUPFI_SSL_KEY"
copy_common_assets

# Validate INX_GROUPFI_LEDGER_NETWORK config
if [[ "${INX_GROUPFI_LEDGER_NETWORK}" != "iota" ]] && [[ "${INX_GROUPFI_LEDGER_NETWORK}" != "shimmer" ]]; then
  echo "Invalid INX_GROUPFI_LEDGER_NETWORK: ${INX_GROUPFI_LEDGER_NETWORK}"
  exit 255
fi

# Validate INX_GROUPFI_NETWORK config
if  [[ ! -z "${INX_GROUPFI_NETWORK}" ]] && [[ "${INX_GROUPFI_NETWORK}" != "mainnet" ]] && [[ "${INX_GROUPFI_NETWORK}" != "testnet" ]]; then
  echo "Invalid INX_GROUPFI_LEDGER_NETWORK: ${INX_GROUPFI_LEDGER_NETWORK}"
  exit 255
fi

prepare_data_dir "${dataDir}" "config" "database/${INX_GROUPFI_NETWORK:-mainnet}" "letsencrypt"

create_docker_network "${INX_GROUPFI_LEDGER_NETWORK}"

extract_file_from_image "dltgreen/inx-groupfi" "${INX_GROUPFI_VERSION}" "/app/${configFilenameInContainer}" "${configPath}"

echo "Adapting config with values from .env..."
set_config "${configPath}" ".im.db.path"     "\"/database\""
set_config "${configPath}" ".inx.address"    "\"hornet:9029\""
set_config "${configPath}" ".logger.level"   "\"${INX_GROUPFI_LOGLEVEL:-warn}\""

echo "Finished"
