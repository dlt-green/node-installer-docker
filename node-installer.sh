#!/bin/bash

VRSN="0.9.7"

VAR_DOMAIN=''
VAR_HOST=''
VAR_DIR=''
VAR_CERT=0
VAR_NETWORK=0
VAR_NODE=0
VAR_CONF_RESET=0

VAR_IOTA_HORNET_VERSION='1.2.1'
VAR_IOTA_BEE_VERSION='0.3.1'
VAR_IOTA_GOSHIMMER_VERSION='0.9.8'
VAR_IOTA_WASP_VERSION='0.2.5'
VAR_SHIMMER_HORNET_VERSION='2.0.0-beta.9'
VAR_SHIMMER_WASP_VERSION='0.3.1'

VAR_INX_INDEXER_VERSION='1.0-beta'
VAR_INX_MQTT_VERSION='1.0-beta'
VAR_INX_PARTICIPATION_VERSION='1.0-beta'
VAR_INX_SPAMMER_VERSION='1.0-beta'
VAR_INX_POI_VERSION='1.0-beta'
VAR_INX_DASHBOARD_VERSION='1.0-beta'

lg='\033[1m'
ca='\e[1;96m'
rd='\e[1;91m'
gn='\e[1;92m'
gr='\e[1;90m'
fl='\033[1m'

xx='\033[0m'

echo "$xx"

InstallerHash=$(curl -L https://github.com/dlt-green/node-installer-docker/releases/download/v.$VRSN/checksum.txt)

IotaHornetHash='a11d0db866a731f105d40a642ad72f6b5b57918ba1366a3f53f29ba21fc1fb05'
IotaHornetPackage="https://github.com/dlt-green/node-installer-docker/releases/download/v.$VRSN/iota-hornet.tar.gz"

IotaBeeHash='a231c786a3fc4deb10eed88623fdd6d29851209ab0b93361eb27f9c7a2f830d3'
IotaBeePackage="https://github.com/dlt-green/node-installer-docker/releases/download/v.$VRSN/iota-bee.tar.gz"

IotaGoshimmerHash='9500b1c9db692804dd57209ed761cd2e8e600210afa37600ec8df8d080adc13e'
IotaGoshimmerPackage="https://github.com/dlt-green/node-installer-docker/releases/download/v.$VRSN/iota-goshimmer.tar.gz"

IotaWaspHash='3ac40eceb1e3232b7ed26234694ea35246a14ef35520d4c52b93c4033364bfae'
IotaWaspPackage="https://github.com/dlt-green/node-installer-docker/releases/download/v.$VRSN/wasp.tar.gz"

ShimmerHornetHash='7604c3e0b7d8b719e65b73e9f5b8be424fbd50ade4a284daadf4750c63bd4325'
ShimmerHornetPackage="https://github.com/dlt-green/node-installer-docker/releases/download/v.$VRSN/shimmer-hornet.tar.gz"

ShimmerWaspHash='3ac40eceb1e3232b7ed26234694ea35246a14ef35520d4c52b93c4033364bfae'
ShimmerWaspPackage="https://github.com/dlt-green/node-installer-docker/releases/download/v.$VRSN/wasp.tar.gz"

SnapshotIotaGoshimmer="https://dbfiles-goshimmer.s3.eu-central-1.amazonaws.com/snapshots/nectar/snapshot-latest.bin"

clear
if [ -f "node-installer.sh" ]; then 

	fgrep -q "alias dlt.green=" ~/.bash_aliases >/dev/null 2>&1 || (echo "" >> ~/.bash_aliases && echo "# DLT.GREEN Node-Installer-Docker" >> ~/.bash_aliases && echo "alias dlt.green=" >> ~/.bash_aliases)
	if [ -f ~/.bash_aliases ]; then sed -i 's/alias dlt.green=.*/alias dlt.green="sudo wget https:\/\/github.com\/dlt-green\/node-installer-docker\/releases\/latest\/download\/node-installer.sh \&\& sudo sh node-installer.sh"/g' ~/.bash_aliases; fi

	if [ "$(shasum -a 256 './node-installer.sh' | cut -d ' ' -f 1)" != "$InstallerHash" ]; then
		echo "$rd"; echo 'Checking Hash of Installer failed...'
		echo 'Installer has been tampered, Installation aborted for your Security!'
		echo "Downloaded Installer is deleted!"
		sudo rm node-installer.sh -f
		echo "$xx"; exit;
	fi
	sudo rm node-installer.sh -f
fi

if [ "$(id -u)" -ne 0 ]; then echo "$rd" && echo 'Please run DLT.GREEN Automatic Node-Installer with sudo or as root' && echo "$xx"; exit; fi

CheckIota() {
	if [ -s "/var/lib/iota-hornet/.env" ];    then VAR_NETWORK=1; fi
	if [ -s "/var/lib/iota-bee/.env" ];       then VAR_NETWORK=1; fi
	if [ -s "/var/lib/iota-goshimmer/.env" ]; then VAR_NETWORK=1; fi
	if [ -s "/var/lib/iota-wasp/.env" ];      then VAR_NETWORK=1; fi
}

CheckShimmer() {
	if [ -s "/var/lib/shimmer-hornet/.env" ]; then VAR_NETWORK=2; fi
	if [ -s "/var/lib/shimmer-bee/.env" ];    then VAR_NETWORK=2; fi
	if [ -s "/var/lib/shimmer-wasp/.env" ];   then VAR_NETWORK=2; fi
}

CheckFirewall() {
	if [ $(LC_ALL=en_GB.UTF-8 LC_LANG=en_GB.UTF-8 ufw status | grep 'Status:' | cut -d ' ' -f 2) != 'active' ]
	then
		clear
		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║ DLT.GREEN           AUTOMATIC NODE-INSTALLER WITH DOCKER            v.$VRSN ║"
		echo "║                                                                             ║"
		echo "║$rd            _   _____  _____  _____  _   _  _____  ___  ___   _   _          $xx║"
		echo "║$rd           / \ |_   _||_   _|| ____|| \ | ||_   _||_ _|/ _ \ | \ | |         $xx║"
		echo "║$rd          / _ \  | |    | |  |  _|  |  \| |  | |   | || | | ||  \| |         $xx║"
		echo "║$rd         / ___ \ | |    | |  | |___ | |\  |  | |   | || |_| || |\  |         $xx║"
		echo "║$rd        /_/   \_\|_|    |_|  |_____||_| \_|  |_|  |___|\___/ |_| \_|         $xx║"
		echo "║                                                                             ║"
		echo "║                                                                             ║"
		echo "║$rd                       !!! Firewall UFW not enabled !!!                      $xx║"
		echo "║                                                                             ║"
		echo "║                 your default or custom SSH Port will be set                 ║"
		echo "║                                                                             ║"
		echo "║          press [S] to skip, [F] to enable the Firewall, [Q] to quit         ║"
		echo "║                                                                             ║"
		echo "║                       GNU General Public License v3.0                       ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""
		echo "select menu item:"
		echo ""

		read -r -p '> ' n
		case $n in
		s|S) ;;
		q|Q) clear; exit ;;
		*) clear
		     echo "$ca"
		     echo 'Enable UFW Firewall...'
		     echo "$xx"
		     sleep 3

			 if [ -z "$(cat /etc/ssh/sshd_config | grep -v '^#' | grep "^Port"| cut -d ' ' -f 2)" ]
			 then
				VAR_SSH_PORT=22
				echo "Set default SSH-Port... $VAR_SSH_PORT/tcp"
			 else
				VAR_SSH_PORT=$(cat /etc/ssh/sshd_config | grep -v '^#' | grep "^Port"| cut -d ' ' -f 2)
				echo "Set custom SSH-Port... $VAR_SSH_PORT/tcp"
			 fi

			 echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"
			 echo ufw allow "$VAR_SSH_PORT/tcp" && ufw allow "$VAR_SSH_PORT/tcp"
			 sudo ufw enable
			 echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"
			 ;;
		esac
	fi
}

