#!/bin/bash

VRSN="0.4.7"

VAR_HOST=''
VAR_DIR=''
VAR_CERT=0
VAR_NETWORK=0
VAR_NODE=0
VAR_CONF_RESET=0

VAR_BEE_VERSION='0.3.1'
VAR_GOSHIMMER_VERSION='0.9.3'
VAR_WASP_VERSION='0.2.5'
VAR_SHIMMER_VERSION='2.0.0-beta.2'

ca='\033[36m'
xx='\033[0m'

echo $xx

DockerShimmerMainnet="https://github.com/dlt-green/node-installer-docker/releases/download/v.$VRSN/HORNET-$VAR_SHIMMER_VERSION-docker.tar.gz"
DockerIotaBee="https://github.com/dlt-green/node-installer-docker/releases/download/v.$VRSN/iota-bee.tar.gz"
DockerIotaGoshimmer="https://github.com/dlt-green/node-installer-docker/releases/download/v.$VRSN/iota-goshimmer.tar.gz"
SnapshotIotaGoshimmer="https://dbfiles-goshimmer.s3.eu-central-1.amazonaws.com/snapshots/nectar/snapshot-latest.bin"

DirShimmerHornet='/var/lib/shimmer-hornet'
DirIotaBee='/var/lib/iota-bee'

if [ -f "node-installer.sh" ]; then rm node-installer.sh; fi

CheckCertificate() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                      Check Let's Encrypt Certificate                        ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	if [ -f "/etc/letsencrypt/live/$VAR_HOST/fullchain.pem" ] 
	then 
		clear
		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║               DLT.GREEN AUTOMATIC NODE-INSTALLER WITH DOCKER                ║"
		echo "║                                    $VRSN                                    ║"
		echo "║                                                                             ║"
		echo "║                            1. Use existing Certificate (recommend)          ║"
		echo "║                            X. Get new Certificate (don't use with SWARM)    ║"
		echo "║                                                                             ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""
		echo "select menu item: "
		echo ""

		read n
		case $n in
		1) VAR_CERT=1 ;;
		*) echo "No existing Let's Encrypt Certificate found, generate a new one... " ;;
		esac
	else 
		echo "No existing Let's Encrypt Certificate found, generate a new one... "
	fi 
}

CheckConfiguration() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                         Check *.env Configuration                           ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	if [ -f "/var/lib/$VAR_DIR/.env" ] 
	then 
		clear
		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║               DLT.GREEN AUTOMATIC NODE-INSTALLER WITH DOCKER                ║"
		echo "║                                    $VRSN                                    ║"
		echo "║                                                                             ║"
		echo "║                            1. Reset Configuration (*.env)                   ║"
		echo "║                            X. Use existing Configuration (*.env)            ║"
		echo "║                                                                             ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""		
		echo "select menu item: "
		echo ""

		read n
		case $n in
		1) echo "Reset Configuration... "
		   VAR_CONF_RESET=1 ;;
		*) echo "Use existing Configuration... "
		   VAR_CONF_RESET=0 ;;
		esac
	else 
	    echo "New Configuration... "
		VAR_CONF_RESET=1
	fi 
}

SetCertificateGlobal() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║               DLT.GREEN AUTOMATIC NODE-INSTALLER WITH DOCKER                ║"
	echo "║                                    $VRSN                                    ║"
	echo "║                                                                             ║"
	echo "║                            1. Set Certificate as Global (recommend)         ║"
	echo "║                            X. Use Certificate only for this Node            ║"
	echo "║                                                                             ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""
		echo "select menu item: "
	echo ""

	read n
	case $n in
	1) mkdir -p "/etc/letsencrypt/live/$VAR_HOST" || exit
	   cd "/var/lib/$VAR_DIR/data/letsencrypt" || exit
	   cat acme.json | jq -r '.myresolver .Certificates[] | select(.domain.main=="'$VAR_HOST'") | .certificate' | base64 -d > "$VAR_HOST.crt"
	   cat acme.json | jq -r '.myresolver .Certificates[] | select(.domain.main=="'$VAR_HOST'") | .key' | base64 -d > "$VAR_HOST.key"
	   if [ -f "/var/lib/$VAR_DIR/data/letsencrypt/$VAR_HOST.crt" ]; then
	     cp "/var/lib/$VAR_DIR/data/letsencrypt/$VAR_HOST.crt" "/etc/letsencrypt/live/$VAR_HOST/fullchain.pem"
	   fi
	   if [ -f "/var/lib/$VAR_DIR/data/letsencrypt/$VAR_HOST.key" ]; then
	     cp "/var/lib/$VAR_DIR/data/letsencrypt/$VAR_HOST.key" "/etc/letsencrypt/live/$VAR_HOST/privkey.pem"
	   fi
	   ;;
	X) ;;
	esac	   
}

