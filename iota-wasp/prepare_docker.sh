#!/bin/bash
set -e
source ../common/scripts/prepare_docker_functions.sh

check_env
elevate_to_root

source $(dirname "${0}")/.env

scriptDir=$(dirname "${0}")
dataDir="${WASP_DATA_DIR:-${scriptDir}/data}"
configFilename="config.json"
configPath="${dataDir}/config/${configFilename}"
usersConfigFilename="users.json"
usersConfigPath="${dataDir}/config/${usersConfigFilename}"
trustedPeersPath="${dataDir}/waspdb/trusted_peers.json"
chainRegistryPath="${dataDir}/waspdb/chains/chain_registry.json"

validate_ssl_config "WASP_SSL_CERT" "WASP_SSL_KEY"
copy_common_assets

prepare_data_dir "${dataDir}" "config" "waspdb" "waspdb/chains"

create_docker_network "iota"

# Generate config
configUrl="https://raw.githubusercontent.com/iotaledger/wasp/v1.5.1/config_defaults.json"
echo "Downloading config from ${configUrl}..."
curl -L -s -o "${configPath}" "${configUrl}"

echo "Adapting config with values from .env..."
sed -i 's|"waspdb/|"/app/waspdb/|g' "${configPath}"
set_config "${configPath}" ".logger.outputPaths"                       "[\"stdout\"]"
set_config "${configPath}" ".logger.level"                             "\"${WASP_LOG_LEVEL:-info}\""
set_config "${configPath}" ".inx.address"                              "\"hornet:9029\""
set_config "${configPath}" ".peering.port"                             "${WASP_PEERING_PORT:-4000}"
set_config "${configPath}" ".peering.peeringURL"                       "\"${WASP_HOST}:${WASP_PEERING_PORT:-4000}\""
set_config "${configPath}" ".webapi.auth.scheme"                       "\"${WASP_WEBAPI_AUTH_SCHEME:-jwt}\""
set_config "${configPath}" ".webapi.auth.jwt.duration"                 "\"${WASP_JWT_DURATION:-24h}\""
set_config "${configPath}" ".webapi.auth.basic.username"               "\"${DASHBOARD_USERNAME:-wasp}\""
set_config "${configPath}" ".webapi.limits.confirmedStateLagThreshold" "10"
set_config "${configPath}" ".prometheus.bindAddress"                   "\"0.0.0.0:9312\""
set_config "${configPath}" ".db.debugSkipHealthCheck"                  "${WASP_DEBUG_SKIP_HEALTH_CHECK:-false}"
#set_config "${configPath}" ".snapshots.localPath"                      "\"/app/waspdb/snap\""
#set_config "${configPath}" ".snapshots.networkPaths"                   "\"https://???\""

set_config_if_present_in_env "${configPath}" "WASP_PRUNING_MIN_STATES_TO_KEEP" ".stateManager.pruningMinStatesToKeep"

if [ -n "${WASP_IDENTITY_PRIVATE_KEY}" ]; then
  echo "Restore identity..."
  create_wasp_identity_file "${dataDir}/waspdb/identity/identity.key" "${WASP_IDENTITY_PRIVATE_KEY}"
fi

echo "Configure users defined in .env..."
echo "{}" > "${usersConfigPath}"
set_config "${usersConfigPath}" ".users.users[\"${DASHBOARD_USERNAME:-wasp}\"].passwordHash" "\"${DASHBOARD_PASSWORD}\"" "secret"
set_config "${usersConfigPath}" ".users.users[\"${DASHBOARD_USERNAME:-wasp}\"].passwordSalt" "\"${DASHBOARD_SALT}\"" "secret"
set_config "${usersConfigPath}" ".users.users[\"${DASHBOARD_USERNAME:-wasp}\"].permissions"  "[\"write\"]"

echo "Configure trusted peers..."
configure_wasp_trusted_peers "${trustedPeersPath}"

echo "Configure chain access nodes for IotaEVM..."
configure_wasp_chain_access_nodes "${chainRegistryPath}" "IotaEVM" "iota1pzt3mstq6khgc3tl0mwuzk3eqddkryqnpdxmk4nr25re2466uxwm28qqxu5"

echo ""
echo "Finished"