CheckDomain() {
	if [ "$(dig +short "$1")" != "$(curl -s 'https://ipinfo.io/ip')" ]
	then
		echo ""
	    echo "$rd""Attention! Verification of your specified Domain failed! Installation aborted!""$xx"
	    echo "$rd""Maybe you entered a wrong Domain or the DNS is not reachable yet?""$xx"
	    echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"
		SubMenuMaintenance
	else
	    echo "$gn""Verification of your specified Domain successful""$xx"
	fi
}

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
		echo "║ DLT.GREEN           AUTOMATIC NODE-INSTALLER WITH DOCKER            v.$VRSN ║"
		echo "║""$ca""$VAR_DOMAIN""$xx""║"
		echo "║                                                                             ║"
		echo "║                            1. Use existing Certificate                      ║"
		echo "║                            X. Generate new Let's Encrypt Certificate        ║"
		echo "║                                                                             ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""
		echo "$rd""Attention! For one Node on your Server (Master-Node, e.g. HORNET)"
		echo "you must use (X) for getting a Let's Encrypt Certificate,"
		echo "for all additional installed Nodes use (1) existing Certificate,"
		echo "then the Node will use the Certificate from the Master-Node""$xx"
		echo ""
		echo "select menu item: "
		echo ""
		read -r -p '> ' n
		case $n in
		1) VAR_CERT=1
		   rm -rf /var/lib/"$VAR_DIR"/data/letsencrypt/* ;;
		*) echo "No existing Let's Encrypt Certificate found, generate a new one... "
		   VAR_CERT=0
		   rm -rf /var/lib/"$VAR_DIR"/data/letsencrypt/* ;;
		esac
	else
		echo "No existing Let's Encrypt Certificate found, generate a new one... "
		VAR_CERT=0
		rm -rf /var/lib/"$VAR_DIR"/data/letsencrypt/*
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
		echo "║ DLT.GREEN           AUTOMATIC NODE-INSTALLER WITH DOCKER            v.$VRSN ║"
		echo "║""$ca""$VAR_DOMAIN""$xx""║"
		echo "║                                                                             ║"
		echo "║                            1. Reset Configuration (*.env)                   ║"
		echo "║                            X. Use existing Configuration (*.env)            ║"
		echo "║                                                                             ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""
		echo "select menu item: "
		echo ""

		read -r -p '> ' n
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
	echo "║ DLT.GREEN           AUTOMATIC NODE-INSTALLER WITH DOCKER            v.$VRSN ║"
	echo "║""$ca""$VAR_DOMAIN""$xx""║"
	echo "║                                                                             ║"
	echo "║                            1. Update Certificate for all Nodes (recommend)  ║"
	echo "║                            X. Use Certificate only for this Node            ║"
	echo "║                                                                             ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""
	echo "$rd""Attention! If you (1) update the Certificate for all Nodes,"
	echo "every Node on your Server will use this Certificate after restarting it""$xx"
	echo ""
		echo "select menu item: "
	echo ""

	read -r -p '> ' n
	case $n in
	1)
	   clear
	   echo "$ca"
	   echo 'Update Certificate for all Nodes...'
	   echo "$xx"
	   sleep 10
	   mkdir -p "/etc/letsencrypt/live/$VAR_HOST" || exit
	   cd "/var/lib/$VAR_DIR/data/letsencrypt" || exit
	   cat acme.json | jq -r '.myresolver .Certificates[]? | select(.domain.main=="'"$VAR_HOST"'") | .certificate' | base64 -d > "$VAR_HOST.crt"
	   cat acme.json | jq -r '.myresolver .Certificates[]? | select(.domain.main=="'"$VAR_HOST"'") | .key' | base64 -d > "$VAR_HOST.key"

	   if [ -s "/var/lib/$VAR_DIR/data/letsencrypt/$VAR_HOST.crt" ]; then
	     cp "/var/lib/$VAR_DIR/data/letsencrypt/$VAR_HOST.crt" "/etc/letsencrypt/live/$VAR_HOST/fullchain.pem"
	   fi
	   if [ -s "/var/lib/$VAR_DIR/data/letsencrypt/$VAR_HOST.key" ]; then
	     cp "/var/lib/$VAR_DIR/data/letsencrypt/$VAR_HOST.key" "/etc/letsencrypt/live/$VAR_HOST/privkey.pem"
	     echo "$gn""Global Certificate is now updated for all Nodes""$xx"
	   else
	     echo "$rd""There was an Error on getting a Let's Encrypt Certificate!""$xx"
	     echo "$gn""A default Certificate is now generated only for this Node""$xx"
	   fi
	   echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"
	   ;;
	X) ;;
	esac
}

Dashboard() {

	if [ "$(docker container inspect -f '{{.State.Status}}' 'iota-hornet'    2>/dev/null)" = 'running' ]; then ih=$gn; elif [ -d /var/lib/iota-hornet ];    then ih=$rd; else ih=$gr; fi
	if [ "$(docker container inspect -f '{{.State.Status}}' 'iota-bee'       2>/dev/null)" = 'running' ]; then ib=$gn; elif [ -d /var/lib/iota-bee ];       then ib=$rd; else ib=$gr; fi
	if [ "$(docker container inspect -f '{{.State.Status}}' 'iota-goshimmer' 2>/dev/null)" = 'running' ]; then ig=$gn; elif [ -d /var/lib/iota-goshimmer ]; then ig=$rd; else ig=$gr; fi
	if [ "$(docker container inspect -f '{{.State.Status}}' 'iota-wasp'      2>/dev/null)" = 'running' ]; then iw=$gn; elif [ -d /var/lib/iota-wasp ];      then iw=$rd; else iw=$gr; fi
	if [ "$(docker container inspect -f '{{.State.Status}}' 'shimmer-hornet' 2>/dev/null)" = 'running' ]; then sh=$gn; elif [ -d /var/lib/shimmer-hornet ]; then sh=$rd; else sh=$gr; fi
	if [ "$(docker container inspect -f '{{.State.Status}}' 'shimmer-bee'    2>/dev/null)" = 'running' ]; then sb=$gn; elif [ -d /var/lib/shimmer-bee ];    then sb=$rd; else sb=$gr; fi
	if [ "$(docker container inspect -f '{{.State.Status}}' 'shimmer-wasp'   2>/dev/null)" = 'running' ]; then sw=$gn; elif [ -d /var/lib/shimmer-wasp ];   then sw=$rd; else sw=$gr; fi

	VAR_DOMAIN=''

	if [ -s "/var/lib/iota-hornet/.env" ];    then VAR_DOMAIN=$(cat /var/lib/iota-hornet/.env    | grep _HOST | cut -d '=' -f 2); fi
	if [ -s "/var/lib/iota-bee/.env" ];       then VAR_DOMAIN=$(cat /var/lib/iota-bee/.env       | grep _HOST | cut -d '=' -f 2); fi
	if [ -s "/var/lib/iota-goshimmer/.env" ]; then VAR_DOMAIN=$(cat /var/lib/iota-goshimmer/.env | grep _HOST | cut -d '=' -f 2); fi
	if [ -s "/var/lib/iota-wasp/.env" ];      then VAR_DOMAIN=$(cat /var/lib/iota-wasp/.env      | grep _HOST | cut -d '=' -f 2); fi
	if [ -s "/var/lib/shimmer-hornet/.env" ]; then VAR_DOMAIN=$(cat /var/lib/shimmer-hornet/.env | grep _HOST | cut -d '=' -f 2); fi
	if [ -s "/var/lib/shimmer-bee/.env" ];    then VAR_DOMAIN=$(cat /var/lib/shimmer-bee/.env    | grep _HOST | cut -d '=' -f 2); fi
	if [ -s "/var/lib/shimmer-wasp/.env" ];   then VAR_DOMAIN=$(cat /var/lib/shimmer-wasp/.env   | grep _HOST | cut -d '=' -f 2); fi

	PositionCenter "$VAR_DOMAIN"
	VAR_DOMAIN=$text

	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║ DLT.GREEN           AUTOMATIC NODE-INSTALLER WITH DOCKER            v.$VRSN ║"
	echo "║""$ca""$VAR_DOMAIN""$xx""║"
	echo "║                                                                             ║"
	echo "║           ┌── IOTA Mainnet ──┐                   ┌── IOTA Devnet ──┐        ║"
	echo "╟─┬─────────────────┬─┬─────────────────┬─┬────────────────┬─┬────────────────╢"
	echo "║1│      ""$ih""HORNET""$xx""     │2│       ""$ib""BEE""$xx""       │3│    ""$ig""GOSHIMMER""$xx""   │4│      ""$iw""WASP""$xx""      ║"
	echo "╟─┴─────────────────┴─┴─────────────────┴─┴────────────────┴─┴────────────────╢"
	echo "║                                                                             ║"
	echo "║                                  Shimmer Beta                               ║"
	echo "╟─┬─────────────────┬─┬─────────────────┬─┬────────────────┬─┬────────────────╢"
	echo "║5│      ""$sh""HORNET""$xx""     │6│       ""$sb""BEE""$xx""       │7│    ""$gr""WASP-CLI""$xx""    │8│      ""$sw""WASP""$xx""      ║"
	echo "╟─┴─────────────────┴─┴─────────────────┴─┴────────────────┴─┴────────────────╢"
	echo "║                                                                             ║"
	echo "║   Status from Docker Container (Nodes): ""$gn""running""$xx"" / ""$rd""stopped""$xx"" / ""$gr""not installed""$xx""   ║"
	echo "║                                                                             ║"
	echo "║       press [S] to start all Nodes, [M] for Maintenance, [Q] to quit        ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""
	echo "select menu item:"
	echo ""

	read -r -p '> ' n
	case $n in

	s|S)
	   clear
	   echo "$ca"
	   echo 'Please wait, starting Nodes can take up to 5 minutes...'
	   echo "$xx"
	   if [ -d /var/lib/iota-hornet ]; then cd /var/lib/iota-hornet || Dashboard; docker-compose up -d; fi
	   if [ -d /var/lib/iota-bee ]; then cd /var/lib/iota-bee || Dashboard; docker-compose up -d; fi
	   if [ -d /var/lib/iota-goshimmer ]; then cd /var/lib/iota-goshimmer || Dashboard; docker-compose up -d; fi
	   if [ -d /var/lib/shimmer-hornet ]; then cd /var/lib/shimmer-hornet || Dashboard; docker-compose up -d; fi
	   if [ -d /var/lib/shimmer-bee ]; then cd /var/lib/shimmer-bee || Dashboard; docker-compose up -d; fi
	   sleep 5
	   if [ -d /var/lib/iota-wasp ]; then cd /var/lib/iota-wasp || Dashboard; docker-compose up -d; fi
	   if [ -d /var/lib/shimmer-wasp ]; then cd /var/lib/shimmer-wasp || Dashboard; docker-compose up -d; fi
	   RenameContainer
	   echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"
	   DashboardHelper ;;

	1) VAR_NETWORK=1; VAR_NODE=1; VAR_DIR='iota-hornet'
	   SubMenuMaintenance ;;
	2) VAR_NETWORK=1; VAR_NODE=2; VAR_DIR='iota-bee'
	   SubMenuMaintenance ;;
	3) VAR_NETWORK=1; VAR_NODE=3; VAR_DIR='iota-goshimmer'
	   SubMenuMaintenance ;;
	4) VAR_NETWORK=1; VAR_NODE=4; VAR_DIR='iota-wasp'
	   SubMenuMaintenance ;;
	5) VAR_NETWORK=2; VAR_NODE=5; VAR_DIR='shimmer-hornet'
	   SubMenuMaintenance ;;
	6) VAR_NETWORK=2; VAR_NODE=6; VAR_DIR='shimmer-bee'
	   DashboardHelper ;;
	7) VAR_NETWORK=2; VAR_NODE=6; VAR_DIR='shimmer-bee'
	   DashboardHelper ;;
	8) VAR_NETWORK=2; VAR_NODE=8; VAR_DIR='shimmer-wasp'
	   SubMenuMaintenance ;;

	q|Q) clear; exit ;;
	*) MainMenu ;;
	esac
}

PositionCenter() {
	text=''
	window_width=78
	text_with=$(echo "$1" | wc -c)
	window_left=$(($window_width / 2 - $text_with / 2))
	window_right=$(($window_width - $text_with - $window_left))
	text=$(printf "%*s%s" $window_left '' "$text")"$1"$(printf "%*s%s" $window_right '' "$text")
}

DashboardHelper() {
Dashboard
}

MainMenu() {

	if [ -z "$VAR_DOMAIN" ]; then PositionCenter ''; VAR_DOMAIN=$text; fi

	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║ DLT.GREEN           AUTOMATIC NODE-INSTALLER WITH DOCKER            v.$VRSN ║"
	echo "║""$ca""$VAR_DOMAIN""$xx""║"
	echo "║                                                                             ║"
	echo "║                              1. System Updates/Docker Cleanup               ║"
	echo "║                              2. Docker Installation                         ║"
	echo "║                              3. Docker Status                               ║"
	echo "║                              4. Firewall Status/Ports                       ║"
	echo "║                              5. License Information                         ║"
	echo "║                              X. Management Dashboard                        ║"
	echo "║                              Q. Quit                                        ║"
	echo "║                                                                             ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""
	echo "select menu item: "
	echo ""

	read -r -p '> ' n
	case $n in
	1) SystemMaintenance ;;
	2) Docker ;;
	3) clear
	   echo "$ca"
	   echo 'Docker Status:'
	   echo "$xx"
	   docker stats --no-stream
	   echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [L] to start live stream... > ' n; echo "$xx"
	   case $n in
	   l|L) clear
	        echo "$rd"; echo 'Closing Installer now, starting Docker Status live stream...';
	        echo 'Hint: Press [STRG+C] to quit the live stream'; echo "$xx"
		  sleep 5
	      docker stats ;;
	   *) ;;
	   esac	   
	   echo "$xx"
	   MainMenu ;;
	4) clear
	   echo "$ca"
	   echo 'Firewall Status/Ports:'
	   echo "$xx"
	   ufw status numbered 2>/dev/null
	   echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"
	   MainMenu ;;
	5) SubMenuLicense ;;
	q|Q) clear; exit ;;
	*) docker --version | grep "Docker version" >/dev/null 2>&1
	   if [ $? -eq 0 ]; then Dashboard; else
  	     echo ""
  	     echo "$rd""Attention! Please install Docker! Loading Dashboard aborted!""$xx"
	     echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"
	     MainMenu
       fi;;
	esac
}

SubMenuLicense() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║ DLT.GREEN           AUTOMATIC NODE-INSTALLER WITH DOCKER            v.$VRSN ║"
	echo "║""$ca""$VAR_DOMAIN""$xx""║"
	echo "║                                                                             ║"
	echo "║                      GNU General Public License v3.0                        ║"
	echo "║                                                                             ║"
	echo "║    https://github.com/dlt-green/node-installer-docker/blob/main/license     ║"
	echo "║                                                                             ║"
	echo "║                              X. Maintenance Menu                            ║"
	echo "║                                                                             ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""
	echo "select menu item: "
	echo ""

	read -r -p '> ' n
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

SubMenuMaintenance() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║ DLT.GREEN           AUTOMATIC NODE-INSTALLER WITH DOCKER            v.$VRSN ║"
	echo "║""$ca""$VAR_DOMAIN""$xx""║"
	echo "║                                                                             ║"
	echo "║                              1. Install/Update                              ║"
	echo "║                              2. Start/Restart                               ║"
	echo "║                              3. Stop                                        ║"
	echo "║                              4. Reset Database                              ║"
	echo "║                              5. Loading Snapshot                            ║"
	echo "║                              6. Show Logs                                   ║"
	echo "║                              7. Deinstall/Remove                            ║"	
	echo "║                              8. Configuration                               ║"
	echo "║                              X. Management Dashboard                        ║"
	echo "║                                                                             ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""
	if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 1 ]; then echo "$ca""Network/Node: $VAR_DIR | Version available: $VAR_IOTA_HORNET_VERSION""$xx"; fi
	if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 2 ]; then echo "$ca""Network/Node: $VAR_DIR | Version available: $VAR_IOTA_BEE_VERSION""$xx"; fi
	if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 3 ]; then echo "$ca""Network/Node: $VAR_DIR | Version available: $VAR_IOTA_GOSHIMMER_VERSION""$xx"; fi
	if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 4 ]; then echo "$ca""Network/Node: $VAR_DIR | Version available: $VAR_IOTA_WASP_VERSION""$xx"; fi
	if [ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 5 ]; then echo "$ca""Network/Node: $VAR_DIR | Version available: $VAR_SHIMMER_HORNET_VERSION""$xx"; fi
	if [ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 8 ]; then echo "$ca""Network/Node: $VAR_DIR | Version available: $VAR_SHIMMER_WASP_VERSION""$xx"; fi
	echo "$rd""Available Diskspace: $(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 4)B/$(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 2)B ($(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 5) used) ""$xx"
	echo ""
	echo "select menu item: "
	echo ""

	read -r -p '> ' n
	case $n in
	1) if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 1 ]; then IotaHornet; fi
	   if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 2 ]; then IotaBee; fi
	   if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 3 ]; then IotaGoshimmer; fi
	   if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 4 ]; then IotaWasp; fi
	   if [ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 5 ]; then ShimmerHornet; fi
	   if [ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 8 ]; then ShimmerWasp; fi
	   ;;
	2) echo '(re)starting...'; sleep 3
	   clear
	   echo "$ca"
	   echo 'Please wait, (re)starting Nodes can take up to 5 minutes...'
	   echo "$xx"

	   if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 1 ]; then docker stop iota-hornet; fi
	   if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 2 ]; then docker stop iota-bee; fi
	   if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 3 ]; then docker stop iota-goshimmer; fi
	   if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 4 ]; then docker stop iota-wasp; fi
	   if [ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 5 ]; then docker stop shimmer-hornet; fi
	   if [ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 8 ]; then docker stop shimmer-wasp; fi

	   if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuMaintenance; docker-compose down; fi
	   rm -rf /var/lib/$VAR_DIR/data/peerdb/*
	   if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuMaintenance; docker-compose up -d; fi

	   RenameContainer; sleep 3

	   echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"
	   SubMenuMaintenance
	   ;;
	3) echo 'stopping...'; sleep 3
	   clear
	   echo "$ca"
	   echo 'Please wait, stopping Nodes can take up to 5 minutes...'
	   echo "$xx"

	   if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 1 ]; then docker stop iota-hornet; fi
	   if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 2 ]; then docker stop iota-bee; fi
	   if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 3 ]; then docker stop iota-goshimmer; fi
	   if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 4 ]; then docker stop iota-wasp; fi
	   if [ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 5 ]; then docker stop shimmer-hornet; fi
	   if [ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 8 ]; then docker stop shimmer-wasp; fi

	   if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuMaintenance; docker-compose down; fi
	   sleep 3;

	   echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"
	   SubMenuMaintenance
	   ;;
	4) echo 'resetting...'; sleep 3
	   clear
	   echo "$ca"
	   echo 'Please wait, resetting Nodes can take up to 5 minutes...'
	   echo "$xx"

	   if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuMaintenance; docker-compose down; fi

	   rm -rf /var/lib/$VAR_DIR/data/storage/mainnet/*
	   rm -rf /var/lib/$VAR_DIR/data/storage/devnet/*
	   rm -rf /var/lib/$VAR_DIR/data/database/*
	   rm -rf /var/lib/$VAR_DIR/data/mainnetdb/*
	   rm -rf /var/lib/$VAR_DIR/data/peerdb/*
	   rm -rf /var/lib/$VAR_DIR/data/waspdb/*

	   if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuMaintenance; docker-compose up -d; fi

	   RenameContainer; sleep 3

	   echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"
	   SubMenuMaintenance
	   ;;
	5) echo 'loading...'; sleep 3
	   clear
	   echo "$ca"
	   echo 'Please wait, loading Snapshots can take up to 5 minutes...'
	   echo "$xx"

	   if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuMaintenance; docker-compose down; fi

	   if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 1 ]; then
	      rm -rf /var/lib/$VAR_DIR/data/storage/*
	      rm -rf /var/lib/$VAR_DIR/data/snapshots/*
	   fi
	   if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 2 ]; then
	      rm -rf /var/lib/$VAR_DIR/data/storage/mainnet/tangle/*
	      rm -rf /var/lib/$VAR_DIR/data/snapshots/mainnet/*
	   fi
	   if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 3 ]
	   then
	      rm -rf /var/lib/$VAR_DIR/data/mainnetdb/*
	      rm -rf /var/lib/$VAR_DIR/data/peerdb/*
	      if [ -f /var/lib/$VAR_DIR/data/snapshots/snapshot.bin ]; then cd /var/lib/$VAR_DIR/data/snapshots || SubMenuMaintenance; wget $SnapshotIotaGoshimmer; mv snapshot-latest.bin snapshot.bin; fi
	   fi
	   cd /var/lib/$VAR_DIR || SubMenuMaintenance;
	   ./prepare_docker.sh
	   if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuMaintenance; docker-compose up -d; fi

	   RenameContainer

	   echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"
	   SubMenuMaintenance
	   ;;
	6) docker logs -f --tail 300 $VAR_DIR
	   echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"
	   SubMenuMaintenance
	   ;;
	8) echo 'deinstall/remove...'; sleep 3
	   echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"
	   clear
	   echo "$ca"
	   echo 'Please wait, deinstalling Nodes can take up to 5 minutes...'
	   echo "$xx"

	   if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuMaintenance; docker-compose down >/dev/null 2>&1; fi
	   if [ -d /var/lib/$VAR_DIR ]; then rm -r /var/lib/$VAR_DIR; fi

	   echo "$rd""$VAR_DIR removed from your system!""$xx"
	   echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"
	   SubMenuMaintenance
	   ;;
	*) Dashboard ;;
	esac
}

SystemMaintenance() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                   DLT.GREEN AUTOMATIC SYSTEM MAINTENANCE                    ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"

	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                  Delete unused old docker containers/images                 ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	docker system prune

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"

	clear
	echo "$ca"
	echo 'Please wait, stopping Nodes can take up to 5 minutes...'
	echo "$xx"
	docker stop $(docker ps -a -q)
	docker ps -a -q

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"

	clear
	echo "$ca"
	echo 'Please wait, updating the System...'
	echo "$xx"
	sudo apt-get update && apt-get upgrade -y
	sudo apt-get dist-upgrade -y
	sudo apt upgrade -y
	sudo apt-get autoremove -y

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"

	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║ DLT.GREEN           AUTOMATIC NODE-INSTALLER WITH DOCKER            v.$VRSN ║"
	echo "║""$ca""$VAR_DOMAIN""$xx""║"
	echo "║                                                                             ║"
	echo "║                            1. System Restart (recommend)                     ║"
	echo "║                            X. Maintenance Menu                              ║"
	echo "║                                                                             ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""
	echo "$gn""You don't have to stop Nodes installed with the DLT.GREEN Installer,"
	echo "but you must restart them with our Installer after reastarting your System""$xx"
	echo ""
	echo "select menu item: "
	echo ""

	read -r -p '> ' n
	case $n in
	1) 	echo 'restarting...'; sleep 3
	    echo "$ca"
	    echo 'System restarted, please reconnect...'
	    echo "$xx"
		sudo reboot
		;;
	*) clear
	   echo "$ca"
	   echo 'Please wait, starting Nodes can take up to 5 minutes...'
	   echo "$xx"
	   if [ -d /var/lib/iota-hornet ]; then cd /var/lib/iota-hornet || Dashboard; docker-compose up -d; fi
	   if [ -d /var/lib/iota-bee ]; then cd /var/lib/iota-bee || Dashboard; docker-compose up -d; fi
	   if [ -d /var/lib/iota-goshimmer ]; then cd /var/lib/iota-goshimmer || Dashboard; docker-compose up -d; fi
	   if [ -d /var/lib/shimmer-hornet ]; then cd /var/lib/shimmer-hornet || Dashboard; docker-compose up -d; fi
	   if [ -d /var/lib/shimmer-bee ]; then cd /var/lib/shimmer-bee || Dashboard; docker-compose up -d; fi
	   sleep 5
	   if [ -d /var/lib/iota-wasp ]; then cd /var/lib/iota-wasp || Dashboard; docker-compose up -d; fi
	   if [ -d /var/lib/shimmer-wasp ]; then cd /var/lib/shimmer-wasp || Dashboard; docker-compose up -d; fi
	   RenameContainer

	   echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"

	   MainMenu ;;
	esac
}

Docker() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                   DLT.GREEN AUTOMATIC DOCKER INSTALLATION                   ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"

	sudo docker ps -a -q >/dev/null 2>&1

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

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"

	MainMenu
}

IotaHornet() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║           DLT.GREEN AUTOMATIC IOTA-HORNET INSTALLATION WITH DOCKER          ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	CheckShimmer
	if [ "$VAR_NETWORK" = 2 ]; then echo "$rd""It's not supported (Security!) to install Nodes from Network"; echo "IOTA and Shimmer on the same Server, deinstall Shimmer Nodes first!""$xx"; fi

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"
	if [ "$VAR_NETWORK" = 2 ]; then VAR_NETWORK=1; SubMenuMaintenance; fi

	echo "Stopping Node... $VAR_DIR"
	if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; if [ -f "/var/lib/$VAR_DIR/docker-compose.yml" ]; then docker-compose down >/dev/null 2>&1; fi; fi

	echo ""
	echo "Check Directory... /var/lib/$VAR_DIR"

	if [ ! -d /var/lib/$VAR_DIR ]; then mkdir /var/lib/$VAR_DIR || exit; fi
	cd /var/lib/$VAR_DIR || exit

	echo ""
	echo "CleanUp Directory... /var/lib/$VAR_DIR"

	find . -maxdepth 1 -mindepth 1 ! \( -name ".env" -o -name "data" \) -exec rm -rf {} +

	echo ""
	echo "Download Package... install.tar.gz"
	wget -cO - "$IotaHornetPackage" -q > install.tar.gz

	if [ "$(shasum -a 256 './install.tar.gz' | cut -d ' ' -f 1)" = "$IotaHornetHash" ]; then
		echo "$gn"; echo 'Checking Hash of Package successful...'; echo "$xx"
	else
		echo "$rd"; echo 'Checking Hash of Package failed...'
		echo 'Package has been tampered, Installation aborted for your Security!'
		echo "Downloaded Package is deleted!"
		rm -r install.tar.gz
		echo "$xx"; exit;
	fi

	if [ -f docker-compose.yml ]; then rm docker-compose.yml; fi

	echo "Unpack Package... install.tar.gz"
	tar -xzf install.tar.gz

	echo "Delete Package... install.tar.gz"
	rm -r install.tar.gz

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"

	CheckConfiguration

	if [ $VAR_CONF_RESET = 1 ]; then

		clear
		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                               Set Parameters                                ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		echo "Set the domain name (example: $ca""vrom.dlt.green""$xx):"
		read -r -p '> ' VAR_HOST
		CheckDomain "$VAR_HOST"

		echo ''
		echo "Set the dashboard port (example: $ca""443""$xx):"
		read -r -p '> ' VAR_IOTA_HORNET_HTTPS_PORT
		echo ''
		echo "Set the pruning size / max. database size (example: $ca""200GB""$xx):"
		echo "$rd""Available Diskspace: $(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 4)B/$(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 2)B ($(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 5) used) ""$xx"
		read -r -p '> ' VAR_IOTA_HORNET_PRUNING_SIZE
		echo ''
		echo "Set PoW / proof of work (example: $ca""true""$xx): "
		read -r -p '> ' VAR_IOTA_HORNET_POW
		echo ''
		echo "Set the dashboard username (example: $ca""vrom""$xx):"
		read -r -p '> ' VAR_USERNAME
		echo ''
		echo "Set the dashboard password:"
		echo "(information: $ca""will be saved as hash / don't leave it empty""$xx):"
		read -r -p '> ' VAR_PASSWORD
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

		echo "HORNET_NETWORK=mainnet" >> .env

		echo "HORNET_HOST=$VAR_HOST" >> .env
		echo "HORNET_PRUNING_TARGET_SIZE=$VAR_IOTA_HORNET_PRUNING_SIZE" >> .env
		echo "HORNET_POW_ENABLED=$VAR_IOTA_HORNET_POW" >> .env
		echo "HORNET_HTTPS_PORT=$VAR_IOTA_HORNET_HTTPS_PORT" >> .env
		echo "HORNET_GOSSIP_PORT=15600" >> .env
		echo "HORNET_AUTOPEERING_PORT=14626" >> .env

		if [ $VAR_CERT = 0 ]
		then
			echo "HORNET_HTTP_PORT=80" >> .env
				read -r -p 'Set mail for certificat renewal (e.g. info@dlt.green): ' VAR_ACME_EMAIL
			echo "ACME_EMAIL=$VAR_ACME_EMAIL" >> .env
		else
			echo "HORNET_HTTP_PORT=8081" >> .env
			echo "SSL_CONFIG=certs" >> .env
			echo "HORNET_SSL_CERT=/etc/letsencrypt/live/$VAR_HOST/fullchain.pem" >> .env
			echo "HORNET_SSL_KEY=/etc/letsencrypt/live/$VAR_HOST/privkey.pem" >> .env
		fi
	else
		if [ -f .env ]; then sed -i "s/HORNET_VERSION=.*/HORNET_VERSION=$VAR_IOTA_HORNET_VERSION/g" .env; fi
		VAR_HOST=$(cat .env | grep _HOST | cut -d '=' -f 2)
	fi

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"

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
	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"

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

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"

	SubMenuMaintenance
}

