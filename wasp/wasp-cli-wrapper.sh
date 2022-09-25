#!/bin/bash
set -e
scriptDir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
currentDir=$( pwd )

if [ -f ../common/scripts/prepare_docker_functions.sh ]; then
  source ../common/scripts/prepare_docker_functions.sh
else
  source "${scriptDir}/scripts/prepare_docker_functions.sh"
fi

source "${scriptDir}/.env"

dataDir="${WASP_DATA_DIR:-${scriptDir}/data}"
configPath="${dataDir}/config/wasp-cli.json"
imageTag="dltgreen/wasp-cli:${WASP_VERSION}"

if [ ! -f "${configPath}" ] && ! is_parameter_present "-v" $@; then
  (cd "${scriptDir}" && ./prepare_cli.sh >/dev/null)
  echo -e "Initial wasp-cli config created. Continuing..."
  print_line 120
fi

docker rm -f ${WASP_LEDGER_NETWORK}-wasp.cli &>/dev/null && \
docker run -it --rm \
  --volume "${configPath}:/etc/wasp-cli.json" \
  --volume "${currentDir}:/workdir" \
  --workdir "/workdir" \
  --network "${WASP_LEDGER_NETWORK}" \
  --name "${WASP_LEDGER_NETWORK}-wasp.cli" \
  --entrypoint "wasp-cli" \
  ${imageTag} \
  -c /etc/wasp-cli.json ${@}

# convenience actions
function set_wallet_seed_in_env () {
  walletSeed=$(read_config "${configPath}" ".wallet.seed")
  if [ "${walletSeed}" != "" ]; then
    sudo fgrep -q "WASP_CLI_WALLET_SEED=" "${scriptDir}/.env" >/dev/null 2>&1 || sudo echo "WASP_CLI_WALLET_SEED=" >> "${scriptDir}/.env"
    sudo sed -i "s/WASP_CLI_WALLET_SEED=.*/WASP_CLI_WALLET_SEED=${walletSeed}/g" "${scriptDir}/.env"
    echo -e "${OUTPUT_GREEN}success${OUTPUT_RESET}"
  else
    echo "${OUTPUT_RED}Wallet seed not found in ${configPath}${OUTPUT_RESET}"
  fi
}

if [ ! $# -eq 0 ] && [ "$1" == "init" ]; then
  print_line 120
  echo -e "${OUTPUT_PURPLE_UNDERLINED}PRESERVE WALLET SEED?${OUTPUT_RESET}"
  echo -e ""
  echo -e "You seem to have generated a new wallet seed. Would you like to add/update it in ${scriptDir}/.env"
  echo -e "to preserve it on prepare_cli.sh execution and/or Wasp node update?"
  echo -e ""
  read -p "Proceed? (y/n) " yn
  case $yn in
    y) set_wallet_seed_in_env
       ;;
    *) echo -e "cancelled"
       ;;
  esac
fi