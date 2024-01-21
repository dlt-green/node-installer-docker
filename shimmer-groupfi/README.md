# DLT.GREEN AUTOMATIC INX-GROUPFI-INSTALLER DOCKER

1. Create a file named `.env` (see parameter documentation below)
2. Run `./prepare_docker.sh` to conly create node config from values in .env
3. Run `./start.sh` to start the node
4. Check the logs using `./show_logs.sh`
5. Run `./stop.sh` to stop node

You will be able to access the api under (mind eventually configured port):
https://node.your-domain.com:<INX_GROUPFI_HTTPS_PORT>

Context roots:
- `/api` (inx-groupfi api)

## .env

```
# SSL_CONFIG=letsencrypt
ACME_EMAIL=your-email@example.com
# or
# SSL_CONFIG=certs
# INX_GROUPFI_SSL_CERT=<absolute path to cert>
# INX_GROUPFI_SSL_KEY=<absolute path to key>

INX_GROUPFI_VERSION=1.0.0
INX_GROUPFI_HOST=node.your-domain.com
INX_GROUPFI_LEDGER_NETWORK=shimmer
# INX_GROUPFI_NETWORK=mainnet
# INX_GROUPFI_HTTP_PORT=80
# INX_GROUPFI_HTTPS_PORT=443

# INX_GROUPFI_DATA_DIR=<absolute path to data dir>
# INX_GROUPFI_LOGLEVEL=warn
```

| Parameter                  | Mandatory |   Default   | Description                                                                                                                                                                         |
| -------------------------- | :-------: | :---------: | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| COMPOSE_PROFILES           |           |             | Allowed values: metrics (grafana dashboard and collect mongodb metrics in influxdb), debug (mongo-express => mongodb admin dashboard)                                               |
| SSL_CONFIG                 |           | letsencrypt | Allowed values: `certs`, `letsencrypt`. Default: `letsencrypt`. If set to certs `INX_GROUPFI_SSL_CERT` and `INX_GROUPFI_SSL_KEY` are used otherwise letsencrypt is used by default. |
| ACME_EMAIL                 |    (x)    |             | Mail address used to fetch SSL certificate from letsencrypt (mandatory if `SSL_CONFIG` not set or is set to `letsencrypt`).                                                         |
| INX_GROUPFI_SSL_CERT       |    (x)    |             | Absolute path to SSL certificate (mandatory if `SSL_CONFIG=certs`)                                                                                                                  |
| INX_GROUPFI_SSL_KEY        |    (x)    |             | Absolute path to SSL private key (mandatory if `SSL_CONFIG=certs`)                                                                                                                  |
| INX_GROUPFI_VERSION        |     x     |             | Version of `dltgreen/inx-groupfi` docker image to use                                                                                                                               |
| INX_GROUPFI_HOST           |     x     |             | Host domain name e.g. `mynode.dlt.green`                                                                                                                                            |
| INX_GROUPFI_LEDGER_NETWORK |     x     |             | Allowed values: iota, shimmer                                                                                                                                                       |
| INX_GROUPFI_NETWORK        |           |   mainnet   | Allowed values: mainnet, testnet                                                                                                                                                    |
| INX_GROUPFI_HTTP_PORT      |           |     80      | HTTP port to access api. Must be 80 if letsencrypt is used.                                                                                                                         |
| INX_GROUPFI_HTTPS_PORT     |           |     443     | HTTPS port to access api                                                                                                                                                            |
| INX_GROUPFI_DATA_DIR       |           |   ./data    | Directory containing configuration, storage etc.                                                                                                                                    |
| INX_GROUPFI_LOGLEVEL       |           |    warn     | Sets the log level of inx-groupfi. e.g. info, warn                                                                                                                                  |