IotaBee() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║            DLT.GREEN AUTOMATIC IOTA-BEE INSTALLATION WITH DOCKER            ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	CheckShimmer
	if [ "$VAR_NETWORK" = 2 ]; then echo "$rd""It's not supported (Security!) to install Nodes from Network"; echo "IOTA and Shimmer on the same Server, deinstall Shimmer Nodes first!""$xx"; fi

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"
	if [ "$VAR_NETWORK" = 2 ]; then VAR_NETWORK=1; SubMenuMaintenance; fi

	echo "Stopping Node... $VAR_DIR"
	if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; if [ -f "/var/lib/$VAR_DIR/docker-compose.yml" ]; then docker-compose down >/dev/null 2>&1; fi; fi

	echo ""
	echo "Check Directory... /var/lib/$VAR_DIR"

	if [ ! -d /var/lib/$VAR_DIR ]; then mkdir /var/lib/$VAR_DIR || exit; fi
	cd /var/lib/$VAR_DIR || exit

	echo ""
	echo "CleanUp Directory... /var/lib/$VAR_DIR"

	find . -maxdepth 1 -mindepth 1 ! \( -name ".env" -o -name "data" \) -exec rm -rf {} +

	echo ""
	echo "Download Package... install.tar.gz"
	wget -cO - "$IotaBeePackage" -q > install.tar.gz

	if [ "$(shasum -a 256 './install.tar.gz' | cut -d ' ' -f 1)" = "$IotaBeeHash" ]; then
		echo "$gn"; echo 'Checking Hash of Package successful...'; echo "$xx"
	else
		echo "$rd"; echo 'Checking Hash of Package failed...'
		echo 'Package has been tampered, Installation aborted for your Security!'
		echo "Downloaded Package is deleted!"
		rm -r install.tar.gz
		echo "$xx"; exit;
	fi

	if [ -f docker-compose.yml ]; then rm docker-compose.yml; fi

	echo "Unpack Package... install.tar.gz"
	tar -xzf install.tar.gz

	echo "Delete Package... install.tar.gz"
	rm -r install.tar.gz

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"

	CheckConfiguration

	if [ $VAR_CONF_RESET = 1 ]; then

		clear
		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                               Set Parameters                                ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		echo "Set the domain name (example: $ca""vrom.dlt.green""$xx):"
		read -r -p '> ' VAR_HOST
		CheckDomain "$VAR_HOST"

		echo ''
		echo "Set the dashboard port (example: $ca""440""$xx):"
		read -r -p '> ' VAR_IOTA_BEE_HTTPS_PORT
		echo ''
		echo "Set PoW / proof of work (example: $ca""true""$xx): "
		read -r -p '> ' VAR_IOTA_BEE_POW
		echo ''
		echo "Set the dashboard username (example: $ca""vrom""$xx):"
		read -r -p '> ' VAR_USERNAME
		echo ''
		echo "Set the dashboard password:"
		echo "(information: $ca""will be saved as hash / don't leave it empty""$xx):"
		read -r -p '> ' VAR_PASSWORD
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

		echo "BEE_NETWORK=mainnet" >> .env

		echo "BEE_HOST=$VAR_HOST" >> .env
		echo "BEE_POW_ENABLED=$VAR_IOTA_BEE_POW" >> .env
		echo "BEE_HTTPS_PORT=$VAR_IOTA_BEE_HTTPS_PORT" >> .env
		echo "BEE_GOSSIP_PORT=15601" >> .env
		echo "BEE_AUTOPEERING_PORT=14636" >> .env

		if [ $VAR_CERT = 0 ]
		then
			echo "BEE_HTTP_PORT=80" >> .env
				read -r -p 'Set mail for certificat renewal (e.g. info@dlt.green): ' VAR_ACME_EMAIL
			echo "ACME_EMAIL=$VAR_ACME_EMAIL" >> .env
		else
			echo "BEE_HTTP_PORT=8082" >> .env
			echo "SSL_CONFIG=certs" >> .env
			echo "BEE_SSL_CERT=/etc/letsencrypt/live/$VAR_HOST/fullchain.pem" >> .env
			echo "BEE_SSL_KEY=/etc/letsencrypt/live/$VAR_HOST/privkey.pem" >> .env
		fi
	else
		if [ -f .env ]; then sed -i "s/BEE_VERSION=.*/BEE_VERSION=$VAR_IOTA_BEE_VERSION/g" .env; fi
		VAR_HOST=$(cat .env | grep _HOST | cut -d '=' -f 2)
	fi

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"

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
	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"

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

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"

	SubMenuMaintenance
}

