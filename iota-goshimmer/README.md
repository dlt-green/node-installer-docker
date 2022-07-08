# DLT.GREEN AUTOMATIC GOSHIMMER-INSTALLER DOCKER

1. Create a file named `.env` (see parameter documentation below)
2. Run `./prepare_docker.sh`
3. Run `docker-compose up -d`
4. Check the logs using `docker-compose -f logs`

You will be able to access your node under  (mind eventually configured port):
https://node.your-domain.com/info

Your dashboard under (mind eventually configured port):
https://node.your-domain.com/dashboard

## .env

```
# SSL_CONFIG=letsencrypt
ACME_EMAIL=your-email@example.com
# or
# SSL_CONFIG=certs
# GOSHIMMER_SSL_CERT=<absolute path to cert>
# GOSHIMMER_SSL_KEY=<absolute path to key>

GOSHIMMER_VERSION=0.9.1
GOSHIMMER_HOST=node.your-domain.com
# GOSHIMMER_HTTP_PORT=80
# GOSHIMMER_HTTPS_PORT=443
# GOSHIMMER_GOSSIP_PORT=14666
# GOSHIMMER_AUTOPEERING_PORT=14646
# GOSHIMMER_DATA_DIR=<absolute path to data dir>

# DASHBOARD_USERNAME=admin
# DASHBOARD_PASSWORD=****
```

| Parameter                  | Mandatory |     Default     | Description                                                                                                                                                                     |
| -------------------------- | :-------: | :-------------: | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GOSHIMMER_VERSION          |     x     |                 | Version of `iotaledger/goshimmer` docker image to use                                                                                                                           |
| GOSHIMMER_HOST             |     x     |                 | Host domain name e.g. `goshimmer.dlt.green`                                                                                                                                     |
| GOSHIMMER_HTTP_PORT        |           |       80        | HTTP port to access dashboard and api. Must be 80 if letsencrypt is used.                                                                                                       |
| GOSHIMMER_HTTPS_PORT       |           |       443       | HTTPS port to access dashboard and api                                                                                                                                          |
| GOSHIMMER_GOSSIP_PORT      |           |      14666      | Gossip port                                                                                                                                                                     |
| GOSHIMMER_AUTOPEERING_PORT |           |      14646      | Autopeering port                                                                                                                                                                |
| GOSHIMMER_DATA_DIR         |           |      .data      | Directory containing configuration, database, snapshots etc.                                                                                                                    |
| DASHBOARD_USERNAME         |           |      admin      | Username to access dashboard                                                                                                                                                    |
| DASHBOARD_PASSWORD         |           | _auth disabled_ | Password in clear text (not hashed, so take care!!!). If this parameter is not set there will be no authentication at all.                                                      |
| SSL_CONFIG                 |           |   letsencrypt   | Allowed values: `certs`, `letsencrypt`. Default: `letsencrypt`. If set to certs `GOSHIMMER_SSL_CERT` and `GOSHIMMER_SSL_KEY` are used otherwise letsencrypt is used by default. |
| GOSHIMMER_SSL_CERT         |    (x)    |                 | Absolute path to SSL certificate (mandatory if `SSL_CONFIG=certs`)                                                                                                              |
| GOSHIMMER_SSL_KEY          |    (x)    |                 | Absolute path to SSL private key (mandatory if `SSL_CONFIG=certs`)                                                                                                              |
| ACME_EMAIL                 |    (x)    |                 | Mail address used to fetch SSL certificate from letsencrypt (mandatory if `SSL_CONFIG` not set or is set to `letsencrypt`).                                                     |
