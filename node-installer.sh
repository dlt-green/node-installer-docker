#!/bin/bash

VRSN="0.5.3"

VAR_HOST=''
VAR_DIR=''
VAR_CERT=0
VAR_NETWORK=0
VAR_NODE=0
VAR_CONF_RESET=0

VAR_IOTA_HORNET_VERSION='1.2.1'
VAR_IOTA_BEE_VERSION='0.3.1'
VAR_IOTA_GOSHIMMER_VERSION='0.9.3'
VAR_IOTA_WASP_VERSION='0.2.5'
VAR_SHIMMER_HORNET_VERSION='2.0.0-beta.4'
VAR_SHIMMER_WASP_VERSION='dev'

ca='\033[36m'
rd='\033[91m'
gn='\033[32m'
fl='\033[5m'
xx='\033[0m'

echo $xx

DockerShimmerHornet="https://github.com/dlt-green/node-installer-docker/releases/download/v.$VRSN/HORNET-$VAR_SHIMMER_HORNET_VERSION-docker.tar.gz"
DockerShimmerWasp="https://github.com/dlt-green/node-installer-docker/releases/download/v.$VRSN/wasp.tar.gz"

DockerIotaHornet="https://github.com/dlt-green/node-installer-docker/releases/download/v.$VRSN/iota-hornet.tar.gz"
DockerIotaBee="https://github.com/dlt-green/node-installer-docker/releases/download/v.$VRSN/iota-bee.tar.gz"
DockerIotaGoshimmer="https://github.com/dlt-green/node-installer-docker/releases/download/v.$VRSN/iota-goshimmer.tar.gz"
DockerIotaWasp="https://github.com/dlt-green/node-installer-docker/releases/download/v.$VRSN/wasp.tar.gz"

SnapshotIotaGoshimmer="https://dbfiles-goshimmer.s3.eu-central-1.amazonaws.com/snapshots/nectar/snapshot-latest.bin"

