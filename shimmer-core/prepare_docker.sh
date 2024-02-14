#!/bin/bash
set -e
source ../common/scripts/prepare_docker_functions.sh

check_env
elevate_to_root

source $(dirname "${0}")/.env

scriptDir=$(dirname "${0}")
dataDir="${IOTA_CORE_DATA_DIR:-$scriptDir/data}"
configFilenameInContainer="config.json"
configFilename="config-${IOTA_CORE_NETWORK:-mainnet}.json"
configPath="${dataDir}/config/${configFilename}"

validate_ssl_config "IOTA_CORE_SSL_CERT" "IOTA_CORE_SSL_KEY"
copy_common_assets

# Validate IOTA_CORE_NETWORK config
if [[ ! -z ${IOTA_CORE_NETWORK} ]] && [[ "${IOTA_CORE_NETWORK}" != "mainnet" ]] && [[ "${IOTA_CORE_NETWORK}" != "testnet" ]]; then
  echo "Invalid IOTA_CORE_NETWORK: ${IOTA_CORE_NETWORK}"
  exit 255
fi

prepare_data_dir "${dataDir}" \
                 "config" \
                 "storage/${IOTA_CORE_NETWORK:-mainnet}" \
                 "p2pstore/${IOTA_CORE_NETWORK:-mainnet}" \
                 "snapshots/${IOTA_CORE_NETWORK:-mainnet}" \
                 "prometheus" \
                 "grafana" \
                 "letsencrypt"

create_docker_network "shimmer"

# Generate config
extract_file_from_image "iotaledger/iota-core" "${IOTA_CORE_VERSION}" "/app/${configFilenameInContainer}" "${configPath}"

echo "Adapting config with values from .env..."
#set_config "${configPath}" ".node.alias"                      "\"${IOTA_CORE_NODE_ALIAS:-IOTA-CORE node}\""
set_config "${configPath}" ".p2p.db.path"                     "\"/app/p2pstore\""
set_config "${configPath}" ".restAPI.jwtAuth.salt"            "\"${RESTAPI_SALT:-$(generate_random_string 80)}\"" "secret"
set_config "${configPath}" ".db.path"                         "\"/app/storage\""
set_config "${configPath}" ".db.pruning.size.targetSize"      "\"${IOTA_CORE_PRUNING_TARGET_SIZE:-64GB}\""
set_config "${configPath}" ".protocol.snapshot.path"          "\"/app/snapshots/snapshot.bin\""
set_config "${configPath}" ".protocol.protocolParametersPath" "\"/app/protocol_parameters.json\""
set_config "${configPath}" ".inx.enabled"                     "true"
set_config "${configPath}" ".inx.bindAddress"                 "\"0.0.0.0:9029\""


rm -f "${tmp}"

echo "Finished"
