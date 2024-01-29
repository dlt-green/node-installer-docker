# DLT.GREEN AUTOMATIC IOTA_CORE-INSTALLER DOCKER

1. Create a file named `.env` (see parameter documentation below)
2. Run `./prepare_docker.sh` to conly create node config from values in .env
3. Run `./start.sh` to start the node
4. Check the logs using `./show_logs.sh`
5. Run `./stop.sh` to stop node

You will be able to access your node under  (mind eventually configured port):
https://node.your-domain.com/api/core/v2/info

Your dashboard under (mind eventually configured port):
https://node.your-domain.com/dashboard

## .env

```
# SSL_CONFIG=letsencrypt
ACME_EMAIL=your-email@example.com
# or
# SSL_CONFIG=certs
# IOTA_CORE_SSL_CERT=<absolute path to cert>
# IOTA_CORE_SSL_KEY=<absolute path to key>

IOTA_CORE_VERSION=2.0.0-beta.5
IOTA_CORE_HOST=node.your-domain.com
# IOTA_CORE_NETWORK=mainnet
# IOTA_CORE_NODE_ALIAS=IOTA_CORE node
# IOTA_CORE_HTTP_PORT=80
# IOTA_CORE_HTTPS_PORT=443
# IOTA_CORE_GOSSIP_PORT=15600
# IOTA_CORE_AUTOPEERING_PORT=14626
# IOTA_CORE_DATA_DIR=<absolute path to data dir>
# IOTA_CORE_PRUNING_TARGET_SIZE=64GB
# IOTA_CORE_PRUNING_MAX_MILESTONES_TO_KEEP=60480
# IOTA_CORE_POW_ENABLED=false

# DASHBOARD_USERNAME=admin
DASHBOARD_PASSWORD=0000000000000000000000000000000000000000000000000000000000000000
DASHBOARD_SALT=0000000000000000000000000000000000000000000000000000000000000000

# RESTAPI_SALT=0000000000000000000000000000000000000000000000000000000000000000

INX_INDEXER_VERSION=1.0.0-beta.5
INX_MQTT_VERSION=1.0.0-beta.5
INX_PARTICIPATION_VERSION=1.0.0-beta.5
INX_SPAMMER_VERSION=1.0.0-beta.5
INX_POI_VERSION=1.0.0-beta.5
INX_DASHBOARD_VERSION=1.0.0-beta.5
```

| Parameter                                | Mandatory |     Default     | Description                                                                                                                                                                      |
| ---------------------------------------- | :-------: | :-------------: | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| IOTA_CORE_VERSION                        |     x     |                 | Version of `iotaledger/hornet` docker image to use                                                                                                                               |
| IOTA_CORE_NETWORK                        |           |     mainnet     | Allowed values: `mainnet`, `testnet`                                                                                                                                             |
| IOTA_CORE_NODE_ALIAS                     |           | IOTA_CORE node  | Node alias                                                                                                                                                                       |
| IOTA_CORE_HOST                           |     x     |                 | Host domain name e.g. `hornet.dlt.green`                                                                                                                                         |
| IOTA_CORE_HTTP_PORT                      |           |       80        | HTTP port to access dashboard and api. Must be 80 if letsencrypt is used.                                                                                                        |
| IOTA_CORE_HTTPS_PORT                     |           |       443       | HTTPS port to access dashboard and api                                                                                                                                           |
| IOTA_CORE_GOSSIP_PORT                    |           |      15600      | Gossip port                                                                                                                                                                      |
| IOTA_CORE_AUTOPEERING_PORT               |           |      14626      | Autopeering port                                                                                                                                                                 |
| IOTA_CORE_DATA_DIR                       |           |      .data      | Directory containing configuration, database, snapshots etc.                                                                                                                     |
| IOTA_CORE_PRUNING_TARGET_SIZE            |           |      64GB       | Target size of database                                                                                                                                                          |
| IOTA_CORE_PRUNING_MAX_MILESTONES_TO_KEEP |           |      60480      | Max umber of milestones to keep in database. Milestone pruning is disabled by default. It's activated if this parameter is set.                                                  |
| IOTA_CORE_POW_ENABLED                    |           |      false      | Whether the node does PoW if messages are received via API                                                                                                                       |
| DASHBOARD_USERNAME                       |           |      admin      | Username to access dashboard                                                                                                                                                     |
| DASHBOARD_PASSWORD                       |     x     |                 | Password hash (can be generated with `docker compose run hornet tool pwd-hash` or non-interactively with `docker compose run hornet tool pwd-hash --json --password <password>`) |
| DASHBOARD_SALT                           |     x     |                 | Password salt (can be generated with `docker compose run hornet tool pwd-hash` or non-interactively with `docker compose run hornet tool pwd-hash --json --password <password>`) |
| RESTAPI_SALT                             |           | <random-string> | Some random secret string used to generate (and validate) JWT tokens. If not given a random string is generated by `prepare_docker.sh` for security reasons                      |
| SSL_CONFIG                               |           |   letsencrypt   | Allowed values: `certs`, `letsencrypt`. Default: `letsencrypt`. If set to certs `IOTA_CORE_SSL_CERT` and `IOTA_CORE_SSL_KEY` are used otherwise letsencrypt is used by default.  |
| IOTA_CORE_SSL_CERT                       |    (x)    |                 | Absolute path to SSL certificate (mandatory if `SSL_CONFIG=certs`)                                                                                                               |
| IOTA_CORE_SSL_KEY                        |    (x)    |                 | Absolute path to SSL private key (mandatory if `SSL_CONFIG=certs`)                                                                                                               |
| ACME_EMAIL                               |    (x)    |                 | Mail address used to fetch SSL certificate from letsencrypt (mandatory if `SSL_CONFIG` not set or is set to `letsencrypt`).                                                      |
| INX_INDEXER_VERSION                      |     x     |                 | Version of `iotaledger/inx-indexer` docker image to use                                                                                                                          |
| INX_MQTT_VERSION                         |     x     |                 | Version of `iotaledger/inx-mqtt` docker image to use                                                                                                                             |
| INX_PARTICIPATION_VERSION                |     x     |                 | Version of `iotaledger/inx-participation` docker image to use                                                                                                                    |
| INX_SPAMMER_VERSION                      |     x     |                 | Version of `iotaledger/inx-spammer` docker image to use                                                                                                                          |
| INX_POI_VERSION                          |     x     |                 | Version of `iotaledger/inx-poi` docker image to use                                                                                                                              |
| INX_DASHBOARD_VERSION                    |     x     |                 | Version of `iotaledger/inx-dashboard` docker image to use                                                                                                                        |
