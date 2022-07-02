# DLT.GREEN AUTOMATIC BEE-INSTALLER DOCKER

1. Create a file named `.env` (see parameter documentation below)
2. Run `./prepare_docker.sh`
3. Run `docker-compose up -d`
4. Check the logs using `docker-compose -f logs`

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
# BEE_SSL_CERT=<absolute path to cert>
# BEE_SSL_KEY=<absolute path to key>

BEE_VERSION=0.3.1
BEE_HOST=node.your-domain.com
# BEE_NETWORK=mainnet
# BEE_HTTP_PORT=80
# BEE_HTTPS_PORT=443
# BEE_GOSSIP_PORT=15601
# BEE_AUTOPEERING_PORT=14636
# BEE_DATA_DIR=<absolute path to data dir>

# DASHBOARD_USERNAME=admin
DASHBOARD_PASSWORD=0000000000000000000000000000000000000000000000000000000000000000
DASHBOARD_SALT=0000000000000000000000000000000000000000000000000000000000000000
```

| Parameter            | Mandatory |   Default   | Description                                                                                                                                                         |
| -------------------- | :-------: | :---------: | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| BEE_VERSION          |     x     |             | Version of `iotaledger/bee` docker image to use                                                                                                                     |
| BEE_NETWORK          |           |   mainnet   | Allowed values: `mainnet`, `devnet`                                                                                                                                 |
| BEE_HOST             |     x     |             | Host domain name e.g. `bee.dlt.green`                                                                                                                               |
| BEE_HTTP_PORT        |           |     80      | HTTP port to access dashboard and api. Must be 80 if letsencrypt is used.                                                                                           |
| BEE_HTTPS_PORT       |           |     443     | HTTPS port to access dashboard and api                                                                                                                              |
| BEE_GOSSIP_PORT      |           |    15601    | Gossip port                                                                                                                                                         |
| BEE_AUTOPEERING_PORT |           |    14636    | Autopeering port                                                                                                                                                    |
| BEE_DATA_DIR         |           |    .data    | Directory containing configuration, database, snapshots etc.                                                                                                        |
| DASHBOARD_USERNAME   |           |    admin    | Username to access dashboard                                                                                                                                        |
| DASHBOARD_PASSWORD   |     x     |             | Password hash (can be generated with `docker-compose run --rm bee password` or non-interactively with `tools/password_scriptable.sh`)                               |
| DASHBOARD_SALT       |     x     |             | Password salt (can be generated with `docker-compose run --rm bee password` or non-interactively with `tools/password_scriptable.sh`)                               |
| SSL_CONFIG           |           | letsencrypt | Allowed values: `certs`, `letsencrypt`. Default: `letsencrypt`. If set to certs `BEE_SSL_CERT` and `BEE_SSL_KEY` are used otherwise letsencrypt is used by default. |
| BEE_SSL_CERT         |    (x)    |             | Absolute path to SSL certificate (mandatory if `SSL_CONFIG=certs`)                                                                                                  |
| BEE_SSL_KEY          |    (x)    |             | Absolute path to SSL private key (mandatory if `SSL_CONFIG=certs`)                                                                                                  |
| ACME_EMAIL           |    (x)    |             | Mail address used to fetch SSL certificate from letsencrypt (mandatory if `SSL_CONFIG` not set or is set to `letsencrypt`).                                         |
