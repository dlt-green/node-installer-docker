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
# INX_COLLECTOR_SSL_CERT=<absolute path to cert>
# INX_COLLECTOR_SSL_KEY=<absolute path to key>

INX_COLLECTOR_VERSION=1.1.0
INX_COLLECTOR_HOST=node.your-domain.com
INX_COLLECTOR_LEDGER_NETWORK=shimmer
# INX_COLLECTOR_NETWORK=mainnet
# INX_COLLECTOR_HTTP_PORT=80
# INX_COLLECTOR_HTTPS_PORT=443
# INX_COLLECTOR_MINIO_PORT=450

# INX_COLLECTOR_DATA_DIR=<absolute path to data dir>

# COMPOSE_PROFILES=local-storage
# INX_COLLECTOR_MINIO_USER=<username>
# INX_COLLECTOR_MINIO_PASSWORD=<secret>
INX_COLLECTOR_STORAGE_ACCESS_ID=<access_id>
INX_COLLECTOR_STORAGE_SECRET_KEY=<secret_key>

# INX_COLLECTOR_STORAGE_ENDPOINT=minio:9000
# INX_COLLECTOR_STORAGE_REGION=eu-south-1
# INX_COLLECTOR_STORAGE_EXTENSION=
# INX_COLLECTOR_STORAGE_SECURE=false
# INX_COLLECTOR_STORAGE_BUCKET_NAME=${INX_COLLECTOR_LEDGER_NETWORK}-${INX_COLLECTOR_NETWORK}-default
# INX_COLLECTOR_STORAGE_BUCKET_EXPIRATION_DAYS=30
# INX_COLLECTOR_POI_URL=http://inx-poi:9687
# INX_COLLECTOR_POI_PLUGIN=true
# INX_COLLECTOR_LISTENER_FILTERS=
```

| Parameter                                    | Mandatory |       Default       | Description                                                                                                                                                                             |
| -------------------------------------------- | :-------: | :-----------------: | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| COMPOSE_PROFILES                             |           |                     | Allowed values: local-storage (use minio as local S3 storage)                                                                                                                           |
| INX_COLLECTOR_LEDGER_NETWORK                 |     x     |                     | Allowed values: iota, shimmer                                                                                                                                                           |
| INX_COLLECTOR_NETWORK                        |           |       mainnet       | Allowed values: mainnet, testnet                                                                                                                                                        |
| INX_COLLECTOR_DATA_DIR                       |           |       ./data        | Directory containing configuration, storage etc.                                                                                                                                        |
| INX_COLLECTOR_HOST                           |     x     |                     | Host domain name e.g. `mynode.dlt.green`                                                                                                                                                |
| INX_COLLECTOR_HTTP_PORT                      |           |         80          | HTTP port to access api. Must be 80 if letsencrypt is used.                                                                                                                             |
| INX_COLLECTOR_HTTPS_PORT                     |           |         443         | HTTPS port to access api                                                                                                                                                                |
| INX_COLLECTOR_MINIO_PORT                     |           |         450         | Minio dashboard port (ssl)                                                                                                                                                              |
| SSL_CONFIG                                   |           |     letsencrypt     | Allowed values: `certs`, `letsencrypt`. Default: `letsencrypt`. If set to certs `INX_COLLECTOR_SSL_CERT` and `INX_COLLECTOR_SSL_KEY` are used otherwise letsencrypt is used by default. |
| INX_COLLECTOR_SSL_CERT                       |    (x)    |                     | Absolute path to SSL certificate (mandatory if `SSL_CONFIG=certs`)                                                                                                                      |
| INX_COLLECTOR_SSL_KEY                        |    (x)    |                     | Absolute path to SSL private key (mandatory if `SSL_CONFIG=certs`)                                                                                                                      |
| INX_COLLECTOR_VERSION                        |     x     |                     | Version of `giordyfish/inx-collector` docker image to use                                                                                                                               |
| INX_COLLECTOR_MINIO_USER                     |     x     |                     | Minio root user                                                                                                                                                                         |
| INX_COLLECTOR_MINIO_PASSWORD                 |     x     |                     | Minio root password (in plain text)                                                                                                                                                     |
| INX_COLLECTOR_STORAGE_ACCESS_ID              |     x     |                     | Defines the access id for the S3 storage. Can be generated using `generate_minio_credentials.sh` if using local-storage (minio).                                                        |
| INX_COLLECTOR_STORAGE_SECRET_KEY             |     x     |                     | Defines the password for the given access id of the S3 storage. Can be generated using `generate_minio_credentials.sh` if using local-storage (minio).                                  |
| INX_COLLECTOR_STORAGE_ENDPOINT               |           |     minio:9000      | Defines the endpoint for the S3 storage                                                                                                                                                 |
| INX_COLLECTOR_STORAGE_REGION                 |           |     eu-south-1      | Defines the region of the S3 storage                                                                                                                                                    |
| INX_COLLECTOR_STORAGE_EXTENSION              |           |                     | Sets the file extension for the object inside the storage                                                                                                                               |
| INX_COLLECTOR_STORAGE_SECURE                 |           |        false        | Defines whether the connection to S3 storage should be secure (SSL)                                                                                                                     |
| INX_COLLECTOR_STORAGE_BUCKET_NAME            |           |                     | Sets the default bucket's name. If not set, default value is `${INX_COLLECTOR_LEDGER_NETWORK}-${INX_COLLECTOR_NETWORK}-default`                                                         |
| INX_COLLECTOR_STORAGE_BUCKET_EXPIRATION_DAYS |           |         30          | Sets the default bucket's expiration days                                                                                                                                               |
| INX_COLLECTOR_POI_URL                        |           | http://inx-poi:9687 | Defines the url of an exposed POI API                                                                                                                                                   |
| INX_COLLECTOR_POI_PLUGIN                     |           |        true         | Defines whether the POI host is a POI plugin or a hornet node with an active plugin                                                                                                     |
| INX_COLLECTOR_LISTENER_FILTERS               |           |                     | A json string which sets startup filters                                                                                                                                                |

## How to configure inx-collector?

Further information and instructions regarding the inx-collector configuration can be found [here](https://github.com/teleconsys/inx-collector/blob/main/INSTRUCTIONS.md).

## How to use local or remote storage?

inx-collector needs an S3 compatible storage solution. The storage can be local or one could also connect a remote S3 storage (e.g. Amazon S3).
The connection can be configured using the `INX_COLLECTOR_STORAGE_*` parameters.

It's also possible to run a local storage solution [minio](https://min.io/) with the environment.
In this case the following configurations are necessary:

- `COMPOSE_PROFILES=local-storage`
- `INX_COLLECTOR_MINIO_PORT=450`
- `INX_COLLECTOR_MINIO_USER=username`
- `INX_COLLECTOR_MINIO_PASSWORD=password`
- `INX_COLLECTOR_STORAGE_ACCESS_ID=access_id generated using generate_minio_credentials.sh`
- `INX_COLLECTOR_STORAGE_SECRET_KEY=secret_key generated using generate_minio_credentials.sh`

Minio comes with a web dashboard that can be accessed by https://node.your-domain.com:`<INX_COLLECTOR_MINIO_PORT>` with
the crendentials set via `INX_COLLECTOR_MINIO_USER` and `INX_COLLECTOR_MINIO_PASSWORD`.