clear
if [ -f "node-installer.sh" ]; then sudo rm node-installer.sh -f; fi
if [ $(id -u) -ne 0 ]; then	echo $rd && echo 'Please run DLT.GREEN Automatic Node-Installer with sudo or as root' && echo $xx; exit; fi

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

		read  -p '> ' n
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

		read  -p '> ' n
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
	echo "║                            1. Update global Certificate (recommend)         ║"
	echo "║                            X. Use Certificate only for this Node            ║"
	echo "║                                                                             ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""
		echo "select menu item: "
	echo ""

	read  -p '> ' n
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
	echo "║                                    $rd""TEST""$xx                                     ║"
	echo "║                                                                             ║"
	echo "║                              1. System Maintenance                          ║"
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

	read  -p '> ' n
	case $n in
	1) VAR_NETWORK=0
	   SystemMaintenance ;;
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
	0) VAR_NETWORK=0
	   S2DLT ;;
	*) clear; exit ;;
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

	read  -p '> ' n
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
	echo "║                              1. IOTA Hornet Mainnet                         ║"
	echo "║                              2. IOTA Bee Mainnet                            ║"
	echo "║                              X. Main Menu                                   ║"
	echo "║                                                                             ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""
	echo "select menu item: "
	echo ""

	read  -p '> ' n
	case $n in
	1) VAR_NODE=1
	   VAR_DIR='iota-hornet'
	   SubMenuMaintenance ;;
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
	echo "║                              1. IOTA Hornet Devnet                          ║"
	echo "║                              2. IOTA Bee Devnet                             ║"
	echo "║                              3. IOTA Goshimmer                              ║"
	echo "║                              4. IOTA Wasp                                   ║"	
	echo "║                              X. Main Menu                                   ║"
	echo "║                                                                             ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""
	echo "select menu item: "
	echo ""

	read  -p '> ' n
	case $n in
	1) VAR_NODE=1
	   VAR_DIR='iota-hornet'
	   SubMenuMaintenance ;;
	2) VAR_NODE=2
	   VAR_DIR='iota-bee'
	   SubMenuMaintenance ;;
	3) VAR_NODE=3
	   VAR_DIR='iota-goshimmer'
	   SubMenuMaintenance ;;
	4) VAR_NODE=4
	   VAR_DIR='iota-wasp'
	   SubMenuMaintenance ;;
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

	read  -p '> ' n
	case $n in
	1) VAR_NODE=1
	   VAR_DIR='shimmer-hornet'
	   SubMenuMaintenance ;;
	2) VAR_NODE=2
	   VAR_DIR='shimmer-bee'
	   MainMenu ;;
	8) VAR_NODE=3
	   VAR_DIR='shimmer-wasp'
	   SubMenuMaintenance ;;
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
	echo "║                              7. Deinstall/Remove                            ║"	
	echo "║                              X. Main Menu                                   ║"
	echo "║                                                                             ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""
	if [ "$VAR_NETWORK" = 3 ] && [ "$VAR_NODE" = 1 ]; then echo "$ca""Network/Node: $VAR_DIR | Version available: $VAR_IOTA_HORNET_VERSION""$xx"; fi
	if [ "$VAR_NETWORK" = 4 ] && [ "$VAR_NODE" = 1 ]; then echo "$ca""Network/Node: $VAR_DIR | Version available: $VAR_IOTA_HORNET_VERSION""$xx"; fi
	if [ "$VAR_NETWORK" = 3 ] && [ "$VAR_NODE" = 2 ]; then echo "$ca""Network/Node: $VAR_DIR | Version available: $VAR_IOTA_BEE_VERSION""$xx"; fi
	if [ "$VAR_NETWORK" = 4 ] && [ "$VAR_NODE" = 2 ]; then echo "$ca""Network/Node: $VAR_DIR | Version available: $VAR_IOTA_BEE_VERSION""$xx"; fi
	if [ "$VAR_NETWORK" = 4 ] && [ "$VAR_NODE" = 3 ]; then echo "$ca""Network/Node: $VAR_DIR | Version available: $VAR_IOTA_GOSHIMMER_VERSION""$xx"; fi
	if [ "$VAR_NETWORK" = 4 ] && [ "$VAR_NODE" = 4 ]; then echo "$ca""Network/Node: $VAR_DIR | Version available: $VAR_IOTA_WASP_VERSION""$xx"; fi	
	if [ "$VAR_NETWORK" = 5 ] && [ "$VAR_NODE" = 1 ]; then echo "$ca""Network/Node: $VAR_DIR | Version available: $VAR_SHIMMER_HORNET_VERSION""$xx"; fi	
	if [ "$VAR_NETWORK" = 5 ] && [ "$VAR_NODE" = 3 ]; then echo "$ca""Network/Node: $VAR_DIR | Version available: $VAR_SHIMMER_WASP_VERSION""$xx"; fi	
	echo ""
	echo "select menu item: "
	echo ""

	read  -p '> ' n
	case $n in
	1) if [ "$VAR_NETWORK" = 3 ] && [ "$VAR_NODE" = 1 ]; then IotaHornet; fi
	   if [ "$VAR_NETWORK" = 4 ] && [ "$VAR_NODE" = 1 ]; then IotaHornet; fi
	   if [ "$VAR_NETWORK" = 3 ] && [ "$VAR_NODE" = 2 ]; then IotaBee; fi
	   if [ "$VAR_NETWORK" = 4 ] && [ "$VAR_NODE" = 2 ]; then IotaBee; fi
	   if [ "$VAR_NETWORK" = 4 ] && [ "$VAR_NODE" = 3 ]; then IotaGoshimmer; fi
	   if [ "$VAR_NETWORK" = 4 ] && [ "$VAR_NODE" = 4 ]; then IotaWasp; fi
	   if [ "$VAR_NETWORK" = 5 ] && [ "$VAR_NODE" = 1 ]; then ShimmerHornet; fi
	   if [ "$VAR_NETWORK" = 5 ] && [ "$VAR_NODE" = 3 ]; then ShimmerWasp; fi
	   ;;
	2) echo '(re)starting...'; sleep 3
	   clear
	   echo $ca
	   echo 'Please wait, this process can take up to 5 minutes...'
	   echo $xx
	   
	   if [ "$VAR_NETWORK" = 3 ] && [ "$VAR_NODE" = 1 ]; then docker stop iota-hornet; fi
	   if [ "$VAR_NETWORK" = 4 ] && [ "$VAR_NODE" = 1 ]; then docker stop iota-hornet; fi
	   if [ "$VAR_NETWORK" = 3 ] && [ "$VAR_NODE" = 2 ]; then docker stop iota-bee; fi
	   if [ "$VAR_NETWORK" = 4 ] && [ "$VAR_NODE" = 2 ]; then docker stop iota-bee; fi
	   if [ "$VAR_NETWORK" = 4 ] && [ "$VAR_NODE" = 3 ]; then docker stop iota-goshimmer; fi
	   if [ "$VAR_NETWORK" = 4 ] && [ "$VAR_NODE" = 4 ]; then docker stop iota-wasp; fi
	   if [ "$VAR_NETWORK" = 5 ] && [ "$VAR_NODE" = 1 ]; then docker stop shimmer-hornet; fi
	   if [ "$VAR_NETWORK" = 5 ] && [ "$VAR_NODE" = 3 ]; then docker stop shimmer-wasp; fi
	   
	   if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuMaintenance; docker-compose down; fi
	   if [ -d /var/lib/$VAR_DIR/data/peerdb ]; then rm -r /var/lib/$VAR_DIR/data/peerdb/*; fi
	   if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuMaintenance; docker-compose up -d; fi

	   RenameContainer; sleep 3
	   
	   echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx
	   SubMenuMaintenance
	   ;;
	3) echo 'stopping...'; sleep 3
	   clear
	   echo $ca
	   echo 'Please wait, this process can take up to 5 minutes...'
	   echo $xx
	   
	   if [ "$VAR_NETWORK" = 3 ] && [ "$VAR_NODE" = 1 ]; then docker stop iota-hornet; fi
	   if [ "$VAR_NETWORK" = 4 ] && [ "$VAR_NODE" = 1 ]; then docker stop iota-hornet; fi
	   if [ "$VAR_NETWORK" = 3 ] && [ "$VAR_NODE" = 2 ]; then docker stop iota-bee; fi
	   if [ "$VAR_NETWORK" = 4 ] && [ "$VAR_NODE" = 2 ]; then docker stop iota-bee; fi
	   if [ "$VAR_NETWORK" = 4 ] && [ "$VAR_NODE" = 3 ]; then docker stop iota-goshimmer; fi
	   if [ "$VAR_NETWORK" = 4 ] && [ "$VAR_NODE" = 4 ]; then docker stop iota-wasp; fi
	   if [ "$VAR_NETWORK" = 5 ] && [ "$VAR_NODE" = 1 ]; then docker stop shimmer-hornet; fi
	   if [ "$VAR_NETWORK" = 5 ] && [ "$VAR_NODE" = 3 ]; then docker stop shimmer-wasp; fi
	   
	   if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuMaintenance; docker-compose down; fi
	   sleep 3;
	   
	   echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx
	   SubMenuMaintenance
	   ;;
	4) echo 'resetting...'; sleep 3
	   clear
	   echo $ca
	   echo 'Please wait, this process can take up to 5 minutes...'
	   echo $xx

	   if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuMaintenance; docker-compose down; fi
	   
	   rm -rf /var/lib/$VAR_DIR/data/storage/mainnet/*
	   rm -rf /var/lib/$VAR_DIR/data/storage/devnet/*
	   rm -rf /var/lib/$VAR_DIR/data/database/*
	   rm -rf /var/lib/$VAR_DIR/data/mainnetdb/*
	   rm -rf /var/lib/$VAR_DIR/data/peerdb/*
	   rm -rf /var/lib/$VAR_DIR/data/waspdb/*
	   
	   if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuMaintenance; docker-compose up -d; fi

	   RenameContainer; sleep 3

	   echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx	   
	   SubMenuMaintenance
	   ;;
	5) echo 'loading...'; sleep 3
	   clear
	   echo $ca
	   echo 'Please wait, this process can take up to 5 minutes...'
	   echo $xx

	   if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuMaintenance; docker-compose down; fi
	   
	   if [ "$VAR_NETWORK" = 3 ] && [ "$VAR_NODE" = 1 ]; then
	      rm -rf /var/lib/$VAR_DIR/data/storage/*
	      rm -rf /var/lib/$VAR_DIR/data/snapshots/*
	   fi
	   if [ "$VAR_NETWORK" = 4 ] && [ "$VAR_NODE" = 1 ]; then
	      rm -rf /var/lib/$VAR_DIR/data/storage/*
	      rm -rf /var/lib/$VAR_DIR/data/snapshots/*
	   fi
	   if [ "$VAR_NETWORK" = 3 ] && [ "$VAR_NODE" = 2 ]; then
	      rm -rf /var/lib/$VAR_DIR/data/storage/mainnet/tangle/*
	      rm -rf /var/lib/$VAR_DIR/data/snapshots/mainnet/*
	   fi
	   if [ "$VAR_NETWORK" = 4 ] && [ "$VAR_NODE" = 2 ]; then
	      rm -rf /var/lib/$VAR_DIR/data/storage/devnet/tangle/*
	      rm -rf /var/lib/$VAR_DIR/data/snapshots/devnet/*
	   fi
	   if [ "$VAR_NETWORK" = 4 ] && [ "$VAR_NODE" = 3 ]
	   then
	      rm -rf /var/lib/$VAR_DIR/data/mainnetdb/*
	      rm -rf /var/lib/$VAR_DIR/data/peerdb/*
	      if [ -f /var/lib/$VAR_DIR/data/snapshots/snapshot.bin ]; then cd /var/lib/$VAR_DIR/data/snapshots || SubMenuMaintenance; wget $SnapshotIotaGoshimmer; mv snapshot-latest.bin snapshot.bin; fi
	   fi
	   cd /var/lib/$VAR_DIR || SubMenuMaintenance;
	   ./prepare_docker.sh
	   if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuMaintenance; docker-compose up -d; fi
	   
	   RenameContainer

	   echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx	  	   
	   SubMenuMaintenance
	   ;;
	6) docker logs -f --tail 300 $VAR_DIR
	   echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx	
	   SubMenuMaintenance
	   ;;
	7) echo 'deinstall/remove...'; sleep 3
	   echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx	
	   clear
	   echo $ca
	   echo 'Please wait, this process can take up to 5 minutes...'
	   echo $xx

	   if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuMaintenance; docker-compose down >/dev/null 2>&1; fi
	   if [ -d /var/lib/$VAR_DIR ]; then rm -r /var/lib/$VAR_DIR; fi

	   echo $rd""$VAR_DIR" removed from your system!"$xx
	   echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx	
	   SubMenuMaintenance
	   ;;
	*) MainMenu ;;
	esac
}

SystemMaintenance() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                   DLT.GREEN AUTOMATIC SYSTEM MAINTENANCE                    ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx

	clear
	sudo apt-get update && apt-get upgrade -y
	sudo apt-get dist-upgrade -y
	sudo apt upgrade -y
	sudo apt-get autoremove -y

	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx

	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                  Delete unused old docker containers/images                 ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	docker system prune

	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx
	
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
	echo "$rd""Attention! If you choose a System Reboot then you must stop Nodes,"
	echo "which are additionally installed with a foreign Installer (e.g. SWARM)""$xx"
	echo ""
	echo "$gn""You don't have to stop Nodes installed with the DLT.GREEN Installer,"
	echo "but you must restart them with our Installer after reastarting your System""$xx"
	echo ""
	echo "select menu item: "
	echo ""
	
	read  -p '> ' n
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

	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx

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

	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx

	MainMenu
}

S2DLT() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                  DLT.GREEN AUTOMATIC IOTA-HORNET DB TRANSFER                ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""
	echo "$rd""!!! Make sure you have stopped IOTA-Hornet in SWARM and Watchdog is disabled !!!""$xx"
	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx
	clear
	echo "$rd""Benenne Verzeichnins in iota-hornet_tmp um...""$xx"
	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx	
	sudo mv /var/lib/iota-hornet /var/lib/iota-hornet_tmp
	clear
	echo "$rd""Installiere IOTA-Hornet...""$xx"
	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx	
	VAR_NETWORK = 3
	VAR_NODE = 1
	VAR_DIR = 'iota-hornet'
	IotaHornet
	clear
	echo "$rd""Stoppe Container IOTA-Hornet...""$xx"
	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx
	docker stop iota-hornet
	echo "$rd""Beende mit DockerSkript...""$xx"
	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx
	if [ -d /var/lib/iota-hornet ]; then cd /var/lib/iota-hornet || exit; docker-compose down; fi
	echo "$rd""Verschiebe Datenbank...""$xx"
	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx
	rm -r /var/lib/iota-hornet_tmp/mainnetdb/mainnetdb
	mv -r /var/lib/iota-hornet_tmp/mainnetdb/* /var/lib/iota-hornet/data/storage/mainnet
	echo "$rd""Starte Hornet mit DockerSkript...""$xx"
	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx
	clear
	echo "---------------------------- TRANSFER IS FINISH - -----------------------------"
	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx
	MainMenu
}

IotaHornet() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║           DLT.GREEN AUTOMATIC IOTA-HORNET INSTALLATION WITH DOCKER          ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx

	if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; if [ -f "/var/lib/$VAR_DIR/docker-compose.yml" ]; then docker-compose down; fi; fi

	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                   Create bee directory /var/lib/iota-hornet                 ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	if [ ! -d /var/lib/$VAR_DIR ]; then mkdir /var/lib/$VAR_DIR || exit; fi
	cd /var/lib/$VAR_DIR || exit

	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║        Pull installer from github.com/dlt-green/node-installer-docker       ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	wget -cO - "$DockerIotaHornet" > install.tar.gz
	
	if [ -f docker-compose.yml ]; then rm docker-compose.yml; fi

	echo "unpack:"
	tar -xzf install.tar.gz

	echo "remove tar.gz:"
	rm -r install.tar.gz

	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx

	CheckConfiguration
	
	if [ $VAR_CONF_RESET = 1 ]; then
	
		clear
		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                               Set Parameters                                ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		echo "Set the domain name (example: $ca""vrom.dlt.green""$xx):"
		read -p '> ' VAR_HOST
		echo ''
		echo "Set the dashboard port (example: $ca""443""$xx):"
		read -p '> ' VAR_IOTA_HORNET_HTTPS_PORT
		echo ''
		echo "Set the pruning size / max. database size (example: $ca""200GB""$xx):"
		echo "$rd""Available Diskspace: $(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 4)B/$(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 2)B ($(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 5) used) ""$xx"
		read -p '> ' VAR_IOTA_HORNET_PRUNING_SIZE
		echo ''
		echo "Set the dashboard username (example: $ca""vrom""$xx):"		
		read -p '> ' VAR_USERNAME
		echo ''
		echo "Set the dashboard password:"
		echo "(information: $ca""will be saved as hash / don't leave it empty""$xx):"
		read -p '> ' VAR_PASSWORD
		echo ''
		
		CheckCertificate
	
		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                              Write Parameters                               ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; fi
		if [ -f .env ]; then rm .env; fi

		echo "HORNET_VERSION=$VAR_IOTA_HORNET_VERSION" >> .env

		if [ $VAR_NETWORK = 3 ]; then echo "HORNET_NETWORK=mainnet" >> .env; fi
		if [ $VAR_NETWORK = 4 ]; then echo "HORNET_NETWORK=devnet" >> .env; fi
	
		echo "HORNET_HOST=$VAR_HOST" >> .env
		echo "HORNET_PRUNING_TARGET_SIZE=$VAR_IOTA_HORNET_PRUNING_SIZE" >> .env
		echo "HORNET_HTTPS_PORT=$VAR_IOTA_HORNET_HTTPS_PORT" >> .env
		echo "HORNET_GOSSIP_PORT=15600" >> .env
		echo "HORNET_AUTOPEERING_PORT=14626" >> .env
	
		if [ $VAR_CERT = 0 ]
		then
			echo "HORNET_HTTP_PORT=80" >> .env
				read -p 'Set mail for certificat renewal (e.g. info@dlt.green): ' VAR_ACME_EMAIL
			echo "ACME_EMAIL=$VAR_ACME_EMAIL" >> .env
		else
			echo "HORNET_HTTP_PORT=8081" >> .env
			echo "SSL_CONFIG=certs" >> .env
			echo "HORNET_SSL_CERT=/etc/letsencrypt/live/$VAR_HOST/fullchain.pem" >> .env
			echo "HORNET_SSL_KEY=/etc/letsencrypt/live/$VAR_HOST/privkey.pem" >> .env
		fi
	else
		if [ -f .env ]; then sed -i "s/HORNET_VERSION=.*/HORNET_VERSION=$VAR_IOTA_HORNET_VERSION/g" .env; fi
	fi
	
	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx

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
	
		echo ufw allow "$VAR_IOTA_HORNET_HTTPS_PORT/tcp" && ufw allow "$VAR_IOTA_HORNET_HTTPS_PORT/tcp"
		echo ufw allow '15600/tcp' && ufw allow '15600/tcp'
		echo ufw allow '14626/udp' && ufw allow '14626/udp'
	fi
	
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                              Start IOTA-Hornet                              ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; fi

	docker-compose up -d
	
	sleep 3
	
	RenameContainer

	echo ""
	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx

	if [ -s "/var/lib/$VAR_DIR/data/letsencrypt/acme.json" ]; then SetCertificateGlobal; fi	

	clear
	echo ""

	if [ $VAR_CONF_RESET = 1 ]; then	
	
	    echo "--------------------------- INSTALLATION IS FINISH ----------------------------"
	    echo ""
		echo "═══════════════════════════════════════════════════════════════════════════════"
		echo " IOTA-Hornet Dashboard: https://$VAR_HOST:$VAR_IOTA_HORNET_HTTPS_PORT/dashboard"
		echo " IOTA-Hornet Dashboard Username: $VAR_USERNAME"
		echo " IOTA-Hornet Dashboard Password: <set during install>"
		echo " IOTA-Hornet API: https://$VAR_HOST:$VAR_IOTA_HORNET_HTTPS_PORT/api/v1/info"
		echo "═══════════════════════════════════════════════════════════════════════════════"
	else
	    echo "------------------------------ UPDATE IS FINISH - -----------------------------"
	fi
	echo ""
	
	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx

	SubMenuMaintenance
}

