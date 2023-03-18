# DLT.GREEN AUTOMATIC PIPE-INSTALLER DOCKER

1. Create a file named `.env` (see parameter documentation below)
2. Execute `generate_seed.sh` and use the information in the JSON output to fill `PIPE_ADDRESS`, `PIPE_SEED` and `PIPE_MNEMONIC_PHRASE` in `.env`
3. Run `./prepare_docker.sh` to only create node config from values in .env
4. Run `./start.sh` to start the node
5. Check the logs using `./show_logs.sh`
6. Run `./stop.sh` to stop node

## .env

```
PIPE_VERSION=0.3
PIPE_SEED=00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
# PIPE_DATA_DIR=<absolute path to data dir>
# PIPE_MNEMONIC_PHRASE="latin duck enhance glove fire render rubber rural rice hover economy advice member faith dash piano kite host yard glove captain color hotel blade"
# PIPE_ADDRESS=<node_address>
# PIPE_PORT=13266
# PIPE_MAX_STORAGE=64GB
# PIPE_LOG_LEVEL=info
```

| Parameter            | Mandatory | Default | Description                                                                                                                                            |
| -------------------- | :-------: | :-----: | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| PIPE_DATA_DIR        |           | ./data  | Directory containing configuration, storage etc.                                                                                                       |
| PIPE_VERSION         |     x     |         | Version of `pipe` docker image to use                                                                                                                  |
| PIPE_PORT            |           |  13266  | Node port to use                                                                                                                                       |
| PIPE_ADDRESS         |           |         | Node address (not necessary to start node; can be generated with `generate_seed.sh` or `docker compose run --rm pipe --action=keygen`)                 |
| PIPE_SEED            |     x     |         | Node seed (can be generated with `generate_seed.sh` or `docker compose run --rm pipe --action=keygen`)                                                 |
| PIPE_MNEMONIC_PHRASE |           |         | Node seed as mnemonic phrase (not necessary to start node; can be generated with `generate_seed.sh` or `docker compose run --rm pipe --action=keygen`) |
| PIPE_MAX_STORAGE     |           |  64GB   | Max storage pipe will use; oldest data will be purged first if storage limit is reached                                                                |
| PIPE_LOG_LEVEL       |           |  info   | Log level; Allowed values: `error`, `warn`, `info`, `debug`, `trace`                                                                                   |

## Scripts

| Script                              | Description                                                             |
| ----------------------------------- | ----------------------------------------------------------------------- |
| `scripts/get_available_versions.sh` | Prints all tags/versions available for image `docker.tanglehub.eu:pipe` |