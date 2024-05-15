# DLT.GREEN AUTOMATIC HORNET-INSTALLER DOCKER

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
# HORNET_SSL_CERT=<absolute path to cert>
# HORNET_SSL_KEY=<absolute path to key>

HORNET_VERSION=2.0.0-beta.5
HORNET_HOST=node.your-domain.com
# HORNET_NETWORK=mainnet
# HORNET_NODE_ALIAS=HORNET node
# HORNET_HTTP_PORT=80
# HORNET_HTTPS_PORT=443
# HORNET_GOSSIP_PORT=15600
# HORNET_AUTOPEERING_PORT=14626
# HORNET_DATA_DIR=<absolute path to data dir>
# HORNET_PRUNING_TARGET_SIZE=64GB
# HORNET_PRUNING_MAX_MILESTONES_TO_KEEP=60480
# HORNET_POW_ENABLED=false
# HORNET_AUTOPEERING_ENABLED=true
# HORNET_STATIC_NEIGHBORS=my-alias:/ip4/127.0.0.1/tcp/15600/p2p/12D3KooWCKWcTWevORKa2KEBputEGASvEBuDfRDSbe8t1DWugUmL
# HORNET_SNAPSHOT_MAINNET_FULL_URL=https://files.shimmer.network/snapshots/latest-full_snapshot.bin
# HORNET_SNAPSHOT_MAINNET_DELTA_URL=https://files.shimmer.network/snapshots/latest-delta_snapshot.bin
# HORNET_SNAPSHOT_TESTNET_FULL_URL=https://files.testnet.shimmer.network/snapshots/latest-full_snapshot.bin
# HORNET_SNAPSHOT_TESTNET_DELTA_URL=https://files.testnet.shimmer.network/snapshots/latest-delta_snapshot.bin

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

| Parameter                                    | Mandatory |     Default     | Description                                                                                                                                                                                                                             |
|----------------------------------------------|:---------:|:---------------:|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| HORNET_VERSION                               |     x     |                 | Version of `iotaledger/hornet` docker image to use                                                                                                                                                                                      |
| HORNET_NETWORK                               |           |     mainnet     | Allowed values: `mainnet`, `testnet`                                                                                                                                                                                                    |
| HORNET_NODE_ALIAS                            |           |   HORNET node   | Node alias                                                                                                                                                                                                                              |
| HORNET_HOST                                  |     x     |                 | Host domain name e.g. `hornet.dlt.green`                                                                                                                                                                                                |
| HORNET_HTTP_PORT                             |           |       80        | HTTP port to access dashboard and api. Must be 80 if letsencrypt is used.                                                                                                                                                               |
| HORNET_HTTPS_PORT                            |           |       443       | HTTPS port to access dashboard and api                                                                                                                                                                                                  |
| HORNET_GOSSIP_PORT                           |           |      15600      | Gossip port                                                                                                                                                                                                                             |
| HORNET_AUTOPEERING_PORT                      |           |      14626      | Autopeering port                                                                                                                                                                                                                        |
| HORNET_DATA_DIR                              |           |      .data      | Directory containing configuration, database, snapshots etc.                                                                                                                                                                            |
| HORNET_PRUNING_TARGET_SIZE                   |           |      64GB       | Target size of database                                                                                                                                                                                                                 |
| HORNET_PRUNING_MAX_MILESTONES_TO_KEEP        |           |      60480      | Max umber of milestones to keep in database. Milestone pruning is disabled by default. It's activated if this parameter is set.                                                                                                         |
| HORNET_POW_ENABLED                           |           |      false      | Whether the node does PoW if messages are received via API                                                                                                                                                                              |
| HORNET_AUTOPEERING_ENABLED                   |           |      true       | Whether the node should automatically connect to other nodes (see [docs](https://wiki.iota.org/hornet/references/peering#autopeering) for further infos)                                                                                |
| HORNET_STATIC_NEIGHBORS                      |           |                 | Comma separated list of static neighbors. Format example: `my-alias:/ip4/127.0.0.1/tcp/15600/p2p/12D3KooWCKWcTWevORKa2KEBputEGASvEBuDfRDSbe8t1DWugUmL` (see [docs](https://wiki.iota.org/hornet/references/peering/) for further infos) |
| HORNET_SNAPSHOT_{MAINNET\|TESTNET}_FULL_URL  |           |     <by IF>     | URL to download full mainnet/testnet snapshot (hint: both variables full and delta have to be set to be taken into account)                                                                                                             |
| HORNET_SNAPSHOT_{MAINNET\|TESTNET}_DELTA_URL |           |     <by IF>     | URL to download delta mainnet/testnet snapshot (hint: both variables full and delta have to be set to be taken into account)                                                                                                            |
| DASHBOARD_USERNAME                           |           |      admin      | Username to access dashboard                                                                                                                                                                                                            |
| DASHBOARD_PASSWORD                           |     x     |                 | Password hash (can be generated with `docker compose run hornet tool pwd-hash` or non-interactively with `docker compose run hornet tool pwd-hash --json --password <password>`)                                                        |
| DASHBOARD_SALT                               |     x     |                 | Password salt (can be generated with `docker compose run hornet tool pwd-hash` or non-interactively with `docker compose run hornet tool pwd-hash --json --password <password>`)                                                        |
| RESTAPI_SALT                                 |           | <random-string> | Some random secret string used to generate (and validate) JWT tokens. If not given a random string is generated by `prepare_docker.sh` for security reasons                                                                             |
| SSL_CONFIG                                   |           |   letsencrypt   | Allowed values: `certs`, `letsencrypt`. Default: `letsencrypt`. If set to certs `HORNET_SSL_CERT` and `HORNET_SSL_KEY` are used otherwise letsencrypt is used by default.                                                               |
| HORNET_SSL_CERT                              |    (x)    |                 | Absolute path to SSL certificate (mandatory if `SSL_CONFIG=certs`)                                                                                                                                                                      |
| HORNET_SSL_KEY                               |    (x)    |                 | Absolute path to SSL private key (mandatory if `SSL_CONFIG=certs`)                                                                                                                                                                      |
| ACME_EMAIL                                   |    (x)    |                 | Mail address used to fetch SSL certificate from letsencrypt (mandatory if `SSL_CONFIG` not set or is set to `letsencrypt`).                                                                                                             |
| INX_INDEXER_VERSION                          |     x     |                 | Version of `iotaledger/inx-indexer` docker image to use                                                                                                                                                                                 |
| INX_MQTT_VERSION                             |     x     |                 | Version of `iotaledger/inx-mqtt` docker image to use                                                                                                                                                                                    |
| INX_PARTICIPATION_VERSION                    |     x     |                 | Version of `iotaledger/inx-participation` docker image to use                                                                                                                                                                           |
| INX_SPAMMER_VERSION                          |     x     |                 | Version of `iotaledger/inx-spammer` docker image to use                                                                                                                                                                                 |
| INX_POI_VERSION                              |     x     |                 | Version of `iotaledger/inx-poi` docker image to use                                                                                                                                                                                     |
| INX_DASHBOARD_VERSION                        |     x     |                 | Version of `iotaledger/inx-dashboard` docker image to use                                                                                                                                                                               |
