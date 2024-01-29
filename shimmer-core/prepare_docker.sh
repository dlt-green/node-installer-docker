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
                 "indexer/${IOTA_CORE_NETWORK:-mainnet}" \
                 "participation/${IOTA_CORE_NETWORK:-mainnet}" \
                 "dashboard/${IOTA_CORE_NETWORK:-mainnet}" \
                 "prometheus" \
                 "grafana" \
                 "letsencrypt"

create_docker_network "shimmer"

# Generate config
extract_file_from_image "iotaledger/iota-core" "${IOTA_CORE_VERSION}" "/app/${configFilenameInContainer}" "${configPath}"

echo "Adapting config with values from .env..."
set_config "${configPath}" ".node.alias"                  "\"${IOTA_CORE_NODE_ALIAS:-IOTA-CORE node}\""
set_config "${configPath}" ".p2p.bindMultiAddresses"      "[\"/ip4/0.0.0.0/tcp/${IOTA_CORE_GOSSIP_PORT:-15600}\", \"/ip6/::/tcp/${IOTA_CORE_GOSSIP_PORT:-15600}\"]"
set_config "${configPath}" ".p2p.autopeering.bindAddress" "\"0.0.0.0:${IOTA_CORE_AUTOPEERING_PORT:-14626}\""
set_config "${configPath}" ".db.path"                     "\"/app/storage\""
set_config "${configPath}" ".p2p.db.path"                 "\"/app/p2pstore\""
set_config "${configPath}" ".snapshots.fullPath"          "\"/app/snapshots/full_snapshot.bin\""
set_config "${configPath}" ".snapshots.deltaPath"         "\"/app/snapshots/delta_snapshot.bin\""
set_config "${configPath}" ".pruning.size.targetSize"     "\"${IOTA_CORE_PRUNING_TARGET_SIZE:-64GB}\""
set_config "${configPath}" ".p2p.autopeering.enabled"     "true"
set_config "${configPath}" ".restAPI.pow.enabled"         "${IOTA_CORE_POW_ENABLED:-true}"
set_config "${configPath}" ".prometheus.enabled"          "true"
set_config "${configPath}" ".prometheus.bindAddress"      "\"0.0.0.0:9311\""
set_config "${configPath}" ".inx.enabled"                 "true"
set_config "${configPath}" ".inx.bindAddress"             "\"0.0.0.0:9029\""
set_config "${configPath}" ".restAPI.jwtAuth.salt"        "\"${RESTAPI_SALT:-$(generate_random_string 80)}\"" "secret"

set_config_if_present_in_env "${configPath}" "IOTA_CORE_PRUNING_MAX_MILESTONES_TO_KEEP" ".pruning.milestones.maxMilestonesToKeep"
if [ ! -z "${IOTA_CORE_PRUNING_MAX_MILESTONES_TO_KEEP}" ]; then
  set_config "${configPath}" ".pruning.milestones.enabled" "true"
fi
rm -f "${tmp}"

echo "Finished"
