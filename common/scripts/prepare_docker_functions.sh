#!/bin/bash
set -e

OUTPUT_RED='\033[0;31m'
OUTPUT_GREEN='\033[0;32m'
OUTPUT_BLUE='\033[0;34m'
OUTPUT_PURPLE='\033[0;35m'
OUTPUT_PURPLE_UNDERLINED='\033[4;35m'
OUTPUT_RESET='\033[0m'

check_env () {
  if [[ ! -f .env ]] || [[ "$1" == "--help" ]]; then
    cat README.md
    exit 0
  fi
}

validate_ssl_config () {
  local sslCertConfigName=$1
  local sslKeyConfigName=$2

  echo "Validating SSL config..."

  if [[ ! -z $SSL_CONFIG ]] && [[ "$SSL_CONFIG" != "certs" && "$SSL_CONFIG" != "letsencrypt" ]]; then
    echo "Invalid SSL_CONFIG: $SSL_CONFIG"
    exit 255
  fi

  if [[ -z $SSL_CONFIG ]] || [[ "$SSL_CONFIG" == "letsencrypt" ]]; then
    if [[ -z $ACME_EMAIL ]]; then
      echo "ACME_EMAIL must be set to use letsencrypt"
      exit 255
    fi
  fi

  if [[ "$SSL_CONFIG" == "certs" ]]; then
    if [[ -z "${!sslCertConfigName}" || -z "${!sslKeyConfigName}" ]]; then
      echo "${sslCertConfigName} and ${sslKeyConfigName} must be set"
      exit 255
    fi
  fi
}

elevate_to_root () {
  local quiet=$1

  if [ "${quiet}" != "true" ]; then echo "Elevating to root privileges..."; fi
  if [[ "$OSTYPE" != "darwin"* && "$EUID" -ne 0 ]]; then
    sudo ELEVATED_TO_ROOT="true" "$0" "$@"
    exit $?
  else
    if [ "${quiet}" != "true" ]; then echo "  root privileges already granted"; fi
  fi
}

is_elevated_to_root () {
  [ "$ELEVATED_TO_ROOT" == "true" ]
}

is_parameter_present () {
  local parameterName=$1

  local i=0;
  for param in "$@"; do
    if [ $i -ne 0 ] && [[ "$param" == *"$parameterName"* ]]; then
      true
      return
    fi
    i=$(($i+1))
  done
  false
}

get_parameter_value () {
  local parameterName=$1

  local i=0;
  for param in "$@"; do
    if [ $i -ne 0 ] && [[ "$param" == *"$parameterName"* ]]; then
      echo $param | cut -d '=' -f 2
      break
    fi
    i=$(($i+1))
  done
}

create_docker_network () {
  local networkName=$1
  
  local existingNetwork=$(docker network ls | tail -n +2 | tr -s ' ' | cut -d ' ' -f 2 | grep "^$networkName$")
  if [ "$networkName" != "$existingNetwork" ]; then
    echo "Creating docker network '${networkName}'"
    docker network create $networkName
  fi
}

prepare_data_dir () {
  local dataDir=$1
  local subDirs=${@:2}

  echo "Preparing data dir and subdirs..."
  mkdir -p "$dataDir"
  for subDir in $subDirs; do
    mkdir -p "$dataDir/$subDir"
    echo "  $dataDir/$subDir"
  done

  if [[ "$OSTYPE" != "darwin"* ]]; then
    chown -R 65532:65532 "${dataDir}"
  fi
}

