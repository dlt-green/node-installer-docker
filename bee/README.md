# DLT.GREEN AUTOMATIC BEE-INSTALLER DOCKER

Create a file named `.env` containing

```
NETWORK=mainnet|devnet

ACME_EMAIL=your-email@example.com

BEE_HOST=node.your-domain.com
BEE_HTTP_PORT=20080
BEE_HTTPS_PORT=20443
BEE_GOSSIP_PORT=15610
BEE_AUTOPEERING_PORT=14636

DASHBOARD_USERNAME=admin
DASHBOARD_PASSWORD=0000000000000000000000000000000000000000000000000000000000000000
DASHBOARD_SALT=0000000000000000000000000000000000000000000000000000000000000000
```

Run `./prepare_docker.sh` to create the `data` folder with correct permissions and bee config.

You can generate your own dashboard password and salt by running:
`docker-compose run bee tool pwd-hash`

Change the values accordingly, then run `docker-compose up -d`

You can check the logs using `docker-compose logs`

You will be able to access your node under:
https://node.your-domain.com/api/core/v2/info

Your dashboard under:
https://node.your-domain.com/dashboard

