# DLT.GREEN AUTOMATIC INSTALLER DOCKER

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
# DLTGREEN_SSL_CERT=<absolute path to cert>
# DLTGREEN_SSL_KEY=<absolute path to key>

# DLTGREEN_HTTP_PORT=80
# DLTGREEN_HTTPS_PORT=443
# DLTGREEN_DATA_DIR=<absolute path to data dir>
```

| Parameter           | Mandatory |   Default   | Description                                                                                                                                                                   |
| ------------------- | :-------: | :---------: | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| SSL_CONFIG          |           | letsencrypt | Allowed values: `certs`, `letsencrypt`. Default: `letsencrypt`. If set to certs `DLTGREEN_SSL_CERT` and `DLTGREEN_SSL_KEY` are used otherwise letsencrypt is used by default. |
| DLTGREEN_SSL_CERT   |    (x)    |             | Absolute path to SSL certificate (mandatory if `SSL_CONFIG=certs`)                                                                                                            |
| DLTGREEN_SSL_KEY    |    (x)    |             | Absolute path to SSL private key (mandatory if `SSL_CONFIG=certs`)                                                                                                            |
| ACME_EMAIL          |    (x)    |             | Mail address used to fetch SSL certificate from letsencrypt (mandatory if `SSL_CONFIG` not set or is set to `letsencrypt`).                                                   |
| DLTGREEN_HOST       |     x     |             | Host domain name e.g. `somehost.dlt.green`                                                                                                                                    |
| DLTGREEN_HTTP_PORT  |           |     80      | HTTP port. Must be 80 if letsencrypt is used.                                                                                                                                 |
| DLTGREEN_HTTPS_PORT |           |     443     | HTTPS port                                                                                                                                                                    |
| DLTGREEN_DATA_DIR   |           |   ./data    | Directory containing configuration etc.                                                                                                                                       |