IotaBee() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║            DLT.GREEN AUTOMATIC IOTA-BEE INSTALLATION WITH DOCKER            ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx

	if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; if [ -f "/var/lib/$VAR_DIR/docker-compose.yml" ]; then docker-compose down; fi; fi

	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                     Create bee directory /var/lib/iota-bee                  ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	if [ ! -d /var/lib/$VAR_DIR ]; then mkdir /var/lib/$VAR_DIR || exit; fi
	cd /var/lib/$VAR_DIR || exit

	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║        Pull installer from github.com/dlt-green/node-installer-docker       ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	wget -cO - "$DockerIotaBee" > install.tar.gz
	
	if [ -f docker-compose.yml ]; then rm docker-compose.yml; fi

	echo "unpack:"
	tar -xzf install.tar.gz

	echo "remove tar.gz:"
	rm -r install.tar.gz

	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx

	CheckConfiguration
	
	if [ $VAR_CONF_RESET = 1 ]; then
	
		clear
		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                               Set Parameters                                ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		echo "Set the domain name (example: $ca""vrom.dlt.green""$xx):"
		read -p '> ' VAR_HOST
		echo ''
		echo "Set the dashboard port (example: $ca""440""$xx):"
		read -p '> ' VAR_IOTA_BEE_HTTPS_PORT
		echo ''
		echo "Set the dashboard username (example: $ca""vrom""$xx):"
		read -p '> ' VAR_USERNAME
		echo ''
		echo "Set the dashboard password:"
		echo "(information: $ca""will be saved as hash / don't leave it empty""$xx):"
		read -p '> ' VAR_PASSWORD
		echo ''
		
		CheckCertificate
	
		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                              Write Parameters                               ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; fi
		if [ -f .env ]; then rm .env; fi

		echo "BEE_VERSION=$VAR_IOTA_BEE_VERSION" >> .env

		if [ $VAR_NETWORK = 3 ]; then echo "BEE_NETWORK=mainnet" >> .env; fi
		if [ $VAR_NETWORK = 4 ]; then echo "BEE_NETWORK=devnet" >> .env; fi
	
		echo "BEE_HOST=$VAR_HOST" >> .env
		echo "BEE_HTTPS_PORT=$VAR_IOTA_BEE_HTTPS_PORT" >> .env
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
		if [ -f .env ]; then sed -i "s/BEE_VERSION=.*/BEE_VERSION=$VAR_IOTA_BEE_VERSION/g" .env; fi
	fi
	
	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx

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
	
		echo ufw allow "$VAR_IOTA_BEE_HTTPS_PORT/tcp" && ufw allow "$VAR_IOTA_BEE_HTTPS_PORT/tcp"
		echo ufw allow '15601/tcp' && ufw allow '15601/tcp'
		echo ufw allow '14636/udp' && ufw allow '14636/udp'
	fi
	
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                                Start IOTA-Bee                               ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; fi

	docker-compose up -d
	
	sleep 3
	
	RenameContainer

	echo ""
	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx

	if [ -s "/var/lib/$VAR_DIR/data/letsencrypt/acme.json" ]; then SetCertificateGlobal; fi	

	clear
	echo ""

	if [ $VAR_CONF_RESET = 1 ]; then	
	
	    echo "--------------------------- INSTALLATION IS FINISH ----------------------------"
	    echo ""
		echo "═══════════════════════════════════════════════════════════════════════════════"
		echo " IOTA-Bee Dashboard: https://$VAR_HOST:$VAR_IOTA_BEE_HTTPS_PORT/dashboard"
		echo " IOTA-Bee Dashboard Username: $VAR_USERNAME"
		echo " IOTA-Bee Dashboard Password: <set during install>"
		echo " IOTA-Bee API: https://$VAR_HOST:$VAR_IOTA_BEE_HTTPS_PORT/api/v1/info"
		echo "═══════════════════════════════════════════════════════════════════════════════"
	else
	    echo "------------------------------ UPDATE IS FINISH - -----------------------------"
	fi
	echo ""
	
	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx

	SubMenuMaintenance
}

