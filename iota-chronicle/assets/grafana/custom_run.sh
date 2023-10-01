#!/bin/sh
if [[ -z "${ADMIN_PASSWORD}" ]]; then
  echo "INFO: admin password not set via env variable"
else
  grafana-cli admin reset-admin-password $ADMIN_PASSWORD >/dev/null
fi
/run.sh