# DLT.GREEN AUTOMATIC WASP-INSTALLER DOCKER

1. Create a file named `.env` (see parameter documentation below)
2. Run `./prepare_docker.sh` to create node config from values in .env
3. Run `./start.sh` to start the node
4. Check the logs using `./show_logs.sh`
5. Run `./stop.sh` to stop node

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

WASP_VERSION=0.4.0-alpha.1
WASP_HOST=node.your-domain.com
# WASP_HTTP_PORT=80
# WASP_HTTPS_PORT=443
# WASP_API_PORT=448
# WASP_PEERING_PORT=4000
# WASP_DATA_DIR=<absolute path to data dir>
# WASP_IDENTITY_PRIVATE_KEY=<optional>
# WASP_PRUNING_MIN_STATES_TO_KEEP=10000
# WASP_DEBUG_SKIP_HEALTH_CHECK=false
# WASP_LOG_LEVEL=info

# DASHBOARD_USERNAME=admin
DASHBOARD_PASSWORD=<password hash>
DASHBOARD_SALT=<password salt>
# WASP_WEBAPI_AUTH_SCHEME=jwt
# WASP_JWT_DURATION=24h

# WASP_TRUSTED_NODE_0_NAME=peer0
# WASP_TRUSTED_NODE_0_URL=trusted.node:4000
# WASP_TRUSTED_NODE_0_PUBKEY=<pubkey>

