#!/bin/bash
set -e
source ../common/scripts/prepare_docker_functions.sh

elevate_to_root true

scriptDir=$(dirname "${0}")
dataDir="${PIPE_DATA_DIR:-${scriptDir}/data}"

prepare_data_dir "${dataDir}" "node_data" "storage" &>/dev/null
touch "${dataDir}/config.yml"

output=$(docker compose run --rm pipe --action=keygen)

mnemonicPhrase=$(echo -e "${output}" | grep 'mnemonic phrase' | cut -d ' ' -f 3- | tr -d '\r')
seed=$(echo -e "${output}" | grep 'Seed' | cut -d ' ' -f 2 | tr -d '\r')
address=$(echo -e "${output}" | grep 'Address' | cut -d ' ' -f 2 | tr -d '\r')

jq --null-input \
   --arg mnemonicPhrase "${mnemonicPhrase}" \
   --arg seed "${seed}" \
   --arg address "${address}" \
   '{"address": $address, "seed": $seed, "mnemonicPhrase": $mnemonicPhrase}'
