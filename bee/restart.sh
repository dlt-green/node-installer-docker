#!/bin/bash
./prepare_docker.sh
docker-compose down && docker-compose up -d && docker-compose logs -f
