#!/bin/bash

# parameters:
#   --uninstall ... to remove alias
#   --bashAliases ... to specify location of .bash_aliases file (used internally to loop through elevate_to_root)

set -e
source ../common/scripts/prepare_docker_functions.sh

elevate_to_root

scriptDir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
dataDir="${IOTA_CORE_DATA_DIR:-$scriptDir/data}"

prepare_data_dir "${dataDir}" "wallet-cli"

# use bashAliases parameter value or fallback to user home
bashAliases=$(get_parameter_value "--bashAliases" "$@")
if [ "${bashAliases}" == "" ]; then
  bashAliases=$(realpath  ~/.bash_aliases)
fi

# alias creation/deletion has to be done before elevating to root
if ! is_elevated_to_root; then
  if is_parameter_present "--uninstall" "$@"; then
    echo "Deleting alias in ${bashAliases}..."
    sed -i '/# DLT.GREEN WALLET-CLI/d' "${bashAliases}" && \
    sed -i '/alias wallet=/d' "${bashAliases}" && \
    echo "  success"
    exit 0
  else
    echo -e "Creating/updating wallet alias in ${bashAliases}..."
    escapedScriptDir=${scriptDir//\//\\\/}
    fgrep -q "alias wallet=" "${bashAliases}" >/dev/null 2>&1 || \
      ( \
        if [ "$(tail -1 ${bashAliases})" != "" ]; then echo "" >> "${bashAliases}"; fi && \
        echo -e "# DLT.GREEN WASP-CLI\nalias wallet=" >> "${bashAliases}" \
      )
    if [ -f "${bashAliases}" ]; then sed -i "s/alias wallet=.*/alias wallet=\"${escapedScriptDir}\/wallet-cli-wrapper.sh\"/g" "${bashAliases}"; fi
    echo -e "  success\n"
  fi

  # bashAliases is looped through to sudo call to show correct path on output at end of script
  elevate_to_root "$@" "--bashAliases=${bashAliases}"
fi

check_env
source .env

print_line 120
echo -e "${OUTPUT_PURPLE_UNDERLINED}ALIAS${OUTPUT_RESET}"
echo -e "An alias 'wallet' has been created in ${bashAliases}."
echo -e "It will be available on next login or you can also execute the following command to activate it immediately:\n"
echo -e "  ${OUTPUT_PURPLE}source ${bashAliases}${OUTPUT_RESET}"
print_line 120
echo -e "${OUTPUT_GREEN}wallet is now ready to be used${OUTPUT_RESET}"
