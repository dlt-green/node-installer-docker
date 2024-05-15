#!/bin/bash
set -e
source ../common/scripts/prepare_docker_functions.sh

check_env
elevate_to_root

source $(dirname "${0}")/.env

scriptDir=$(dirname "${0}")
assetsDir="$scriptDir/assets"
dataDir="${HORNET_DATA_DIR:-$scriptDir/data}"
configFilenameInContainer="config.json"
configFilenameInAssets="config_${HORNET_NETWORK:-mainnet}.json"
configFilename="config-${HORNET_NETWORK:-mainnet}.json"
configPath="${dataDir}/config/${configFilename}"
peeringFilename="peering-${HORNET_NETWORK:-mainnet}.json"
peeringFilePath="${dataDir}/config/${peeringFilename}"

validate_ssl_config "HORNET_SSL_CERT" "HORNET_SSL_KEY"
copy_common_assets

# Validate HORNET_NETWORK config
if [[ ! -z ${HORNET_NETWORK} ]] && [[ "${HORNET_NETWORK}" != "mainnet" ]] && [[ "${HORNET_NETWORK}" != "testnet" ]]; then
  echo "Invalid HORNET_NETWORK: ${HORNET_NETWORK}"
  exit 255
fi

prepare_data_dir "${dataDir}" \
                 "config" \
                 "storage/${HORNET_NETWORK:-mainnet}" \
                 "p2pstore/${HORNET_NETWORK:-mainnet}" \
                 "snapshots/${HORNET_NETWORK:-mainnet}" \
                 "indexer/${HORNET_NETWORK:-mainnet}" \
                 "participation/${HORNET_NETWORK:-mainnet}" \
                 "dashboard/${HORNET_NETWORK:-mainnet}" \
                 "prometheus" \
                 "grafana" \
                 "letsencrypt"

create_docker_network "iota"

# Generate config
extract_file_from_image "iotaledger/hornet" "${HORNET_VERSION}" "/app/${configFilenameInContainer}" "${configPath}_fromImage.tmp"
merge_json_files "${configPath}_fromImage.tmp" "${assetsDir}/config/${configFilenameInAssets}" "${configPath}"
rm -f "${configPath}_fromImage.tmp"

echo "Adapting config with values from .env..."
set_config "${configPath}" ".node.alias"                  "\"${HORNET_NODE_ALIAS:-HORNET node}\""
set_config "${configPath}" ".p2p.bindMultiAddresses"      "[\"/ip4/0.0.0.0/tcp/${HORNET_GOSSIP_PORT:-15600}\", \"/ip6/::/tcp/${HORNET_GOSSIP_PORT:-15600}\"]"
set_config "${configPath}" ".p2p.autopeering.bindAddress" "\"0.0.0.0:${HORNET_AUTOPEERING_PORT:-14626}\""
set_config "${configPath}" ".db.path"                     "\"/app/storage\""
set_config "${configPath}" ".p2p.db.path"                 "\"/app/p2pstore\""
set_config "${configPath}" ".snapshots.fullPath"          "\"/app/snapshots/full_snapshot.bin\""
set_config "${configPath}" ".snapshots.deltaPath"         "\"/app/snapshots/delta_snapshot.bin\""
set_config "${configPath}" ".pruning.size.targetSize"     "\"${HORNET_PRUNING_TARGET_SIZE:-64GB}\""
set_config "${configPath}" ".p2p.autopeering.enabled"     "${HORNET_AUTOPEERING_ENABLED:-true}"
set_config "${configPath}" ".restAPI.pow.enabled"         "${HORNET_POW_ENABLED:-true}"
set_config "${configPath}" ".prometheus.enabled"          "true"
set_config "${configPath}" ".prometheus.bindAddress"      "\"0.0.0.0:9311\""
set_config "${configPath}" ".inx.enabled"                 "true"
set_config "${configPath}" ".inx.bindAddress"             "\"0.0.0.0:9029\""
set_config "${configPath}" ".restAPI.jwtAuth.salt"        "\"${RESTAPI_SALT:-$(generate_random_string 80)}\"" "secret"

set_config_if_present_in_env "${configPath}" "HORNET_PRUNING_MAX_MILESTONES_TO_KEEP" ".pruning.milestones.maxMilestonesToKeep"
if [ -n "${HORNET_PRUNING_MAX_MILESTONES_TO_KEEP}" ]; then
  set_config "${configPath}" ".pruning.milestones.enabled" "true"
fi

if [[ "${HORNET_NETWORK:-mainnet}" == "mainnet" ]] && [ -n "${HORNET_SNAPSHOT_MAINNET_FULL_URL}" ] && [ -n "${HORNET_SNAPSHOT_MAINNET_DELTA_URL}" ]; then
  set_config "${configPath}" ".snapshots.downloadURLs[0].full" "\"${HORNET_SNAPSHOT_MAINNET_FULL_URL}\""
  set_config "${configPath}" ".snapshots.downloadURLs[0].delta" "\"${HORNET_SNAPSHOT_MAINNET_DELTA_URL}\""
elif [[ "${HORNET_NETWORK:-mainnet}" == "testnet" ]] && [ -n "${HORNET_SNAPSHOT_TESTNET_FULL_URL}" ] && [ -n "${HORNET_SNAPSHOT_TESTNET_DELTA_URL}" ]; then
  set_config "${configPath}" ".snapshots.downloadURLs[0].full" "\"${HORNET_SNAPSHOT_TESTNET_FULL_URL}\""
  set_config "${configPath}" ".snapshots.downloadURLs[0].delta" "\"${HORNET_SNAPSHOT_TESTNET_DELTA_URL}\""
fi

# Generate peering.json
if [ -d "${peeringFilePath}" ]; then
  rm -Rf "${peeringFilePath}"
fi
generate_peering_json "${peeringFilePath}" "${HORNET_STATIC_NEIGHBORS:-""}"

rm -f "${tmp}"
echo "Finished"