IotaWasp() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║            DLT.GREEN AUTOMATIC IOTA-WASP INSTALLATION WITH DOCKER           ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx

	if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; if [ -f "/var/lib/$VAR_DIR/docker-compose.yml" ]; then docker-compose down; fi; fi

	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                    Create wasp directory /var/lib/iota-wasp                 ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	if [ ! -d /var/lib/$VAR_DIR ]; then mkdir /var/lib/$VAR_DIR || exit; fi
	cd /var/lib/$VAR_DIR || exit

	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║        Pull installer from github.com/dlt-green/node-installer-docker       ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	wget -cO - "$DockerIotaWasp" > install.tar.gz

	if [ -f docker-compose.yml ]; then rm docker-compose.yml; fi

	echo "unpack:"
	tar -xzf install.tar.gz

	echo "remove tar.gz:"
	rm -r install.tar.gz

	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx

	CheckConfiguration
	
	if [ $VAR_CONF_RESET = 1 ]; then
	
		clear
		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                               Set Parameters                                ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		echo "Set the domain name (example: $ca""vrom.dlt.green""$xx):"
		read -p '> ' VAR_HOST
		echo ''
		echo "Set the dashboard port (example: $ca""447""$xx):"
		read -p '> ' VAR_IOTA_WASP_HTTPS_PORT
		echo ''
		echo "Set the api port (example: $ca""448""$xx):"
		read -p '> ' VAR_IOTA_WASP_API_PORT
		echo ''
		echo "Set the peering port (example: $ca""4000""$xx):"
		read -p '> ' VAR_IOTA_WASP_PEERING_PORT
		echo ''
		echo "Set the nano-msg-port (example: $ca""5550""$xx):"
		read -p '> ' VAR_IOTA_WASP_NANO_MSG_PORT
		echo ''
		echo "Set the ledger-connection/txstream (example: $ca""127.0.0.1:5000""$xx):"
		read -p '> ' VAR_IOTA_WASP_LEDGER_CONNECTION
		echo ''
		echo "Set the dashboard username (example: $ca""vrom""$xx):"
		read -p '> ' VAR_USERNAME
		echo ''
		echo "Set the dashboard password:"
		echo "(information: $ca""will be saved as text / don't leave it empty""$xx):"
		read -p '> ' VAR_PASSWORD
		echo ''
		
		CheckCertificate
	
		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                              Write Parameters                               ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; fi
		if [ -f .env ]; then rm .env; fi

		echo "WASP_VERSION=$VAR_IOTA_WASP_VERSION" >> .env

		echo "WASP_HOST=$VAR_HOST" >> .env
		echo "WASP_HTTPS_PORT=$VAR_IOTA_WASP_HTTPS_PORT" >> .env
		echo "WASP_API_PORT=$VAR_IOTA_WASP_API_PORT" >> .env
		echo "WASP_PEERING_PORT=$VAR_IOTA_WASP_PEERING_PORT" >> .env
		echo "WASP_NANO_MSG_PORT=$VAR_IOTA_WASP_NANO_MSG_PORT" >> .env
		echo "WASP_LEDGER_CONNECTION=$VAR_IOTA_WASP_LEDGER_CONNECTION" >> .env
	
		if [ $VAR_CERT = 0 ]
		then
			echo "WASP_HTTP_PORT=80" >> .env
				read -p 'Set mail for certificat renewal (e.g. info@dlt.green): ' VAR_ACME_EMAIL
			echo "ACME_EMAIL=$VAR_ACME_EMAIL" >> .env
		else
			echo "WASP_HTTP_PORT=8084" >> .env
			echo "SSL_CONFIG=certs" >> .env
			echo "WASP_SSL_CERT=/etc/letsencrypt/live/$VAR_HOST/fullchain.pem" >> .env
			echo "WASP_SSL_KEY=/etc/letsencrypt/live/$VAR_HOST/privkey.pem" >> .env
		fi
	else
		if [ -f .env ]; then sed -i "s/WASP_VERSION=.*/WASP_VERSION=$VAR_IOTA_WASP_VERSION/g" .env; fi
	fi
	
	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx

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

		VAR_DASHBOARD_PASSWORD=VAR_PASSWORD

		echo "DASHBOARD_USERNAME=$VAR_USERNAME" >> .env
		echo "DASHBOARD_PASSWORD=$VAR_PASSWORD" >> .env
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
	
		echo ufw allow "$VAR_IOTA_WASP_HTTPS_PORT/tcp" && ufw allow "$VAR_IOTA_WASP_HTTPS_PORT/tcp"
		echo ufw allow "$VAR_IOTA_WASP_API_PORT/tcp" && ufw allow "$VAR_IOTA_WASP_API_PORT/tcp"
		echo ufw allow "$VAR_IOTA_WASP_PEERING_PORT/tcp" && ufw allow "$VAR_IOTA_WASP_PEERING_PORT/tcp"
		echo ufw allow "$VAR_IOTA_WASP_NANO_MSG_PORT/tcp" && ufw allow "$VAR_IOTA_WASP_NANO_MSG_PORT/tcp"		
		VAR_IOTA_WASP_LEDGER_CONNECTION_PORT=$(echo $VAR_IOTA_WASP_LEDGER_CONNECTION | sed -e 's/^.*://')
		echo ufw allow "$VAR_IOTA_WASP_LEDGER_CONNECTION_PORT/tcp" && ufw allow "$VAR_IOTA_WASP_LEDGER_CONNECTION_PORT/tcp"
	fi
	
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                               Start IOTA-Wasp                               ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; fi

	docker-compose up -d
	
	sleep 3
	
	RenameContainer

	echo ""
	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx

	if [ -s "/var/lib/$VAR_DIR/data/letsencrypt/acme.json" ]; then SetCertificateGlobal; fi	

	clear
	echo ""

	if [ $VAR_CONF_RESET = 1 ]; then	
	
	    echo "--------------------------- INSTALLATION IS FINISH ----------------------------"
	    echo ""
		echo "═══════════════════════════════════════════════════════════════════════════════"
		echo " IOTA-Wasp Dashboard: https://$VAR_HOST:$VAR_IOTA_WASP_HTTPS_PORT/dashboard"
		echo " IOTA-Wasp Dashboard Username: $VAR_USERNAME"
		echo " IOTA-Wasp Dashboard Password: <set during install>"
		echo " IOTA-Wasp API: https://$VAR_HOST:$VAR_IOTA_WASP_API_PORT/info"
		echo " IOTA-Wasp peering: $VAR_HOST:$VAR_IOTA_WASP_PEERING_PORT"
		echo " IOTA-Wasp nano-msg: $VAR_HOST:$VAR_IOTA_WASP_NANO_MSG_PORT"
		echo " IOTA-Wasp ledger-connection/txstream: $VAR_IOTA_WASP_LEDGER_CONNECTION"
		echo "═══════════════════════════════════════════════════════════════════════════════"
	else
	    echo "------------------------------ UPDATE IS FINISH - -----------------------------"
	fi
	echo ""
	
	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx

	SubMenuMaintenance
}