MainMenu() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║               DLT.GREEN AUTOMATIC NODE-INSTALLER WITH DOCKER                ║"
	echo "║                                    $VRSN                                    ║"
	echo "║                                                                             ║"
	echo "║                              1. System Updates                              ║"
	echo "║                              2. Docker Installation                         ║"
	echo "║                              3. IOTA Mainnet                                ║"
	echo "║                              4. IOTA Devnet                                 ║"
	echo "║                              5. Shimmer Testnet Beta                        ║"
	echo "║                              6. License Information                         ║"
	echo "║                              X. Abort Installer                             ║"
	echo "║                                                                             ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""
	echo "select menu item: "
	echo ""

	read n
	case $n in
	1) VAR_NETWORK=0
	   SystemUpdates ;;
	2) VAR_NETWORK=0 
	   Docker ;;
	3) VAR_NETWORK=3 
	   SubMenuIotaMainnet;;
	4) VAR_NETWORK=4
	   SubMenuIotaDevnet ;;
	5) VAR_NETWORK=5
	   SubMenuShimmerMainnet ;;
	6) VAR_NETWORK=6
	   SubMenuLicense ;;
	*) exit ;;
	esac
}

SubMenuLicense() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║               DLT.GREEN AUTOMATIC NODE-INSTALLER WITH DOCKER                ║"
	echo "║                                    $VRSN                                    ║"
	echo "║                                                                             ║"
	echo "║                      GNU General Public License v3.0                        ║"
	echo "║                                                                             ║"
	echo "║    https://github.com/dlt-green/node-installer-docker/blob/main/license     ║"
	echo "║                                                                             ║"	
	echo "║                              X. Main Menu                                   ║"
	echo "║                                                                             ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""
	echo "select menu item: "
	echo ""

	read n
	case $n in
	1) VAR_NODE=1
	   VAR_DIR='iota-hornet'
	   MainMenu ;;
	2) VAR_NODE=2
	   VAR_DIR='iota-bee'
	   SubMenuMaintenance ;;
	*) MainMenu ;;
	esac
}

SubMenuIotaMainnet() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║               DLT.GREEN AUTOMATIC NODE-INSTALLER WITH DOCKER                ║"
	echo "║                                    $VRSN                                    ║"
	echo "║                                                                             ║"
	echo "║                              1. IOTA Hornet Mainnet (soon)                  ║"
	echo "║                              2. IOTA Bee Mainnet                            ║"
	echo "║                              X. Main Menu                                   ║"
	echo "║                                                                             ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""
	echo "select menu item: "
	echo ""

	read n
	case $n in
	1) VAR_NODE=1
	   VAR_DIR='iota-hornet'
	   MainMenu ;;
	2) VAR_NODE=2
	   VAR_DIR='iota-bee'
	   SubMenuMaintenance ;;
	*) MainMenu ;;
	esac
}

SubMenuIotaDevnet() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║               DLT.GREEN AUTOMATIC NODE-INSTALLER WITH DOCKER                ║"
	echo "║                                    $VRSN                                    ║"
	echo "║                                                                             ║"
	echo "║                              1. IOTA Hornet Devnet (soon)                   ║"
	echo "║                              2. IOTA Bee Devnet                             ║"
	echo "║                              3. IOTA Goshimmer                              ║"
	echo "║                              4. IOTA Wasp (soon)                            ║"	
	echo "║                              X. Main Menu                                   ║"
	echo "║                                                                             ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""
	echo "select menu item: "
	echo ""

	read n
	case $n in
	1) VAR_NODE=1
	   VAR_DIR='iota-hornet'
	   MainMenu ;;
	2) VAR_NODE=2
	   VAR_DIR='iota-bee'
	   SubMenuMaintenance ;;
	3) VAR_NODE=3
	   VAR_DIR='iota-goshimmer'
	   SubMenuMaintenance ;;
	4) VAR_NODE=4
	   VAR_DIR='iota-wasp'
	   MainMenu ;;
	*) MainMenu ;;
	esac
}

