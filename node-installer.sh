#!/bin/sh

rm node-installer.sh

MainMenu() {

	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║               DLT.GREEN AUTOMATIC NODE-INSTALLER WITH DOCKER                ║"
	echo "║                                                                             ║"
	echo "║                              1. System Updates                              ║"
	echo "║                              2. Docker Installation                         ║"
	echo "║                              3. IOTA Mainnet                                ║"
	echo "║                              4. IOTA Devnet                                 ║"
	echo "║                              5. SHIMMER Mainnet                             ║"
	echo "║                              6. SHIMMER EVM                                 ║"
	echo "║                              X. Abort Installer                             ║"
	echo "║                                                                             ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo "select: "
	echo ""

	read n
    case $n in
	1) SystemUpdates ;;
	2) Docker ;;
	3) MainMenu ;;
	4) MainMenu ;;
	5) ShimmerMainnet ;;
	6) MainMenu ;;
	*) exit ;;
	esac
}

SystemUpdates() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                     DLT.GREEN AUTOMATIC SYSTEM UPDATES                      ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	read -p 'Press [Enter] key to continue...' W

	clear
	sudo apt-get update && apt-get upgrade -y
	sudo apt-get dist-upgrade -y
	sudo apt upgrade -y
	sudo apt-get autoremove -y

	read -p 'Press [Enter] key to continue...' W

	clear
	
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║               DLT.GREEN AUTOMATIC NODE-INSTALLER WITH DOCKER                ║"
	echo "║                                                                             ║"
	echo "║                            1. Main Menu                                     ║"
	echo "║                            2. System Reboot                                 ║"
	echo "║                                                                             ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo "select: "
	echo ""
	
	read n
    case $n in
	1) MainMenu ;;
	2) sudo reboot ;;
	*) MainMenu ;;
	esac
}

Docker() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                   DLT.GREEN AUTOMATIC DOCKER INSTALLATION                   ║"
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

	read -p 'Press [Enter] key to continue...' W

	MainMenu
}

ShimmerMainnet() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║            DLT.GREEN AUTOMATIC SHIMMER INSTALLATION WITH DOCKER             ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	read -p 'Press [Enter] key to continue...' W

	cd /var/lib/hornet
	docker-compose down

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

	wget -cO - https://github.com/iotaledger/hornet/releases/download/v2.0.0-alpha.21/HORNET-2.0.0-alpha.21-docker-example.tar.gz > install.tar.gz

	echo "unpack:"
	tar -xzf install.tar.gz

	echo "remove tar.gz:"
	rm -r install.tar.gz

	read -p 'Press [Enter] key to continue...' W
	
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                               Set parameter                                 ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	read -p 'Set domain-name: ' VAR_HORNET_HOST
	read -p 'Set mail for certificat renewal: ' VAR_ACME_EMAIL
	read -p 'Set dashboard username: ' VAR_USERNAME
	read -p 'Set password (blank): ' VAR_PASSWORD

	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                               Prepare docker                                ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	cd /var/lib/hornet/
	./prepare_docker.sh
	
	docker-compose pull
	
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                            Generate Creditials                              ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	credentials=$(docker-compose run --rm hornet tool pwd-hash --json --password "$VAR_PASSWORD" | sed -e 's/\r//g')

	VAR_DASHBOARD_PASSWORD=$(echo "$credentials" | jq -r '.passwordHash')
	VAR_DASHBOARD_SALT=$(echo "$credentials" | jq -r '.passwordSalt')

	cd /var/lib/hornet
	rm .env

	echo "ACME_EMAIL=$VAR_ACME_EMAIL" >> .env
	echo "HORNET_HOST=$VAR_HORNET_HOST" >> .env
	echo "DASHBOARD_USERNAME=$VAR_USERNAME" >> .env
	echo "DASHBOARD_PASSWORD=$VAR_DASHBOARD_PASSWORD" >> .env
	echo "DASHBOARD_SALT=$VAR_DASHBOARD_SALT" >> .env
	echo "GRAFANA_HOST=grafana.$VAR_HORNET_HOST" >> .env

	sed "/alias/s/node/$VAR_HORNET_HOST/g" config.json > config_tmp.json
	mv config_tmp.json config.json

	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                                Start Hornet                                 ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	cd /var/lib/hornet/
	docker-compose up -d
	docker exec -it grafana grafana-cli admin reset-admin-password "$VAR_PASSWORD"

	echo ""
	echo "═══════════════════════════════════════════════════════════════════════════════"
	echo " Hornet Dashboard: https://$VAR_HORNET_HOST/dashboard"
	echo " Hornet Username: $VAR_USERNAME"
	echo " Hornet Password: <set during install>"
	echo " Grafana Dashboard: https://$VAR_HORNET_HOST/grafana"
	echo " Grafana Username: admin"
	echo " Grafana Password: <same as hornet password>"
	echo " API: https://$VAR_HORNET_HOST/api/core/v2/info"
	echo "═══════════════════════════════════════════════════════════════════════════════"
	echo ""

	read -p 'Press [Enter] key to continue...' W

	MainMenu
}

MainMenu