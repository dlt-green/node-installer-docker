# DLT.GREEN AUTOMATIC INX-CHRONICLE-INSTALLER DOCKER

1. Create a file named `.env` (see parameter documentation below)
2. Run `./prepare_docker.sh` to conly create node config from values in .env
3. Run `./start.sh` to start the node
4. Check the logs using `./show_logs.sh`
5. Run `./stop.sh` to stop node

You will be able to access the api under (mind eventually configured port):
https://node.your-domain.com:<INX_CHRONICLE_HTTPS_PORT>

Context roots:
- `/api` (inx-chronicle api)
- /grafana (grafana dashboards)
- /influxdb (influxdb admini dashboard)
- /mongodb (mongo-express admin dashboard; only active in profile `debug`)

## .env

```
# COMPOSE_PROFILES=metrics,debug

# SSL_CONFIG=letsencrypt
ACME_EMAIL=your-email@example.com
# or
# SSL_CONFIG=certs
# INX_CHRONICLE_SSL_CERT=<absolute path to cert>
# INX_CHRONICLE_SSL_KEY=<absolute path to key>

INX_CHRONICLE_VERSION=1.0.0-rc.1
INX_CHRONICLE_HOST=node.your-domain.com
# INX_CHRONICLE_NETWORK=mainnet
# INX_CHRONICLE_HTTP_PORT=80
# INX_CHRONICLE_HTTPS_PORT=443

# INX_CHRONICLE_DATA_DIR=<absolute path to data dir>

# INX_CHRONICLE_MONGODB_USERNAME=mongodb
INX_CHRONICLE_MONGODB_PASSWORD=<secret>

# INX_CHRONICLE_INFLUXDB_USERNAME=influxdb
INX_CHRONICLE_INFLUXDB_PASSWORD=<secret>
INX_CHRONICLE_INFLUXDB_TOKEN=<secret_token>

INX_CHRONICLE_JWT_SALT=<salt>
INX_CHRONICLE_JWT_PASSWORD=<secret>
# INX_CHRONICLE_JWT_EXPIRATION=72h
# INX_CHRONICLE_SYNC_START=1

INX_CHRONICLE_GRAFANA_ADMIN_PASSWORD=<secret>
```

| Parameter                            | Mandatory |   Default   | Description                                                                                                                                                                             |
| ------------------------------------ | :-------: | :---------: | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| COMPOSE_PROFILES                     |           |             | Allowed values: metrics (grafana dashboard and collect mongodb metrics in influxdb), debug (mongo-express => mongodb admin dashboard)                                                   |
| SSL_CONFIG                           |           | letsencrypt | Allowed values: `certs`, `letsencrypt`. Default: `letsencrypt`. If set to certs `INX_CHRONICLE_SSL_CERT` and `INX_CHRONICLE_SSL_KEY` are used otherwise letsencrypt is used by default. |
| ACME_EMAIL                           |    (x)    |             | Mail address used to fetch SSL certificate from letsencrypt (mandatory if `SSL_CONFIG` not set or is set to `letsencrypt`).                                                             |
| INX_CHRONICLE_SSL_CERT               |    (x)    |             | Absolute path to SSL certificate (mandatory if `SSL_CONFIG=certs`)                                                                                                                      |
| INX_CHRONICLE_SSL_KEY                |    (x)    |             | Absolute path to SSL private key (mandatory if `SSL_CONFIG=certs`)                                                                                                                      |
| INX_CHRONICLE_VERSION                |     x     |             | Version of `iotaledger/inx-chronicle` docker image to use                                                                                                                               |
| INX_CHRONICLE_HOST                   |     x     |             | Host domain name e.g. `mynode.dlt.green`                                                                                                                                                |
| INX_CHRONICLE_NETWORK                |           |   mainnet   | Allowed values: mainnet, testnet                                                                                                                                                        |
| INX_CHRONICLE_HTTP_PORT              |           |     80      | HTTP port to access api. Must be 80 if letsencrypt is used.                                                                                                                             |
| INX_CHRONICLE_HTTPS_PORT             |           |     443     | HTTPS port to access api                                                                                                                                                                |
| INX_CHRONICLE_DATA_DIR               |           |   ./data    | Directory containing configuration, storage etc.                                                                                                                                        |
| INX_CHRONICLE_MONGODB_USERNAME       |           |   mongodb   | Username for MongoDB and mongo-express login                                                                                                                                            |
| INX_CHRONICLE_MONGODB_PASSWORD       |     x     |             | Password for MongoDB and mongo-express login                                                                                                                                            |
| INX_CHRONICLE_INFLUXDB_USERNAME      |           |  influxdb   | Username for InfluxDB login                                                                                                                                                             |
| INX_CHRONICLE_INFLUXDB_PASSWORD      |     x     |             | Password for InfluxDB login                                                                                                                                                             |
| INX_CHRONICLE_INFLUXDB_TOKEN         |     x     |             | Authentication token to authenticate grafana agains InfluxDB                                                                                                                            |
| INX_CHRONICLE_JWT_SALT               |     x     |             | Salt for JWT generation (restricted API access)                                                                                                                                         |
| INX_CHRONICLE_JWT_PASSWORD           |     x     |             | Password to fetch JWT token via `/login` (`POST` request with body `{"password": "<secret>"}`)                                                                                          |
| INX_CHRONICLE_JWT_EXPIRATION         |           |     72h     | Expiration period for JWT token                                                                                                                                                         |
| INX_CHRONICLE_SYNC_START             |           |      1      | Lowest milestone index to sync from                                                                                                                                                     |
| INX_CHRONICLE_GRAFANA_ADMIN_PASSWORD |     x     |             | Password for user `admin` on grafana                                                                                                                                                    |
