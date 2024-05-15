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
                 "grafana" \
                 "prometheus" \
                 "database/${IOTA_CORE_NETWORK:-mainnet}" \
                 "snapshots/${IOTA_CORE_NETWORK:-mainnet}" \
                 "dashboard/${IOTA_CORE_NETWORK:-mainnet}" \
                 "p2p/${IOTA_CORE_NETWORK:-mainnet}" \
                 "letsencrypt"

# create empty peering json if it does not exist yet
if [ -d "${dataDir}/config/peering-${IOTA_CORE_NETWORK:-mainnet}.json" ]; then
  rm -rf "${dataDir}/config/peering-${IOTA_CORE_NETWORK:-mainnet}.json"
fi
if [ ! -f "${dataDir}/config/peering-${IOTA_CORE_NETWORK:-mainnet}.json" ]; then
  echo "{\"peers\": []}" > "${dataDir}/config/peering-${IOTA_CORE_NETWORK:-mainnet}.json"
fi

create_docker_network "shimmer"

# Generate config
extract_file_from_image "iotaledger/iota-core" "${IOTA_CORE_VERSION}" "/app/${configFilenameInContainer}" "${configPath}"

echo "Adapting config with values from .env..."
set_config "${configPath}" ".p2p.identityPrivateKeyFilePath"         "\"/app/data/p2p/identity.key\""
set_config "${configPath}" ".profiling.bindAddress"                  "\"0.0.0.0:6060\""
set_config "${configPath}" ".debugAPI.db.path"                       "\"/app/data/debug\""
set_config "${configPath}" ".db.path"                                "\"/app/data/database\""
set_config "${configPath}" ".db.pruning.size.targetSize"             "\"${IOTA_CORE_PRUNING_TARGET_SIZE:-64GB}\""
set_config "${configPath}" ".protocol.snapshot.path"                 "\"/app/data/snapshots/snapshot.bin\""
set_config "${configPath}" ".protocol.protocolParametersPath"        "\"/app/data/protocol_parameters.json\""
set_config "${configPath}" ".prometheus.enabled"                     "true"
set_config "${configPath}" ".prometheus.bindAddress"                 "\"0.0.0.0:9311\""
set_config "${configPath}" ".inx.enabled"                            "true"
set_config "${configPath}" ".inx.bindAddress"                        "\"0.0.0.0:9029\""
set_config "${configPath}" ".p2p.autopeering.externalMultiAddresses" "\"/dns/${IOTA_CORE_HOST}/tcp/15600\""

set_array_config "${configPath}" ".p2p.bindMultiAddresses"           "\"/ip4/0.0.0.0/tcp/${IOTA_CORE_GOSSIP_PORT:-15600}\",\"/ip6/::/tcp/${IOTA_CORE_GOSSIP_PORT:-15600}\"" ","
set_array_config "${configPath}" ".p2p.autopeering.bootstrapPeers"   "\"${IOTA_CORE_AUTOPEERING_BOOTSTRAP_PEER:-}\"" ","

# secret things
set_config "${configPath}" ".protocol.baseToken.name"                "\"TST\""
set_config "${configPath}" ".protocol.baseToken.tickerSymbol"        "\"TST\""
set_config "${configPath}" ".protocol.baseToken.unit"                "\"TST\""
set_config "${configPath}" ".protocol.baseToken.subunit"             "\"testies\""
set_config "${configPath}" ".protocol.baseToken.decimals"            "6"
set_config "${configPath}" ".protocol.baseToken.useMetricPrefix"     "false"

rm -f "${tmp}"

echo "Finished"
