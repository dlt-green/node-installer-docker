#!/bin/bash
set -e
source ../common/scripts/prepare_docker_functions.sh

check_env
elevate_to_root

source $(dirname "${0}")/.env

scriptDir=$(dirname "${0}")
dataDir="${INX_CHRONICLE_DATA_DIR:-$scriptDir/data}"
configFilename="config-${INX_CHRONICLE_LEDGER_NETWORK}.json"
configPath="${dataDir}/config/${configFilename}"

validate_ssl_config "INX_CHRONICLE_SSL_CERT" "INX_CHRONICLE_SSL_KEY"
copy_common_assets

# Validate INX_CHRONICLE_LEDGER_NETWORK config
if [[ "${INX_CHRONICLE_LEDGER_NETWORK}" != "iota" ]] && [[ "${INX_CHRONICLE_LEDGER_NETWORK}" != "shimmer" ]]; then
  echo "Invalid INX_CHRONICLE_LEDGER_NETWORK: ${INX_CHRONICLE_LEDGER_NETWORK}"
  exit 255
fi

# Validate INX_CHRONICLE_NETWORK config
if  [[ ! -z "${INX_CHRONICLE_NETWORK}" ]] && [[ "${INX_CHRONICLE_NETWORK}" != "mainnet" ]] && [[ "${INX_CHRONICLE_NETWORK}" != "testnet" ]]; then
  echo "Invalid INX_CHRONICLE_LEDGER_NETWORK: ${INX_CHRONICLE_LEDGER_NETWORK}"
  exit 255
fi

prepare_data_dir "${dataDir}" "mongodb/${INX_CHRONICLE_NETWORK:-mainnet}" "influxdb/${INX_CHRONICLE_NETWORK:-mainnet}/storage" "influxdb/${INX_CHRONICLE_NETWORK:-mainnet}/config" "grafana/${INX_CHRONICLE_NETWORK:-mainnet}" 

create_docker_network "${INX_CHRONICLE_LEDGER_NETWORK}"

# Generate identity file
if [[ ! -f "${dataDir}/identity-${INX_CHRONICLE_NETWORK:-mainnet}.key" ]]; then
  sudo openssl genpkey -algorithm ed25519 -out "${dataDir}/identity-${INX_CHRONICLE_NETWORK:-mainnet}.key"
  sudo chown 65532:65532 "${dataDir}/identity-${INX_CHRONICLE_NETWORK:-mainnet}.key"
fi

echo "Finished"
