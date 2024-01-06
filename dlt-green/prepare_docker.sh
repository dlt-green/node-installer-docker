#!/bin/bash
set -e
source ../common/scripts/prepare_docker_functions.sh

check_env
elevate_to_root

source $(dirname "${0}")/.env

scriptDir=$(dirname "${0}")
dataDir="${DLTGREEN_DATA_DIR:-${scriptDir}/data}"

validate_ssl_config "DLTGREEN_SSL_CERT" "DLTGREEN_SSL_KEY"
copy_common_assets

prepare_data_dir "${dataDir}"

create_docker_network "dlt-green"

echo "Finished"
