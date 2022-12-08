#!/bin/bash
set -e

output=$(docker compose run --rm pipe --action=keygen)

mnemonicPhrase=$(echo -e "${output}" | grep 'mnemonic phrase' | cut -d ' ' -f 3- | tr -d '\r')
seed=$(echo -e "${output}" | grep 'Seed' | cut -d ' ' -f 2 | tr -d '\r')
address=$(echo -e "${output}" | grep 'Address' | cut -d ' ' -f 2 | tr -d '\r')

jq --null-input \
   --arg mnemonicPhrase "${mnemonicPhrase}" \
   --arg seed "${seed}" \
   --arg address "${address}" \
   '{"address": $address, "seed": $seed, "mnemonicPhrase": $mnemonicPhrase}'
