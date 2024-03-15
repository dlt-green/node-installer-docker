#!/bin/bash
set -e
scriptDir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
currentDir=$( pwd )

if [ -f ../common/scripts/prepare_docker_functions.sh ]; then
  source ../common/scripts/prepare_docker_functions.sh
else
  source "${scriptDir}/scripts/prepare_docker_functions.sh"
fi

source "${scriptDir}/.env"

dataDir="${WASP_DATA_DIR:-${scriptDir}/data}"
configRootPath="${dataDir}/config/wasp-cli"
configPath="${configRootPath}/wasp-cli.json"
imageTag="dltgreen/wasp-cli:${WASP_CLI_VERSION}"
if [ ! -f "${configPath}" ] && ! is_parameter_present "-v" $@; then
  (cd "${scriptDir}" && ./prepare_cli.sh >/dev/null)
  echo -e "Initial wasp-cli config created. Continuing..."
  print_line 120
fi
docker rm -f shimmer-wasp.cli &>/dev/null && \
docker run -it --rm \
  --volume "${configRootPath}:/home/nonroot/.wasp-cli" \
  --volume "${currentDir}:/workdir" \
  --workdir "/workdir" \
  --network "shimmer" \
  --name "shimmer-wasp.cli" \
  --entrypoint "/app/wasp-cli" \
  "${imageTag}" \
  "${@}"