SubMenuShimmerMainnet() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║               DLT.GREEN AUTOMATIC NODE-INSTALLER WITH DOCKER                ║"
	echo "║                                    $VRSN                                    ║"
	echo "║                                                                             ║"
	echo "║                              1. Shimmer Hornet Mainnet                      ║"
	echo "║                              2. Shimmer Bee Mainnet (soon)                  ║"
	echo "║                              X. Main Menu                                   ║"
	echo "║                                                                             ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""
	echo "select menu item: "
	echo ""

	read n
	case $n in
	1) VAR_NODE=1
	   VAR_DIR='shimmer-hornet'
	   SubMenuMaintenance ;;
	2) VAR_NODE=2
	   VAR_DIR='shimmer-bee'
	   MainMenu ;;
	*) MainMenu ;;
	esac
}


SubMenuMaintenance() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║               DLT.GREEN AUTOMATIC NODE-INSTALLER WITH DOCKER                ║"
	echo "║                                    $VRSN                                    ║"
	echo "║                                                                             ║"
	echo "║                              1. Install/Update                              ║"
	echo "║                              2. Start/Restart                               ║"
	echo "║                              3. Stop                                        ║"
	echo "║                              4. Reset Database                              ║"	
	echo "║                              5. Loading Snaphot                             ║"	
	echo "║                              6. Show Logs                                   ║"	
	echo "║                              X. Main Menu                                   ║"
	echo "║                                                                             ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""
	if [ "$VAR_NETWORK" = 3 ] && [ "$VAR_NODE" = 2 ]; then echo "$ca""Network/Node: $VAR_DIR | Version available: $VAR_BEE_VERSION""$xx"; fi
	if [ "$VAR_NETWORK" = 4 ] && [ "$VAR_NODE" = 2 ]; then echo "$ca""Network/Node: $VAR_DIR | Version available: $VAR_BEE_VERSION""$xx"; fi
	if [ "$VAR_NETWORK" = 4 ] && [ "$VAR_NODE" = 3 ]; then echo "$ca""Network/Node: $VAR_DIR | Version available: $VAR_GOSHIMMER_VERSION""$xx"; fi
	if [ "$VAR_NETWORK" = 5 ] && [ "$VAR_NODE" = 1 ]; then echo "$ca""Network/Node: $VAR_DIR | Version available: $VAR_SHIMMER_VERSION""$xx"; fi	
	echo "select menu item: "
	echo ""

	read n
	case $n in
	1) if [ "$VAR_NETWORK" = 3 ] && [ "$VAR_NODE" = 2 ]; then IotaBee; fi
	   if [ "$VAR_NETWORK" = 4 ] && [ "$VAR_NODE" = 2 ]; then IotaBee; fi
	   if [ "$VAR_NETWORK" = 4 ] && [ "$VAR_NODE" = 3 ]; then IotaGoshimmer; fi
	   if [ "$VAR_NETWORK" = 5 ] && [ "$VAR_NODE" = 1 ]; then ShimmerHornet; fi
	   ;;
	2) echo '(re)starting...'; sleep 3
	   if [ "$VAR_NETWORK" = 3 ] && [ "$VAR_NODE" = 2 ]; then docker stop iota-bee; fi
	   if [ "$VAR_NETWORK" = 4 ] && [ "$VAR_NODE" = 2 ]; then docker stop iota-bee; fi
	   if [ "$VAR_NETWORK" = 4 ] && [ "$VAR_NODE" = 3 ]; then docker stop iota-goshimmer; fi
	   if [ "$VAR_NETWORK" = 5 ] && [ "$VAR_NODE" = 1 ]; then docker stop shimmer-hornet; fi
	   
	   if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; docker-compose down; fi
	   if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; docker-compose up -d; fi
	   RenameContainer; sleep 3; SubMenuMaintenance
	   ;;
	3) echo 'stopping...'; sleep 3
	   if [ "$VAR_NETWORK" = 3 ] && [ "$VAR_NODE" = 2 ]; then docker stop iota-bee; fi
	   if [ "$VAR_NETWORK" = 4 ] && [ "$VAR_NODE" = 2 ]; then docker stop iota-bee; fi
	   if [ "$VAR_NETWORK" = 4 ] && [ "$VAR_NODE" = 3 ]; then docker stop iota-goshimmer; fi
	   if [ "$VAR_NETWORK" = 5 ] && [ "$VAR_NODE" = 1 ]; then docker stop shimmer-hornet; fi
	   
	   if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; docker-compose down; fi
	   sleep 3; SubMenuMaintenance
	   ;;
	4) echo 'resetting...'; sleep 3
	   if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || MainMenu; docker-compose down; fi
	   if [ -d /var/lib/$VAR_DIR/data/database ]; then rm -r /var/lib/$VAR_DIR/data/database/*; fi
	   if [ -d /var/lib/$VAR_DIR/data/storage/mainnet/tangle ]; then rm -r /var/lib/$VAR_DIR/data/storage/mainnet/tangle/*; fi
	   if [ -d /var/lib/$VAR_DIR/data/mainnetdb ]; then rm -r /var/lib/$VAR_DIR/data/mainnetdb/*; fi
	   if [ -d /var/lib/$VAR_DIR/data/peerdb ]; then rm -r /var/lib/$VAR_DIR/data/peerdb/*; fi
	   if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || MainMenu; docker-compose up -d; fi
	   RenameContainer; sleep 3; SubMenuMaintenance
	   ;;
	6) docker logs -f --tail 300 $VAR_DIR
	   read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W	
	   SubMenuMaintenance
	   ;;

	5) echo 'loading...'; sleep 3
	   if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || MainMenu; docker-compose down; fi
	   
	   if [ "$VAR_NETWORK" = 3 ] && [ "$VAR_NODE" = 2 ]; then
	      if [ -d /var/lib/$VAR_DIR/data/storage/mainnet/tangle ]; then rm -r /var/lib/$VAR_DIR/data/storage/mainnet/tangle/*; fi
	      if [ -d /var/lib/$VAR_DIR/data/snapshots/mainnet ]; then rm -r /var/lib/$VAR_DIR/data/snapshots/mainnet/*; fi
	   fi
	   if [ "$VAR_NETWORK" = 4 ] && [ "$VAR_NODE" = 2 ]; then
	      if [ -d /var/lib/$VAR_DIR/data/storage/devnet/tangle ]; then rm -r /var/lib/$VAR_DIR/data/storage/devnet/tangle/*; fi
	      if [ -d /var/lib/$VAR_DIR/data/snapshots/devnet ]; then rm -r /var/lib/$VAR_DIR/data/snapshots/devnet/*; fi
	   fi
	   if [ "$VAR_NETWORK" = 4 ] && [ "$VAR_NODE" = 3 ]
	   then
	      if [ -d /var/lib/$VAR_DIR/data/mainnetdb ]; then rm -r /var/lib/$VAR_DIR/data/mainnetdb/*; fi
	      if [ -d /var/lib/$VAR_DIR/data/peerdb ]; then rm -r /var/lib/$VAR_DIR/data/peerdb/*; fi
	      if [ -f /var/lib/$VAR_DIR/data/snapshots/snapshot.bin ]; then cd /var/lib/$VAR_DIR/data/snapshots || MainMenu; wget $SnapshotIotaGoshimmer; mv snapshot-latest.bin snapshot.bin; fi
	   fi
	   cd /var/lib/$VAR_DIR || MainMenu;
	   ./prepare_docker.sh
	   if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || MainMenu; docker-compose up -d; fi
	   RenameContainer; SubMenuMaintenance
	   ;;
	*) MainMenu ;;
	esac
}

SystemUpdates() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                     DLT.GREEN AUTOMATIC SYSTEM UPDATES                      ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W

	clear
	sudo apt-get update && apt-get upgrade -y
	sudo apt-get dist-upgrade -y
	sudo apt upgrade -y
	sudo apt-get autoremove -y

	read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W

	clear
	
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║               DLT.GREEN AUTOMATIC NODE-INSTALLER WITH DOCKER                ║"
	echo "║                                    $VRSN                                    ║"
	echo "║                                                                             ║"
	echo "║                            1. System Reboot (recommend)                     ║"
	echo "║                            X. Main Menu                                     ║"
	echo "║                                                                             ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""
	echo "select menu item: "
	echo ""
	
	read n
	case $n in
	1) 	echo 'rebooting...'; sleep 3
	    docker stop $(docker ps -a -q)
		docker ps -a -q
	    sleep 3
		sudo reboot
		;;
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

	read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W

	sudo docker ps -a -q
	sudo apt-get install jq -y
	sudo apt-get install expect -y
	
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

	read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W

	MainMenu
}

IotaBee() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║              DLT.GREEN AUTOMATIC BEE INSTALLATION WITH DOCKER               ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W

	if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; docker-compose down; rm docker-compose.yml; fi

	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                     Create bee directory /var/lib/iota-bee                  ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	if [ ! -d /var/lib/$VAR_DIR ]; then mkdir /var/lib/$VAR_DIR || exit; fi
	cd /var/lib/$VAR_DIR || exit

	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                   Pull installer from dlt.green/iota-bee                    ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	wget -cO - "$DockerIotaBee" > install.tar.gz

	echo "unpack:"
	tar -xzf install.tar.gz

	echo "remove tar.gz:"
	rm -r install.tar.gz

	read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W

	CheckConfiguration
	
	if [ $VAR_CONF_RESET = 1 ]; then
	
		clear
		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                               Set Parameters                                ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		read -p 'Set domain-name (e.g. node.dlt.green): ' VAR_HOST
		read -p 'Set domain-port (e.g. 440): ' VAR_BEE_HTTPS_PORT	
		read -p 'Set dashboard username (e.g. vrom): ' VAR_USERNAME
		read -p 'Set password (blank): ' VAR_PASSWORD
	
		CheckCertificate
	
		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                              Write Parameters                               ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; fi
		if [ -f .env ]; then rm .env; fi

		echo "BEE_VERSION=$VAR_BEE_VERSION" >> .env

		if [ $VAR_NETWORK = 3 ]; then echo "BEE_NETWORK=mainnet" >> .env; fi
		if [ $VAR_NETWORK = 4 ]; then echo "BEE_NETWORK=devnet" >> .env; fi
	
		echo "BEE_HOST=$VAR_HOST" >> .env
		echo "BEE_HTTPS_PORT=$VAR_BEE_HTTPS_PORT" >> .env
		echo "BEE_GOSSIP_PORT=15601" >> .env
		echo "BEE_AUTOPEERING_PORT=14636" >> .env
	
		if [ $VAR_CERT = 0 ]
		then
			echo "BEE_HTTP_PORT=80" >> .env
				read -p 'Set mail for certificat renewal (e.g. info@dlt.green): ' VAR_ACME_EMAIL
			echo "ACME_EMAIL=$VAR_ACME_EMAIL" >> .env
		else
			echo "BEE_HTTP_PORT=8082" >> .env
			echo "SSL_CONFIG=certs" >> .env
			echo "BEE_SSL_CERT=/etc/letsencrypt/live/$VAR_HOST/fullchain.pem" >> .env
			echo "BEE_SSL_KEY=/etc/letsencrypt/live/$VAR_HOST/privkey.pem" >> .env
		fi
	else
		if [ -f .env ]; then sed -i "s/BEE_VERSION=.*/BEE_VERSION=$VAR_BEE_VERSION/g" .env; fi
	fi
	
	read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W

	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                                 Pull Data                                   ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	docker-compose pull

	if [ $VAR_CONF_RESET = 1 ]; then
	
		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                               Set Creditials                                ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		credentials=$(./password.sh "$VAR_PASSWORD" | sed -e 's/\r//g')

		VAR_DASHBOARD_PASSWORD=$(echo "$credentials" | jq -r '.passwordHash')
		VAR_DASHBOARD_SALT=$(echo "$credentials" | jq -r '.passwordSalt')

		echo "DASHBOARD_USERNAME=$VAR_USERNAME" >> .env
		echo "DASHBOARD_PASSWORD=$VAR_DASHBOARD_PASSWORD" >> .env
		echo "DASHBOARD_SALT=$VAR_DASHBOARD_SALT" >> .env
	fi
	
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                               Prepare Docker                                ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; fi
	./prepare_docker.sh

	if [ $VAR_CONF_RESET = 1 ]; then

		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                             Configure Firewall                              ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		if [ $VAR_CERT = 0 ]; then echo ufw allow '80/tcp' && ufw allow '80/tcp'; fi	
	
		echo ufw allow "$VAR_BEE_HTTPS_PORT/tcp" && ufw allow "$VAR_BEE_HTTPS_PORT/tcp"
		echo ufw allow '15601/tcp' && ufw allow '15601/tcp'
		echo ufw allow '14636/udp' && ufw allow '14636/udp'
	fi
	
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                                 Start Bee                                   ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; fi

	docker-compose up -d
	
	sleep 3
	
	RenameContainer

	echo ""
	read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W

	if ([ $VAR_CERT = 0 ] && [ $VAR_CONF_RESET = 1 ]); then SetCertificateGlobal; fi	

	clear
	echo ""

	if [ $VAR_CONF_RESET = 1 ]; then	
	
	    echo "--------------------------- INSTALLATION IS FINISH ----------------------------"
	    echo ""
		echo "═══════════════════════════════════════════════════════════════════════════════"
		echo " Bee Dashboard: https://$VAR_HOST:$VAR_BEE_HTTPS_PORT/dashboard"
		echo " Bee Username: $VAR_USERNAME"
		echo " Bee Password: <set during install>"
		echo " API: https://$VAR_HOST:$VAR_BEE_HTTPS_PORT/api/v1/info"
		echo "═══════════════════════════════════════════════════════════════════════════════"
	else
	    echo "------------------------------ UPDATE IS FINISH - -----------------------------"
	fi
	echo ""
	
	read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W

	SubMenuMaintenance
}