IotaWasp() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║            DLT.GREEN AUTOMATIC IOTA-WASP INSTALLATION WITH DOCKER           ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	CheckShimmer
	if [ "$VAR_NETWORK" = 2 ]; then echo "$rd""It's not supported (Security!) to install Nodes from Network"; echo "IOTA and Shimmer on the same Server, deinstall Shimmer Nodes first!""$xx"; fi

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"
	if [ "$VAR_NETWORK" = 2 ]; then VAR_NETWORK=1; SubMenuMaintenance; fi

	echo "Stopping Node... $VAR_DIR"
	if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; if [ -f "/var/lib/$VAR_DIR/docker-compose.yml" ]; then docker-compose down >/dev/null 2>&1; fi; fi

	echo ""
	echo "Check Directory... /var/lib/$VAR_DIR"

	if [ ! -d /var/lib/$VAR_DIR ]; then mkdir /var/lib/$VAR_DIR || exit; fi
	cd /var/lib/$VAR_DIR || exit

	echo ""
	echo "CleanUp Directory... /var/lib/$VAR_DIR"

	find . -maxdepth 1 -mindepth 1 ! \( -name ".env" -o -name "data" \) -exec rm -rf {} +

	echo ""
	echo "Download Package... install.tar.gz"
	wget -cO - "$IotaWaspPackage" -q > install.tar.gz

	if [ "$(shasum -a 256 './install.tar.gz' | cut -d ' ' -f 1)" = "$IotaWaspHash" ]; then
		echo "$gn"; echo 'Checking Hash of Package successful...'; echo "$xx"
	else
		echo "$rd"; echo 'Checking Hash of Package failed...'
		echo 'Package has been tampered, Installation aborted for your Security!'
		echo "Downloaded Package is deleted!"
		rm -r install.tar.gz
		echo "$xx"; exit;
	fi

	if [ -f docker-compose.yml ]; then rm docker-compose.yml; fi

	echo "Unpack Package... install.tar.gz"
	tar -xzf install.tar.gz

	echo "Delete Package... install.tar.gz"
	rm -r install.tar.gz

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"

	CheckConfiguration

	VAR_WASP_LEDGER_NETWORK='iota'

	if [ $VAR_CONF_RESET = 1 ]; then

		clear
		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                               Set Parameters                                ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		echo "Set the domain name (example: $ca""vrom.dlt.green""$xx):"
		read -r -p '> ' VAR_HOST
		CheckDomain "$VAR_HOST"

		echo ''
		echo "Set the dashboard port (example: $ca""447""$xx):"
		read -r -p '> ' VAR_IOTA_WASP_HTTPS_PORT
		echo ''
		echo "Set the api port (example: $ca""448""$xx):"
		read -r -p '> ' VAR_IOTA_WASP_API_PORT
		echo ''
		echo "Set the peering port (example: $ca""4000""$xx):"
		read -r -p '> ' VAR_IOTA_WASP_PEERING_PORT
		echo ''
		echo "Set the nano-msg-port (example: $ca""5550""$xx):"
		read -r -p '> ' VAR_IOTA_WASP_NANO_MSG_PORT
		echo ''
		echo "Set the ledger-connection/txstream (example: $ca""127.0.0.1:5000""$xx):"
		read -r -p '> ' VAR_IOTA_WASP_LEDGER_CONNECTION
		echo ''
		echo "Set the dashboard username (example: $ca""vrom""$xx):"
		read -r -p '> ' VAR_USERNAME
		echo ''
		echo "Set the dashboard password:"
		echo "(information: $ca""will be saved as text / don't leave it empty""$xx):"
		read -r -p '> ' VAR_PASSWORD
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
		echo "WASP_LEDGER_NETWORK=$VAR_WASP_LEDGER_NETWORK" >> .env
		echo "WASP_LEDGER_CONNECTION=$VAR_IOTA_WASP_LEDGER_CONNECTION" >> .env

		if [ $VAR_CERT = 0 ]
		then
			echo "WASP_HTTP_PORT=80" >> .env
				read -r -p 'Set mail for certificat renewal (e.g. info@dlt.green): ' VAR_ACME_EMAIL
			echo "ACME_EMAIL=$VAR_ACME_EMAIL" >> .env
		else
			echo "WASP_HTTP_PORT=8084" >> .env
			echo "SSL_CONFIG=certs" >> .env
			echo "WASP_SSL_CERT=/etc/letsencrypt/live/$VAR_HOST/fullchain.pem" >> .env
			echo "WASP_SSL_KEY=/etc/letsencrypt/live/$VAR_HOST/privkey.pem" >> .env
		fi
	else
		if grep -q 'WASP_LEDGER_NETWORK=' .env; then sed -i "s/WASP_LEDGER_NETWORK=.*/WASP_LEDGER_NETWORK=$VAR_WASP_LEDGER_NETWORK/g" .env; else echo "WASP_LEDGER_NETWORK=$VAR_WASP_LEDGER_NETWORK" >> .env; fi
		if [ -f .env ]; then sed -i "s/WASP_VERSION=.*/WASP_VERSION=$VAR_IOTA_WASP_VERSION/g" .env; fi
		VAR_HOST=$(cat .env | grep _HOST | cut -d '=' -f 2)
	fi

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"

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
		VAR_IOTA_WASP_LEDGER_CONNECTION_PORT=$(echo "$VAR_IOTA_WASP_LEDGER_CONNECTION" | sed -e 's/^.*://')
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
	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"

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

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"

	SubMenuMaintenance
}

