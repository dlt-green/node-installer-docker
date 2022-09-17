#!/bin/bash
set -e
source ../common/scripts/prepare_docker_functions.sh

check_env
elevate_to_root

scriptDir=$(dirname "$0")
dataDir="${WASP_DATA_DIR:-$scriptDir/data}"
configTemplate=assets/wasp-cli.json.template
configFilename="wasp-cli.json"
configPath=$(realpath "${dataDir}/config/$configFilename")

source .env
echo "Creating wasp-cli config..."
rm -Rf $configPath && echo "{}" > $configPath
set_config $configPath ".l1.apiaddress"    "\"http://hornet:14265\""
set_config $configPath ".l1.faucetaddress" "\"http://inx-faucet:8091\""

if [ "$WASP_CLI_WALLET_SEED" != "" ]; then
  echo "  ${OUTPUT_BLUE}Using wallet seed from .env${OUTPUT_RESET}"
  set_config $configPath ".wallet.seed" "\"$WASP_CLI_WALLET_SEED\"" "suppress"
fi

echo "Configuring committee..."
source .env
for committeeApiConfig in $(grep -E "^WASP_CLI_COMMITTEE_[0-9]+_API" .env); do
  committeeConfigNumber=$(echo $committeeApiConfig | cut -d '_' -f 4)
  api=$(grep -E "WASP_CLI_COMMITTEE_${committeeConfigNumber}_API" .env | cut -d '=' -f 2)
  nanomsg=$(grep -E "WASP_CLI_COMMITTEE_${committeeConfigNumber}_NANOMSG" .env | cut -d '=' -f 2)
  peering=$(grep -E "WASP_CLI_COMMITTEE_${committeeConfigNumber}_PEERING" .env | cut -d '=' -f 2)

  set_config $configPath ".wasp[\"${committeeConfigNumber}\"].api" "\"${api}\""
  set_config $configPath ".wasp[\"${committeeConfigNumber}\"].nanomsg" "\"${nanomsg}\""
  set_config $configPath ".wasp[\"${committeeConfigNumber}\"].peering" "\"${peering}\""
done

echo -e "----------"
if [ "$WASP_CLI_WALLET_SEED" == "" ]; then
  echo -e "${OUTPUT_PURPLE_UNDERLINED}HINT:${OUTPUT_RESET}"
  echo -e "If you are using a wallet seed (generated with wasp-cli init) you can add a parameter WASP_CLI_WALLET_SEED in .env"
  echo -e "with the value taken from data/config/wasp-cli.json. This will automatically add that seed on"
  echo -e "re-execution of this script."
  echo -e "----------"
fi
echo -e "${OUTPUT_PURPLE_UNDERLINED}FRIENDLY REMINDER${OUTPUT_RESET}"
echo -e ""
echo -e "Consider to create the following ${OUTPUT_PURPLE}alias${OUTPUT_RESET} (or add it to ~/.bashrc):"
echo -e ""
echo -e "    alias wasp-cli=\"docker run -it --rm -v ${configPath}:/wasp-cli/wasp-cli.json --network ${WASP_LEDGER_NETWORK} wasp-cli:latest wasp-cli\""
echo -e "----------"
echo -e "${OUTPUT_GREEN}wasp-cli prepared successfully${OUTPUT_RESET}"

