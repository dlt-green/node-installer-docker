# DLT.GREEN AUTOMATIC HORNET-INSTALLER DOCKER

1. Create a file named `.env` (see parameter documentation below)
2. Run `./prepare_docker.sh` to conly create node config from values in .env
3. Run `./start.sh` to start the node
4. Check the logs using `./show_logs.sh`
5. Run `./stop.sh` to stop node

You will be able to access your node under  (mind eventually configured port):
https://node.your-domain.com/api/v1/info

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

HORNET_VERSION=1.2.1
HORNET_HOST=node.your-domain.com
# HORNET_NODE_ALIAS=HORNET mainnet node
# HORNET_NETWORK=mainnet
# HORNET_HTTP_PORT=80
# HORNET_HTTPS_PORT=443
# HORNET_GOSSIP_PORT=15600
# HORNET_AUTOPEERING_PORT=14626
# HORNET_DATA_DIR=<absolute path to data dir>
# HORNET_PRUNING_TARGET_SIZE=64GB
# HORNET_PRUNING_MAX_MILESTONES_TO_KEEP=60480
# HORNET_POW_ENABLED=false

# DASHBOARD_USERNAME=admin
DASHBOARD_PASSWORD=0000000000000000000000000000000000000000000000000000000000000000
DASHBOARD_SALT=0000000000000000000000000000000000000000000000000000000000000000

# RESTAPI_SALT=0000000000000000000000000000000000000000000000000000000000000000
```

| Parameter                             | Mandatory |       Default       | Description                                                                                                                                                                      |
| ------------------------------------- | :-------: | :-----------------: | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| HORNET_VERSION                        |     x     |                     | Version of `dltgreen/iota-hornet` docker image to use                                                                                                                            |
| HORNET_NETWORK                        |           |       mainnet       | Allowed values: `mainnet`, `devnet`                                                                                                                                              |
| HORNET_NODE_ALIAS                     |           | HORNET mainnet node | Node alias                                                                                                                                                                       |
| HORNET_HOST                           |     x     |                     | Host domain name e.g. `hornet.dlt.green`                                                                                                                                         |
| HORNET_HTTP_PORT                      |           |         80          | HTTP port to access dashboard and api. Must be 80 if letsencrypt is used.                                                                                                        |
| HORNET_HTTPS_PORT                     |           |         443         | HTTPS port to access dashboard and api                                                                                                                                           |
| HORNET_GOSSIP_PORT                    |           |        15600        | Gossip port                                                                                                                                                                      |
| HORNET_AUTOPEERING_PORT               |           |        14626        | Autopeering port                                                                                                                                                                 |
| HORNET_DATA_DIR                       |           |        .data        | Directory containing configuration, database, snapshots etc.                                                                                                                     |
| HORNET_PRUNING_TARGET_SIZE            |           |        64GB         | Target size of database                                                                                                                                                          |
| HORNET_PRUNING_MAX_MILESTONES_TO_KEEP |           |        60480        | Max umber of milestones to keep in database. Milestone pruning is disabled by default. It's activated if this parameter is set.                                                  |
| HORNET_POW_ENABLED                    |           |        false        | Whether the node does PoW if messages are received via API                                                                                                                       |
| DASHBOARD_USERNAME                    |           |        admin        | Username to access dashboard                                                                                                                                                     |
| DASHBOARD_PASSWORD                    |     x     |                     | Password hash (can be generated with `docker compose run hornet tool pwd-hash` or non-interactively with `docker compose run hornet tool pwd-hash --json --password <password>`) |
| DASHBOARD_SALT                        |     x     |                     | Password salt (can be generated with `docker compose run hornet tool pwd-hash` or non-interactively with `docker compose run hornet tool pwd-hash --json --password <password>`) |
| RESTAPI_SALT                          |           |   <random-string>   | Some random secret string used to generate (and validate) JWT tokens. If not given a random string is generated by `prepare_docker.sh` for security reasons                      |
| SSL_CONFIG                            |           |     letsencrypt     | Allowed values: `certs`, `letsencrypt`. Default: `letsencrypt`. If set to certs `HORNET_SSL_CERT` and `HORNET_SSL_KEY` are used otherwise letsencrypt is used by default.        |
| HORNET_SSL_CERT                       |    (x)    |                     | Absolute path to SSL certificate (mandatory if `SSL_CONFIG=certs`)                                                                                                               |
| HORNET_SSL_KEY                        |    (x)    |                     | Absolute path to SSL private key (mandatory if `SSL_CONFIG=certs`)                                                                                                               |
| ACME_EMAIL                            |    (x)    |                     | Mail address used to fetch SSL certificate from letsencrypt (mandatory if `SSL_CONFIG` not set or is set to `letsencrypt`).                                                      |