IotaGoshimmer() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║         DLT.GREEN AUTOMATIC IOTA-GOSHIMMER INSTALLATION WITH DOCKER         ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	CheckShimmer
	if [ "$VAR_NETWORK" = 2 ]; then echo "$rd""It's not supported (Security!) to install Nodes from Network"; echo "IOTA and Shimmer on the same Server, deinstall Shimmer Nodes first!""$xx"; fi

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"
	if [ "$VAR_NETWORK" = 2 ]; then VAR_NETWORK=1; SubMenuMaintenance; fi

	echo "Stopping Node... $VAR_DIR"
	if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; if [ -f "/var/lib/$VAR_DIR/docker-compose.yml" ]; then docker-compose down >/dev/null 2>&1; fi; fi

	echo ""
	echo "Check Directory... /var/lib/$VAR_DIR"

	if [ ! -d /var/lib/$VAR_DIR ]; then mkdir /var/lib/$VAR_DIR || exit; fi
	cd /var/lib/$VAR_DIR || exit

	echo ""
	echo "CleanUp Directory... /var/lib/$VAR_DIR"

	find . -maxdepth 1 -mindepth 1 ! \( -name ".env" -o -name "data" \) -exec rm -rf {} +

	echo ""
	echo "Download Package... install.tar.gz"
	wget -cO - "$IotaGoshimmerPackage" -q > install.tar.gz

	if [ "$(shasum -a 256 './install.tar.gz' | cut -d ' ' -f 1)" = "$IotaGoshimmerHash" ]; then
		echo "$gn"; echo 'Checking Hash of Package successful...'; echo "$xx"
	else
		echo "$rd"; echo 'Checking Hash of Package failed...'
		echo 'Package has been tampered, Installation aborted for your Security!'
		echo "Downloaded Package is deleted!"
		rm -r install.tar.gz
		echo "$xx"; exit;
	fi

	if [ -f docker-compose.yml ]; then rm docker-compose.yml; fi

	echo "Unpack Package... install.tar.gz"
	tar -xzf install.tar.gz

	echo "Delete Package... install.tar.gz"
	rm -r install.tar.gz

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"

	CheckConfiguration

	if [ $VAR_CONF_RESET = 1 ]; then

		clear
		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                               Set Parameters                                ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		echo "Set the domain name (example: $ca""vrom.dlt.green""$xx):"
		read -r -p '> ' VAR_HOST
		CheckDomain "$VAR_HOST"

		echo ''
		echo "Set the dashboard port (example: $ca""446""$xx):"
		read -r -p '> ' VAR_IOTA_GOSHIMMER_HTTPS_PORT
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
		echo "GOSHIMMER_WEBAPI_PORT=8080" >> .env

		if [ $VAR_CERT = 0 ]
		then
			echo "GOSHIMMER_HTTP_PORT=80" >> .env
			read -r -p 'Set mail for certificat renewal (e.g. info@dlt.green): ' VAR_ACME_EMAIL
			echo "ACME_EMAIL=$VAR_ACME_EMAIL" >> .env
		else
			echo "GOSHIMMER_HTTP_PORT=8083" >> .env
			echo "SSL_CONFIG=certs" >> .env
			echo "GOSHIMMER_SSL_CERT=/etc/letsencrypt/live/$VAR_HOST/fullchain.pem" >> .env
			echo "GOSHIMMER_SSL_KEY=/etc/letsencrypt/live/$VAR_HOST/privkey.pem" >> .env
		fi
	else
		if [ -f .env ]; then sed -i "s/GOSHIMMER_VERSION=.*/GOSHIMMER_VERSION=$VAR_IOTA_GOSHIMMER_VERSION/g" .env; fi
		VAR_HOST=$(cat .env | grep _HOST | cut -d '=' -f 2)
		echo ""
		echo "Add http Port for connection cli-wallet..."
		fgrep -q "GOSHIMMER_WEBAPI_PORT" .env || echo "GOSHIMMER_WEBAPI_PORT=8080" >> .env
		echo ufw allow '8080/tcp' && ufw allow '8080/tcp'
	fi

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"

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
		echo ufw allow '8080/tcp' && ufw allow '8080/tcp'
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
	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"

	if [ -s "/var/lib/$VAR_DIR/data/letsencrypt/acme.json" ]; then SetCertificateGlobal; fi

	clear
	echo ""

	if [ $VAR_CONF_RESET = 1 ]; then

		echo "--------------------------- INSTALLATION IS FINISH ----------------------------"
		echo ""
		echo "═══════════════════════════════════════════════════════════════════════════════"
		echo " IOTA-Goshimmer Dashboard: https://$VAR_HOST:$VAR_IOTA_GOSHIMMER_HTTPS_PORT/dashboard"
		echo " IOTA-Goshimmer API: https://$VAR_HOST:$VAR_IOTA_GOSHIMMER_HTTPS_PORT/info"
		echo " IOTA-Goshimmer API HTTP Port (for cli-wallet): 8080"
		echo "═══════════════════════════════════════════════════════════════════════════════"
		echo ""
	else
	    echo "------------------------------ UPDATE IS FINISH - -----------------------------"
	fi
	echo ""

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"

	SubMenuMaintenance
}

