# DLT.GREEN AUTOMATIC PIPE-INSTALLER DOCKER

### Bootstrap node
1. Create a file named `.env` (see parameter documentation below)
2. Execute `generate_seed.sh` and use the information in the JSON output to fill `PIPE_ADDRESS`, `PIPE_SEED` and `PIPE_MNEMONIC_PHRASE` in `.env`
3. Start a bootstrap node (`PIPE_IS_BOOTSTRAP_NODE=true`) all other nodes can connect to. `PIPE_BOOTSTRAP_NODE_*` do not have to exist.
4. Execute `get_bootstrap_param.sh` to geht the information to be set in `PIPE_BOOTSTRAP_NODE_0` parameters of all other nodes of the network.
5. Further bootstrap nodes (`PIPE_BOOTSTRAP_NODE_*`) can be added.
6. Run `./prepare_docker.sh` to only create node config from values in .env
7. Run `./start.sh` to start the node
8. Check the logs using `./show_logs.sh`
9. Run `./stop.sh` to stop node

### Non-bootstrap nodes
1. Create a file named `.env` (see parameter documentation below)
2. Execute `generate_seed.sh` and use the information in the JSON output to fill `PIPE_ADDRESS`, `PIPE_SEED` and `PIPE_MNEMONIC_PHRASE` in `.env`
3. Set `PIPE_BOOTSTRAP_NODE_0` with the information of the bootstrap node
4. Further bootstrap nodes can be added if wanted
5. Run `./prepare_docker.sh` to only create node config from values in .env
6. Run `./start.sh` to start the node
7. Check the logs using `./show_logs.sh`
8. Run `./stop.sh` to stop node

## .env

```
PIPE_VERSION=0.2
PIPE_SEED=00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
# PIPE_DATA_DIR=<absolute path to data dir>
# PIPE_MNEMONIC_PHRASE="latin duck enhance glove fire render rubber rural rice hover economy advice member faith dash piano kite host yard glove captain color hotel blade"
# PIPE_ADDRESS=<node_address>
# PIPE_PORT=13266
# PIPE_IS_BOOTSTRAP_NODE=false
# PIPE_BOOTSTRAP_NODE_0=ChhvVeGZUm5lAhKSNpz2OFHu9G8kMXiLC8UxodbH7iHbXiVfmAryXe9ABIKgS5UKS@77.174.83.189:13266~chhvvegzum5lahks.ion.ooo:13266
# PIPE_LOG_LEVEL=info
```

| Parameter                    | Mandatory | Default | Description                                                                                                                                                                                      |
| ---------------------------- | :-------: | :-----: | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| PIPE_DATA_DIR                |           | ./data  | Directory containing configuration, storage etc.                                                                                                                                                 |
| PIPE_VERSION                 |     x     |         | Version of `pipe` docker image to use                                                                                                                                                            |
| PIPE_PORT                    |           |  13266  | Node port to use                                                                                                                                                                                 |
| PIPE_ADDRESS                 |           |         | Node address (not necessary to start node; can be generated with `generate_seed.sh` or `docker compose run --rm pipe --action=keygen`)                                                           |
| PIPE_SEED                    |     x     |         | Node seed (can be generated with `generate_seed.sh` or `docker compose run --rm pipe --action=keygen`)                                                                                           |
| PIPE_MNEMONIC_PHRASE         |           |         | Node seed as mnemonic phrase (not necessary to start node; can be generated with `generate_seed.sh` or `docker compose run --rm pipe --action=keygen`)                                           |
| PIPE_IS_BOOTSTRAP_NODE       |           |  false  | Boolean if this node should have the capability `Bootstrap`                                                                                                                                      |
| PIPE_BOOTSTRAP_NODE_\[0-9\]+ |    (x)    |         | mandatory if `PIPE_IS_BOOTSTRAP_NODE` != true; Bootstrap nodes to connect to on start; number starting from 0; use `get_bootstrap_param.sh` on a bootstrap node to get the information to be set |
| PIPE_LOG_LEVEL               |           |  info   | Log level; Allowed values: `error`, `warn`, `info`, `debug`, `trace`                                                                                                                             |
