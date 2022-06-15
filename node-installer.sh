#!/bin/sh

clear
echo "####################################################"
echo "DLT.GREEN AUTOMATIC SHIMMER INSTALLATION WITH DOCKER"
echo "####################################################"

read -p 'Press [Enter] key to continue...' W

cd /var/lib/hornet
docker-compose down
sudo apt-get install jq -y

clear
echo "##############################################################################################"
echo "Update the apt package index and install packages to allow apt to use a repository over HTTPS:"
echo "##############################################################################################"

read -p 'Press [Enter] key to continue...' W

sudo apt-get update

sudo apt-get install \
   ca-certificates \
   curl \
   gnupg \
   lsb-release

clear
echo "#############################"
echo "Add dockers official GPG key:"
echo "#############################"

read -p 'Press [Enter] key to continue...' W

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

clear
echo "##########################"
echo "Now set up the repository:"
echo "##########################"

read -p 'Press [Enter] key to continue...' W

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

clear
echo "######################"
echo "Install docker engine:"
echo "######################"

read -p 'Press [Enter] key to continue...' W

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-compose -y

clear
echo "#########################################"
echo "Create hornet directory /var/lib/hornet:"
echo "#########################################"

read -p 'Press [Enter] key to continue...' W

cd /var/lib
mkdir hornet
cd hornet

clear
echo "##############################################################"
echo "Pull Repo DEVELOP:"
echo "from pre release https://github.com/iotaledger/hornet/releases"
echo "##############################################################"

read -p 'Press [Enter] key to continue...' W

wget -cO - https://github.com/iotaledger/hornet/tarball/develop > install.tar.gz

echo "unpack:"
tar -xzf install.tar.gz

echo "remove tar.gz:"
rm -r install.tar.gz

clear
echo "#####################"
echo "Set parameter:"
echo "#####################"

read -p 'Press [Enter] key to continue...' W

cd /var/lib/hornet/

read -p 'Set domain-name: ' VAR_HORNET_HOST
read -p 'Set mail for certificat renewal: ' VAR_ACME_EMAIL
read -p 'Set dashboard username: ' VAR_USERNAME
read -p 'Set password (blank): ' VAR_PASSWORD

VAR_USERNAME=${VAR_USERNAME:=admin}
sed "/username/s/admin/$VAR_USERNAME/g" config.json > config_tmp.json
mv config_tmp.json config.json

credentials=$(docker-compose run --rm hornet tool pwd-hash --json --password $VAR_PASSWORD | sed -e 's/\r//g')

VAR_DASHBOARD_PASSWORD=$(echo $credentials | jq -r '.passwordHash')
VAR_DASHBOARD_SALT=$(echo $credentials | jq -r '.passwordSalt')

clear
echo "##############"
echo "generate .env:"
echo "##############"

read -p 'Press [Enter] key to continue...' W

cd /var/lib/hornet/
rm .env

echo "ACME_EMAIL=$VAR_ACME_EMAIL" >> .env
echo "HORNET_HOST=$VAR_HORNET_HOST" >> .env
echo "DASHBOARD_HOST=dashboard.$VAR_HORNET_HOST" >> .env
echo "DASHBOARD_PASSWORD=$VAR_DASHBOARD_PASSWORD" >> .env
echo "DASHBOARD_SALT=$VAR_DASHBOARD_SALT" >> .env
echo "GRAFANA_HOST=grafana.$VAR_HORNET_HOST" >> .env

sed "/alias/s/node/$VAR_HORNET_HOST/g" config.json > config_tmp.json
mv config_tmp.json config.json

clear
echo "###############"
echo "prepare docker:"
echo "###############"

read -p 'Press [Enter] key to continue...' W

cd /var/lib/hornet/
./prepare_docker.sh

clear
echo "#########################"
echo "prepare and start hornet:"
echo "#########################"

read -p 'Press [Enter] key to continue...' W

cd /var/lib/hornet/
docker-compose up -d
docker exec -it grafana grafana-cli admin reset-admin-password $VAR_PASSWORD

clear
echo "###############################################################################"
echo "Hornet Dashboard: https://dashboard.$VAR_HORNET_HOST"
echo "Hornet Password: <set during install>"
echo "Grafana Dashboard: https://grafana.$VAR_HORNET_HOST"
echo "Grafana Username: admin"
echo "Grafana Password: <same as hornet password>"
echo "###############################################################################"