ShimmerHornet() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║         DLT.GREEN AUTOMATIC SHIMMER-HORNET INSTALLATION WITH DOCKER         ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	CheckIota
	if [ "$VAR_NETWORK" = 1 ]; then echo "$rd""It's not supported (Security!) to install Nodes from Network"; echo "Shimmer and IOTA on the same Server, deinstall IOTA Nodes first!""$xx"; fi

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"
	if [ "$VAR_NETWORK" = 1 ]; then VAR_NETWORK=2; SubMenuMaintenance; fi

	echo "Stopping Node... $VAR_DIR"
	if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; if [ -f "/var/lib/$VAR_DIR/docker-compose.yml" ]; then docker-compose down >/dev/null 2>&1; fi; fi

	echo ""
	echo "Check Directory... /var/lib/$VAR_DIR"

	if [ ! -d /var/lib/$VAR_DIR ]; then mkdir /var/lib/$VAR_DIR || exit; fi
	cd /var/lib/$VAR_DIR || exit

	echo ""
	echo "CleanUp Directory... /var/lib/$VAR_DIR"

	find . -maxdepth 1 -mindepth 1 ! \( -name ".env" -o -name "data" \) -exec rm -rf {} +

	echo ""
	echo "Download Package... install.tar.gz"
	wget -cO - "$ShimmerHornetPackage" -q > install.tar.gz

	if [ "$(shasum -a 256 './install.tar.gz' | cut -d ' ' -f 1)" = "$ShimmerHornetHash" ]; then
		echo "$gn"; echo 'Checking Hash of Package successful...'; echo "$xx"
	else
		echo "$rd"; echo 'Checking Hash of Package failed...'
		echo 'Package has been tampered, Installation aborted for your Security!'
		echo "Downloaded Package is deleted!"
		rm -r install.tar.gz
		echo "$xx"; exit;
	fi

	if [ -f docker-compose.yml ]; then rm docker-compose.yml; fi

	echo "Unpack Package... install.tar.gz"
	tar -xzf install.tar.gz

	echo "Delete Package... install.tar.gz"
	rm -r install.tar.gz

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"

	CheckConfiguration

	if [ $VAR_CONF_RESET = 1 ]; then

		clear
		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                               Set Parameters                                ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		echo "Set the domain name (example: $ca""vrom.dlt.builders""$xx):"
		read -r -p '> ' VAR_HOST
		CheckDomain "$VAR_HOST"

		echo ''
		echo "Set the dashboard port (example: $ca""443""$xx):"
		read -r -p '> ' VAR_SHIMMER_HORNET_HTTPS_PORT
		echo ''
		echo "Set the pruning size / max. database size (example: $ca""200GB""$xx):"
		echo "$rd""Available Diskspace: $(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 4)B/$(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 2)B ($(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 5) used) ""$xx"
		read -r -p '> ' VAR_SHIMMER_HORNET_PRUNING_SIZE
		echo ''
		echo "Set PoW / proof of work (example: $ca""false""$xx): "
		read -r -p '> ' VAR_SHIMMER_HORNET_POW
		echo ''
		echo "Set the dashboard username (example: $ca""vrom""$xx):"
		read -r -p '> ' VAR_USERNAME
		echo ''
		echo "Set the dashboard password:"
		echo "(information: $ca""will be saved as hash / don't leave it empty""$xx):"
		read -r -p '> ' VAR_PASSWORD
		echo ''

		CheckCertificate

		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                              Write Parameters                               ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; fi
		if [ -f .env ]; then rm .env; fi

		echo "HORNET_VERSION=$VAR_SHIMMER_HORNET_VERSION" >> .env

		echo "HORNET_NETWORK=mainnet" >> .env

		echo "HORNET_HOST=$VAR_HOST" >> .env
		echo "HORNET_PRUNING_TARGET_SIZE=$VAR_SHIMMER_HORNET_PRUNING_SIZE" >> .env
		echo "HORNET_POW_ENABLED=$VAR_SHIMMER_HORNET_POW" >> .env
		echo "HORNET_HTTPS_PORT=$VAR_SHIMMER_HORNET_HTTPS_PORT" >> .env
		echo "HORNET_GOSSIP_PORT=15600" >> .env
		echo "HORNET_AUTOPEERING_PORT=14626" >> .env

		if [ $VAR_CERT = 0 ]
		then
			echo "HORNET_HTTP_PORT=80" >> .env
				read -r -p 'Set mail for certificat renewal (e.g. info@dlt.green): ' VAR_ACME_EMAIL
			echo "ACME_EMAIL=$VAR_ACME_EMAIL" >> .env
		else
			echo "HORNET_HTTP_PORT=8081" >> .env
			echo "SSL_CONFIG=certs" >> .env
			echo "HORNET_SSL_CERT=/etc/letsencrypt/live/$VAR_HOST/fullchain.pem" >> .env
			echo "HORNET_SSL_KEY=/etc/letsencrypt/live/$VAR_HOST/privkey.pem" >> .env
		fi

		echo "INX_INDEXER_VERSION=$VAR_INX_INDEXER_VERSION" >> .env
		echo "INX_MQTT_VERSION=$VAR_INX_MQTT_VERSION" >> .env
		echo "INX_PARTICIPATION_VERSION=$VAR_INX_PARTICIPATION_VERSION" >> .env
		echo "INX_SPAMMER_VERSION=$VAR_INX_SPAMMER_VERSION" >> .env
		echo "INX_POI_VERSION=$VAR_INX_POI_VERSION" >> .env
		echo "INX_DASHBOARD_VERSION=$VAR_INX_DASHBOARD_VERSION" >> .env

	else
		if [ -f .env ]; then sed -i "s/HORNET_VERSION=.*/HORNET_VERSION=$VAR_SHIMMER_HORNET_VERSION/g" .env; fi
		if [ -f .env ]; then sed -i "s/INX_INDEXER_VERSION=.*/INX_INDEXER_VERSION=$VAR_INX_MQTT_VERSION/g" .env; fi
		if [ -f .env ]; then sed -i "s/INX_MQTT_VERSION=.*/INX_MQTT_VERSION=$VAR_INX_MQTT_VERSION/g" .env; fi
		if [ -f .env ]; then sed -i "s/INX_PARTICIPATION_VERSION=.*/INX_PARTICIPATION_VERSION=$VAR_INX_PARTICIPATION_VERSION/g" .env; fi
		if [ -f .env ]; then sed -i "s/INX_SPAMMER_VERSION=.*/INX_SPAMMER_VERSION=$VAR_INX_SPAMMER_VERSION/g" .env; fi
		if [ -f .env ]; then sed -i "s/INX_POI_VERSION=.*/INX_POI_VERSION=$VAR_INX_POI_VERSION/g" .env; fi
		if [ -f .env ]; then sed -i "s/INX_DASHBOARD_VERSION=.*/INX_DASHBOARD_VERSION=$VAR_INX_DASHBOARD_VERSION/g" .env; fi

		VAR_HOST=$(cat .env | grep _HOST | cut -d '=' -f 2)
	fi

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"

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
	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"

	if [ -s "/var/lib/$VAR_DIR/data/letsencrypt/acme.json" ]; then SetCertificateGlobal; fi

	clear
	echo ""

	if [ $VAR_CONF_RESET = 1 ]; then

		echo "--------------------------- INSTALLATION IS FINISH ----------------------------"
		echo ""
		echo "═══════════════════════════════════════════════════════════════════════════════"
		echo " SHIMMER-Hornet Dashboard: https://$VAR_HOST:$VAR_SHIMMER_HORNET_HTTPS_PORT/dashboard"
		echo " SHIMMER-Hornet Dashboard Username: $VAR_USERNAME"
		echo " SHIMMER-Hornet Dashboard Password: <set during install>"
		echo " SHIMMER-Hornet API: https://$VAR_HOST:$VAR_SHIMMER_HORNET_HTTPS_PORT/api/core/v2/info"
		echo " Grafana Dashboard: https://$VAR_HOST/grafana"
		echo " Grafana Username: admin"
		echo " Grafana Password: <same as hornet password>"
		echo "═══════════════════════════════════════════════════════════════════════════════"
		echo ""
	else
	    echo "------------------------------ UPDATE IS FINISH - -----------------------------"
	fi
	echo ""

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"

	SubMenuMaintenance
}