IotaGoshimmer() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║         DLT.GREEN AUTOMATIC IOTA-GOSHIMMER INSTALLATION WITH DOCKER         ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx

	if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; if [ -f "/var/lib/$VAR_DIR/docker-compose.yml" ]; then docker-compose down; fi; fi

	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                  Create bee directory /var/lib/iota-goshimmer               ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	if [ ! -d /var/lib/$VAR_DIR ]; then mkdir /var/lib/$VAR_DIR || exit; fi
	cd /var/lib/$VAR_DIR || exit

	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║        Pull installer from github.com/dlt-green/node-installer-docker       ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	wget -cO - "$DockerIotaGoshimmer" > install.tar.gz

	if [ -f docker-compose.yml ]; then rm docker-compose.yml; fi

	echo "unpack:"
	tar -xzf install.tar.gz

	echo "remove tar.gz:"
	rm -r install.tar.gz

	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx

	CheckConfiguration

	if [ $VAR_CONF_RESET = 1 ]; then
	
		clear
		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                               Set Parameters                                ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		echo "Set the domain name (example: $ca""vrom.dlt.green""$xx):"
		read -p '> ' VAR_HOST
		echo ''
		echo "Set the dashboard port (example: $ca""446""$xx):"
		read -p '> ' VAR_IOTA_GOSHIMMER_HTTPS_PORT
		echo ''
	
		CheckCertificate

		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                              Write Parameters                               ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; fi
		if [ -f .env ]; then rm .env; fi

		echo "GOSHIMMER_VERSION=$VAR_IOTA_GOSHIMMER_VERSION" >> .env

		echo "GOSHIMMER_HOST=$VAR_HOST" >> .env
		echo "GOSHIMMER_HTTPS_PORT=$VAR_IOTA_GOSHIMMER_HTTPS_PORT" >> .env
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
		if [ -f .env ]; then sed -i "s/GOSHIMMER_VERSION=.*/GOSHIMMER_VERSION=$VAR_IOTA_GOSHIMMER_VERSION/g" .env; fi
	fi
	
	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx

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
	
		echo ufw allow "$VAR_IOTA_GOSHIMMER_HTTPS_PORT/tcp" && ufw allow "$VAR_IOTA_GOSHIMMER_HTTPS_PORT/tcp"
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
	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx

	if [ -s "/var/lib/$VAR_DIR/data/letsencrypt/acme.json" ]; then SetCertificateGlobal; fi	

	clear
	echo ""
	
	if [ $VAR_CONF_RESET = 1 ]; then
	
		echo "--------------------------- INSTALLATION IS FINISH ----------------------------"
		echo ""
		echo "═══════════════════════════════════════════════════════════════════════════════"
		echo " IOTA-Goshimmer Dashboard: https://$VAR_HOST:$VAR_IOTA_GOSHIMMER_HTTPS_PORT/dashboard"
		echo " IOTA-Goshimmer API: https://$VAR_HOST:$VAR_IOTA_GOSHIMMER_HTTPS_PORT/info"
		echo "═══════════════════════════════════════════════════════════════════════════════"
		echo ""
	else
	    echo "------------------------------ UPDATE IS FINISH - -----------------------------"
	fi
	echo ""	

	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx

	SubMenuMaintenance
}

