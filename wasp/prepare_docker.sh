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

validate_ssl_config "WASP_SSL_CERT" "WASP_SSL_KEY"
copy_common_assets

# Validate HORNET_NETWORK config
if [[ "${WASP_LEDGER_NETWORK}" != "iota" ]] && [[ "${WASP_LEDGER_NETWORK}" != "shimmer" ]]; then
  echo "Invalid WASP_LEDGER_NETWORK: ${WASP_LEDGER_NETWORK}"
  exit 255
fi

prepare_data_dir "${dataDir}" "config" "waspdb"

create_docker_network "${WASP_LEDGER_NETWORK}"

# Generate config
cp assets/wasp/docker_config.json "${configPath}"

echo "Adapting config with values from .env..."
sed -i 's|"waspdb/|"/app/waspdb/|g' "${configPath}"
set_config "${configPath}" ".logger.outputPaths"            "[\"stdout\"]"
set_config "${configPath}" ".inx.address"                   "\"hornet:9029\""
set_config "${configPath}" ".p2p.identity.privateKey"       "\"${WASP_IDENTITY_PRIVATE_KEY}\""
set_config "${configPath}" ".peering.port"                  "${WASP_PEERING_PORT:-4000}"
set_config "${configPath}" ".peering.peeringURL"            "\"https://${WASP_HOST}:${WASP_PEERING_PORT:-4000}\""
set_config "${configPath}" ".webapi.auth.scheme"            "\"${WASP_WEBAPI_AUTH_SCHEME:-jwt}\""
set_config "${configPath}" ".webapi.auth.jwt.duration"      "\"${WASP_JWT_DURATION:-24h}\""
set_config "${configPath}" ".webapi.auth.basic.username"    "\"${DASHBOARD_USERNAME:-wasp}\""
set_config "${configPath}" ".prometheus.bindAddress"        "\"0.0.0.0:9312\""

echo "Configure users defined in .env..."
echo "{}" > "${usersConfigPath}"
set_config "${usersConfigPath}" ".users.users[\"${DASHBOARD_USERNAME:-wasp}\"].passwordHash" "\"${DASHBOARD_PASSWORD}\"" "secret"
set_config "${usersConfigPath}" ".users.users[\"${DASHBOARD_USERNAME:-wasp}\"].passwordSalt" "\"${DASHBOARD_SALT}\"" "secret"
set_config "${usersConfigPath}" ".users.users[\"${DASHBOARD_USERNAME:-wasp}\"].permissions"  "[\"write\"]"

echo "Finished"
