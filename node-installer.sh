
#!/bin/sh

rm -r shimmer.sh
clear
echo ""
echo "╔═════════════════════════════════════════════════════════════════════════════╗"
echo "║            DLT.GREEN AUTOMATIC SHIMMER INSTALLATION WITH DOCKER             ║"
echo "╚═════════════════════════════════════════════════════════════════════════════╝"
echo ""

read -p 'Press [Enter] key to continue...' W

cd /var/lib/hornet
docker-compose down
sudo apt-get install jq -y

echo ""
echo "╔═════════════════════════════════════════════════════════════════════════════╗"
echo "║   Update and install packages to allow apt to use a repository over HTTPS   ║"
echo "╚═════════════════════════════════════════════════════════════════════════════╝"
echo ""

sudo apt-get update

sudo apt-get install \
   ca-certificates \
   curl \
   gnupg \
   lsb-release

echo ""
echo "╔═════════════════════════════════════════════════════════════════════════════╗"
echo "║                        Add dockers official GPG key                         ║"
echo "╚═════════════════════════════════════════════════════════════════════════════╝"
echo ""

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo ""
echo "╔═════════════════════════════════════════════════════════════════════════════╗"
echo "║                          Now set up the repository                          ║"
echo "╚═════════════════════════════════════════════════════════════════════════════╝"
echo ""

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo ""
echo "╔═════════════════════════════════════════════════════════════════════════════╗"
echo "║                            Install docker engine                            ║"
echo "╚═════════════════════════════════════════════════════════════════════════════╝"
echo ""

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-compose -y

echo ""
echo "╔═════════════════════════════════════════════════════════════════════════════╗"
echo "║                   Create hornet directory /var/lib/hornet                   ║"
echo "╚═════════════════════════════════════════════════════════════════════════════╝"
echo ""

cd /var/lib
mkdir hornet
cd hornet

echo ""
echo "╔═════════════════════════════════════════════════════════════════════════════╗"
echo "║                   Pull repo from iotaledger/hornet:develop                  ║"
echo "╚═════════════════════════════════════════════════════════════════════════════╝"
echo ""

wget -cO - https://github.com/iotaledger/hornet/releases/download/v2.0.0-alpha20/HORNET-2.0.0-alpha20-docker-example.tar.gz > install.tar.gz

echo "unpack:"
tar -xzf install.tar.gz

echo "remove tar.gz:"
rm -r install.tar.gz

echo ""
echo "╔═════════════════════════════════════════════════════════════════════════════╗"
echo "║                               Set parameter                                 ║"
echo "╚═════════════════════════════════════════════════════════════════════════════╝"
echo ""

cd /var/lib/hornet

read -p 'Set domain-name: ' VAR_HORNET_HOST
read -p 'Set mail for certificat renewal: ' VAR_ACME_EMAIL
read -p 'Set dashboard username: ' VAR_USERNAME
read -p 'Set password (blank): ' VAR_PASSWORD

credentials=$(docker-compose run --rm hornet tool pwd-hash --json --password $VAR_PASSWORD | sed -e 's/\r//g')

VAR_DASHBOARD_PASSWORD=$(echo $credentials | jq -r '.passwordHash')
VAR_DASHBOARD_SALT=$(echo $credentials | jq -r '.passwordSalt')

cd /var/lib/hornet
rm .env

echo "ACME_EMAIL=$VAR_ACME_EMAIL" >> .env
echo "HORNET_HOST=$VAR_HORNET_HOST" >> .env
echo "DASHBOARD_HOST=dashboard.$VAR_HORNET_HOST" >> .env
echo "DASHBOARD_USERNAME=$VAR_USERNAME" >> .env
echo "DASHBOARD_PASSWORD=$VAR_DASHBOARD_PASSWORD" >> .env
echo "DASHBOARD_SALT=$VAR_DASHBOARD_SALT" >> .env
echo "GRAFANA_HOST=grafana.$VAR_HORNET_HOST" >> .env

sed "/alias/s/node/$VAR_HORNET_HOST/g" config.json > config_tmp.json
mv config_tmp.json config.json

echo ""
echo "╔═════════════════════════════════════════════════════════════════════════════╗"
echo "║                               Prepare docker                                ║"
echo "╚═════════════════════════════════════════════════════════════════════════════╝"
echo ""

cd /var/lib/hornet/
./prepare_docker.sh

echo ""
echo "╔═════════════════════════════════════════════════════════════════════════════╗"
echo "║                                Start Hornet                                 ║"
echo "╚═════════════════════════════════════════════════════════════════════════════╝"
echo ""

cd /var/lib/hornet/
docker-compose up -d
docker exec -it grafana grafana-cli admin reset-admin-password $VAR_PASSWORD

echo ""
echo "═══════════════════════════════════════════════════════════════════════════════"
echo " Hornet Dashboard: https://dashboard.$VAR_HORNET_HOST"
echo " Hornet Password: <set during install>"
echo " Grafana Dashboard: https://grafana.$VAR_HORNET_HOST"
echo " Grafana Username: admin"
echo " Grafana Password: <same as hornet password>"
echo "═══════════════════════════════════════════════════════════════════════════════"
echo ""