IotaGoshimmer() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║           DLT.GREEN AUTOMATIC GOSHIMMER INSTALLATION WITH DOCKER            ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W

	if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; docker-compose down; rm docker-compose.yml; fi

	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                  Create bee directory /var/lib/iota-goshimmer               ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	if [ ! -d /var/lib/$VAR_DIR ]; then mkdir /var/lib/$VAR_DIR || exit; fi
	cd /var/lib/$VAR_DIR || exit

	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                Pull installer from dlt.green/iota-goshimmer                 ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	wget -cO - "$DockerIotaGoshimmer" > install.tar.gz

	echo "unpack:"
	tar -xzf install.tar.gz

	echo "remove tar.gz:"
	rm -r install.tar.gz

	read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W

	CheckConfiguration

	if [ $VAR_CONF_RESET = 1 ]; then
	
		clear
		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                               Set Parameters                                ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		read -p 'Set domain-name (e.g. node.dlt.green): ' VAR_HOST
		read -p 'Set domain-port (e.g. 446): ' VAR_GOSHIMMER_HTTPS_PORT	
	
		CheckCertificate

		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                              Write Parameters                               ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; fi
		if [ -f .env ]; then rm .env; fi

		echo "GOSHIMMER_VERSION=$VAR_GOSHIMMER_VERSION" >> .env

		echo "GOSHIMMER_HOST=$VAR_HOST" >> .env
		echo "GOSHIMMER_HTTPS_PORT=$VAR_GOSHIMMER_HTTPS_PORT" >> .env
		echo "GOSHIMMER_GOSSIP_PORT=14666" >> .env
		echo "GOSHIMMER_AUTOPEERING_PORT=14646" >> .env
	
		if [ $VAR_CERT = 0 ]
		then
			echo "GOSHIMMER_HTTP_PORT=80" >> .env
			read -p 'Set mail for certificat renewal (e.g. info@dlt.green): ' VAR_ACME_EMAIL
			echo "ACME_EMAIL=$VAR_ACME_EMAIL" >> .env
		else
			echo "GOSHIMMER_HTTP_PORT=8083" >> .env
			echo "SSL_CONFIG=certs" >> .env
			echo "GOSHIMMER_SSL_CERT=/etc/letsencrypt/live/$VAR_HOST/fullchain.pem" >> .env
			echo "GOSHIMMER_SSL_KEY=/etc/letsencrypt/live/$VAR_HOST/privkey.pem" >> .env
		fi
	else
		if [ -f .env ]; then sed -i "s/GOSHIMMER_VERSION=.*/GOSHIMMER_VERSION=$VAR_GOSHIMMER_VERSION/g" .env; fi
	fi
	
	read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W

	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                                 Pull Data                                   ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	docker-compose pull

	if [ $VAR_CONF_RESET = 1 ]; then
	
		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                            No Creditials Needed                             ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""
	fi
	
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                               Prepare Docker                                ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; fi
	./prepare_docker.sh

	if [ $VAR_CONF_RESET = 1 ]; then

		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                             Configure Firewall                              ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		if [ $VAR_CERT = 0 ]; then echo ufw allow '80/tcp' && ufw allow '80/tcp'; fi	
	
		echo ufw allow "$VAR_GOSHIMMER_HTTPS_PORT/tcp" && ufw allow "$VAR_GOSHIMMER_HTTPS_PORT/tcp"
		echo ufw allow '14666/tcp' && ufw allow '14666/tcp'
		echo ufw allow '14646/udp' && ufw allow '14646/udp'
		echo ufw allow '5000/tcp' && ufw allow '5000/tcp'
	fi
	
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                              Start Goshimmer                                ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; fi

	docker-compose up -d
	
	sleep 3
	
	RenameContainer

	echo ""
	read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W

	if ([ $VAR_CERT = 0 ] && [ $VAR_CONF_RESET = 1 ]); then SetCertificateGlobal; fi	

	clear
	echo ""
	
	if [ $VAR_CONF_RESET = 1 ]; then
	
		echo "--------------------------- INSTALLATION IS FINISH ----------------------------"
		echo ""
		echo "═══════════════════════════════════════════════════════════════════════════════"
		echo " Goshimmer Dashboard: https://$VAR_HOST:$VAR_GOSHIMMER_HTTPS_PORT/dashboard"
		echo " API: https://$VAR_HOST:$VAR_GOSHIMMER_HTTPS_PORT/info"
		echo "═══════════════════════════════════════════════════════════════════════════════"
		echo ""
	else
	    echo "------------------------------ UPDATE IS FINISH - -----------------------------"
	fi
	echo ""	

	read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W

	SubMenuMaintenance
}

