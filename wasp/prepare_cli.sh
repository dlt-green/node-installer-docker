#!/bin/bash

# parameters:
#   --uninstall ... to remove alias
#   --bashAliases ... to specify location of .bash_aliases file (used internally to loop through elevate_to_root)

set -e
source ../common/scripts/prepare_docker_functions.sh

scriptDir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
dataDir="${WASP_DATA_DIR:-$scriptDir/data}"
configTemplate=assets/wasp-cli.json.template
configFilename="wasp-cli.json"
configPath=$(realpath "${dataDir}/config/${configFilename}")

# use bashAliases parameter value or fallback to user home
bashAliases=$(get_parameter_value "--bashAliases" $@)
if [ "${bashAliases}" == "" ]; then
  bashAliases=$(realpath  ~/.bash_aliases)
fi

# alias creation/deletion has to be done before elevating to root
if ! is_elevated_to_root; then
  if is_parameter_present "--uninstall" $@; then
    echo "Deleting alias in ${bashAliases}..."
    sed -i '/# DLT.GREEN WASP-CLI/d' "${bashAliases}" && \
    sed -i '/alias wasp-cli=/d' "${bashAliases}" && \
    sudo rm -Rf "${configPath}"
    echo "  success"
    exit 0
  else
    echo -e "Creating/updating wasp-cli alias in ${bashAliases}..."
    escapedScriptDir=${scriptDir//\//\\\/}
    fgrep -q "alias wasp-cli=" "${bashAliases}" >/dev/null 2>&1 || \
      ( \
        if [ "$(tail -1 ${bashAliases})" != "" ]; then echo "" >> "${bashAliases}"; fi && \
        echo -e "# DLT.GREEN WASP-CLI\nalias wasp-cli=" >> "${bashAliases}" \
      )
    if [ -f "${bashAliases}" ]; then sed -i "s/alias wasp-cli=.*/alias wasp-cli=\"${escapedScriptDir}\/wasp-cli-wrapper.sh\"/g" "${bashAliases}"; fi
    echo -e "  success\n"
  fi

  # bashAliases is looped through to sudo call to show correct path on output at end of script
  elevate_to_root "$@" "--bashAliases=${bashAliases}"
fi

check_env
source .env

echo -e "\nCreating wasp-cli config..."
rm -Rf "${configPath}" && echo "{}" > "${configPath}"
set_config "${configPath}" ".l1.apiaddress"    "\"http://hornet:14265\""
set_config "${configPath}" ".l1.faucetaddress" "\"${WASP_CLI_FAUCET_ADDRESS:-http://inx-faucet:8091}\""

if [ "${WASP_CLI_WALLET_SEED}" != "" ]; then
  echo -e "  ${OUTPUT_PURPLE}Using wallet seed from .env${OUTPUT_RESET}"
  set_config "${configPath}" ".wallet.seed" "\"${WASP_CLI_WALLET_SEED}\"" "suppress"
fi

echo -e "\nConfiguring committee..."
i=0
while true; do
  api=$(get_env_by_name "WASP_CLI_COMMITTEE_${i}_API")
  nanomsg=$(get_env_by_name "WASP_CLI_COMMITTEE_${i}_NANOMSG")
  peering=$(get_env_by_name "WASP_CLI_COMMITTEE_${i}_PEERING")

  if [ "${api}" == "" ]; then
    if [ ${i} -eq 0 ]; then
      echo -e "  ${OUTPUT_PURPLE}Missing WASP_CLI_COMMITTEE_0_* parameters.${OUTPUT_RESET}"
      echo -e "  ${OUTPUT_PURPLE}Defaulting to local node parameters.${OUTPUT_RESET}"
      api="https://${WASP_HOST}:${WASP_API_PORT}"
      nanomsg="${WASP_HOST}:${WASP_NANO_MSG_PORT}"
      peering="${WASP_HOST}:${WASP_PEERING_PORT}"
    else
      break
    fi
  fi

  if [ "${api}" == "" ] || [ "${nanomsg}" == "" ] || [ "${peering}" == "" ]; then
      echo -e "  ${OUTPUT_RED}Missing one of WASP_CLI_COMMITTEE_${i}_API, WASP_CLI_COMMITTEE_${i}_NANOMSG or WASP_CLI_COMMITTEE_${i}_PEERING.${OUTPUT_RESET}"
      exit 255
  else
    set_config "${configPath}" ".wasp[\"${i}\"].api" "\"${api}\""
    set_config "${configPath}" ".wasp[\"${i}\"].nanomsg" "\"${nanomsg}\""
    set_config "${configPath}" ".wasp[\"${i}\"].peering" "\"${peering}\""
  fi
  i=$((i+1))
done

chown 65532:65532 "${configPath}"

print_line 120
if [ "${WASP_CLI_WALLET_SEED}" == "" ]; then
  echo -e "${OUTPUT_PURPLE_UNDERLINED}WALLET SEED${OUTPUT_RESET}"
  echo -e "If you are using a wallet seed (generated with wasp-cli init) you can add a parameter WASP_CLI_WALLET_SEED in .env"
  echo -e "with the value taken from data/config/wasp-cli.json. This will automatically add that seed on re-execution of this script."
  print_line 120
fi
echo -e "${OUTPUT_PURPLE_UNDERLINED}ALIAS${OUTPUT_RESET}"
echo -e "An alias 'wasp-cli' has been created in ${bashAliases}."
echo -e "It will be available on next login or you can also execute the following command to activate it immediately:\n"
echo -e "  ${OUTPUT_PURPLE}source ${bashAliases}${OUTPUT_RESET}"
print_line 120
echo -e "${OUTPUT_GREEN}wasp-cli is now ready to be used${OUTPUT_RESET}"