copy_common_assets () {
  if [[ -d ../common/assets ]]; then
    echo "Copying common assets..."
    mkdir -p ./assets
    cp -r ../common/assets/* ./assets
  fi
}

extract_file_from_image () {
  local imageName=$1
  local imageTag=$2
  local source="$3"
  local target="$4"

  echo "Extracting $source from docker image $imageName:$imageTag..."

  if [ -z "$(docker images | grep $imageName | grep $imageTag)" ]; then
    echo "Pulling docker image $imageName:$imageTag..."
    docker pull $imageName:$imageTag >/dev/null 2>&1
  fi

  rm -Rf $target
  docker rm -f config-extract-tmp >/dev/null 2>&1
  docker create --name config-extract-tmp $imageName:$imageTag >/dev/null 2>&1
  docker cp config-extract-tmp:$source "$target"
  docker rm -f config-extract-tmp >/dev/null 2>&1
}

read_config () {
  local configPath="$1"
  local jsonPath="$2"

  local value=$(jq "$jsonPath" "$configPath")
  echo "$value"
}

delete_config () {
  local configPath="$1"
  local jsonPath="$2"

  jq "del($jsonPath)" "$configPath"
}

move_rename_config () {
  local configPath="$1"
  local jsonPathFrom="$2"
  local jsonPathTo="$3"

  if [ "$(jq $jsonPathFrom $configPath)" != "null" ]; then
    echo "  $jsonPathFrom -> $jsonPathTo (moved/renamed)"
    jq "$jsonPathTo = $jsonPathFrom | del($jsonPathFrom)" "$configPath" > "$configPath.tmp" && mv "$configPath.tmp" "$configPath"
  fi
}

set_config () {
  local configPath="$1"
  local jsonPath="$2"
  local value="$3"
  local outputCfg="$4"

  if [ "$outputCfg" != "suppress" ]; then
    if [ "$outputCfg" == "secret" ]; then echo "  $jsonPath: ****"; else echo "  $jsonPath: $value"; fi
  fi
  jq "$jsonPath=$value" "$configPath" > "$configPath.tmp" && mv "$configPath.tmp" "$configPath"
}

set_array_config () {
  local configPath="$1"
  local jsonPath="$2"
  local values="$3"
  local delimiter="$4"
  local outputCfg="$5"

  i=0
  for value in $(echo $values | sed "s/$delimiter/ /g"); do
    set_config "${configPath}" "$jsonPath[${i}]" "${value}" "$outputCfg"
    i=$((i+1))
  done
}

set_array_config_from_numbered_env () {
  local configPath="$1"
  local jsonPath="$2"
  local pattern="$3" # string containing env name pattern with <> as placeholder for number; starting from 0
  local outputCfg="$4"

  set_array_config "${configPath}" "${jsonPath}" "$(get_numbered_env_as_csv ${pattern} ' ')" " " "${outputCfg}"
}

set_config_if_field_exists () {
  local configPath="$1"
  local jsonPath="$2"
  local value="$3"
  local outputCfg="$4"

  if [ "$(jq $jsonPath $configPath)" != "null" ]; then
    set_config "$configPath" "$jsonPath" "$value" "$outputCfg"
  fi
}

set_config_if_present_in_env () {
  local configPath="$1"
  local envVariableName="$2" # name of env variable containing value
  local jsonPath="$3"        # jsonpath to set value in configuration
  local outputCfg="$4"

  local defaultValue=$(read_config "$configPath" "$jsonPath")
  if [ ! -z "${!envVariableName}" ]; then set_config "$configPath" "$jsonPath" "${!envVariableName:-$defaultValue}" "$outputCfg"; else echo "  $jsonPath: $defaultValue (default)"; fi
}

get_numbered_env_as_csv () {
  local pattern="$1" # string containing env name pattern with <> as placeholder for number; starting from 0
  local delimiter="${2:-,}"

  csv=""
  i=0
  while true; do
    variableName=$(echo $pattern | sed "s/<>/${i}/g")
    value=$(get_env_by_name "$variableName")
    if [ "${value}" == "" ]; then
      break
    elif [ ${i} -eq 0 ]; then
      csv="\"$value\""
    else
      csv="$csv$delimiter\"$value\""
    fi
    i=$((i+1))
  done

  echo "$csv"
}

get_env_by_name () {
  local envVariableName="$1"
  local defaultValue="$2"
  echo "${!envVariableName:-$defaultValue}"
}

get_host_ip () {
  local hostIp=$(dig @resolver1.opendns.com myip.opendns.com +short)
  echo $hostIp
}

generate_random_string () {
  local stringLength=${1:-20}

  cat /dev/urandom | tr -dc '[:alpha:]' | fold -w ${1:-$stringLength} | head -n 1
}

print_line () {
  local columns="$1"
  printf '%*s\n' "${columns:-$(tput cols)}" '' | tr ' ' -
}

start_node () {
  if [ ! -z "$(docker compose ps | tail -n +3)" ]; then
      read -p "Node is already running. Restart? (y/n) " yn
      case $yn in
        y) stop_node
           ;;
        *) echo "Restart cancelled"
           exit 0
           ;;
      esac
  fi

  $(dirname "$0")/prepare_docker.sh
  docker compose down && docker compose up -d && docker compose logs -f
}

stop_node () {
  docker compose down
}

show_logs () {
  docker compose logs -f --tail 1000
}

merge_json_files() {
  local inputFile1Path="$1"
  local inputFile2Path="$2"
  local outputFile="$3"

  jq -s '.[0] * .[1]' "$inputFile1Path" "$inputFile2Path" > "$inputFile1Path.tmp" && mv "$inputFile1Path.tmp" "$outputFile"
}

generate_peering_json() {
  local peeringFilePath="$1"
  local staticNeighbors="$2"

  if [ -d "$peeringFilePath" ]; then
    rm -Rf "$peeringFilePath"
  fi

  if [ -z "$staticNeighbors" ]; then
    echo -e "No static neighbors defined"
    jq -n '{peers: []}' > "$peeringFilePath"
    return
  fi
  echo "Generating peering.json..."
  local peersJson="[]"
  IFS=','
  for neighbor in $staticNeighbors; do
    local cleanedNeighbor=$(echo "$neighbor" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    local alias=""
    local multiAddress=""

    if [[ "$cleanedNeighbor" =~ .*:.* ]]; then
        alias=$(echo "$cleanedNeighbor" | cut -d ':' -f 1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        multiAddress=$(echo "$cleanedNeighbor" | cut -d ':' -f 2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    else
        alias="Node-$(date +%s%N | sha256sum | head -c 8)"
        multiAddress="$cleanedNeighbor"
    fi

    peersJson=$(jq --arg alias "$alias" --arg multiAddress "$multiAddress" '. += [{"alias": $alias, "multiAddress": $multiAddress}]' <<< "$peersJson")
  done
  unset IFS
  echo "$peersJson" | jq '{peers: .}' > "$peeringFilePath" && echo "  ${peeringFilePath} successfully generated" || echo "  Failed to generate peering.json"
}

configure_wasp_trusted_peers() {
  local trustedPeersPath="$1"

  echo "{\"trustedPeers\": []}" > "${trustedPeersPath}";

  if ! grep -q -E "^WASP_TRUSTED_NODE_[0-9]+_URL" .env && \
     ! grep -q -E "^WASP_TRUSTED_ACCESSNODE_[0-9]+_URL" .env; then
    echo "  Cleared all trusted peers: No peers defined in .env"
  else
    local configPrefixes=("WASP_TRUSTED_ACCESSNODE" "WASP_TRUSTED_NODE")
    for configPrefix in "${configPrefixes[@]}"; do
      grep -E "^${configPrefix}_[0-9]+_URL" .env | sort | while IFS= read -r trustedNodeUrl; do
        trustedNodeNumber=$(echo "${trustedNodeUrl}" | cut -d '_' -f 4)
        name=$(grep -E "${configPrefix}_${trustedNodeNumber}_NAME" .env | cut -d '=' -f 2)
        url=$(grep -E "${configPrefix}_${trustedNodeNumber}_URL" .env | cut -d '=' -f 2)
        pubKey=$(grep -E "${configPrefix}_${trustedNodeNumber}_PUBKEY" .env | cut -d '=' -f 2)

        unnamedNodePrefix="peer"
        if [ "${configPrefix}" == "WASP_TRUSTED_ACCESSNODE" ]; then unnamedNodePrefix="accessnode"; fi
        if [ -z "${name}" ]; then name="${unnamedNodePrefix}${trustedNodeNumber}"; fi

        echo "  Adding trusted peer ${name} (${url})"
        jq -r --arg name "${name}" --arg url "${url}" --arg pubKey "${pubKey}" \
          '.trustedPeers += [{name: $name, publicKey: $pubKey, peeringURL: $url}]' \
          "${trustedPeersPath}" > "${trustedPeersPath}.tmp" && mv -f "${trustedPeersPath}.tmp" "${trustedPeersPath}"
      done
    done
  fi
  chown 65532:65532 "${trustedPeersPath}"
}

configure_wasp_chain_access_nodes() {
  local chainRegistryPath="$1"
  local evmChainName="$2"
  local evmChainID="$3"

  if [ ! -f "${chainRegistryPath}" ]; then echo "{\"chainRecords\": []}" > "${chainRegistryPath}"; fi

  if ! jq -e '.chainRecords' "${chainRegistryPath}" >/dev/null || \
     ! jq -e --arg chainID "${evmChainID}" '.chainRecords[] | select(.chainID == $chainID)' "${chainRegistryPath}" >/dev/null; then
    echo "  Skipped (chain registry): ${evmChainName} not present in chain registry"
  elif ! grep -q -E "^WASP_TRUSTED_ACCESSNODE_[0-9]+_URL" .env; then
    echo "  Cleared all access nodes: No peers defined in .env"
    jq --arg chainID "${evmChainID}" '.chainRecords |= map(if .chainID == $chainID then .accessNodes = [] else . end)' \
      "${chainRegistryPath}" > "${chainRegistryPath}.tmp" && mv -f "${chainRegistryPath}.tmp" "${chainRegistryPath}"
  else
    jq --arg chainID "${evmChainID}" '.chainRecords |= map(if .chainID == $chainID then .accessNodes = [] else . end)' \
      "${chainRegistryPath}" > "${chainRegistryPath}.tmp" && mv -f "${chainRegistryPath}.tmp" "${chainRegistryPath}"

    grep -E "^WASP_TRUSTED_ACCESSNODE_[0-9]+_URL" .env | sort | while IFS= read -r trustedNodeUrl; do
      trustedNodeNumber=$(echo "${trustedNodeUrl}" | cut -d '_' -f 4)
      name=$(grep -E "WASP_TRUSTED_ACCESSNODE_${trustedNodeNumber}_NAME" .env | cut -d '=' -f 2)
      if [ -z "${name}" ]; then name="peer${trustedNodeNumber}"; fi
      pubKey=$(grep -E "WASP_TRUSTED_ACCESSNODE_${trustedNodeNumber}_PUBKEY" .env | cut -d '=' -f 2)

      echo "  Adding access node ${name}: ${pubKey}"
      jq --arg chainID "${evmChainID}" --arg access_node "${pubKey}" \
        '.chainRecords |= map(if .chainID == $chainID then .accessNodes += [$access_node] else . end)' \
        "${chainRegistryPath}" > "${chainRegistryPath}.tmp" && mv -f "${chainRegistryPath}.tmp" "${chainRegistryPath}"
    done
  fi

  chown 65532:65532 "${chainRegistryPath}"
}

create_wasp_identity_file() {
  local identityFilePath="$1"
  local privateKey="$2"
  local identityFileDir="$(dirname "${identityFilePath}")"

  rm -Rf "${identityFileDir}"
  mkdir -p "${identityFileDir}"
  chown 65532:65532 "${identityFileDir}"
  chmod 700 "${identityFileDir}"

  echo -e "-----BEGIN PRIVATE KEY-----\n${privateKey}\n-----END PRIVATE KEY-----" > "${identityFilePath}"
  chown 65532:65532 "${identityFilePath}"
  chmod 640 "${identityFilePath}"
}