ShimmerHornet() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║            DLT.GREEN AUTOMATIC SHIMMER INSTALLATION WITH DOCKER             ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W

	if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; docker-compose down; rm docker-compose.yml; fi

	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                   Create hornet directory /var/lib/shimmer-hornet           ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	if [ ! -d /var/lib/$VAR_DIR ]; then mkdir /var/lib/$VAR_DIR || exit; fi
	cd /var/lib/$VAR_DIR || exit

	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                   Pull repo from iotaledger/hornet:develop                  ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	wget -cO - "$DockerShimmerMainnet" > install.tar.gz

	echo "unpack:"
	tar -xzf install.tar.gz

	echo "remove tar.gz:"
	rm -r install.tar.gz

	read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W

	CheckConfiguration

	if [ $VAR_CONF_RESET = 1 ]; then
	
		clear
		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                               Set Parameters                                ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		read -p 'Set domain-name (e.g. node.dlt.green): ' VAR_HOST
		read -p 'Set dashboard username (e.g. vrom): ' VAR_USERNAME
		read -p 'Set password (blank): ' VAR_PASSWORD
		read -p 'Set mail for certificat renewal (e.g. info@dlt.green): ' VAR_ACME_EMAIL

		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                              Write Parameters                               ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; fi
		if [ -f .env ]; then rm .env; fi

		echo "HORNET_HOST=$VAR_HOST" >> .env
		echo "ACME_EMAIL=$VAR_ACME_EMAIL" >> .env
	fi

	read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W

	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                                 Pull Data                                   ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	docker-compose pull

	if [ $VAR_CONF_RESET = 1 ]; then

		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                               Set Creditials                                ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		credentials=$(docker-compose run --rm hornet tool pwd-hash --json --password "$VAR_PASSWORD" | sed -e 's/\r//g')

		VAR_DASHBOARD_PASSWORD=$(echo "$credentials" | jq -r '.passwordHash')
		VAR_DASHBOARD_SALT=$(echo "$credentials" | jq -r '.passwordSalt')
	
		echo "DASHBOARD_USERNAME=$VAR_USERNAME" >> .env
		echo "DASHBOARD_PASSWORD=$VAR_DASHBOARD_PASSWORD" >> .env
		echo "DASHBOARD_SALT=$VAR_DASHBOARD_SALT" >> .env
	fi

	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                               Prepare Docker                                ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; fi
	./prepare_docker.sh

	if [ $VAR_CONF_RESET = 1 ]; then

		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                             Configure Firewall                              ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		if [ $VAR_CERT = 0 ]; then echo ufw allow '80/tcp' && ufw allow '80/tcp'; fi	

		echo ufw allow '443/tcp' && ufw allow '443/tcp'
		echo ufw allow '15600/tcp' && ufw allow '15600/tcp'
		echo ufw allow '14626/udp' && ufw allow '14626/udp'
	fi

	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                                Start Hornet                                 ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; fi

	docker-compose up -d
	
	sleep 3
	
	RenameContainer

	if [ $VAR_CONF_RESET = 1 ]; then docker exec -it grafana grafana-cli admin reset-admin-password "$VAR_PASSWORD"; fi

	echo ""
	read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W

	if ([ $VAR_CERT = 0 ] && [ $VAR_CONF_RESET = 1 ]); then SetCertificateGlobal; fi
	
	clear
	echo ""	

	if [ $VAR_CONF_RESET = 1 ]; then
	
		echo "--------------------------- INSTALLATION IS FINISH ----------------------------"
		echo ""
		echo "═══════════════════════════════════════════════════════════════════════════════"
		echo " Hornet Dashboard: https://$VAR_HOST/dashboard"
		echo " Hornet Username: $VAR_USERNAME"
		echo " Hornet Password: <set during install>"
		echo " Grafana Dashboard: https://$VAR_HOST/grafana"
		echo " Grafana Username: admin"
		echo " Grafana Password: <same as hornet password>"
		echo " API: https://$VAR_HOST/api/core/v2/info"
		echo "═══════════════════════════════════════════════════════════════════════════════"
		echo ""
	else
	    echo "------------------------------ UPDATE IS FINISH - -----------------------------"
	fi
	echo ""		

	read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W

	SubMenuMaintenance
}

