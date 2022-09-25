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

# image="dltgreen/wasp:$WASP_VERSION"

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
if [ "${WASP_VERSION}" == "0.2.5" ] || [ "${WASP_VERSION}" == "0.3.0" ]; then
  extract_file_from_image "dltgreen/wasp" "${WASP_VERSION}" "/etc/wasp_config.json" "${configPath}"
else
  cp assets/wasp/docker_config.yml "${configPath}"
fi

echo "Adapting config with values from .env..."
set_config "${configPath}" ".database.directory" "\"/app/waspdb\""
set_config "${configPath}" ".nanomsg.port"       "${WASP_NANO_MSG_PORT:-5550}"
set_config "${configPath}" ".peering.port"       "${WASP_PEERING_PORT:-4000}"
set_config "${configPath}" ".logger.outputPaths" "[\"stdout\"]"
set_config "${configPath}" ".peering.netid"      "\"${WASP_HOST}:${WASP_PEERING_PORT:-4000}\""

set_config_if_field_exists "${configPath}" ".inx.address"                                           "\"hornet:9029\""
move_rename_config         "${configPath}" ".users.users.wasp"                                      ".users.users[\"${DASHBOARD_USERNAME:-wasp}\"]"
set_config_if_field_exists "${configPath}" ".users.users[\"${DASHBOARD_USERNAME:-wasp}\"].password" "\"${DASHBOARD_PASSWORD:-wasp}\"" "secret"
set_config_if_field_exists "${configPath}" ".webapi.auth.basic.username"                            "\"${DASHBOARD_USERNAME:-wasp}\""
set_config_if_field_exists "${configPath}" ".webapi.auth.scheme"                                    "\"${WASP_WEBAPI_AUTH_SCHEME:-jwt}\""
set_config_if_field_exists "${configPath}" ".dashboard.auth.basic.username"                         "\"${DASHBOARD_USERNAME:-wasp}\""
set_config_if_field_exists "${configPath}" ".webapi.auth.jwt.durationHours"                         "${WASP_JWT_DURATION_HOURS:-24}"
set_config_if_field_exists "${configPath}" ".dashboard.auth.jwt.durationHours"                      "${WASP_JWT_DURATION_HOURS:-24}"

# wasp 0.2.5
set_config_if_field_exists "${configPath}" ".dashboard.auth.username" "\"${DASHBOARD_USERNAME:-wasp}\""
set_config_if_field_exists "${configPath}" ".dashboard.auth.password" "\"${DASHBOARD_PASSWORD:-wasp}\"" "secret"
set_config_if_field_exists "${configPath}" ".nodeconn.address"        "\"${WASP_LEDGER_CONNECTION}\""
# wasp 0.3.0
set_config_if_field_exists "${configPath}" ".l1.inxAddress" "\"hornet:9029\""
rm -f ${tmp}

echo "Finished"