# WASP_TRUSTED_ACCESSNODE_0_NAME=accessnode0
# WASP_TRUSTED_ACCESSNODE_0_URL=accessnode.node:4000
# WASP_TRUSTED_ACCESSNODE_0_PUBKEY=<pubkey>
```

| Parameter                               | Mandatory |   Default   | Description                                                                                                                                                                                                        |
|-----------------------------------------|:---------:|:-----------:|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| SSL_CONFIG                              |           | letsencrypt | Allowed values: `certs`, `letsencrypt`. Default: `letsencrypt`. If set to certs `WASP_SSL_CERT` and `WASP_SSL_KEY` are used otherwise letsencrypt is used by default.                                              |
| WASP_SSL_CERT                           |    (x)    |             | Absolute path to SSL certificate (mandatory if `SSL_CONFIG=certs`)                                                                                                                                                 |
| WASP_SSL_KEY                            |    (x)    |             | Absolute path to SSL private key (mandatory if `SSL_CONFIG=certs`)                                                                                                                                                 |
| ACME_EMAIL                              |    (x)    |             | Mail address used to fetch SSL certificate from letsencrypt (mandatory if `SSL_CONFIG` not set or is set to `letsencrypt`).                                                                                        |                                |
| WASP_VERSION                            |     x     |             | Version of `iotaledger/wasp` docker image to use                                                                                                                                                                   |
| WASP_DASHBOARD_VERSION                  |     x     |             | Version of `iotaledger/wasp-dashboard` docker image to use                                                                                                                                                         |
| WASP_HOST                               |     x     |             | Host domain name e.g. `wasp.dlt.green`                                                                                                                                                                             |
| WASP_HTTP_PORT                          |           |     80      | HTTP port to access dashboard. Must be 80 if letsencrypt is used.                                                                                                                                                  |
| WASP_HTTPS_PORT                         |           |     443     | HTTPS port to access dashboard                                                                                                                                                                                     |
| WASP_API_PORT                           |           |     448     | HTTPS port to access webapi                                                                                                                                                                                        |
| WASP_PEERING_PORT                       |           |    4000     | Peering port                                                                                                                                                                                                       |
| WASP_DATA_DIR                           |           |    .data    | Directory containing configuration, database etc.                                                                                                                                                                  |
| WASP_IDENTITY_PRIVATE_KEY               |           |             | Private key used to derive the node identity                                                                                                                                                                       |
| WASP_PRUNING_MIN_STATES_TO_KEEP         |           |    10000    | Minimum number of states to keep in the database. If the number of states exceeds this value, the oldest states are pruned.                                                                                        |
| WASP_DEBUG_SKIP_HEALTH_CHECK            |           |    false    | Set to true if health check should be skipped                                                                                                                                                                      |
| WASP_LOG_LEVEL                          |           |    info     | Log level of the node (e.g. debug, info, warn etc.)                                                                                                                                                                |
| DASHBOARD_USERNAME                      |           |    wasp     | Username to access dashboard                                                                                                                                                                                       |
| DASHBOARD_PASSWORD                      |     x     |             | Password hash (can be generated with `docker run --rm -it iotaledger/hornet:2.0-rc tool pwd-hash` or non-interactively with `docker run --rm iotaledger/hornet:2.0-rc tool pwd-hash --json --password <password>`) |
| DASHBOARD_SALT                          |     x     |             | Password salt (can be generated with `docker run --rm -it iotaledger/hornet:2.0-rc tool pwd-hash` or non-interactively with `docker run --rm iotaledger/hornet:2.0-rc tool pwd-hash --json --password <password>`) |
| WASP_WEBAPI_AUTH_SCHEME                 |           |     jwt     | Defines scheme of authentication of client with the wasp node e.g. basic or jwt                                                                                                                                    |
| WASP_JWT_DURATION                       |           |     24h     | Defines how log jwt tokens are valid (is used for webapi and dashboard)                                                                                                                                            |
| WASP_TRUSTED_NODE_\[0-9\]+_NAME         |           |  peer{no}   | Name of trusted node                                                                                                                                                                                               |
| WASP_TRUSTED_NODE_\[0-9\]+_URL          |    (x)    |             | URL of trusted node                                                                                                                                                                                                |
| WASP_TRUSTED_NODE_\[0-9\]+_PUBKEY       |    (x)    |             | PublicKey of trusted node                                                                                                                                                                                          |
| WASP_TRUSTED_ACCESSNODE_\[0-9\]+_NAME   |           |  peer{no}   | Name of trusted access node for evm                                                                                                                                                                                |
| WASP_TRUSTED_ACCESSNODE_\[0-9\]+_URL    |    (x)    |             | URL of trusted access node for evm                                                                                                                                                                                 |
| WASP_TRUSTED_ACCESSNODE_\[0-9\]+_PUBKEY |    (x)    |             | PublicKey of trusted access node for evm                                                                                                                                                                           |

## wasp-cli

wasp-cli is delivered in a docker image. To use it execute the following steps:

1. Evenutally create a file named `.env` and set parameters given in documentation below
2. Run `./prepare_cli.sh` to generate wasp-cli config from values in `.env`. The config is created
   in `data/config/wasp-cli/wasp-cli.json`.
3. An _alias_ names wasp-cli is automatically added to `~/.bash_aliases` for easier execution of wasp-cli in docker
4. Try to execute `wasp-cli login` and use wasp credentials to authenticate with API

| Parameter                   | Default | Description                                                                           |
|-----------------------------|---------|---------------------------------------------------------------------------------------|
| WASP_CLI_FAUCET_ADDRESS     |         | Address to faucet (fallback is docker network interal address http://inx-faucet:8091) |
| WASP_CLI_COMMITTEE_\[0-9\]+ |         | WebAPI url of the node in the committee (e.g. https://host:448)                       |
| WASP_CLI_CHAIN_NAME         | mychain | Chain name                                                                            |
| WASP_CLI_CHAIN              |         | Address of chain; if missing, no chain is added to config                             |

**Important hints:**

- The WASP_CLI_COMMITTEE_* parameters must be numbered in ascending order and without gaps starting from 0 or 1
  respectively. If committee member 0 is not configured the information of the local node is used automatically.
- Execute `prepare_cli.sh` after each wasp upgrade.
- Uninstalling the wasp-cli alias can be done with `prepare_cli.sh --uninstall`

### FAQ

#### How do I get URL and publicKey to give to other node operators so they can trust my node?

Execute `wasp-cli peering info` to get URL and pubKey. Other node operators can add this information to `.env` to trust
your node or execute `wasp-cli peering trust <name> <publicKey> <peeringURL>` manually.

#### How can I generate a wallet seed?

To generate a new wallet seed execute `wasp-cli init`. The seed is added to `data/config/wasp-cli/secrets.db`. If there
is already a wallet seed you have to call `wasp-cli init --overwrite` instead.
