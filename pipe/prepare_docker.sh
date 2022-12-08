#!/bin/bash
set -e
source ../common/scripts/prepare_docker_functions.sh

check_env
elevate_to_root

source $(dirname "${0}")/.env

scriptDir=$(dirname "${0}")
dataDir="${HORNET_DATA_DIR:-${scriptDir}/data}"
configTemplate="${scriptDir}/assets/pipe/config_template.json"
configFilename="config.json"
configPath="${dataDir}/config/${configFilename}"

prepare_data_dir "${dataDir}" "config" "storage"

# Validate .env
if [[ -z ${PIPE_SEED} ]]; then
  echo -e "${OUTPUT_RED}Missing mandatory config PIPE_SEED${OUTPUT_RESET}"
  exit 255
fi

# Generate config
cp -f $configTemplate $configPath

echo "Adapting config with values from .env..."
set_config "${configPath}" ".seed" "\"${PIPE_SEED}\"" "secret"
set_config "${configPath}" ".port" "${PIPE_PORT:-13266}"

set_array_config_from_numbered_env "${configPath}" ".bootstrap_override" "PIPE_BOOTSTRAP_NODE_<>"

echo "Finished"
