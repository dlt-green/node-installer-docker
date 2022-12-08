# DLT.GREEN AUTOMATIC PIPE-INSTALLER DOCKER

1. Create a file named `.env` (see parameter documentation below)
2. Run `./prepare_docker.sh` to only create node config from values in .env
3. Run `./start.sh` to start the node
4. Check the logs using `./show_logs.sh`
5. Run `./stop.sh` to stop node

## .env

```
PIPE_VERSION=0.2
PIPE_SEED=00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
# PIPE_MNEMONIC_PHRASE="latin duck enhance glove fire render rubber rural rice hover economy advice member faith dash piano kite host yard glove captain color hotel blade"
# PIPE_ADDRESS=<node_address>
# PIPE_PORT=13266
# PIPE_BOOTSTRAP_NODE_0=cGi9M4NQ5KRYIiRnZT51s4gdQ32Ygm0V7_tP8lAW3acJBnhcqbUJLHIsBKYPI7qn@192.168.1.180:13266~bootstrap
# PIPE_LOG_LEVEL=info
```

| Parameter                    | Mandatory |  Default  | Description                                                                                                                                            |
| ---------------------------- | :-------: | :-------: | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| PIPE_VERSION                 |     x     |           | Version of `pipe` docker image to use                                                                                                                  |
| PIPE_PORT                    |           |   13266   | Node port to use                                                                                                                                       |
| PIPE_SEED                    |     x     |           | Node seed (can be generated with `generate_seed.sh` or `docker compose run --rm pipe --action=keygen`)                                                 |
| PIPE_MNEMONIC_PHRASE         |           |           | Node seed as mnemonic phrase (not necessary to start node; can be generated with `generate_seed.sh` or `docker compose run --rm pipe --action=keygen`) |
| PIPE_ADDRESS                 |           |           | Node address (not necessary to start node; can be generated with `generate_seed.sh` or `docker compose run --rm pipe --action=keygen`)                 |
| PIPE_BOOTSTRAP_NODE_\[0-9\]+ |           | <default> | Bootstrap nodes to connect to on start; number starting from 0                                                                                         |
| PIPE_LOG_LEVEL               |           |   info    | Log level; Allowed values: `error`, `warn`, `info`, `debug`, `trace`                                                                                   |
