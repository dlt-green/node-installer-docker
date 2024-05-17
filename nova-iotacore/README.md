# DLT.GREEN AUTOMATIC IOTA-CORE-INSTALLER DOCKER

1. Create a file named `.env` (see parameter documentation below)
2. Run `./prepare_docker.sh` to conly create node config from values in .env
3. Run `./start.sh` to start the node
4. Check the logs using `./show_logs.sh`
5. Run `./stop.sh` to stop node

You will be able to access your node under  (mind eventually configured port):
https://node.your-domain.com/api/core/v3/info

Your dashboard under (mind eventually configured port):
https://node.your-domain.com/

Your grafana dashboard under (mind eventually configured port):
https://node.your-domain.com/grafana

## .env

```
# SSL_CONFIG=letsencrypt
ACME_EMAIL=your-email@example.com
# or
# SSL_CONFIG=certs
# IOTA_CORE_SSL_CERT=<absolute path to cert>
# IOTA_CORE_SSL_KEY=<absolute path to key>

IOTA_CORE_VERSION=1.0-alpha
IOTA_CORE_HOST=node.your-domain.com
# IOTA_CORE_NODE_ALIAS=IOTA-CORE node
# IOTA_CORE_DATA_DIR=<absolute path to data dir>
# IOTA_CORE_NETWORK=mainnet
# IOTA_CORE_HTTP_PORT=80
# IOTA_CORE_HTTPS_PORT=443
# IOTA_CORE_GOSSIP_PORT=15600
# IOTA_CORE_PRUNING_TARGET_SIZE=64GB
# IOTA_CORE_JWT_SALT=0000000000000000000000000000000000000000000000000000000000000000
# IOTA_CORE_STATIC_PEERS=my-alias:/ip4/127.0.0.1/tcp/15600/p2p/12D3KooWCKWcTWevORKa2KEBputEGASvEBuDfRDSbe8t1DWugUmL
# IOTA_CORE_AUTOPEERING_BOOTSTRAP_PEER=/dns/<dns>/tcp/15600/p2p/<key>

# DASHBOARD_USERNAME=admin
DASHBOARD_PASSWORD=0000000000000000000000000000000000000000000000000000000000000000
DASHBOARD_SALT=0000000000000000000000000000000000000000000000000000000000000000

INX_INDEXER_VERSION=2.0-alpha
INX_MQTT_VERSION=2.0-alpha
INX_BLOCKISSUER_VERSION=1.0-alpha
INX_VALIDATOR_VERSION=1.0-alpha

# INX_BLOCKISSUER_ACCOUNT_ADDR=???
# INX_BLOCKISSUER_PRV_KEY=???
# INX_VALIDATOR_ACCOUNT_ADDR=???
# INX_VALIDATOR_PRV_KEY=???

# COMPOSE_PROFILES=monitoring
```