ShimmerHornet() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║         DLT.GREEN AUTOMATIC SHIMMER-HORNET INSTALLATION WITH DOCKER         ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx

	if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; if [ -f "/var/lib/$VAR_DIR/docker-compose.yml" ]; then docker-compose down; fi; fi

	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                   Create hornet directory /var/lib/shimmer-hornet           ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	if [ ! -d /var/lib/$VAR_DIR ]; then mkdir /var/lib/$VAR_DIR || exit; fi
	cd /var/lib/$VAR_DIR || exit

	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║        Pull installer from github.com/dlt-green/node-installer-docker       ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	wget -cO - "$DockerShimmerHornet" > install.tar.gz
	
	if [ -f docker-compose.yml ]; then rm docker-compose.yml; fi

	echo "unpack:"
	tar -xzf install.tar.gz

	echo "remove tar.gz:"
	rm -r install.tar.gz

	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx

	CheckConfiguration

	if [ $VAR_CONF_RESET = 1 ]; then
	
		clear
		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                               Set Parameters                                ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		echo "Set the domain name (example: $ca""vrom.dlt.builders""$xx):"
		read -p '> ' VAR_HOST
		echo ''
		echo "Set the dashboard username (example: $ca""vrom""$xx):"
		read -p '> ' VAR_USERNAME
		echo ''
		echo "Set the dashboard password:"
		echo "(information: $ca""will be saved as hash / don't leave it empty""$xx):"
		read -p '> ' VAR_PASSWORD
		echo ''
		echo "Set the mail for letz encrypt certificat renewal (example: $ca""info@dlt.green""$xx):"
		read -p '> ' VAR_ACME_EMAIL
		echo ''

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

	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx

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
	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx

	if [ -s "/var/lib/$VAR_DIR/data/letsencrypt/acme.json" ]; then SetCertificateGlobal; fi
	
	clear
	echo ""	

	if [ $VAR_CONF_RESET = 1 ]; then
	
		echo "--------------------------- INSTALLATION IS FINISH ----------------------------"
		echo ""
		echo "═══════════════════════════════════════════════════════════════════════════════"
		echo " SHIMMER-Hornet Dashboard: https://$VAR_HOST/dashboard"
		echo " SHIMMER-Hornet Dashboard Username: $VAR_USERNAME"
		echo " SHIMMER-Hornet Dashboard Password: <set during install>"
		echo " SHIMMER-Hornet API: https://$VAR_HOST/api/core/v2/info"
		echo " Grafana Dashboard: https://$VAR_HOST/grafana"
		echo " Grafana Username: admin"
		echo " Grafana Password: <same as hornet password>"
		echo "═══════════════════════════════════════════════════════════════════════════════"
		echo ""
	else
	    echo "------------------------------ UPDATE IS FINISH - -----------------------------"
	fi
	echo ""		

	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx

	SubMenuMaintenance
}

