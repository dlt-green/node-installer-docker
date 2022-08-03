#!/bin/bash
set -e

if [[ "$OSTYPE" != "darwin"* && "$EUID" -ne 0 ]]; then
  echo "Elevating to root privileges..."
  sudo "$0" "$@"
  exit $?
fi

$(dirname "$0")/prepare_docker.sh
docker-compose down && docker-compose up -d && docker-compose logs -f