| Parameter                            | Mandatory |     Default     | Description                                                                                                                                                                                                                         |
|--------------------------------------|:---------:|:---------------:|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| IOTA_CORE_NODE_ALIAS                 |           | IOTA-CORE node  | Node alias                                                                                                                                                                                                                          |
| IOTA_CORE_VERSION                    |     x     |                 | Version of `iotaledger/iota-core` docker image to use                                                                                                                                                                               |
| IOTA_CORE_NETWORK                    |           |     mainnet     | Allowed values: `mainnet`, `testnet`                                                                                                                                                                                                |
| IOTA_CORE_HOST                       |     x     |                 | Host domain name e.g. `hornet.dlt.green`                                                                                                                                                                                            |
| IOTA_CORE_HTTP_PORT                  |           |       80        | HTTP port to access dashboard and api. Must be 80 if letsencrypt is used.                                                                                                                                                           |
| IOTA_CORE_HTTPS_PORT                 |           |       443       | HTTPS port to access dashboard and api                                                                                                                                                                                              |
| IOTA_CORE_GOSSIP_PORT                |           |      15600      | Gossip port                                                                                                                                                                                                                         |
| IOTA_CORE_DATA_DIR                   |           |     ./data      | Directory containing configuration, database, snapshots etc.                                                                                                                                                                        |
| IOTA_CORE_PRUNING_TARGET_SIZE        |           |      64GB       | Target size of database                                                                                                                                                                                                             |
| IOTA_CORE_JWT_SALT                   |           | <random-string> | Some random secret string used to generate (and validate) JWT tokens. If not given a random string is generated by `prepare_docker.sh` for security reasons                                                                         |
| IOTA_CORE_STATIC_PEERS               |           |                 | Comma separated list of static peers. Format example: `my-alias:/ip4/127.0.0.1/tcp/15600/p2p/12D3KooWCKWcTWevORKa2KEBputEGASvEBuDfRDSbe8t1DWugUmL` (see [docs](https://wiki.iota.org/hornet/references/peering/) for further infos) |
| IOTA_CORE_AUTOPEERING_BOOTSTRAP_PEER |     x     |                 | Peer to bootstrap autopeerring                                                                                                                                                                                                      |
| DASHBOARD_USERNAME                   |           |      admin      | Username to access dashboard                                                                                                                                                                                                        |
| DASHBOARD_PASSWORD                   |     x     |                 | Password hash: `docker compose run iota-core tools pwd-hash`                                                                                                                                                                        |
| DASHBOARD_SALT                       |     x     |                 | Password salt                                                                                                                                                                                                                       |
| SSL_CONFIG                           |           |   letsencrypt   | Allowed values: `certs`, `letsencrypt`. Default: `letsencrypt`. If set to certs `IOTA_CORE_SSL_CERT` and `IOTA_CORE_SSL_KEY` are used otherwise letsencrypt is used by default.                                                     |
| IOTA_CORE_SSL_CERT                   |    (x)    |                 | Absolute path to SSL certificate (mandatory if `SSL_CONFIG=certs`)                                                                                                                                                                  |
| IOTA_CORE_SSL_KEY                    |    (x)    |                 | Absolute path to SSL private key (mandatory if `SSL_CONFIG=certs`)                                                                                                                                                                  |
| ACME_EMAIL                           |    (x)    |                 | Mail address used to fetch SSL certificate from letsencrypt (mandatory if `SSL_CONFIG` not set or is set to `letsencrypt`).                                                                                                         |
| INX_INDEXER_VERSION                  |     x     |                 | Version of `iotaledger/inx-indexer` docker image to use                                                                                                                                                                             |
| INX_MQTT_VERSION                     |     x     |                 | Version of `iotaledger/inx-mqtt` docker image to use                                                                                                                                                                                |
| INX_BLOCKISSUER_VERSION              |     x     |                 | Version of `iotaledger/inx-blockissuer` docker image to use                                                                                                                                                                         |
| INX_VALIDATOR_VERSION                |     x     |                 | Version of `iotaledger/inx-validator` docker image to use                                                                                                                                                                           |
| INX_BLOCKISSUER_ACCOUNT_ADDR         |    (x)    |                 | Account address used by inx-blockissuer                                                                                                                                                                                             |
| INX_BLOCKISSUER_PRV_KEY              |    (x)    |                 | Private key used by inx-blockissuer                                                                                                                                                                                                 |
| INX_VALIDATOR_ACCOUNT_ADDR           |    (x)    |                 | Account address used by inx-validator                                                                                                                                                                                               |
| INX_VALIDATOR_PRV_KEY                |    (x)    |                 | Private key used by inx-validator                                                                                                                                                                                                   |
| COMPOSE_PROFILES                     |           |                 | Allowed values: `monitoring`, `blockissuer`, `validator`                                                                                                                                                                            |

## wallet-cli

wallet-cli is delivered in a docker image. To use it execute the following steps:

1. Evenutally create a file named `.env` and set parameters given in documentation below
2. Run `./prepare_cli.sh` to prepare workdir.
3. An _alias_ named wallet is automatically added to `~/.bash_aliases` for easier execution of wallet-cli in docker
4. Execute `wallet init` to initialize the node connection and a wallet

| Parameter          | Default | Description                                                                                      |
|--------------------|---------|--------------------------------------------------------------------------------------------------|
| WALLET_CLI_VERSION |         | Version to be used (see https://hub.docker.com/r/dltgreen/wallet-cli/tags for available version) |

**Important hints:**

- Execute `prepare_cli.sh` after each iotacore upgrade.
- Uninstalling the wallet alias can be done with `prepare_cli.sh --uninstall`
- `wallet init` automatically append `--node-url http://iota-core:14265` to the command. If you would like to set another node url, you can do it by adding `--node-url <url>` to the command.

#### How can I generate a wallet?

To generate a new wallet execute `wallet init`. The database and stronghold store is created in `data/wallet-cli`.