ShimmerWasp() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║          DLT.GREEN AUTOMATIC SHIMMER-WASP INSTALLATION WITH DOCKER          ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx

	if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; if [ -f "/var/lib/$VAR_DIR/docker-compose.yml" ]; then docker-compose down; fi; fi

	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                 Create wasp directory /var/lib/shimmer-wasp                 ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	if [ ! -d /var/lib/$VAR_DIR ]; then mkdir /var/lib/$VAR_DIR || exit; fi
	cd /var/lib/$VAR_DIR || exit

	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║        Pull installer from github.com/dlt-green/node-installer-docker       ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	wget -cO - "$DockerShimmerWasp" > install.tar.gz

	if [ -f docker-compose.yml ]; then rm docker-compose.yml; fi

	echo "unpack:"
	tar -xzf install.tar.gz

	echo "remove tar.gz:"
	rm -r install.tar.gz

	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx

	CheckConfiguration
	
	if [ $VAR_CONF_RESET = 1 ]; then
	
		clear
		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                               Set Parameters                                ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		echo "Set the domain name (example: $ca""vrom.dlt.green""$xx):"
		read -p '> ' VAR_HOST
		echo ''
		echo "Set the dashboard port (example: $ca""441""$xx):"
		read -p '> ' VAR_SHIMMER_WASP_HTTPS_PORT
		echo ''
		echo "Set the api port (example: $ca""442""$xx):"
		read -p '> ' VAR_SHIMMER_WASP_API_PORT
		echo ''
		echo "Set the peering port (example: $ca""4001""$xx):"
		read -p '> ' VAR_SHIMMER_WASP_PEERING_PORT
		echo ''
		echo "Set the nano-msg-port (example: $ca""5551""$xx):"
		read -p '> ' VAR_SHIMMER_WASP_NANO_MSG_PORT
		echo ''
		echo "Set the ledger-connection/txstream (example: $ca""127.0.0.1:5001""$xx):"
		read -p '> ' VAR_SHIMMER_WASP_LEDGER_CONNECTION
		echo ''
		echo "Set the dashboard username (example: $ca""vrom""$xx):"
		read -p '> ' VAR_USERNAME
		echo ''
		echo "Set the dashboard password:"
		echo "(information: $ca""will be saved as text / don't leave it empty""$xx):"
		read -p '> ' VAR_PASSWORD
		echo ''
		
		CheckCertificate
	
		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                              Write Parameters                               ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; fi
		if [ -f .env ]; then rm .env; fi

		echo "WASP_VERSION=$VAR_SHIMMER_WASP_VERSION" >> .env
		echo "WASP_HOST=$VAR_HOST" >> .env
		echo "WASP_HTTPS_PORT=$VAR_SHIMMER_WASP_HTTPS_PORT" >> .env
		echo "WASP_API_PORT=$VAR_SHIMMER_WASP_API_PORT" >> .env
		echo "WASP_PEERING_PORT=$VAR_SHIMMER_WASP_PEERING_PORT" >> .env
		echo "WASP_NANO_MSG_PORT=$VAR_SHIMMER_WASP_NANO_MSG_PORT" >> .env
		echo "WASP_LEDGER_CONNECTION=$VAR_SHIMMER_WASP_LEDGER_CONNECTION" >> .env
	
		if [ $VAR_CERT = 0 ]
		then
			echo "WASP_HTTP_PORT=80" >> .env
				read -p 'Set mail for certificat renewal (e.g. info@dlt.green): ' VAR_ACME_EMAIL
			echo "ACME_EMAIL=$VAR_ACME_EMAIL" >> .env
		else
			echo "WASP_HTTP_PORT=8087" >> .env
			echo "SSL_CONFIG=certs" >> .env
			echo "WASP_SSL_CERT=/etc/letsencrypt/live/$VAR_HOST/fullchain.pem" >> .env
			echo "WASP_SSL_KEY=/etc/letsencrypt/live/$VAR_HOST/privkey.pem" >> .env
		fi
	else
		if [ -f .env ]; then sed -i "s/WASP_VERSION=.*/WASP_VERSION=$VAR_SHIMMER_WASP_VERSION/g" .env; fi
	fi
	
	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx

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

		VAR_DASHBOARD_PASSWORD=VAR_PASSWORD

		echo "DASHBOARD_USERNAME=$VAR_USERNAME" >> .env
		echo "DASHBOARD_PASSWORD=$VAR_PASSWORD" >> .env
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
	
		echo ufw allow "$VAR_SHIMMER_WASP_HTTPS_PORT/tcp" && ufw allow "$VAR_SHIMMER_WASP_HTTPS_PORT/tcp"
		echo ufw allow "$VAR_SHIMMER_WASP_API_PORT/tcp" && ufw allow "$VAR_SHIMMER_WASP_API_PORT/tcp"
		echo ufw allow "$VAR_SHIMMER_WASP_PEERING_PORT/tcp" && ufw allow "$VAR_SHIMMER_WASP_PEERING_PORT/tcp"
		echo ufw allow "$VAR_SHIMMER_WASP_NANO_MSG_PORT/tcp" && ufw allow "$VAR_SHIMMER_WASP_NANO_MSG_PORT/tcp"		
		VAR_SHIMMER_WASP_LEDGER_CONNECTION_PORT=$(echo $VAR_SHIMMER_WASP_LEDGER_CONNECTION | sed -e 's/^.*://')
		echo ufw allow "$VAR_SHIMMER_WASP_LEDGER_CONNECTION_PORT/tcp" && ufw allow "$VAR_SHIMMER_WASP_LEDGER_CONNECTION_PORT/tcp"
	fi
	
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                             Start SHIMMER-Wasp                              ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; fi

	docker-compose up -d
	
	sleep 3
	
	RenameContainer

	echo ""
	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx

	if [ -s "/var/lib/$VAR_DIR/data/letsencrypt/acme.json" ]; then SetCertificateGlobal; fi	

	clear
	echo ""

	if [ $VAR_CONF_RESET = 1 ]; then	
	
	    echo "--------------------------- INSTALLATION IS FINISH ----------------------------"
	    echo ""
		echo "═══════════════════════════════════════════════════════════════════════════════"
		echo " SHIMMER-Wasp Dashboard: https://$VAR_HOST:$VAR_SHIMMER_WASP_HTTPS_PORT/dashboard"
		echo " SHIMMER-Wasp Dashboard Username: $VAR_USERNAME"
		echo " SHIMMER-Wasp Dashboard Password: <set during install>"
		echo " SHIMMER-Wasp API: https://$VAR_HOST:$VAR_SHIMMER_WASP_API_PORT/info"
		echo " SHIMMER-Wasp peering: $VAR_HOST:$VAR_SHIMMER_WASP_PEERING_PORT"
		echo " SHIMMER-Wasp nano-msg: $VAR_HOST:$VAR_SHIMMER_WASP_NANO_MSG_PORT"
		echo " SHIMMER-Wasp ledger-connection/txstream: $VAR_SHIMMER_WASP_LEDGER_CONNECTION"
		echo "═══════════════════════════════════════════════════════════════════════════════"
	else
	    echo "------------------------------ UPDATE IS FINISH - -----------------------------"
	fi
	echo ""
	
	echo $fl; read -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo $xx

	SubMenuMaintenance
}

