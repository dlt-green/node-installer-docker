#!/bin/bash
set -e
source ../common/scripts/prepare_docker_functions.sh

check_env
elevate_to_root true "$@"

source $(dirname "${0}")/.env

SERVICE_NAME=minio
CONTAINER_NAME=${INX_COLLECTOR_LEDGER_NETWORK}-inx-collector.minio

if [[ -z "${INX_COLLECTOR_MINIO_USER}" ]] || [[ -z "${INX_COLLECTOR_MINIO_PASSWORD}" ]]; then
  echo "Missing .env and/or variables INX_COLLECTOR_MINIO_USER, INX_COLLECTOR_MINIO_PASSWORD"
  exit 255
fi

scriptDir=$(dirname "${0}")
dataDir="${INX_COLLECTOR_DATA_DIR:-$scriptDir/data}"
prepare_data_dir "${dataDir}" "storage" &>/dev/null

# make sure that the container is stopped on any error
shutdown_container() {
  docker compose down -t 15 &>/dev/null
  exit 255
}
trap shutdown_container INT ERR

docker compose up --no-deps ${SERVICE_NAME} -d &>/dev/null

timeout=30
while ! output=$(docker exec ${CONTAINER_NAME} mc admin user svcacct list local ${INX_COLLECTOR_MINIO_USER} 2>&1); do
  if [ "${timeout}" -eq 0 ]; then
    echo -e "${OUTPUT_RED}Timed out waiting for ${CONTAINER_NAME} container to be available${OUTPUT_RESET}"
    shutdown_container
    exit 255
  elif [[ "${output}" =~ "Specified user does not exist" ]]; then
    output=""
    break
  fi
  sleep 1
  timeout=$((timeout - 1))
done

if [[ ! -z "${output}" ]]; then
  force=false
  for arg in "$@"; do if [[ "${arg}" == "--force" ]]; then force=true; break; fi; done

  clearAccessKeys=false
  for arg in "$@"; do if [[ "${arg}" == "--clear-access-keys" ]]; then clearAccessKeys=true; break; fi; done

  if [ "${clearAccessKeys}" = true ]; then
    echo "$output" | while read accessKey; do
      while ! docker exec ${CONTAINER_NAME} mc admin user svcacct remove local ${accessKey} &>/dev/null; do sleep 1; done
    done
  elif [ "${force}" = false ]; then
    echo -e "${OUTPUT_RED}There is already an access key for user ${INX_COLLECTOR_MINIO_USER}${OUTPUT_RESET}"
    echo -e ""
    echo -e "Parameters:"
    echo -e ""
    echo -e "  --clear-access-keys   clear all existing access keys before creating the new one"
    echo -e "  --force               create a new access key (existing access key(s) will not be touched and can be deleted via minio console)"
    echo -e ""
    echo -e "Existing access key(s):"
    echo "${output}" | while read accessKey; do echo -e "  * ${accessKey}"; done
    shutdown_container
    exit 255
  fi
fi

output=$(docker exec ${CONTAINER_NAME} mc admin user svcacct add local ${INX_COLLECTOR_MINIO_USER})

access_key=$(echo "${output}" | grep -oP 'Access Key: \K.*')
secret_key=$(echo "${output}" | grep -oP 'Secret Key: \K.*')
json=$(jq -n --arg ak "${access_key}" --arg sk "${secret_key}" '{"access_key":$ak,"secret_key":$sk}')

echo "${json}"

docker compose down -t 15 &>/dev/null