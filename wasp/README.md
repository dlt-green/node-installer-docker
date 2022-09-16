# DLT.GREEN AUTOMATIC WASP-INSTALLER DOCKER

1. Create a file named `.env` (see parameter documentation below)
2. Run `./prepare_docker.sh` to conly create node config from values in .env
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

WASP_LEDGER_NETWORK=iota # or shimmer
WASP_VERSION=0.3.0
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
# WASP_WEBAPI_AUTH_SCHEME=jwt
# WASP_JWT_DURATION_HOURS=24

# WASP_PEERING_NETID=0.0.0.0:4000
# WASP_TRUSTED_NODE_0_NETID=trusted.node:4000
# WASP_TRUSTED_NODE_0_PUBKEY=<pubkey>
```

| Parameter                         | Mandatory |   Default    | Description                                                                                                                                                                             |
| --------------------------------- | :-------: | :----------: | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| SSL_CONFIG                        |           | letsencrypt  | Allowed values: `certs`, `letsencrypt`. Default: `letsencrypt`. If set to certs `WASP_SSL_CERT` and `WASP_SSL_KEY` are used otherwise letsencrypt is used by default.                   |
| WASP_SSL_CERT                     |    (x)    |              | Absolute path to SSL certificate (mandatory if `SSL_CONFIG=certs`)                                                                                                                      |
| WASP_SSL_KEY                      |    (x)    |              | Absolute path to SSL private key (mandatory if `SSL_CONFIG=certs`)                                                                                                                      |
| ACME_EMAIL                        |    (x)    |              | Mail address used to fetch SSL certificate from letsencrypt (mandatory if `SSL_CONFIG` not set or is set to `letsencrypt`).                                                             |
| WASP_LEDGER_NETWORK               |     x     |              | Network this wasp note belongs to (iota or shimmer)                                                                                                                                     |
| WASP_VERSION                      |     x     |              | Version of `dltgreen/wasp` docker image to use                                                                                                                                          |
| WASP_HOST                         |     x     |              | Host domain name e.g. `wasp.dlt.green`                                                                                                                                                  |
| WASP_HTTP_PORT                    |           |      80      | HTTP port to access dashboard. Must be 80 if letsencrypt is used.                                                                                                                       |
| WASP_HTTPS_PORT                   |           |     443      | HTTPS port to access dashboard                                                                                                                                                          |
| WASP_API_PORT                     |           |     448      | HTTPS port to access webapi                                                                                                                                                             |
| WASP_PEERING_PORT                 |           |     4000     | Peering port                                                                                                                                                                            |
| WASP_NANO_MSG_PORT                |           |     5550     | nano MSG port                                                                                                                                                                           |
| WASP_DATA_DIR                     |           |    .data     | Directory containing configuration, database etc.                                                                                                                                       |
| WASP_LEDGER_CONNECTION            |     x     |              | IOTA node url (txstream protocol) to connect to (GoShimmer txstream plugin uses port 5000 by default) WARNING: This parameter has no effect if WASP_LEDGER_NETWORK=shimmer              |
| DASHBOARD_USERNAME                |           |    admin     | Username to access dashboard                                                                                                                                                            |
| DASHBOARD_PASSWORD                |     x     |              | Password in clear text (not hashed, so take care!!!)                                                                                                                                    |
| WASP_WEBAPI_AUTH_SCHEME           |           |     jwt      | Defines scheme of authentication of client with the wasp node e.g. basic or jwt                                                                                                         |
| WASP_JWT_DURATION_HOURS           |           |      24      | Defines how log jwt tokens are valid (is used for webapi and dashboard)                                                                                                                 |
| WASP_PEERING_NETID                |           | 0.0.0.0:4000 | Peering netid needed to connect to other trusted wasp nodes (should be the nodes hostname and peering port and has to be unique in committee)                                           |
| WASP_TRUSTED_NODE_\[0-9\]+_NETID  |           |              | NetId of trusted node (the script `refresh_trusted_nodes.sh` reads all `WASP_TRUSTED_NODE_*` parameters from `.env` and calls `wasp-cli peering trust` to trust the configured nodes.)  |
| WASP_TRUSTED_NODE_\[0-9\]+_PUBKEY |           |              | Pubkey of trusted node (the script `refresh_trusted_nodes.sh` reads all `WASP_TRUSTED_NODE_*` parameters from `.env` and calls `wasp-cli peering trust` to trust the configured nodes.) |

## wasp-cli

wasp-cli can be executed in a docker image in order to e.g. add trusted nodes etc. Execute `prepare_cli.sh` in order to prepare for usage or activate eventually changed config parameters in `.env`. The script will output some hints how to use the wasp-cli comfortably.

| Parameter                           | Description                                                                                                                                                                                    |
| ----------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| WASP_CLI_WALLET_SEED                | Wallet seed to be used with wasp-cli. If not seed has been specified yet the `prepare_cli.sh` script will generate a seed by executing `wasp-cli init`. The seed is immediately set in `.env`. |
| WASP_CLI_COMMITTEE_\[0-9\]+_API     | WebAPI url of the node in the committee (e.g. https://host:448)                                                                                                                                |
| WASP_CLI_COMMITTEE_\[0-9\]+_NANOMSG | Nanomsg url of the node in the committee (e.g. host:5550)                                                                                                                                      |
| WASP_CLI_COMMITTEE_\[0-9\]+_PEERING | Peering url of the node in the committee (e.g. host:4000)                                                                                                                                      |
