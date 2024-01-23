# DLT.GREEN AUTOMATIC INX-GROUPFI-INSTALLER DOCKER

1. Create a file named `.env` (see parameter documentation below)
2. Run `./prepare_docker.sh` to conly create node config from values in .env
3. Run `./start.sh` to start the node
4. Check the logs using `./show_logs.sh`
5. Run `./stop.sh` to stop node

You will be able to access the api under (mind eventually configured port):
https://node.your-domain.com:<INX_GROUPFI_HTTPS_PORT>

Context roots:
- `/api` (inx-groupfi api)

## .env

```
INX_GROUPFI_VERSION=1.0.0
INX_GROUPFI_LEDGER_NETWORK=shimmer
# INX_GROUPFI_NETWORK=mainnet

# INX_GROUPFI_DATA_DIR=<absolute path to data dir>
# INX_GROUPFI_LOGLEVEL=warn
```

| Parameter                  | Mandatory | Default | Description                                           |
| -------------------------- | :-------: | :-----: | ----------------------------------------------------- |
| INX_GROUPFI_VERSION        |     x     |         | Version of `dltgreen/inx-groupfi` docker image to use |
| INX_GROUPFI_LEDGER_NETWORK |     x     |         | Allowed values: iota, shimmer                         |
| INX_GROUPFI_NETWORK        |           | mainnet | Allowed values: mainnet, testnet                      |
| INX_GROUPFI_DATA_DIR       |           | ./data  | Directory containing configuration, storage etc.      |
| INX_GROUPFI_LOGLEVEL       |           |  warn   | Sets the log level of inx-groupfi. e.g. info, warn    |