RenameContainer() {
	docker container rename iota-hornet_hornet_1 iota-hornet >/dev/null 2>&1
	docker container rename iota-hornet_traefik_1 iota-hornet.traefik >/dev/null 2>&1
	docker container rename iota-bee_bee_1 iota-bee >/dev/null 2>&1
	docker container rename iota-bee_traefik_1 iota-bee.traefik >/dev/null 2>&1
	docker container rename iota-goshimmer_goshimmer_1 iota-goshimmer >/dev/null 2>&1
	docker container rename iota-goshimmer_traefik_1 iota-goshimmer.traefik >/dev/null 2>&1
	docker container rename iota-wasp_traefik_1 iota-wasp.traefik >/dev/null 2>&1
	docker container rename iota-wasp_wasp_1 iota-wasp >/dev/null 2>&1
	docker container rename shimmer-hornet_hornet_1 shimmer-hornet >/dev/null 2>&1
	docker container rename shimmer-hornet_traefik_1 shimmer-hornet.traefik >/dev/null 2>&1
	docker container rename shimmer-hornet_inx-participation_1 shimmer-hornet.inx-participation >/dev/null 2>&1
	docker container rename shimmer-hornet_inx-dashboard_1 shimmer-hornet.inx-dashboard >/dev/null 2>&1
	docker container rename shimmer-hornet_inx-indexer_1 shimmer-hornet.inx-indexer >/dev/null 2>&1
	docker container rename shimmer-hornet_inx-poi_1 shimmer-hornet.inx-poi >/dev/null 2>&1
	docker container rename shimmer-hornet_inx-spammer_1 shimmer-hornet.inx-spammer >/dev/null 2>&1
	docker container rename shimmer-hornet_inx-mqtt_1 shimmer-hornet.inx-mqtt >/dev/null 2>&1
	docker container rename shimmer-wasp_traefik_1 shimmer-wasp.traefik >/dev/null 2>&1
	docker container rename shimmer-wasp_wasp_1 shimmer-wasp >/dev/null 2>&1
}

MainMenu