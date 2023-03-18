#!/bin/bash
tags=($(curl -s https://docker.tanglehub.eu/v2/pipe/tags/list | jq -r '.tags[]'))
for tag in "${tags[@]}"; do
  echo "$tag"
done