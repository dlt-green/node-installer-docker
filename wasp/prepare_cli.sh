#!/bin/bash
set -e
source ../common/scripts/prepare_docker_functions.sh

scriptDir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
dataDir="${WASP_DATA_DIR:-$scriptDir/data}"
configTemplate=assets/wasp-cli.json.template
configFilename="wasp-cli.json"
configPath=$(realpath "${dataDir}/config/$configFilename")

if [ ! $# -eq 0 ] && [ "$1" == "--uninstall" ]; then
  echo "Deleting alias..."
  sed -i '/alias wasp-cli=/d' ~/.bash_aliases && echo "  success"
  exit 0
fi

check_env
elevate_to_root

source .env

echo -e "\nCreating wasp-cli config..."
rm -Rf $configPath && echo "{}" > $configPath
set_config $configPath ".l1.apiaddress"    "\"http://hornet:14265\""
set_config $configPath ".l1.faucetaddress" "\"http://inx-faucet:8091\""

if [ "$WASP_CLI_WALLET_SEED" != "" ]; then
  echo -e "  ${OUTPUT_BLUE}Using wallet seed from .env${OUTPUT_RESET}"
  set_config $configPath ".wallet.seed" "\"$WASP_CLI_WALLET_SEED\"" "suppress"
fi

echo -e "\nConfiguring committee..."
i=0
while true; do
  api=$(get_env_by_name "WASP_CLI_COMMITTEE_${i}_API")
  nanomsg=$(get_env_by_name "WASP_CLI_COMMITTEE_${i}_NANOMSG")
  peering=$(get_env_by_name "WASP_CLI_COMMITTEE_${i}_PEERING")

  if [ "$api" == "" ]; then
    if [ $i -eq 0 ]; then
      echo -e "  ${OUTPUT_BLUE}Missing WASP_CLI_COMMITTEE_0_* parameters. Defaulting to local node parameters.${OUTPUT_RESET}"
      api="https://$WASP_HOST:$WASP_API_PORT"
      nanomsg="$WASP_HOST:$WASP_NANO_MSG_PORT"
      peering="$WASP_HOST:$WASP_PEERING_PORT"
    else
      break
    fi
  fi

  if [ "$api" == "" ] || [ "$nanomsg" == "" ] || [ "$peering" == "" ]; then
      echo -e "  ${OUTPUT_RED}Missing one of WASP_CLI_COMMITTEE_${i}_API, WASP_CLI_COMMITTEE_${i}_NANOMSG or WASP_CLI_COMMITTEE_${i}_PEERING.${OUTPUT_RESET}"
      exit 255
  else
    set_config $configPath ".wasp[\"${i}\"].api" "\"${api}\""
    set_config $configPath ".wasp[\"${i}\"].nanomsg" "\"${nanomsg}\""
    set_config $configPath ".wasp[\"${i}\"].peering" "\"${peering}\""
  fi
  i=$((i+1))
done

chown 65532:65532 $configPath

userHome=$(getent passwd "$(logname)" | cut -d: -f6)
echo -e "\nCreating/updating wasp-cli alias in ${userHome}/.bash_aliases..."
escapedScriptDir=${scriptDir//\//\\\/}
fgrep -q "alias wasp-cli=" "$userHome/.bash_aliases" >/dev/null 2>&1 || echo "alias wasp-cli=" >> "$userHome/.bash_aliases"
if [ -f "$userHome/.bash_aliases" ]; then sed -i "s/alias wasp-cli=.*/alias wasp-cli=\"${escapedScriptDir}\/wasp-cli-wrapper.sh\"/g" "$userHome/.bash_aliases"; fi

print_line 120
if [ "$WASP_CLI_WALLET_SEED" == "" ]; then
  echo -e "${OUTPUT_PURPLE_UNDERLINED}WALLET SEED${OUTPUT_RESET}"
  echo -e "If you are using a wallet seed (generated with wasp-cli init) you can add a parameter WASP_CLI_WALLET_SEED in .env"
  echo -e "with the value taken from data/config/wasp-cli.json. This will automatically add that seed on re-execution of this script."
  print_line 120
fi
echo -e "${OUTPUT_PURPLE_UNDERLINED}ALIAS${OUTPUT_RESET}"
echo -e "An alias 'wasp-cli' has been created in ~/.bash_aliases."
echo -e "It will be available on next login or you can also execute the following command to activate it immediately: ${OUTPUT_PURPLE}source ~/.bash_aliases${OUTPUT_RESET}"
print_line 120
echo -e "${OUTPUT_GREEN}wasp-cli is now ready to be used${OUTPUT_RESET}"

