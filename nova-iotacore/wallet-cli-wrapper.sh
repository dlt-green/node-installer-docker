#!/bin/bash
set -e
scriptDir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ -f ../common/scripts/prepare_docker_functions.sh ]; then
  source ../common/scripts/prepare_docker_functions.sh
else
  source "${scriptDir}/scripts/prepare_docker_functions.sh"
fi

source "${scriptDir}/.env"

dataDir="${IOTA_CORE_DATA_DIR:-${scriptDir}/data}"
workDir="${dataDir}/wallet-cli"
imageTag="dltgreen/wallet-cli:${WALLET_CLI_VERSION}"
if [ ! -d "${workDir}" ] && ! is_parameter_present "-v" $@; then
  (cd "${scriptDir}" && ./prepare_cli.sh >/dev/null)
  echo -e "Usage of wallet-cli prepared. Continuing..."
  print_line 120
fi

initNodeUrlParam=""
if [[ "$1" == "init" ]]; then
  initNodeUrlParam="--node-url http://iota-core:14265"
fi

# Check if any of the command line parameters are "--node-url"
for param in "$@"; do
  if [[ "$param" == "--node-url" ]]; then
    initNodeUrlParam=""
    break
  fi
done

docker rm -f nova-wallet.cli &>/dev/null && \
docker run -it --rm \
  --volume "${workDir}:/workdir" \
  --workdir "/workdir" \
  --network "nova" \
  --name "nova-wallet.cli" \
  --entrypoint "/app/wallet" \
  "${imageTag}" \
  "${@}" ${initNodeUrlParam}