ShimmerWasp() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║          DLT.GREEN AUTOMATIC SHIMMER-WASP INSTALLATION WITH DOCKER          ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""
	echo "$ca""Wasp is like a INX-Plugin and can only installed on the same Server as Shimmer!""$xx";
	CheckIota
	if [ "$VAR_NETWORK" = 1 ]; then echo "$rd""It's not supported (Security!) to install Nodes from Network"; echo "Shimmer and IOTA on the same Server, deinstall IOTA Nodes first!""$xx"; fi

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"
	if [ "$VAR_NETWORK" = 1 ]; then VAR_NETWORK=2; SubMenuMaintenance; fi

	echo "Stopping Node... $VAR_DIR"
	if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; if [ -f "/var/lib/$VAR_DIR/docker-compose.yml" ]; then docker-compose down >/dev/null 2>&1; fi; fi

	echo ""
	echo "Check Directory... /var/lib/$VAR_DIR"

	if [ ! -d /var/lib/$VAR_DIR ]; then mkdir /var/lib/$VAR_DIR || exit; fi
	cd /var/lib/$VAR_DIR || exit

	echo ""
	echo "CleanUp Directory... /var/lib/$VAR_DIR"

	find . -maxdepth 1 -mindepth 1 ! \( -name ".env" -o -name "data" \) -exec rm -rf {} +

	echo ""
	echo "Download Package... install.tar.gz"
	wget -cO - "$ShimmerWaspPackage" -q > install.tar.gz

	if [ "$(shasum -a 256 './install.tar.gz' | cut -d ' ' -f 1)" = "$ShimmerWaspHash" ]; then
		echo "$gn"; echo 'Checking Hash of Package successful...'; echo "$xx"
	else
		echo "$rd"; echo 'Checking Hash of Package failed...'
		echo 'Package has been tampered, Installation aborted for your Security!'
		echo "Downloaded Package is deleted!"
		rm -r install.tar.gz
		echo "$xx"; exit;
	fi

	if [ -f docker-compose.yml ]; then rm docker-compose.yml; fi

	echo "Unpack Package... install.tar.gz"
	tar -xzf install.tar.gz

	echo "Delete Package... install.tar.gz"
	rm -r install.tar.gz

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"

	CheckConfiguration

	VAR_WASP_LEDGER_NETWORK='shimmer'

	if [ $VAR_CONF_RESET = 1 ]; then

		clear
		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                               Set Parameters                                ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		echo "Set the domain name (example: $ca""vrom.dlt.builders""$xx):"
		read -r -p '> ' VAR_HOST
		CheckDomain "$VAR_HOST"

		echo ''
		echo "Set the dashboard port (example: $ca""447""$xx):"
		read -r -p '> ' VAR_SHIMMER_WASP_HTTPS_PORT
		echo ''
		echo "Set the api port (example: $ca""448""$xx):"
		read -r -p '> ' VAR_SHIMMER_WASP_API_PORT
		echo ''
		echo "Set the peering port (example: $ca""4000""$xx):"
		read -r -p '> ' VAR_SHIMMER_WASP_PEERING_PORT
		echo ''
		echo "Set the nano-msg-port (example: $ca""5550""$xx):"
		read -r -p '> ' VAR_SHIMMER_WASP_NANO_MSG_PORT
		echo ''
		echo "Set the dashboard username (example: $ca""vrom""$xx):"
		read -r -p '> ' VAR_USERNAME
		echo ''
		echo "Set the dashboard password:"
		echo "(information: $ca""will be saved as text / don't leave it empty""$xx):"
		read -r -p '> ' VAR_PASSWORD
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
		echo "WASP_LEDGER_NETWORK=$VAR_WASP_LEDGER_NETWORK" >> .env

		if [ $VAR_CERT = 0 ]
		then
			echo "WASP_HTTP_PORT=80" >> .env
				read -r -p 'Set mail for certificat renewal (e.g. info@dlt.green): ' VAR_ACME_EMAIL
			echo "ACME_EMAIL=$VAR_ACME_EMAIL" >> .env
		else
			echo "WASP_HTTP_PORT=8087" >> .env
			echo "SSL_CONFIG=certs" >> .env
			echo "WASP_SSL_CERT=/etc/letsencrypt/live/$VAR_HOST/fullchain.pem" >> .env
			echo "WASP_SSL_KEY=/etc/letsencrypt/live/$VAR_HOST/privkey.pem" >> .env
		fi
	else
		if [ -f .env ]; then sed -i "s/WASP_VERSION=.*/WASP_VERSION=$VAR_SHIMMER_WASP_VERSION/g" .env; fi
		VAR_HOST=$(cat .env | grep _HOST | cut -d '=' -f 2)
	fi

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"

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
	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"

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

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"

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
	docker container rename shimmer-hornet_grafana_1 grafana >/dev/null 2>&1
	docker container rename shimmer-hornet_prometheus_1 prometheus >/dev/null 2>&1
}

