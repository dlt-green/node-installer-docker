#!/bin/bash
set -e
source ../common/scripts/prepare_docker_functions.sh

check_env
elevate_to_root

source $(dirname "${0}")/.env

scriptDir=$(dirname "${0}")
dataDir="${PIPE_DATA_DIR:-${scriptDir}/data}"
configTemplate="${scriptDir}/assets/pipe/config_template.yml"
configFilename="config.yml"
configPath="${dataDir}/${configFilename}"

prepare_data_dir "${dataDir}" "node_data" "storage"

# Validate .env
if [[ -z ${PIPE_SEED} ]]; then
  echo -e "${OUTPUT_RED}Missing mandatory config PIPE_SEED. Execute generate_seed.sh and add configuration to .env.${OUTPUT_RESET}"
  exit 255
fi

# Determine host IP
hostIp=$(get_host_ip)

# Generate config
rm -Rf "${configPath}"
cp -f "${configTemplate}" "${configPath}"

echo "Adapting config with values from .env..."
sed -i "s|<seed>|${PIPE_SEED}|g" "${configPath}" && echo "  .seed: ****"
sed -i "s|<host>|${hostIp}|g" "${configPath}" && echo "  .host: ${hostIp}"
sed -i "s|<port>|${PIPE_PORT:-13266}|g" "${configPath}" && echo "  .port: ${PIPE_PORT:-13266}"

echo "Finished"
