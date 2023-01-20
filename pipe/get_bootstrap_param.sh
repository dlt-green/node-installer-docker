#!/bin/bash

scriptDir=$(dirname "${0}")
dataDir="${PIPE_DATA_DIR:-${scriptDir}/data}"

source $(dirname "${0}")/.env

if [[ -z ${PIPE_PORT} ]] || [[ -z "${PIPE_ADDRESS}" ]]; then
  echo "${OUTPUT_RED}Missing at least one of parameters PIPE_HOST_IP, PIPE_PORT or PIPE_ADDRESS. Execute generate_seed.sh first and set parameters accordingly.${OUTPUT_RESET}"
  exit 255
fi

if [[ ! -f "${dataDir}/config/config.yml" ]] || [[ ! -d "${dataDir}/storage" ]]; then
  echo "${OUTPUT_RED}Failed because data dir does not yet exist. Execute generate_seed.sh and/or prepare_docker.sh first.${OUTPUT_RESET}"
  exit 255
fi

output=$(docker compose run --rm pipe --action=capability_group -c /etc/pipe/config.yml)
outputFromJSON=$(echo -e "${output}" | grep -E "JSON:" -A9999 | tail -n +2)
endOfJsonLine=$(echo -e "${outputFromJSON}" | grep -En '^}' | cut -d ':' -f 1)
jsonOutput=$(echo -e "${outputFromJSON}" | sed -n "1,${endOfJsonLine}p")
bootstrapUrl=$(echo -e "${jsonOutput}" | jq -r '.[][].data' | grep '^[^127.0.0.1;]')

hostIp=$(dig @resolver1.opendns.com myip.opendns.com +short)

echo "${PIPE_ADDRESS}@${hostIp}:${PIPE_PORT}~${bootstrapUrl}"