#!/bin/bash
if [[ "$OSTYPE" != "darwin"* && "$EUID" -ne 0 ]]; then
  echo "Please run as root or with sudo"
  exit
fi

$(dirname "$0")/prepare_docker.sh
docker-compose down && docker-compose up -d && docker-compose logs -f
