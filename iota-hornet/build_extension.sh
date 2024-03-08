#!/bin/bash
echo "Updating configs in assets dir with files from iotaledger repo"
curl -L -s -o "./assets/config/config_mainnet.json" "https://raw.githubusercontent.com/iotaledger/hornet/production/config_mainnet.json"
curl -L -s -o "./assets/config/config_testnet.json" "https://raw.githubusercontent.com/iotaledger/hornet/production/config_testnet.json"