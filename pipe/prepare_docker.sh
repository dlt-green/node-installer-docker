#!/bin/bash
set -e
source ../common/scripts/prepare_docker_functions.sh

check_env
elevate_to_root

source $(dirname "${0}")/.env

scriptDir=$(dirname "${0}")
dataDir="${PIPE_DATA_DIR:-${scriptDir}/data}"
configTemplate="${scriptDir}/assets/pipe/config_template.yml"
configTemplateBootstrap="${scriptDir}/assets/pipe/config_template_bootstrap_override.yml"
configFilename="config.yml"
configPath="${dataDir}/config/${configFilename}"

prepare_data_dir "${dataDir}" "config" "storage"

# Validate .env
if [[ -z ${PIPE_SEED} ]]; then
  echo -e "${OUTPUT_RED}Missing mandatory config PIPE_SEED. Execute generate_seed.sh and add configuration to .env.${OUTPUT_RESET}"
  exit 255
fi

if [[ "${PIPE_IS_BOOTSTRAP_NODE}" != true ]] && [[ -z "${PIPE_BOOTSTRAP_NODE_0}" ]]; then
  echo -e "${OUTPUT_RED}This is not a bootstrap node and no other bootstrap node given.${OUTPUT_RESET}"
  exit 255
fi

# Generate config
cp -f $configTemplate $configPath

echo "Adapting config with values from .env..."
sed -i "s|<seed>|${PIPE_SEED}|g" "${configPath}" && echo "  .seed: ****"
sed -i "s|<port>|${PIPE_PORT:-13266}|g" "${configPath}" && echo "  .port: ${PIPE_PORT:-13266}"

if [ "${PIPE_IS_BOOTSTRAP_NODE}" = true ]; then
  sed -i "s|<bootstrap_capability>|- Bootstrap|g" "${configPath}"
  echo "  .capabilities: +Bootstrap"
else
  sed -i "s|<bootstrap_capability>||g" "${configPath}"
fi

echo -e "\nbootstrap_override:" >> "${configPath}"

add_bootstrap_node () {
  local bootstrapNode=$1

  address=$(echo $bootstrapNode | tr -d '"' | cut -d '@' -f 1)
  ipAndPort=$(echo $bootstrapNode | tr -d '"' | cut -d '@' -f 2 | cut -d '~' -f 1)
  dnsAndPort=$(echo $bootstrapNode | tr -d '"' | cut -d '@' -f 2 | cut -d '~' -f 2)

  cat "$configTemplateBootstrap" | sed "s|<address>|${address}|g" | sed "s|<ip_and_port>|${ipAndPort}|g" | sed "s|<dns_and_port>|${dnsAndPort}|g" >> "${configPath}"
  echo "  .bootstrap_override[]: $(echo ${bootstrapNode} | tr -d '"')"
}

if [ "${PIPE_IS_BOOTSTRAP_NODE}" = true ]; then
  selfBootstrapNode=$(${scriptDir}/get_bootstrap_param.sh)
  add_bootstrap_node $selfBootstrapNode
fi
bootstrapNodes=$(get_numbered_env_as_csv "PIPE_BOOTSTRAP_NODE_<>")
for bootstrapNode in $(echo $bootstrapNodes | sed "s/,/ /g"); do add_bootstrap_node $bootstrapNode; done

echo "Finished"
