# DLT.GREEN AUTOMATIC WASP-INSTALLER DOCKER

1. Create a file named `.env` (see parameter documentation below)
2. Run `./prepare_docker.sh`
3. Run `docker-compose up -d`
4. Check the logs using `docker-compose -f logs`

Your dashboard under (mind eventually configured port):
https://node.your-domain.com/
## .env

```
# SSL_CONFIG=letsencrypt
ACME_EMAIL=your-email@example.com
# or
# SSL_CONFIG=certs
# WASP_SSL_CERT=<absolute path to cert>
# WASP_SSL_KEY=<absolute path to key>

WASP_VERSION=0.2.5
WASP_HOST=node.your-domain.com
# WASP_HTTP_PORT=80
# WASP_HTTPS_PORT=443
# WASP_API_PORT=448
# WASP_PEERING_PORT=4000
# WASP_NANO_MSG_PORT=5550
# WASP_DATA_DIR=<absolute path to data dir>

WASP_LEDGER_CONNECTION=node.your-domain.com:5000

# DASHBOARD_USERNAME=admin
# DASHBOARD_PASSWORD=****
```

| Parameter              | Mandatory |   Default   | Description                                                                                                                                                           |
| ---------------------- | :-------: | :---------: | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| WASP_VERSION           |     x     |             | Version of `dlt.green/iota-wasp` docker image to use                                                                                                                  |
| WASP_HOST              |     x     |             | Host domain name e.g. `wasp.dlt.green`                                                                                                                                |
| WASP_HTTP_PORT         |           |     80      | HTTP port to access dashboard. Must be 80 if letsencrypt is used.                                                                                                     |
| WASP_HTTPS_PORT        |           |     443     | HTTPS port to access dashboard                                                                                                                                        |
| WASP_API_PORT          |           |     448     | HTTPS port to access webapi.                                                                                                                                          |
| WASP_PEERING_PORT      |           |    4000     | Peering port                                                                                                                                                          |
| WASP_NANO_MSG_PORT     |           |    5550     | nano MSG port                                                                                                                                                         |
| WASP_LEDGER_CONNECTION |     x     |             | IOTA node url (txstream protocol) to connect to (GoShimmer txstream plugin uses port 5000 by default)                                                                 |
| WASP_DATA_DIR          |           |    .data    | Directory containing configuration, database etc.                                                                                                                     |
| DASHBOARD_USERNAME     |           |    admin    | Username to access dashboard                                                                                                                                          |
| DASHBOARD_PASSWORD     |     x     |             | Password in clear text (not hashed, so take care!!!)                                                                                                                  |
| SSL_CONFIG             |           | letsencrypt | Allowed values: `certs`, `letsencrypt`. Default: `letsencrypt`. If set to certs `WASP_SSL_CERT` and `WASP_SSL_KEY` are used otherwise letsencrypt is used by default. |
| WASP_SSL_CERT          |    (x)    |             | Absolute path to SSL certificate (mandatory if `SSL_CONFIG=certs`)                                                                                                    |
| WASP_SSL_KEY           |    (x)    |             | Absolute path to SSL private key (mandatory if `SSL_CONFIG=certs`)                                                                                                    |
| ACME_EMAIL             |    (x)    |             | Mail address used to fetch SSL certificate from letsencrypt (mandatory if `SSL_CONFIG` not set or is set to `letsencrypt`).                                           |
