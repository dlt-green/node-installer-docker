#!/bin/bash
scriptDir=$(dirname "${0}")

download() {
  local url="${1}"
  local targetFile="${2}"
  local httpCode
  httpCode=$(curl -L -s -w "%{http_code}" -o "${targetFile}" "${url}")
  if [ "${httpCode}" -ne 200 ]; then
    echo "ERROR: Failed to download ${url}"
    exit 255
  fi
}

echo "Updating configs in assets dir with files from iotaledger repo"
download "https://raw.githubusercontent.com/iotaledger/hornet/production/config_shimmer.json" "${scriptDir}/assets/config/config_mainnet.json"
download "https://raw.githubusercontent.com/iotaledger/hornet/production/config_testnet.json" "${scriptDir}/assets/config/config_testnet.json"
