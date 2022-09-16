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

echo "Creating wasp-cli config..."
rm -Rf $configPath && cp $configTemplate $configPath
source .env
if [ "$WASP_CLI_WALLET_SEED" != "" ]; then
  echo "  Using wallet seed from .env"
  set_config $configPath ".wallet.seed" "\"$WASP_CLI_WALLET_SEED\"" "suppress"
else
  echo "  Generating new wallet seed"
  echo "  -----"
  docker run --rm -v "${configPath}":/wasp-cli/wasp-cli.json wasp-cli:latest wasp-cli init | while read line ; do echo -e "    ${OUTPUT_RED}$line${OUTPUT_RESET}"; done
  echo "  -----"

  walletSeed=$(read_config "$configPath" ".wallet.seed")
  echo "WASP_CLI_WALLET_SEED=$walletSeed" >> $scriptDir/.env
fi

echo "Configuring committee..."
source .env
for committeeApiConfig in $(grep -E "WASP_CLI_COMMITTEE_[0-9]+_API" .env); do
  committeeConfigNumber=$(echo $committeeApiConfig | cut -d '_' -f 4)
  api=$(grep -E "WASP_CLI_COMMITTEE_${committeeConfigNumber}_API" .env | cut -d '=' -f 2)
  nanomsg=$(grep -E "WASP_CLI_COMMITTEE_${committeeConfigNumber}_NANOMSG" .env | cut -d '=' -f 2)
  peering=$(grep -E "WASP_CLI_COMMITTEE_${committeeConfigNumber}_PEERING" .env | cut -d '=' -f 2)

  set_config $configPath ".wasp[\"${committeeConfigNumber}\"].api" "\"${api}\""
  set_config $configPath ".wasp[\"${committeeConfigNumber}\"].nanomsg" "\"${nanomsg}\""
  set_config $configPath ".wasp[\"${committeeConfigNumber}\"].peering" "\"${peering}\""
done

echo -e "----------"
echo -e "${OUTPUT_PURPLE_UNDERLINED}FRIENDLY REMINDER${OUTPUT_RESET}"
echo -e ""
echo -e "Consider to create the following ${OUTPUT_PURPLE}alias${OUTPUT_RESET} (or add it to ~/.bashrc):"
echo -e ""
echo -e "    alias wasp-cli=\"docker run -it --rm -v ${configPath}:/wasp-cli/wasp-cli.json --network ${WASP_LEDGER_NETWORK} wasp-cli:latest wasp-cli\""
echo -e "----------"
echo -e "${OUTPUT_GREEN}wasp-cli prepared successfully${OUTPUT_RESET}"