RenameContainer() {
	docker container rename iota-bee_bee_1 iota-bee >/dev/null 2>&1
	docker container rename iota-bee_traefik_1 iota-bee.traefik >/dev/null 2>&1
	docker container rename iota-bee_traefik-certs-dumper_1 iota-bee.traefik-certs-dumper >/dev/null 2>&1
	docker container rename iota-goshimmer_goshimmer_1 iota-goshimmer >/dev/null 2>&1
	docker container rename iota-goshimmer_traefik_1 iota-goshimmer.traefik >/dev/null 2>&1
	docker container rename iota-goshimmer_traefik-certs-dumper_1 iota-goshimmer.traefik-certs-dumper >/dev/null 2>&1
	docker container rename shimmer-hornet_hornet_1 shimmer-hornet >/dev/null 2>&1
	docker container rename shimmer-hornet_traefik_1 shimmer-hornet.traefik >/dev/null 2>&1
	docker container rename shimmer-hornet_inx-participation_1 shimmer-hornet.inx-participation >/dev/null 2>&1
	docker container rename shimmer-hornet_inx-dashboard_1 shimmer-hornet.inx-dashboard >/dev/null 2>&1
	docker container rename shimmer-hornet_inx-indexer_1 shimmer-hornet.inx-indexer >/dev/null 2>&1
	docker container rename shimmer-hornet_inx-poi_1 shimmer-hornet.inx-poi >/dev/null 2>&1
	docker container rename shimmer-hornet_inx-spammer_1 shimmer-hornet.inx-spammer >/dev/null 2>&1
	docker container rename shimmer-hornet_inx-mqtt_1 shimmer-hornet.inx-mqtt >/dev/null 2>&1
}

MainMenu