clear
echo ""
echo "╔═════════════════════════════════════════════════════════════════════════════╗"
echo "║ DLT.GREEN           AUTOMATIC NODE-INSTALLER WITH DOCKER            v.$VRSN ║"
echo "║                                                                             ║"
echo "║$lg      ____    _      _____         ____   ____    _____   _____   _   _      $xx║"
echo "║$lg     |  _ \  | |    |_   _|       / ___| |  _ \  | ____| | ____| | \ | |     $xx║"
echo "║$lg     | | | | | |      | |        | |  _  | |_) | |  _|   |  _|   |  \| |     $xx║"
echo "║$lg     | |_| | | |___   | |    _   | |_| | |  _ <  | |___  | |___  | |\  |     $xx║"
echo "║$lg     |____/  |_____|  |_|   (_)   \____| |_| \_\ |_____| |_____| |_| \_|     $xx║"
echo "║                                                                             ║"
echo "║                                                                             ║"
echo "║                         for IOTA and SHIMMER Nodes                          ║"
echo "║                                                                             ║"
echo "║                                 loading...                                  ║"
echo "║                                                                             ║"
echo "║         Github: https://github.com/dlt-green/node-installer-docker          ║"
echo "║                                                                             ║"
echo "║                       GNU General Public License v3.0                       ║"
echo "╚═════════════════════════════════════════════════════════════════════════════╝"
echo ""
echo "> $gn""Checking Hash of Installer successful...""$xx"
echo "> $gn""$InstallerHash""$xx"

sleep 3

sudo apt-get install curl jq expect dnsutils ufw -y -qq >/dev/null 2>&1

CheckFirewall

docker --version | grep "Docker version" >/dev/null 2>&1
if [ $? -eq 0 ]
	then
        Dashboard
	else
        MainMenu
fi