# DLT.GREEN AUTOMATIC INX-COLLECTOR-INSTALLER DOCKER

1. Create a file named `.env` (see parameter documentation below)
2. Run `./prepare_docker.sh` to conly create node config from values in .env
3. Run `./start.sh` to start the node
4. Check the logs using `./show_logs.sh`
5. Run `./stop.sh` to stop node

You will be able to access the api under (mind eventually configured port):
https://node.your-domain.com:<INX_COLLECTOR_HTTPS_PORT>

Your minio dashboard under (INX_COLLECTOR_MINIO_PORT):
https://node.your-domain.com:<INX_COLLECTOR_MINIO_PORT>

## .env

```
# SSL_CONFIG=letsencrypt
ACME_EMAIL=your-email@example.com
# or
# SSL_CONFIG=certs
# INX_COLLECTOR_CERT=<absolute path to cert>
# INX_COLLECTOR_KEY=<absolute path to key>

INX_COLLECTOR_VERSION=1.1.0
INX_COLLECTOR_HOST=node.your-domain.com
# INX_COLLECTOR_HTTP_PORT=80
# INX_COLLECTOR_HTTPS_PORT=443
# INX_COLLECTOR_MINIO_PORT=450
# INX_COLLECTO_DATA_DIR=<absolute path to data dir>

INX_COLLECTOR_MINIO_USER=<username>
INX_COLLECTOR_MINIO_PASSWORD=<secret>
INX_COLLECTOR_STORAGE_ACCESS_ID=<access_id>
INX_COLLECTOR_STORAGE_SECRET_KEY=<secret_key>
```

| Parameter                        | Mandatory |   Default   | Description                                                                                                                                                                             |
| -------------------------------- | :-------: | :---------: | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| COMPOSE_PROFILES                 |           |             | local-storage: use minio as local S3 storage                                                                                                                                            |
| INX_COLLECTOR_DATA_DIR           |           |   ./data    | Directory containing configuration, storage etc.                                                                                                                                        |
| INX_COLLECTOR_HOST               |     x     |             | Host domain name e.g. `inx-collector.dlt.green`                                                                                                                                         |
| INX_COLLECTOR_HTTP_PORT          |           |     80      | HTTP port to access api. Must be 80 if letsencrypt is used.                                                                                                                             |
| INX_COLLECTOR_HTTPS_PORT         |           |     443     | HTTPS port to access api                                                                                                                                                                |
| INX_COLLECTOR_MINIO_PORT         |           |     450     | Minio dashboard port (ssl)                                                                                                                                                              |
| SSL_CONFIG                       |           | letsencrypt | Allowed values: `certs`, `letsencrypt`. Default: `letsencrypt`. If set to certs `INX_COLLECTOR_SSL_CERT` and `INX_COLLECTOR_SSL_KEY` are used otherwise letsencrypt is used by default. |
| INX_COLLECTOR_SSL_CERT           |    (x)    |             | Absolute path to SSL certificate (mandatory if `SSL_CONFIG=certs`)                                                                                                                      |
| INX_COLLECTOR_SSL_KEY            |    (x)    |             | Absolute path to SSL private key (mandatory if `SSL_CONFIG=certs`)                                                                                                                      |
| INX_COLLECTOR_VERSION            |     x     |             | Version of `giordyfish/inx-collector` docker image to use                                                                                                                               |
| INX_COLLECTOR_MINIO_USER         |     x     |             | Minio root user                                                                                                                                                                         |
| INX_COLLECTOR_MINIO_PASSWORD     |     x     |             | Minio root password (in plain text)                                                                                                                                                     |
| INX_COLLECTOR_STORAGE_ACCESS_ID  |     x     |             | Minio access id (for inx-collector connection). Can be generated using `generate_minio_credentials.sh`                                                                                  |
| INX_COLLECTOR_STORAGE_SECRET_KEY |     x     |             | Minio secret key (for inx-collector connection). Can be generated using `generate_minio_credentials.sh`                                                                                 |
