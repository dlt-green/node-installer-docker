#!/bin/bash

VRSN="v.2.0.0"
BUILD="20230213_205457"

VAR_DOMAIN=''
VAR_HOST=''
VAR_DIR=''
VAR_CERT=0
VAR_NETWORK=0
VAR_NODE=0
VAR_CONF_RESET=0

VAR_IOTA_HORNET_VERSION='1.2.3'
VAR_IOTA_GOSHIMMER_VERSION='0.9.8'
VAR_IOTA_WASP_VERSION='0.2.5'
VAR_SHIMMER_HORNET_VERSION='2.0.0-rc.4'
VAR_SHIMMER_WASP_VERSION='0.4.0-alpha.8'
VAR_SHIMMER_WASP_CLI_VERSION='0.4.0-alpha.5'

VAR_INX_INDEXER_VERSION='1.0-rc'
VAR_INX_MQTT_VERSION='1.0-rc'
VAR_INX_PARTICIPATION_VERSION='1.0-rc'
VAR_INX_SPAMMER_VERSION='1.0-rc'
VAR_INX_POI_VERSION='1.0-rc'
VAR_INX_DASHBOARD_VERSION='1.0-rc'

VAR_PIPE_VERSION='0.5'

lg='\033[1m'
or='\e[1;33m'
ca='\e[1;96m'
rd='\e[1;91m'
gn='\e[1;92m'
gr='\e[1;90m'
fl='\033[1m'

xx='\033[0m'

echo "$xx"

InstallerHash=$(curl -L https://github.com/dlt-green/node-installer-docker/releases/download/$VRSN/checksum.txt)

IotaHornetHash='e5526a19099330ce59a6e014fd97e883d9d5ae5159d46e33b7a64e57cc02321d'
IotaHornetPackage="https://github.com/dlt-green/node-installer-docker/releases/download/$VRSN/iota-hornet.tar.gz"

IotaGoshimmerHash='a188fb1d15f7340605cf93b4d69a0d626193cc7b68e1774679a967f75cccee1a'
IotaGoshimmerPackage="https://github.com/dlt-green/node-installer-docker/releases/download/$VRSN/iota-goshimmer.tar.gz"

IotaWaspHash='577a5ffe6010f6f06687f6b4ddf7c5c47280da142a1f4381567536e4422e6283'
IotaWaspPackage="https://github.com/dlt-green/node-installer-docker/releases/download/$VRSN/iota-wasp.tar.gz"

ShimmerHornetHash='6bf292f0c1a0e1c30289c033790d6b63be86ab75457e549dc531951ecbc25ebc'
ShimmerHornetPackage="https://github.com/dlt-green/node-installer-docker/releases/download/$VRSN/shimmer-hornet.tar.gz"

ShimmerWaspHash='035f7c554e2c4db85a22bc15ac31ed71d9605b3d6407caeca7553fa50071b005'
ShimmerWaspPackage="https://github.com/dlt-green/node-installer-docker/releases/download/$VRSN/shimmer-wasp.tar.gz"

PipeHash='1f2f352594cd3b27e661164efc39f5bed133f7548b60bc2eb6780adb91700e1b'
PipePackage="https://github.com/dlt-green/node-installer-docker/releases/download/$VRSN/pipe.tar.gz"

SnapshotIotaGoshimmer="https://dbfiles-goshimmer.s3.eu-central-1.amazonaws.com/snapshots/nectar/snapshot-latest.bin"
SnapshotShimmerHornet="https://github.com/iotaledger/global-snapshots/raw/main/shimmer/genesis_snapshot.bin"

if [ "$VRSN" = 'dev-latest' ]; then VRSN=$BUILD; fi

clear
if [ -f "node-installer.sh" ]; then 

	fgrep -q "alias dlt.green=" ~/.bash_aliases >/dev/null 2>&1 || (echo "" >> ~/.bash_aliases && echo "# DLT.GREEN Node-Installer-Docker" >> ~/.bash_aliases && echo "alias dlt.green=" >> ~/.bash_aliases)
	if [ -f ~/.bash_aliases ]; then sed -i 's/alias dlt.green=.*/alias dlt.green="sudo wget https:\/\/github.com\/dlt-green\/node-installer-docker\/releases\/latest\/download\/node-installer.sh \&\& sudo sh node-installer.sh"/g' ~/.bash_aliases; fi

	if [ "$(shasum -a 256 './node-installer.sh' | cut -d ' ' -f 1)" != "$InstallerHash" ]; then
		echo "$rd"; echo 'Checking Hash of Installer failed...'
		echo 'Installer may have been corrupted or tampered during downloading!'
		echo "Installation aborted for your Security, downloaded Installer has been deleted!"
		sudo rm node-installer.sh -f
		echo "$xx"; exit;
	fi
	sudo rm node-installer.sh -f
fi

if [ "$(id -u)" -ne 0 ]; then echo "$rd" && echo 'Please run DLT.GREEN Automatic Node-Installer with sudo or as root' && echo "$xx"; exit; fi

CheckIota() {
	if [ -s "/var/lib/iota-hornet/.env" ];    then VAR_NETWORK=1; fi
	if [ -s "/var/lib/iota-goshimmer/.env" ]; then VAR_NETWORK=1; fi
	if [ -s "/var/lib/iota-wasp/.env" ];      then VAR_NETWORK=1; fi
}

CheckShimmer() {
	if [ -s "/var/lib/shimmer-hornet/.env" ]; then VAR_NETWORK=2; fi
	if [ -s "/var/lib/shimmer-wasp/.env" ];   then VAR_NETWORK=2; fi
}

CheckFirewall() {
	if [ $(LC_ALL=en_GB.UTF-8 LC_LANG=en_GB.UTF-8 ufw status | grep 'Status:' | cut -d ' ' -f 2) != 'active' ]
	then
		clear
		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║ DLT.GREEN           AUTOMATIC NODE-INSTALLER WITH DOCKER $VAR_VRN ║"
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

			 echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"
			 echo ufw allow "$VAR_SSH_PORT/tcp" && ufw allow "$VAR_SSH_PORT/tcp"
			 sudo ufw enable
			 echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"
			 ;;
		esac
	fi
}

CheckDomain() {
	if [ "$(dig +short "$1")" != "$(curl -s 'https://ipinfo.io/ip')" ]
	then
		echo ""
	    echo "$rd""Attention! Verification of your Domain $VAR_HOST failed! Installation aborted!""$xx"
	    echo "$rd""Maybe you entered a wrong Domain or the DNS is not reachable yet?""$xx"
	    echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"
		SubMenuMaintenance
	else
	    echo "$gn""Verification of your Domain $VAR_HOST successful""$xx"
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
		echo "║ DLT.GREEN           AUTOMATIC NODE-INSTALLER WITH DOCKER $VAR_VRN ║"
		echo "║""$ca""$VAR_DOMAIN""$xx""║"
		echo "║                                                                             ║"
		echo "║                            1. Use global Certificate                        ║"
		echo "║                            X. Generate new Let's Encrypt Certificate        ║"
		echo "║                                                                             ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""
		echo "$rd""Attention! For one Node on your Server (Master-Node, e.g. HORNET)"
		echo "you must use (X) for getting a Let's Encrypt Certificate,"
		echo "for all additional installed Nodes use (1) global Certificate,"
		echo "then the Node will use the Certificate from the Master-Node""$xx"
		echo ""
		echo "select menu item: "
		echo ""
		read -r -p '> ' n
		case $n in
		1) VAR_CERT=1
		   rm -rf /var/lib/"$VAR_DIR"/data/letsencrypt/* ;;
		*) echo "No global Let's Encrypt Certificate found, generate a new one... "
		   VAR_CERT=0
		   rm -rf /var/lib/"$VAR_DIR"/data/letsencrypt/* ;;
		esac
	else
		echo "No global Let's Encrypt Certificate found, generate a new one... "
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
		echo "║ DLT.GREEN           AUTOMATIC NODE-INSTALLER WITH DOCKER $VAR_VRN ║"
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

CheckNodeHealthy() {
	VAR_NodeHealthy=false
	case $VAR_NODE in
	1) VAR_API="api/v1/info"; OBJ=".data.isHealthy" ;;
	2) VAR_API="info"; OBJ=".Version" ;;
	3) VAR_API="info"; OBJ=".tangleTime.synced" ;;
	5) VAR_API="api/core/v2/info"; OBJ=".status.isHealthy" ;;
	6) VAR_API="info"; OBJ=".Version" ;;
	*) ;;
	esac
	VAR_NodeHealthy=$(curl https://${VAR_DOMAIN}:${VAR_PORT}/${VAR_API} --http1.1 -m 3 -s -X GET -H 'Content-Type: application/json' | jq ${OBJ} 2>/dev/null)
	if [ -z $VAR_NodeHealthy ]; then VAR_NodeHealthy=false; fi
}

CheckEvents() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║ DLT.GREEN           AUTOMATIC NODE-INSTALLER WITH DOCKER $VAR_VRN ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo "$ca"
	echo "Verify Event Results..."
	echo "$xx"
		
	VAR_DIR='iota-hornet'
	
	cd /var/lib/$VAR_DIR >/dev/null 2>&1 || Dashboard;
	
	VAR_RESTAPI_SALT=$(cat .env 2>/dev/null | grep RESTAPI_SALT | cut -d '=' -f 2);
	if [ -z $VAR_RESTAPI_SALT ]; then echo "$rd""IOTA-Hornet: No Salt found!""$xx"
	else
	   echo "Event IDs can be found at 'https://github.com/iotaledger/participation-events'"
	   echo "Event Data will be saved locally under '/var/lib/{network-node}/verify-events'"	   
	   echo ''
	   echo "Set the Event ID for verifying ($ca""keep empty to verify all Events of your Node""$xx):"
	   read -r -p '> ' EVENTS
	   echo ''
	   
	   ADDR=$(cat .env 2>/dev/null | grep HORNET_HOST | cut -d '=' -f 2)':'$(cat .env 2>/dev/null | grep HORNET_HTTPS_PORT | cut -d '=' -f 2)
	   TOKEN=$(docker compose run --rm hornet tool jwt-api --salt $VAR_RESTAPI_SALT | awk '{ print $5 }')
	   echo "$ca""Address: ""$xx"$ADDR" ($ca""JWT-Token for API Access randomly generated""$xx)"
	   echo ''
	   sleep 5

	   if [ -z $EVENTS ]; then 
	   EVENTS=$(curl https://${ADDR}/api/plugins/participation/events --http1.1 -s -X GET -H 'Content-Type: application/json' \
	      -H "Authorization: Bearer ${TOKEN}" | jq -r '.data.eventIds'); fi

	   for EVENT_ID in $(echo $EVENTS  | tr -d '"[] ' | sed 's/,/ /g'); do
	      echo "───────────────────────────────────────────────────────────────────────────────"
	      EVENT_NAME=$(curl https://${ADDR}/api/plugins/participation/events/${EVENT_ID} --http1.1 -s -X GET -H 'Content-Type: application/json' \
	      -H "Authorization: Bearer ${TOKEN}" | jq -r '.data.name')

	      EVENT_SYMBOL=$(curl https://${ADDR}/api/plugins/participation/events/${EVENT_ID} --http1.1 -s -X GET -H 'Content-Type: application/json' \
	      -H "Authorization: Bearer ${TOKEN}" | jq -r '.data.payload.symbol')

	      EVENT_STATUS=$(curl https://${ADDR}/api/plugins/participation/events/${EVENT_ID}/status --http1.1 -s -X GET -H 'Content-Type: application/json' \
	      -H "Authorization: Bearer ${TOKEN}" | jq -r '.data.status')

	      EVENT_CHECKSUM=$(curl https://${ADDR}/api/plugins/participation/events/${EVENT_ID}/status --http1.1 -s -X GET -H 'Content-Type: application/json' \
	      -H "Authorization: Bearer ${TOKEN}" | jq -r '.data.checksum')

	      EVENT_MILESTONE=$(curl https://${ADDR}/api/plugins/participation/events/${EVENT_ID}/status --http1.1 -s -X GET -H 'Content-Type: application/json' \
	      -H "Authorization: Bearer ${TOKEN}" | jq -r '.data.milestoneIndex')

	      EVENT_QUESTIONS=$(curl https://${ADDR}/api/plugins/participation/events/${EVENT_ID}/status --http1.1 -s -X GET -H 'Content-Type: application/json' \
	      -H "Authorization: Bearer ${TOKEN}" | jq -r '.data.questions')

	      echo "$ca""Name: ""$xx"$EVENT_NAME"$ca"" Symbol: ""$xx"$EVENT_SYMBOL"$ca"" Status: ""$xx"$EVENT_STATUS

	      if [ $EVENT_STATUS = "ended" ]; then
	        if [ ! -d /var/lib/$VAR_DIR/verify-events ]; then mkdir /var/lib/$VAR_DIR/verify-events || Dashboard; fi
	        cd /var/lib/$VAR_DIR/verify-events || Dashboard
	        $(curl https://${ADDR}/api/plugins/participation/admin/events/${EVENT_ID}/rewards --http1.1 -s -X GET -H 'Content-Type: application/json' \
	        -H "Authorization: Bearer ${TOKEN}" | jq '.data' > ${EVENT_ID})
	        echo ""
	        echo "$xx""Event ID: ""$EVENT_ID"
	        
	        if [ $(jq '.totalRewards' ${EVENT_ID}) = 'null' ]; then
			  if [ $EVENT_SYMBOL = 'null' ]; then
			    echo "$gn""Checksum: ""$EVENT_CHECKSUM"
			  else
			    echo "$rd""Checksum: ""Authentication Error!""$xx"
			  fi
	        else
	          echo "$gn""Checksum: ""$(jq -r '.checksum' ${EVENT_ID})"
	        fi
	        EVENT_REWARDS="$(jq '.totalRewards' ${EVENT_ID})"
	      else
	        echo ""
	        echo "$xx""Event ID: ""$EVENT_ID"
	        echo "$rd""Checksum: ""Event not found or not over yet!""$xx"
	        EVENT_REWARDS='not available'
	      fi
	      echo ""
	      echo "$ca""Milestone index: ""$xx"$EVENT_MILESTONE"$ca"" Total rewards: ""$xx"$EVENT_REWARDS
	      echo "───────────────────────────────────────────────────────────────────────────────"
	   done
	fi
	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"
	Dashboard
}

SetCertificateGlobal() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║ DLT.GREEN           AUTOMATIC NODE-INSTALLER WITH DOCKER $VAR_VRN ║"
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
	   echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"
	   ;;
	X) ;;
	esac
}

Dashboard() {

	VAR_DOMAIN=''
	
	VAR_NODE=1; VAR_NodeHealthy=false; VAR_PORT="9999"
	if [ -f "/var/lib/iota-hornet/.env" ]; then
	  VAR_DOMAIN=$(cat /var/lib/iota-hornet/.env | grep _HOST | cut -d '=' -f 2)
	  VAR_PORT=$(cat "/var/lib/iota-hornet/.env" | grep HTTPS_PORT | cut -d '=' -f 2)
	  if [ -z $VAR_PORT ]; then VAR_PORT="9999"; fi; CheckNodeHealthy
	fi
	if $VAR_NodeHealthy; then ih=$gn; elif [ -d /var/lib/iota-hornet ]; then ih=$rd; else ih=$gr; fi

	VAR_NODE=2; VAR_NodeHealthy=false; VAR_PORT="9999"
	if [ -f "/var/lib/iota-wasp/.env" ]; then
	  VAR_DOMAIN=$(cat /var/lib/iota-wasp/.env | grep _HOST | cut -d '=' -f 2)
	  VAR_PORT=$(cat "/var/lib/iota-wasp/.env" | grep API_PORT | cut -d '=' -f 2)
	  if [ -z $VAR_PORT ]; then VAR_PORT="9999"; fi; CheckNodeHealthy
	fi
	if ! [ "$VAR_NodeHealthy" = "false" ]; then iw=$gn; elif [ -d /var/lib/iota-wasp ]; then iw=$rd; else iw=$gr; fi	

	VAR_NODE=3; VAR_NodeHealthy=false; VAR_PORT="9999"
	if [ -f "/var/lib/iota-goshimmer/.env" ]; then
	  VAR_DOMAIN=$(cat /var/lib/iota-goshimmer/.env | grep _HOST | cut -d '=' -f 2)
	  VAR_PORT=$(cat "/var/lib/iota-goshimmer/.env" | grep HTTPS_PORT | cut -d '=' -f 2)
	  if [ -z $VAR_PORT ]; then VAR_PORT="9999"; fi; CheckNodeHealthy
	fi
	if $VAR_NodeHealthy; then ig=$gn; elif [ -d /var/lib/iota-goshimmer ]; then ig=$rd; else ig=$gr; fi	

	VAR_NODE=5; VAR_NodeHealthy=false; VAR_PORT="9999"
	if [ -f "/var/lib/shimmer-hornet/.env" ]; then
	  VAR_DOMAIN=$(cat /var/lib/shimmer-hornet/.env | grep _HOST | cut -d '=' -f 2)
	  VAR_PORT=$(cat "/var/lib/shimmer-hornet/.env" | grep HTTPS_PORT | cut -d '=' -f 2)
	  VAR_HORNET_NETWORK=$(cat "/var/lib/shimmer-hornet/.env" | grep HORNET_NETWORK | cut -d '=' -f 2)
	  if [ -z $VAR_PORT ]; then VAR_PORT="9999"; fi; CheckNodeHealthy
	else
	  VAR_HORNET_NETWORK='mainnet'
	fi
	if $VAR_NodeHealthy; then sh=$gn; elif [ -d /var/lib/shimmer-hornet ]; then sh=$rd; else sh=$gr; fi	

	VAR_NODE=6; VAR_NodeHealthy=false; VAR_PORT="9999"
	if [ -f "/var/lib/shimmer-wasp/.env" ]; then
	  VAR_DOMAIN=$(cat /var/lib/shimmer-wasp/.env | grep _HOST | cut -d '=' -f 2)
	  VAR_PORT=$(cat "/var/lib/shimmer-wasp/.env" | grep API_PORT | cut -d '=' -f 2)
	  if [ -z $VAR_PORT ]; then VAR_PORT="9999"; fi; CheckNodeHealthy
	fi
	
	if ! [ "$VAR_NodeHealthy" = "false" ]; then sw=$gn; elif [ -d /var/lib/shimmer-wasp ]; then sw=$rd; else sw=$gr; fi

	VAR_NODE=7; if [ -f "/var/lib/shimmer-wasp/data/config/wasp-cli.json" ]; then wc=$gn; elif [ -d /var/lib/shimmer-wasp ]; then wc=$or; else wc=$gr; fi

	if [ "$(docker container inspect -f '{{.State.Status}}' 'pipe' 2>/dev/null)" = 'running' ]; then tg=$gn; elif [ -d /var/lib/pipe ]; then tg=$rd; else tg=$gr; fi

	VAR_NODE=0

	PositionCenter "$VAR_DOMAIN"
	VAR_DOMAIN=$text

	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║ DLT.GREEN           AUTOMATIC NODE-INSTALLER WITH DOCKER $VAR_VRN ║"
	echo "║""$ca""$VAR_DOMAIN""$xx""║"
	echo "║                                                                             ║"
	echo "║           ┌── IOTA Mainnet ──┐           IOTA Research        Tanglehub     ║"
	echo "║ ┌─┬────────────────┬─┬────────────────┬─┬──────────────┐ ┌─┬──────────────┐ ║"
	echo "║ │1│     ""$ih""HORNET""$xx""     │2│      ""$iw""WASP""$xx""      │3│  ""$ig""GOSHIMMER""$xx""   │ │4│     ""$tg""PIPE""$xx""     │ ║"
	echo "║ └─┴────────────────┴─┴────────────────┴─┴──────────────┘ └─┴──────────────┘ ║"
	echo "║                                                                             ║"
	echo "║           ┌───────── Shimmer ┬ ""$(echo "$VAR_HORNET_NETWORK" | sed 's/.*/\u&/')"" ────────┐                            ║"
	echo "║ ┌─┬────────────────┬─┬────────────────┬─┬──────────────┐ ┌─┬──────────────┐ ║"
	echo "║ │5│     ""$sh""HORNET""$xx""     │6│      ""$sw""WASP""$xx""      │7│   ""$wc""WASP-CLI""$xx""   │ │8│      -       │ ║"
	echo "║ └─┴────────────────┴─┴────────────────┴─┴──────────────┘ └─┴──────────────┘ ║"
	echo "║                                                                             ║"
	echo "║    Node-Status:  ""$gn""running | healthy""$xx"" / ""$rd""stopped | unhealthy""$xx"" / ""$gr""not installed""$xx""    ║"
	echo "║                                                                             ║"
	echo "║   [E] Events  [R] Refresh  [S] Start all Nodes  [M] Maintenance  [Q] Quit   ║"
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
	   if [ -d /var/lib/iota-hornet ]; then cd /var/lib/iota-hornet || Dashboard; docker compose up -d; fi
	   if [ -d /var/lib/iota-goshimmer ]; then cd /var/lib/iota-goshimmer || Dashboard; docker compose up -d; fi
	   if [ -d /var/lib/shimmer-hornet ]; then cd /var/lib/shimmer-hornet || Dashboard; docker compose up -d; fi
	   sleep 5
	   if [ -d /var/lib/iota-wasp ]; then cd /var/lib/iota-wasp || Dashboard; docker compose up -d; fi
	   if [ -d /var/lib/shimmer-wasp ]; then cd /var/lib/shimmer-wasp || Dashboard; docker compose up -d; fi
	   sleep 2
	   if [ -d /var/lib/pipe ]; then cd /var/lib/pipe || Dashboard; docker compose up -d; fi
	   RenameContainer
	   echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"
	   DashboardHelper ;;

	1) VAR_NETWORK=1; VAR_NODE=1; VAR_DIR='iota-hornet'
	   SubMenuMaintenance ;;
	2) VAR_NETWORK=1; VAR_NODE=2; VAR_DIR='iota-wasp'
	   SubMenuMaintenance ;;
	3) VAR_NETWORK=1; VAR_NODE=3; VAR_DIR='iota-goshimmer'
	   SubMenuMaintenance ;;
	4) VAR_NETWORK=3; VAR_NODE=4; VAR_DIR='pipe'
	   SubMenuMaintenance ;;
	5) VAR_NETWORK=2; VAR_NODE=5; VAR_DIR='shimmer-hornet'
	   SubMenuMaintenance ;;
	6) VAR_NETWORK=2; VAR_NODE=6; VAR_DIR='shimmer-wasp'
	   SubMenuMaintenance ;;
	7) VAR_NETWORK=2; VAR_NODE=7; VAR_DIR='shimmer-wasp'
	   clear
	   echo "$ca"
	   echo 'Please wait, checking for Updates...'
	   echo "$xx"
	   if [ -s "/var/lib/shimmer-wasp/wasp-cli-wrapper.sh" ]; then echo "$ca""Network/Node: $VAR_DIR | $(/var/lib/shimmer-wasp/wasp-cli-wrapper.sh -v)""$xx"; else echo "$ca""Network/Node: $VAR_DIR | wasp-cli not installed""$xx"; fi 
	   SubMenuWaspCLI ;;
	8) clear
	   VAR_NETWORK=0; VAR_NODE=0; VAR_DIR=''
	   DashboardHelper ;;
	e|E) clear
	   VAR_NETWORK=0; VAR_NODE=0; VAR_DIR=''
	   CheckEvents ;;
	r|R) clear
	   VAR_NETWORK=0; VAR_NODE=0; VAR_DIR=''
	   DashboardHelper ;;
	q|Q) clear; exit ;;
	*) MainMenu ;;
	esac
}

PositionVersion() {
	text=''
	window_width=78
	text_left_width=57
	text_right_width=2
	version_with=$(echo "$1" | wc -c)
	window_left=$(($window_width - $text_left_width - $text_right_width - $version_with))
	text=$(printf "%*s%s" $window_left)"$1"
}

PositionCenter() {
	text=''
	window_width=78
	text_with=$(echo "$1" | wc -c)
	window_left=$(($window_width / 2 - $text_with / 2))
	window_right=$(($window_width - $text_with - $window_left))
	text=$(printf "%*s%s" $window_left)"$1"$(printf "%*s%s" $window_right)
}

DashboardHelper() {
Dashboard
}

MainMenu() {

	if [ -z "$VAR_DOMAIN" ]; then PositionCenter ''; VAR_DOMAIN=$text; fi

	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║ DLT.GREEN           AUTOMATIC NODE-INSTALLER WITH DOCKER $VAR_VRN ║"
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
	0) clear
	   echo "$ca"
	   echo "Set Alias 'dlt.green-dev' for Pre-Release 'dev-latest':"
	   echo "$xx"

	   if [ -f ~/.bash_aliases ]; then
	     headerLine=$(awk '/# DLT.GREEN Node-Installer-Docker/{ print NR; exit }' ~/.bash_aliases)
	     insertLine=$(awk '/dlt.green-dev=/{ print NR; exit }' ~/.bash_aliases)
	     if [ -z "$insertLine" ]; then
	         if [ ! -z "$headerLine" ]; then
	           insertLine=$(($headerLine))
	         sed -i "$insertLine a alias dlt.green-dev=\"sudo wget https:\/\/github.com\/dlt-green\/node-installer-docker\/releases\/download\/dev-latest\/node-installer.sh \&\& sudo sh node-installer.sh\"" ~/.bash_aliases
	         echo "$gn""Alias set!""$xx"
	       else
	         echo "$rd""Error setting Alias!""$xx"
	       fi
	     else
	       sed -i 's/alias dlt.green-dev=.*/alias dlt.green-dev="sudo wget https:\/\/github.com\/dlt-green\/node-installer-docker\/releases\/download\/dev-latest\/node-installer.sh \&\& sudo sh node-installer.sh"/g' ~/.bash_aliases
	       echo "$gn""Alias set!""$xx"
	     fi	     

		 echo ""
		 echo "$rd""Attention! Please reconnect so that the alias works!""$xx"
	   fi

	   echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"
	   MainMenu ;;
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
	   echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"
	   MainMenu ;;
	5) SubMenuLicense ;;
	q|Q) clear; exit ;;
	*) docker --version | grep "Docker version" >/dev/null 2>&1
	   if [ $? -eq 0 ]; then Dashboard; else
  	     echo ""
  	     echo "$rd""Attention! Please install Docker! Loading Dashboard aborted!""$xx"
	     echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"
	     MainMenu
       fi;;
	esac
}

SubMenuLicense() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║ DLT.GREEN           AUTOMATIC NODE-INSTALLER WITH DOCKER $VAR_VRN ║"
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
	*) MainMenu ;;
	esac
}

SubMenuMaintenance() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║ DLT.GREEN           AUTOMATIC NODE-INSTALLER WITH DOCKER $VAR_VRN ║"
	echo "║""$ca""$VAR_DOMAIN""$xx""║"
	echo "║                                                                             ║"
	echo "║                              1. Install/Update                              ║"
	echo "║                              2. Start/Restart                               ║"
	echo "║                              3. Stop                                        ║"
	echo "║                              4. Reset Database                              ║"
	echo "║                              5. Loading Snapshot                            ║"
	echo "║                              6. Show Logs                                   ║"
	echo "║                              7. Configuration                               ║"
	echo "║                              8. Deinstall/Remove                            ║"
	echo "║                              X. Management Dashboard                        ║"
	echo "║                                                                             ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""
	   
	if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || Dashboard; fi
	if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 1 ]; then
		if [ -f /var/lib/$VAR_DIR/.env ]; then
			if [ $(cat .env 2>/dev/null | grep HORNET_VERSION | cut -d '=' -f 2) = $VAR_IOTA_HORNET_VERSION ]; then
				echo "$ca""Network/Node: $VAR_DIR | installed: v."$(cat .env 2>/dev/null | grep HORNET_VERSION | cut -d '=' -f 2)" | up-to-date""$xx"
			else
				echo "$ca""Network/Node: $VAR_DIR | installed: v."$(cat .env 2>/dev/null | grep HORNET_VERSION | cut -d '=' -f 2)" | available: $VAR_IOTA_HORNET_VERSION""$xx"
			fi
		else
			echo "$ca""Network/Node: $VAR_DIR | available: v.$VAR_IOTA_HORNET_VERSION""$xx"
		fi
	fi
	if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 2 ]; then
		if [ -f /var/lib/$VAR_DIR/.env ]; then
			if [ $(cat .env 2>/dev/null | grep WASP_VERSION | cut -d '=' -f 2) = $VAR_IOTA_WASP_VERSION ]; then
				echo "$ca""Network/Node: $VAR_DIR | installed: v."$(cat .env 2>/dev/null | grep WASP_VERSION | cut -d '=' -f 2)" | up-to-date""$xx"
			else
				echo "$ca""Network/Node: $VAR_DIR | installed: v."$(cat .env 2>/dev/null | grep WASP_VERSION | cut -d '=' -f 2)" | available: v.$VAR_IOTA_WASP_VERSION""$xx"
			fi
		else
			echo "$ca""Network/Node: $VAR_DIR | available: v.$VAR_IOTA_WASP_VERSION""$xx"
		fi
	fi
	if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 3 ]; then
		if [ -f /var/lib/$VAR_DIR/.env ]; then
			if [ $(cat .env 2>/dev/null | grep GOSHIMMER_VERSION | cut -d '=' -f 2) = $VAR_IOTA_GOSHIMMER_VERSION ]; then
				echo "$ca""Network/Node: $VAR_DIR | installed: v."$(cat .env 2>/dev/null | grep GOSHIMMER_VERSION | cut -d '=' -f 2)" | up-to-date""$xx"
			else
				echo "$ca""Network/Node: $VAR_DIR | installed: v."$(cat .env 2>/dev/null | grep GOSHIMMER_VERSION | cut -d '=' -f 2)" | available: v.$VAR_IOTA_GOSHIMMER_VERSION""$xx"
			fi
		else
			echo "$ca""Network/Node: $VAR_DIR | available: v.$VAR_IOTA_GOSHIMMER_VERSION""$xx"
		fi
	fi
	if [ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 5 ]; then
		if [ -f /var/lib/$VAR_DIR/.env ]; then
			if [ $(cat .env 2>/dev/null | grep HORNET_VERSION | cut -d '=' -f 2) = $VAR_SHIMMER_HORNET_VERSION ]; then
				echo "$ca""Network/Node: $VAR_DIR | installed: v."$(cat .env 2>/dev/null | grep HORNET_VERSION | cut -d '=' -f 2)" | up-to-date""$xx"
			else
				echo "$ca""Network/Node: $VAR_DIR | installed: v."$(cat .env 2>/dev/null | grep HORNET_VERSION | cut -d '=' -f 2)" | available: $VAR_SHIMMER_HORNET_VERSION""$xx"
			fi
		else
			echo "$ca""Network/Node: $VAR_DIR | available: v.$VAR_SHIMMER_HORNET_VERSION""$xx"
		fi
	fi
	if [ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 6 ]; then
		if [ -f /var/lib/$VAR_DIR/.env ]; then
			if [ $(cat .env 2>/dev/null | grep WASP_VERSION | cut -d '=' -f 2) = $VAR_SHIMMER_WASP_VERSION ]; then
				echo "$ca""Network/Node: $VAR_DIR | installed: v."$(cat .env 2>/dev/null | grep WASP_VERSION | cut -d '=' -f 2)" | up-to-date""$xx"
			else
				echo "$ca""Network/Node: $VAR_DIR | installed: v."$(cat .env 2>/dev/null | grep WASP_VERSION | cut -d '=' -f 2)" | available: v.$VAR_SHIMMER_WASP_VERSION""$xx"
			fi
		else
			echo "$ca""Network/Node: $VAR_DIR | available: v.$VAR_SHIMMER_WASP_VERSION""$xx"
		fi
	fi
	if [ "$VAR_NETWORK" = 3 ] && [ "$VAR_NODE" = 4 ]; then
		if [ -f /var/lib/$VAR_DIR/.env ]; then
			if [ $(cat .env 2>/dev/null | grep PIPE_VERSION | cut -d '=' -f 2) = $VAR_PIPE_VERSION ]; then
				echo "$ca""Network/Node: $VAR_DIR | installed: v."$(cat .env 2>/dev/null | grep PIPE_VERSION | cut -d '=' -f 2)" | up-to-date""$xx"
			else
				echo "$ca""Network/Node: $VAR_DIR | installed: v."$(cat .env 2>/dev/null | grep PIPE_VERSION | cut -d '=' -f 2)" | available: $VAR_PIPE_VERSION""$xx"
			fi
		else
			echo "$ca""Network/Node: $VAR_DIR | available: v.$VAR_PIPE_VERSION""$xx"
		fi
	fi
	echo "$rd""Available Diskspace: $(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 4)B/$(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 2)B ($(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 5) used) ""$xx"
	echo ""
	echo "select menu item: "
	echo ""

	read -r -p '> ' n
	case $n in
	1) if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 1 ]; then IotaHornet; fi
	   if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 2 ]; then IotaWasp; fi
	   if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 3 ]; then IotaGoshimmer; fi
	   if [ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 5 ]; then ShimmerHornet; fi
	   if [ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 6 ]; then ShimmerWasp; fi
	   if [ "$VAR_NETWORK" = 3 ] && [ "$VAR_NODE" = 4 ]; then Pipe; fi
	   ;;
	2) echo '(re)starting...'; sleep 3
	   clear
	   echo "$ca"
	   echo 'Please wait, (re)starting Nodes can take up to 5 minutes...'
	   echo "$xx"

	   if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 1 ]; then docker stop iota-hornet; fi
	   if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 2 ]; then docker stop iota-wasp; fi
	   if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 3 ]; then docker stop iota-goshimmer; fi
	   if [ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 5 ]; then docker stop shimmer-hornet; fi
	   if [ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 6 ]; then docker stop shimmer-wasp; fi
	   if [ "$VAR_NETWORK" = 3 ] && [ "$VAR_NODE" = 4 ]; then docker stop pipe; fi

	   if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuMaintenance; docker compose down; fi
	   rm -rf /var/lib/$VAR_DIR/data/peerdb/*
	   if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuMaintenance; docker compose up -d; fi

	   RenameContainer; sleep 3

	   echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"
	   SubMenuMaintenance
	   ;;
	3) echo 'stopping...'; sleep 3
	   clear
	   echo "$ca"
	   echo 'Please wait, stopping Nodes can take up to 5 minutes...'
	   echo "$xx"

	   if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 1 ]; then docker stop iota-hornet; fi
	   if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 2 ]; then docker stop iota-wasp; fi
	   if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 3 ]; then docker stop iota-goshimmer; fi
	   if [ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 5 ]; then docker stop shimmer-hornet; fi
	   if [ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 6 ]; then docker stop shimmer-wasp; fi
	   if [ "$VAR_NETWORK" = 3 ] && [ "$VAR_NODE" = 4 ]; then docker stop pipe; fi

	   if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuMaintenance; docker compose down; fi
	   sleep 3;

	   echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"
	   SubMenuMaintenance
	   ;;
	4) echo 'resetting...'; sleep 3
	   clear
	   echo "$ca"
	   echo 'Please wait, resetting Nodes can take up to 5 minutes...'
	   echo "$xx"

	   if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuMaintenance; docker compose down; fi

	   if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 1 ]; then
	      rm -rf /var/lib/$VAR_DIR/data/storage/mainnet/*
	   fi
	   if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 2 ]; then
	      rm -rf /var/lib/$VAR_DIR/data/waspdb/*
	   fi
	   if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 3 ]
	   then
	      rm -rf /var/lib/$VAR_DIR/data/mainnetdb/*
	      rm -rf /var/lib/$VAR_DIR/data/peerdb/*
	   fi
	   if [ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 5 ]
	   then
	      rm -rf /var/lib/$VAR_DIR/data/storage/$VAR_HORNET_NETWORK/*
	   fi
	   if [ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 6 ]; then
	      rm -rf /var/lib/$VAR_DIR/data/waspdb/*
	   fi

	   if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuMaintenance; docker compose up -d; fi

	   RenameContainer; sleep 3

	   echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"
	   SubMenuMaintenance
	   ;;
	5) echo 'loading...'; sleep 3
	   clear
	   echo "$ca"
	   echo 'Please wait, loading Snapshots can take up to 5 minutes...'
	   echo "$xx"

	   if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuMaintenance; docker compose down; fi

	   if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 1 ]; then
	      rm -rf /var/lib/$VAR_DIR/data/storage/mainnet/*
	      rm -rf /var/lib/$VAR_DIR/data/snapshots/mainnet/*
	   fi
	   if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 3 ]
	   then
	      rm -rf /var/lib/$VAR_DIR/data/mainnetdb/*
	      rm -rf /var/lib/$VAR_DIR/data/peerdb/*
	      if [ -f /var/lib/$VAR_DIR/data/snapshots/snapshot.bin ]; then cd /var/lib/$VAR_DIR/data/snapshots || SubMenuMaintenance; wget $SnapshotIotaGoshimmer; mv snapshot-latest.bin snapshot.bin; fi
	   fi
	   if [ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 5 ]
	   then
	      if [ -d /var/lib/$VAR_DIR/data/snapshots/$VAR_HORNET_NETWORK ]; then rm -rf /var/lib/$VAR_DIR/data/snapshots/$VAR_HORNET_NETWORK/*; cd /var/lib/$VAR_DIR/data/snapshots/$VAR_HORNET_NETWORK || SubMenuMaintenance; if [ $VAR_HORNET_NETWORK="mainnet" ]; then wget $SnapshotShimmerHornet; mv genesis_snapshot.bin full_snapshot.bin; fi; fi
	   fi
	   cd /var/lib/$VAR_DIR || SubMenuMaintenance;
	   ./prepare_docker.sh
	   if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuMaintenance; docker compose up -d; fi

	   RenameContainer

	   echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"
	   SubMenuMaintenance
	   ;;
	6) docker logs -f --tail 300 $VAR_DIR
	   echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"
	   SubMenuMaintenance
	   ;;
	7) SubMenuConfiguration
	   ;;
	8) echo 'deinstall/remove...'; sleep 3
	   echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"
	   clear
	   echo "$ca"
	   echo 'Please wait, deinstalling Nodes can take up to 5 minutes...'
	   echo "$xx"

	   if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuMaintenance; docker compose down >/dev/null 2>&1; fi
	   if [ -d /var/lib/$VAR_DIR ]; then rm -r /var/lib/$VAR_DIR; fi

	   echo "$rd""$VAR_DIR removed from your system!""$xx"
	   echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"
	   SubMenuMaintenance
	   ;;
	*) Dashboard ;;
	esac
}

SubMenuConfiguration() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║ DLT.GREEN           AUTOMATIC NODE-INSTALLER WITH DOCKER $VAR_VRN ║"
	echo "║""$ca""$VAR_DOMAIN""$xx""║"
	echo "║                                                                             ║"
	echo "║                              1. Generate JWT-Token (for secured API Access) ║"
	echo "║                              2. Toggle Proof of Work (if Node supports it)  ║"
	echo "║                              3. Toggle Network (Mainnet/Testnet)            ║"
	echo "║                              4. Set Node Alias (Name in Dashboard)          ║"
	echo "║                              5. Edit Node Configuration File (.env)         ║"
	echo "║                              X. Maintenance Menu                            ║"
	echo "║                                                                             ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || Dashboard; fi
	if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 1 ]; then
		if [ -f /var/lib/$VAR_DIR/.env ]; then
			if [ $(cat .env 2>/dev/null | grep HORNET_VERSION | cut -d '=' -f 2) = $VAR_IOTA_HORNET_VERSION ]; then
				echo "$ca""Network/Node: $VAR_DIR | installed: v."$(cat .env 2>/dev/null | grep HORNET_VERSION | cut -d '=' -f 2)" | up-to-date""$xx"
			else
				echo "$ca""Network/Node: $VAR_DIR | installed: v."$(cat .env 2>/dev/null | grep HORNET_VERSION | cut -d '=' -f 2)" | available: $VAR_IOTA_HORNET_VERSION""$xx"
			fi
		else
			echo "$ca""Network/Node: $VAR_DIR | available: v.$VAR_IOTA_HORNET_VERSION""$xx"
		fi
	fi
	if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 2 ]; then
		if [ -f /var/lib/$VAR_DIR/.env ]; then
			if [ $(cat .env 2>/dev/null | grep WASP_VERSION | cut -d '=' -f 2) = $VAR_IOTA_WASP_VERSION ]; then
				echo "$ca""Network/Node: $VAR_DIR | installed: v."$(cat .env 2>/dev/null | grep WASP_VERSION | cut -d '=' -f 2)" | up-to-date""$xx"
			else
				echo "$ca""Network/Node: $VAR_DIR | installed: v."$(cat .env 2>/dev/null | grep WASP_VERSION | cut -d '=' -f 2)" | available: v.$VAR_IOTA_WASP_VERSION""$xx"
			fi
		else
			echo "$ca""Network/Node: $VAR_DIR | available: v.$VAR_IOTA_WASP_VERSION""$xx"
		fi
	fi
	if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 3 ]; then
		if [ -f /var/lib/$VAR_DIR/.env ]; then
			if [ $(cat .env 2>/dev/null | grep GOSHIMMER_VERSION | cut -d '=' -f 2) = $VAR_IOTA_GOSHIMMER_VERSION ]; then
				echo "$ca""Network/Node: $VAR_DIR | installed: v."$(cat .env 2>/dev/null | grep GOSHIMMER_VERSION | cut -d '=' -f 2)" | up-to-date""$xx"
			else
				echo "$ca""Network/Node: $VAR_DIR | installed: v."$(cat .env 2>/dev/null | grep GOSHIMMER_VERSION | cut -d '=' -f 2)" | available: v.$VAR_IOTA_GOSHIMMER_VERSION""$xx"
			fi
		else
			echo "$ca""Network/Node: $VAR_DIR | available: v.$VAR_IOTA_GOSHIMMER_VERSION""$xx"
		fi
	fi
	if [ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 5 ]; then
		if [ -f /var/lib/$VAR_DIR/.env ]; then
			if [ $(cat .env 2>/dev/null | grep HORNET_VERSION | cut -d '=' -f 2) = $VAR_SHIMMER_HORNET_VERSION ]; then
				echo "$ca""Network/Node: $VAR_DIR | installed: v."$(cat .env 2>/dev/null | grep HORNET_VERSION | cut -d '=' -f 2)" | up-to-date""$xx"
			else
				echo "$ca""Network/Node: $VAR_DIR | installed: v."$(cat .env 2>/dev/null | grep HORNET_VERSION | cut -d '=' -f 2)" | available: $VAR_SHIMMER_HORNET_VERSION""$xx"
			fi
		else
			echo "$ca""Network/Node: $VAR_DIR | available: v.$VAR_SHIMMER_HORNET_VERSION""$xx"
		fi
	fi
	if [ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 6 ]; then
		if [ -f /var/lib/$VAR_DIR/.env ]; then
			if [ $(cat .env 2>/dev/null | grep WASP_VERSION | cut -d '=' -f 2) = $VAR_SHIMMER_WASP_VERSION ]; then
				echo "$ca""Network/Node: $VAR_DIR | installed: v."$(cat .env 2>/dev/null | grep WASP_VERSION | cut -d '=' -f 2)" | up-to-date""$xx"
			else
				echo "$ca""Network/Node: $VAR_DIR | installed: v."$(cat .env 2>/dev/null | grep WASP_VERSION | cut -d '=' -f 2)" | available: v.$VAR_SHIMMER_WASP_VERSION""$xx"
			fi
		else
			echo "$ca""Network/Node: $VAR_DIR | available: v.$VAR_SHIMMER_WASP_VERSION""$xx"
		fi
	fi
	echo "$rd""Available Diskspace: $(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 4)B/$(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 2)B ($(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 5) used) ""$xx"
	echo ""
	echo "select menu item: "
	echo ""

	read -r -p '> ' n
	case $n in
	1) clear
	   echo "$ca"
	   echo "Generate JWT-Token..."
	   echo "$xx"

	   cd /var/lib/$VAR_DIR || SubMenuConfiguration;
	   if ([ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 1 ]) || ([ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 5 ]); then
		  VAR_RESTAPI_SALT=$(cat .env 2>/dev/null | grep RESTAPI_SALT | cut -d '=' -f 2);
	      if [ -z $VAR_RESTAPI_SALT ]; then echo "$rd""Generate JWT-Token is not supportet, please update your Node! ""$xx"
		  else
		     VAR_JWT=$(docker compose run --rm hornet tool jwt-api --salt $VAR_RESTAPI_SALT | awk '{ print $5 }')
		     echo "Your JWT-Token for secured API Access is generated:"
		     echo "$gn"
		     echo "$VAR_JWT""$xx"
		  fi
	   else
	      echo "$rd""Generate JWT-Token is not supportet, aborted! ""$xx"
	   fi	
	   echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"
	   SubMenuConfiguration ;;
	2) clear
	   echo "$ca"
	   echo "Toggle Proof of Work..."
	   echo "$xx""$fl"
	   
	   cd /var/lib/$VAR_DIR || SubMenuConfiguration;
	   if ([ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 1 ]) || ([ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 5 ]); then
		  read -r -p 'Press [P] to enable Proof of Work... Press [X] key to disable... ' K; echo "$xx"
		  if  [ "$K" = 'p' ] || [ "$K" = 'P' ]; then 
	         if [ -f .env ]; then sed -i "s/HORNET_POW_ENABLED=.*/HORNET_POW_ENABLED=true/g" .env; K='P'; fi
		  fi
		  if  [ "$K" = 'x' ] || [ "$K" = 'X' ]; then 		  
	         if [ -f .env ]; then sed -i "s/HORNET_POW_ENABLED=.*/HORNET_POW_ENABLED=false/g" .env; K='X'; fi	  
		  fi
		  if  [ "$K" = 'P' ] || [ "$K" = 'X' ]; then		  
		     ./prepare_docker.sh >/dev/null 2>&1
	         if  [ "$K" = 'P' ]; then echo "$gn""Proof of Work of your Node successfully enabled""$xx"; else echo "$rd""Proof of Work of your Node successfully disabled""$xx"; fi
	         echo "$rd""Please restart your Node for the changes to take effect!""$xx"
		  else
	         echo "$rd""Toggle Proof of Work aborted!""$xx"
		  fi
	   else
	      echo "$rd""Toggle Proof of Work is not supportet, aborted!""$xx"
	   fi	
	   echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"
	   SubMenuConfiguration ;;
	3) clear
	   echo "$ca"
	   echo "Toggle Network..."
	   echo "$xx""$fl"
	   
	   cd /var/lib/$VAR_DIR || SubMenuConfiguration;
	   if ([ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 5 ]); then
		  read -r -p 'Press [M] to enable Mainnet... Press [T] to enable Testnet... ' K; echo "$xx"
		  if  [ "$K" = 'm' ] || [ "$K" = 'M' ]; then 
	         if [ -f .env ]; then sed -i "s/HORNET_NETWORK=.*/HORNET_NETWORK=mainnet/g" .env; K='M'; fi
		  fi
		  if  [ "$K" = 't' ] || [ "$K" = 'T' ]; then 		  
	         if [ -f .env ]; then sed -i "s/HORNET_NETWORK=.*/HORNET_NETWORK=testnet/g" .env; K='T'; fi	  
		  fi
		  if  [ "$K" = 'M' ] || [ "$K" = 'T' ]; then		  
		     ./prepare_docker.sh >/dev/null 2>&1
			 VAR_HORNET_NETWORK=$(cat ".env" | grep HORNET_NETWORK | cut -d '=' -f 2)
	         if  [ "$K" = 'M' ]; then echo "$gn""Mainnet of your Node successfully enabled""$xx"; else echo "$gn""Testnet of your Node successfully enabled""$xx"; fi
	         echo "$rd""Please restart your Node for the changes to take effect!""$xx"
		  else
	         echo "$rd""Toggle Network aborted!""$xx"
		  fi
	   else
	      echo "$rd""Toggle Network is not supportet, aborted!""$xx"
	   fi	
	   echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"
	   SubMenuConfiguration ;;
	4) clear
	   echo "$ca"
	   echo "Set Node Alias..."
	   echo "$xx"
	   
	   cd /var/lib/$VAR_DIR || SubMenuConfiguration;
	   if [ "$VAR_NODE" = 1 ] || [ "$VAR_NODE" = 5 ]; then
	      echo "Set the node alias (example: $ca""DLT.GREEN Node""$xx):"
	      read -r -p '> ' VAR_NODE_ALIAS
	      echo ''
	      if [ "$VAR_NODE" = 1 ] || [ "$VAR_NODE" = 5 ]; then  
		     fgrep -q "HORNET_NODE_ALIAS" .env || echo "HORNET_NODE_ALIAS=$VAR_NODE_ALIAS" >> .env
	         if [ -f .env ]; then sed -i "s/HORNET_NODE_ALIAS=.*/HORNET_NODE_ALIAS=\"$VAR_NODE_ALIAS\"/g" .env; fi
		  fi
		  ./prepare_docker.sh >/dev/null 2>&1
		  echo "$gn""Node Alias of your Node successfully set""$xx"
		  echo "$rd""Please restart your Node for the changes to take effect!""$xx"
	   else
	      echo "$rd""Set Node Alias is not supportet, aborted!""$xx"
	   fi
	   echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"
	   SubMenuConfiguration ;;
	5) clear
	   echo "$ca"
	   echo "Edit Node Configuration File (.env)..."
	   echo "$xx"
	   cd /var/lib/$VAR_DIR || SubMenuConfiguration;
       if [ -f .env ]; then
	      nano .env
	      ./prepare_docker.sh >/dev/null 2>&1
	      echo "$rd""Please restart your Node for the changes to take effect!""$xx"
       fi
	   echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel...' W; echo "$xx"
	   SubMenuConfiguration ;;
	*) SubMenuMaintenance ;;
	esac
}

SubMenuWaspCLI() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║ DLT.GREEN           AUTOMATIC NODE-INSTALLER WITH DOCKER $VAR_VRN ║"
	echo "║""$ca""$VAR_DOMAIN""$xx""║"
	echo "║                                                                             ║"
	echo "║                              1. Install/Prepare Wasp-CLI                    ║"
	echo "║                              2. Run Wasp-CLI | alias: wasp-cli {commands}   ║"	
	echo "║                              3. Login (Authenticate against a Wasp node)    ║"	
	echo "║                              4. Initialize a new wallet                     ║"
	echo "║                              5. Show the wallet address                     ║"	
	echo "║                              6. Show the wallet balance                     ║"	
	echo "║                              7. Show the committee peering info             ║"	
	echo "║                              8. Help                                        ║"	
	echo "║                              9. Deinstall/Remove                            ║"
	echo "║                              X. Management Dashboard                        ║"
	echo "║                                                                             ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""
	if [ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 7 ]; then
	if [ -s "/var/lib/shimmer-wasp/wasp-cli-wrapper.sh" ]; then echo "$ca""Network/Node: $VAR_DIR | $(/var/lib/shimmer-wasp/wasp-cli-wrapper.sh -v)""$xx"; else echo "$ca""Network/Node: $VAR_DIR | wasp-cli not installed""$xx"; fi; fi
	echo "$rd""Available Diskspace: $(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 4)B/$(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 2)B ($(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 5) used) ""$xx"
	echo ""
	echo "select menu item: "
	echo ""

	read -r -p '> ' n
	case $n in
	1) clear
	   echo "$ca"
	   echo "Install/Prepare Wasp-CLI...$xx"

	   if [ -d /var/lib/shimmer-wasp ]; then
	      if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuWaspCLI; fi
	      echo "$fl"; read -r -p 'Press [F] to enable Faucet... Press [ENTER] key to skip... ' F; echo "$xx"
		  if  [ "$F" = 'f' ] && ! [ "$F" = 'F' ]; then 
	         fgrep -q "WASP_CLI_FAUCET_ADDRESS" .env || echo "WASP_CLI_FAUCET_ADDRESS=https://faucet.testnet.shimmer.network" >> .env
		  fi
		  if [ -f "./prepare_cli.sh" ]; then ./prepare_cli.sh; else echo "$rd""For using Wasp-CLI you must update Shimmer-Wasp first!""$xx"; fi
	   else
	      echo "$rd""For using Wasp-CLI you must install Shimmer-Wasp first!""$xx"
	   fi
	   echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"
	   SubMenuWaspCLI
	   ;;
	2) clear
	   if [ -d /var/lib/shimmer-wasp ]; then
	      if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuWaspCLI; fi
          VAR_RUN_WASP_CLI_CMD=''
          echo "$ca"
          if [ -s "/var/lib/shimmer-wasp/wasp-cli-wrapper.sh" ]; then echo "$ca""Network/Node: $VAR_DIR | $(/var/lib/shimmer-wasp/wasp-cli-wrapper.sh -v)""$xx"; else echo "$ca""Network/Node: $VAR_DIR | wasp-cli not installed""$xx"; fi
          echo "$rd""Hint: Quit Wasp-CLI with [q] | Help [-h] | Clear [clear]"
          echo "$xx"
          echo "Set command: (example: $ca""'wasp-cli {commands}' or '{commands}'""$xx):"
		  while ! [ "$VAR_RUN_WASP_CLI_CMD" = 'q' ] && ! [ "$VAR_RUN_WASP_CLI_CMD" = 'Q' ]
	      do
             echo "$ca"
		     read -r -p 'Wasp-CLI > ' VAR_RUN_WASP_CLI_CMD
			 echo "$xx"
		     VAR_RUN_WASP_CLI_CMD=$(echo "$VAR_RUN_WASP_CLI_CMD" | sed 's/^wasp-cli//g')
			 if [ "$VAR_RUN_WASP_CLI_CMD" = 'clear' ]; then
			    clear
			    echo "$ca"
			    if [ -s "/var/lib/shimmer-wasp/wasp-cli-wrapper.sh" ]; then echo "$ca""Network/Node: $VAR_DIR | $(/var/lib/shimmer-wasp/wasp-cli-wrapper.sh -v)""$xx"; else echo "$ca""Network/Node: $VAR_DIR | wasp-cli not installed""$xx"; fi
			    echo "$rd""Hint: Quit Wasp-CLI with [q] | Help [-h] | Clear [clear]"
			    echo "$xx"
			    echo "Set command: (example: $ca""'wasp-cli {commands}' or '{commands}'""$xx):"
			 fi
			 if ! [ "$VAR_RUN_WASP_CLI_CMD" = 'clear' ] && ! [ "$VAR_RUN_WASP_CLI_CMD" = 'q' ] && ! [ "$VAR_RUN_WASP_CLI_CMD" = 'Q' ]; then
			    if [ -f "./data/config/wasp-cli.json" ]; then ./wasp-cli-wrapper.sh "$VAR_RUN_WASP_CLI_CMD"; else echo ""; echo "$rd""For using Wasp-CLI you must install/prepare Wasp-CLI first!""$xx"; fi
			 fi
	      done
	   else
	      echo "$rd""For using Wasp-CLI you must install Shimmer-Wasp first!""$xx"
	      echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"
	   fi
	   SubMenuWaspCLI
	   ;;
	3) clear
	   echo "$ca"
	   echo 'Login (Authenticate against a Wasp node)...'
	   echo "$xx"
	   if [ -d /var/lib/shimmer-wasp ]; then
	      if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuWaspCLI; fi
		  if [ -f "./data/config/wasp-cli.json" ]; then ./wasp-cli-wrapper.sh login; else echo "$rd""For using Wasp-CLI you must install/prepare Wasp-CLI first!""$xx"; fi
	   else
	      echo "$rd""For using Wasp-CLI you must install Shimmer-Wasp first!""$xx"
	   fi
	   echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"
	   SubMenuWaspCLI
	   ;;
	4) clear
	   echo "$ca"
	   echo 'Initialize a new wallet...'
	   echo "$xx"
	   if [ -d /var/lib/shimmer-wasp ]; then
	      if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuWaspCLI; fi
		  if [ -f "./data/config/wasp-cli.json" ]; then ./wasp-cli-wrapper.sh init; else echo "$rd""For using Wasp-CLI you must install/prepare Wasp-CLI first!""$xx"; fi
	   else
	      echo "$rd""For using Wasp-CLI you must install Shimmer-Wasp first!""$xx"
	   fi
	   echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"
	   SubMenuWaspCLI
	   ;;
	5) clear
	   echo "$ca"
	   echo 'Show the wallet address...'
	   echo "$xx"
	   if [ -d /var/lib/shimmer-wasp ]; then
	      if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuWaspCLI; fi
		  if [ -f "./data/config/wasp-cli.json" ]; then ./wasp-cli-wrapper.sh address; else echo "$rd""For using Wasp-CLI you must install/prepare Wasp-CLI first!""$xx"; fi
	   else
	      echo "$rd""For using Wasp-CLI you must install Shimmer-Wasp first!""$xx"
	   fi
	   echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"
	   SubMenuWaspCLI
	   ;;
	6) clear
	   echo "$ca"
	   echo 'Show the wallet balance...'
	   echo "$xx"
	   if [ -d /var/lib/shimmer-wasp ]; then
	      if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuWaspCLI; fi
		  if [ -f "./data/config/wasp-cli.json" ]; then ./wasp-cli-wrapper.sh balance; else echo "$rd""For using Wasp-CLI you must install/prepare Wasp-CLI first!""$xx"; fi
	   else
	      echo "$rd""For using Wasp-CLI you must install Shimmer-Wasp first!""$xx"
	   fi
	   echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"
	   SubMenuWaspCLI
	   ;;
	7) clear
	   echo "$ca"
	   echo 'Show the committee peering info...'
	   echo "$xx"
	   if [ -d /var/lib/shimmer-wasp ]; then
	      if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuWaspCLI; fi
		  if [ -f "./data/config/wasp-cli.json" ]; then
		     VAR_WASP_CLI_PUBKEY=$(./wasp-cli-wrapper.sh peering info | grep PubKey | tr -s ' ' | cut -d ' ' -f 2)
		     VAR_WASP_CLI_NETID=$(./wasp-cli-wrapper.sh peering info | grep NetID | tr -s ' ' | cut -d ' ' -f 2)

			echo "PubKey:   " $VAR_WASP_CLI_PUBKEY
			echo "NetID:    " $VAR_WASP_CLI_NETID
			
		  else echo "$rd""For using Wasp-CLI you must install/prepare Wasp-CLI first!""$xx"; fi
	  else
	      echo "$rd""For using Wasp-CLI you must install Shimmer-Wasp first!""$xx"
	   fi
	   echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"
	   SubMenuWaspCLI
	   ;;
	8) clear
	   echo "$ca"
	   echo 'Help...'
	   echo "$xx"
	   if [ -d /var/lib/shimmer-wasp ]; then
	      if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuWaspCLI; fi
		  if [ -f "./data/config/wasp-cli.json" ]; then ./wasp-cli-wrapper.sh -h; else echo "$rd""For using Wasp-CLI you must install/prepare Wasp-CLI first!""$xx"; fi
	   else
	      echo "$rd""For using Wasp-CLI you must install Shimmer-Wasp first!""$xx"
	   fi
	   echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"
	   SubMenuWaspCLI
	   ;;
	9) clear
	   echo "$ca"
	   echo 'Deinstall/Remove Wasp-CLI...'
	   echo "$xx"
	   if [ -d /var/lib/shimmer-wasp ]; then
	      if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuWaspCLI; fi
		  if [ -s "./prepare_cli.sh" ]; then ./prepare_cli.sh --uninstall; else echo "$rd""For using Wasp-CLI you must install/prepare Wasp-CLI first!""$xx"; fi
	   else
	      echo "$rd""For using Wasp-CLI you must install Shimmer-Wasp first!""$xx"
	   fi
	   echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"
	   SubMenuWaspCLI
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

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"

	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                  Delete unused old docker containers/images                 ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	docker system prune

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"

	clear
	echo "$ca"
	echo 'Please wait, stopping Nodes can take up to 5 minutes...'
	echo "$xx"
	docker stop $(docker ps -a -q)
	docker ps -a -q >/dev/null 2>&1

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"

	clear
	echo "$ca"
	echo 'Please wait, updating the System...'
	echo "$xx"
	sudo apt-get update && apt-get upgrade -y
	sudo apt-get dist-upgrade -y
	sudo apt upgrade -y
	sudo apt-get autoremove -y

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"

	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║           Update global Certificate from Let's Encrypt Certificate          ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	NODES="iota-hornet iota-goshimmer iota-wasp shimmer-hornet shimmer-wasp"
	CERT=0
	
	for NODE in $NODES; do
	  if [ -f "/var/lib/$NODE/data/letsencrypt/acme.json" ]; then
	    if [ -d "/var/lib/$NODE" ]; then cd "/var/lib/$NODE" || exit; fi
	    if [ -f .env ]; then HOST=$(cat .env 2>/dev/null | grep _HOST | cut -d '=' -f 2); fi
	    if [ -d "/var/lib/$NODE/data/letsencrypt" ]; then cd "/var/lib/$NODE/data/letsencrypt" || exit; fi
	    if [ -d "/etc/letsencrypt/live/$HOST" ]; then
	      cat acme.json | jq -r '.myresolver .Certificates[]? | select(.domain.main=="'"$HOST"'") | .certificate' | base64 -d > "$HOST.crt"
	      cat acme.json | jq -r '.myresolver .Certificates[]? | select(.domain.main=="'"$HOST"'") | .key' | base64 -d > "$HOST.key"
	      if [ -s "/var/lib/$NODE/data/letsencrypt/$HOST.crt" ]; then
	        cp "/var/lib/$NODE/data/letsencrypt/$HOST.crt" "/etc/letsencrypt/live/$HOST/fullchain.pem"
	        if [ -s "/var/lib/$NODE/data/letsencrypt/$HOST.key" ]; then
	          cp "/var/lib/$NODE/data/letsencrypt/$HOST.key" "/etc/letsencrypt/live/$HOST/privkey.pem"
	          echo "$gn""Global Certificate is now updated for all Nodes from $NODE""$xx"
	          echo "valid until: "$(openssl x509 -in $HOST.crt -noout -enddate | cut -d '=' -f 2)
	          CERT=$(( CERT + 1 ))
	        fi
	      fi
	    fi
	  fi
	done
	
	if [ $CERT = 0 ]; then echo "$rd""No Let's Encrypt Certificate found, aborted!""$xx"; fi
	if [ $CERT -gt 1 ]; then echo "$rd"; echo "Misconfiguration with Certificates from your Nodes detected!""$xx"; fi
	
	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"
	
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║ DLT.GREEN           AUTOMATIC NODE-INSTALLER WITH DOCKER $VAR_VRN ║"
	echo "║""$ca""$VAR_DOMAIN""$xx""║"
	echo "║                                                                             ║"
	echo "║                            1. System Restart (recommend)                    ║"
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
	    echo "$rd"
	    echo "System restarted, dont't forget to reconnect and start your Nodes again!"
	    echo "$xx"
		sudo reboot
		;;
	*) clear
	   echo "$ca"
	   echo 'Please wait, starting Nodes can take up to 5 minutes...'
	   echo "$xx"
	   if [ -d /var/lib/iota-hornet ]; then cd /var/lib/iota-hornet || Dashboard; docker compose up -d; fi
	   if [ -d /var/lib/iota-goshimmer ]; then cd /var/lib/iota-goshimmer || Dashboard; docker compose up -d; fi
	   if [ -d /var/lib/shimmer-hornet ]; then cd /var/lib/shimmer-hornet || Dashboard; docker compose up -d; fi
	   sleep 5
	   if [ -d /var/lib/iota-wasp ]; then cd /var/lib/iota-wasp || Dashboard; docker compose up -d; fi
	   if [ -d /var/lib/shimmer-wasp ]; then cd /var/lib/shimmer-wasp || Dashboard; docker compose up -d; fi
	   RenameContainer

	   echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"

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

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"

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

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"

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

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"
	if [ "$VAR_NETWORK" = 2 ]; then VAR_NETWORK=1; SubMenuMaintenance; fi

	echo "Stopping Node... $VAR_DIR"
	if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; if [ -f "/var/lib/$VAR_DIR/docker-compose.yml" ]; then docker compose down >/dev/null 2>&1; fi; fi

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

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"

	CheckConfiguration

	VAR_SALT=$(cat /dev/urandom | tr -dc '[:alpha:]' | fold -w ${1:-20} | head -n 1)

	if [ $VAR_CONF_RESET = 1 ]; then

		clear
		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                               Set Parameters                                ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		VAR_HOST=$(cat .env 2>/dev/null | grep HORNET_HOST= | cut -d '=' -f 2)
		if [ -z "$VAR_HOST" ]; then
		  VAR_HOST=$(echo $VAR_DOMAIN | xargs)
		  if [ -n "$VAR_HOST" ]; then
		    echo "Set domain name (global: $ca""$VAR_HOST""$xx):"; echo "Press [Enter] to use global domain:"
		  else
			echo "Set domain name (example: $ca""vrom.dlt.green""$xx):";
		  fi
		else echo "Set domain name (config: $ca""$VAR_HOST""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_HOST=$VAR_TMP; fi
		CheckDomain "$VAR_HOST"

		echo ''
		VAR_IOTA_HORNET_HTTPS_PORT=$(cat .env 2>/dev/null | grep HORNET_HTTPS_PORT= | cut -d '=' -f 2)
		VAR_DEFAULT='443';
		if [ -z "$VAR_IOTA_HORNET_HTTPS_PORT" ]; then
		  echo "Set dashboard port (default: $ca"$VAR_DEFAULT"$xx):"; echo "Press [Enter] to use default value:"; else echo "Set dashboard port (config: $ca""$VAR_IOTA_HORNET_HTTPS_PORT""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_IOTA_HORNET_HTTPS_PORT=$VAR_TMP; elif [ -z "$VAR_IOTA_HORNET_HTTPS_PORT" ]; then VAR_IOTA_HORNET_HTTPS_PORT=$VAR_DEFAULT; fi
		echo "$gn""Set dashboard port: $VAR_IOTA_HORNET_HTTPS_PORT""$xx"

		echo ''
		while [ -z "$VAR_IOTA_HORNET_PRUNING_SIZE" ]; do
		  VAR_IOTA_HORNET_PRUNING_SIZE=$(cat .env 2>/dev/null | grep HORNET_PRUNING_TARGET_SIZE= | cut -d '=' -f 2)
		  if [ -z "$VAR_IOTA_HORNET_PRUNING_SIZE" ]; then
		    echo "Set pruning size / max. database size (example: $ca""200GB""$xx):"; else echo "Set pruning size / max. database size (config: $ca""$VAR_IOTA_HORNET_PRUNING_SIZE""$xx)"; echo "Press [Enter] to use existing config:"; fi
		  echo "$rd""Available Diskspace: $(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 4)B/$(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 2)B ($(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 5) used) ""$xx"
		  read -r -p '> ' VAR_TMP
		  if [ -n "$VAR_TMP" ]; then VAR_IOTA_HORNET_PRUNING_SIZE=$VAR_TMP; fi
		  if ! [ -z "${VAR_IOTA_HORNET_PRUNING_SIZE##*B*}" ]; then
		    VAR_IOTA_HORNET_PRUNING_SIZE=''
		    echo "$rd""Set pruning size: Please insert with unit!"; echo "$xx"
		  fi
		done
		echo "$gn""Set pruning size: $VAR_IOTA_HORNET_PRUNING_SIZE""$xx"

		echo ''
		VAR_IOTA_HORNET_POW=$(cat .env 2>/dev/null | grep HORNET_POW_ENABLED= | cut -d '=' -f 2)
		VAR_DEFAULT='true';
		if [ -z "$VAR_IOTA_HORNET_POW" ]; then
		  echo "Set PoW / proof of work (default: $ca"$VAR_DEFAULT"$xx):"; echo "Press [Enter] to use default value:"; else echo "Set PoW / proof of work (config: $ca""$VAR_IOTA_HORNET_POW""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> Press [P] to enable Proof of Work... Press [X] key to disable... ' VAR_TMP;
		if [ -n "$VAR_TMP" ]; then
		  VAR_IOTA_HORNET_POW=$VAR_TMP
		  if  [ "$VAR_IOTA_HORNET_POW" = 'p' ] || [ "$VAR_IOTA_HORNET_POW" = 'P' ]; then 
		    VAR_IOTA_HORNET_POW='true'
		  else
		    VAR_IOTA_HORNET_POW='false'
		  fi
		elif [ -z "$VAR_IOTA_HORNET_POW" ]; then VAR_IOTA_HORNET_POW=$VAR_DEFAULT; fi

		if  [ "$VAR_IOTA_HORNET_POW" ]; then
		  echo "$gn""Set PoW / proof of work: $VAR_IOTA_HORNET_POW""$xx"
		else
		  echo "$rd""Set PoW / proof of work: $VAR_IOTA_HORNET_POW""$xx"		
		fi

		echo ''
		VAR_USERNAME=$(cat .env 2>/dev/null | grep DASHBOARD_USERNAME= | cut -d '=' -f 2)
		VAR_DEFAULT=$(cat /dev/urandom | tr -dc '[:alpha:]' | fold -w ${1:-10} | head -n 1);
		if [ -z "$VAR_USERNAME" ]; then
		echo "Set dashboard username (generated: $ca"$VAR_DEFAULT"$xx):"; echo "to use generated value press [ENTER]:"; else echo "Set dashboard username (config: $ca""$VAR_USERNAME""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_USERNAME=$VAR_TMP; elif [ -z "$VAR_USERNAME" ]; then VAR_USERNAME=$VAR_DEFAULT; fi
		echo "$gn""Set dashboard username: $VAR_USERNAME""$xx"

		echo ''
		VAR_DASHBOARD_PASSWORD=$(cat .env 2>/dev/null | grep DASHBOARD_PASSWORD= | cut -d '=' -f 2)
		VAR_DASHBOARD_SALT=$(cat .env 2>/dev/null | grep DASHBOARD_SALT= | cut -d '=' -f 2)
		VAR_DEFAULT=$(cat /dev/urandom | tr -dc '[:alpha:]' | fold -w ${1:-20} | head -n 1);
		if [ -z "$VAR_DASHBOARD_PASSWORD" ]; then
		echo "Set dashboard password / will be saved as hash ($ca""use generated""$xx):"; echo "to use generated value press [ENTER]:"; else echo "Set dashboard password / will be saved as hash (config: $ca""use existing""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then
		  VAR_PASSWORD=$VAR_TMP
		  echo "$gn""Set dashboard password: new""$xx"
		else
		  if [ -z "$VAR_DASHBOARD_PASSWORD" ]; then
		    VAR_PASSWORD=$VAR_DEFAULT
		    echo "$gn""Set dashboard password: "$VAR_DEFAULT"$xx"
		  else
		    VAR_PASSWORD=''
		    echo "$gn""Set dashboard password: use existing""$xx"
		  fi
		fi	

		echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"
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
		echo "RESTAPI_SALT=$VAR_SALT" >> .env

		if [ $VAR_CERT = 0 ]
		then
			echo "HORNET_HTTP_PORT=80" >> .env
			while [ -z "$VAR_ACME_EMAIL" ]; do
				read -r -p 'Set mail for certificat renewal (e.g. info@dlt.green): ' VAR_ACME_EMAIL
			done
			echo "ACME_EMAIL=$VAR_ACME_EMAIL" >> .env
		else
			echo "HORNET_HTTP_PORT=8081" >> .env
			echo "SSL_CONFIG=certs" >> .env
			echo "HORNET_SSL_CERT=/etc/letsencrypt/live/$VAR_HOST/fullchain.pem" >> .env
			echo "HORNET_SSL_KEY=/etc/letsencrypt/live/$VAR_HOST/privkey.pem" >> .env
		fi
	else
		if [ -f .env ]; then sed -i "s/HORNET_VERSION=.*/HORNET_VERSION=$VAR_IOTA_HORNET_VERSION/g" .env; fi
		VAR_HOST=$(cat .env 2>/dev/null | grep _HOST | cut -d '=' -f 2)
		fgrep -q "RESTAPI_SALT" .env || echo "RESTAPI_SALT=$VAR_SALT" >> .env
	fi

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"

	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                                 Pull Data                                   ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	docker compose pull

	if [ $VAR_CONF_RESET = 1 ]; then

		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                               Set Creditials                                ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		if [ -n "$VAR_PASSWORD" ]; then
		  credentials=$(docker compose run --rm hornet tool pwd-hash --json --password "$VAR_PASSWORD" | sed -e 's/\r//g')
		  VAR_DASHBOARD_PASSWORD=$(echo "$credentials" | jq -r '.passwordHash')
		  VAR_DASHBOARD_SALT=$(echo "$credentials" | jq -r '.passwordSalt')
		fi
		
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

	docker compose up -d

	sleep 3

	RenameContainer

	echo ""
	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"

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

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"

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

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"
	if [ "$VAR_NETWORK" = 2 ]; then VAR_NETWORK=1; SubMenuMaintenance; fi

	echo "Stopping Node... $VAR_DIR"
	if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; if [ -f "/var/lib/$VAR_DIR/docker-compose.yml" ]; then docker compose down >/dev/null 2>&1; fi; fi

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

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"

	CheckConfiguration

	VAR_WASP_LEDGER_NETWORK='iota'

	if [ $VAR_CONF_RESET = 1 ]; then

		clear
		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                               Set Parameters                                ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		VAR_HOST=$(cat .env 2>/dev/null | grep WASP_HOST= | cut -d '=' -f 2)
		if [ -z "$VAR_HOST" ]; then
		  VAR_HOST=$(echo $VAR_DOMAIN | xargs)
		  if [ -n "$VAR_HOST" ]; then
		    echo "Set domain name (global: $ca""$VAR_HOST""$xx):"; echo "Press [Enter] to use global domain:"
		  else
			echo "Set domain name (example: $ca""vrom.dlt.green""$xx):";
		  fi
		else echo "Set domain name (config: $ca""$VAR_HOST""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_HOST=$VAR_TMP; fi
		CheckDomain "$VAR_HOST"

		echo ''
		VAR_IOTA_WASP_HTTPS_PORT=$(cat .env 2>/dev/null | grep WASP_HTTPS_PORT= | cut -d '=' -f 2)
		VAR_DEFAULT='447';
		if [ -z "$VAR_IOTA_WASP_HTTPS_PORT" ]; then
		  echo "Set dashboard port (default: $ca"$VAR_DEFAULT"$xx):"; echo "Press [Enter] to use default value:"; else echo "Set dashboard port (config: $ca""$VAR_IOTA_WASP_HTTPS_PORT""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_IOTA_WASP_HTTPS_PORT=$VAR_TMP; elif [ -z "$VAR_IOTA_WASP_HTTPS_PORT" ]; then VAR_IOTA_WASP_HTTPS_PORT=$VAR_DEFAULT; fi
		echo "$gn""Set dashboard port: $VAR_IOTA_WASP_HTTPS_PORT""$xx"

		echo ''
		VAR_IOTA_WASP_API_PORT=$(cat .env 2>/dev/null | grep WASP_API_PORT= | cut -d '=' -f 2)
		VAR_DEFAULT='448';
		if [ -z "$VAR_IOTA_WASP_API_PORT" ]; then
		  echo "Set api port (default: $ca"$VAR_DEFAULT"$xx):"; echo "Press [Enter] to use default value:"; else echo "Set api port (config: $ca""$VAR_IOTA_WASP_API_PORT""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_IOTA_WASP_API_PORT=$VAR_TMP; elif [ -z "$VAR_IOTA_WASP_API_PORT" ]; then VAR_IOTA_WASP_API_PORT=$VAR_DEFAULT; fi
		echo "$gn""Set api port: $VAR_IOTA_WASP_API_PORT""$xx"

		echo ''
		VAR_IOTA_WASP_PEERING_PORT=$(cat .env 2>/dev/null | grep WASP_PEERING_PORT= | cut -d '=' -f 2)
		VAR_DEFAULT='4000';
		if [ -z "$VAR_IOTA_WASP_PEERING_PORT" ]; then
		  echo "Set peering port (default: $ca"$VAR_DEFAULT"$xx):"; echo "Press [Enter] to use default value:"; else echo "Set peering port (config: $ca""$VAR_IOTA_WASP_PEERING_PORT""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_IOTA_WASP_PEERING_PORT=$VAR_TMP; elif [ -z "$VAR_IOTA_WASP_PEERING_PORT" ]; then VAR_IOTA_WASP_PEERING_PORT=$VAR_DEFAULT; fi
		echo "$gn""Set peering port: $VAR_IOTA_WASP_PEERING_PORT""$xx"

		echo ''
		VAR_IOTA_WASP_NANO_MSG_PORT=$(cat .env 2>/dev/null | grep WASP_NANO_MSG_PORT= | cut -d '=' -f 2)
		VAR_DEFAULT='5550';
		if [ -z "$VAR_IOTA_WASP_NANO_MSG_PORT" ]; then
		  echo "Set nano-msg-port (default: $ca"$VAR_DEFAULT"$xx):"; echo "Press [Enter] to use default value:"; else echo "Set nano-msg-port (config: $ca""$VAR_IOTA_WASP_NANO_MSG_PORT""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_IOTA_WASP_NANO_MSG_PORT=$VAR_TMP; elif [ -z "$VAR_IOTA_WASP_NANO_MSG_PORT" ]; then VAR_IOTA_WASP_NANO_MSG_PORT=$VAR_DEFAULT; fi
		echo "$gn""Set nano-msg-port: $VAR_IOTA_WASP_NANO_MSG_PORT""$xx"

		echo ''
		VAR_IOTA_WASP_LEDGER_CONNECTION=$(cat .env 2>/dev/null | grep WASP_LEDGER_CONNECTION= | cut -d '=' -f 2)
		VAR_DEFAULT='127.0.0.1:5000';
		if [ -z "$VAR_IOTA_WASP_LEDGER_CONNECTION" ]; then
		  echo "Set ledger-connection/txstream (default: $ca"$VAR_DEFAULT"$xx):"; echo "Press [Enter] to use default value:"; else echo "Set ledger-connection/txstream (config: $ca""$VAR_IOTA_WASP_LEDGER_CONNECTION""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_IOTA_WASP_LEDGER_CONNECTION=$VAR_TMP; elif [ -z "$VAR_IOTA_WASP_LEDGER_CONNECTION" ]; then VAR_IOTA_WASP_LEDGER_CONNECTION=$VAR_DEFAULT; fi
		echo "$gn""Set ledger-connection/txstream: $VAR_IOTA_WASP_LEDGER_CONNECTION""$xx"

		echo ''
		VAR_USERNAME=$(cat .env 2>/dev/null | grep DASHBOARD_USERNAME= | cut -d '=' -f 2)
		VAR_DEFAULT=$(cat /dev/urandom | tr -dc '[:alpha:]' | fold -w ${1:-10} | head -n 1);
		if [ -z "$VAR_USERNAME" ]; then
		echo "Set dashboard username (generated: $ca"$VAR_DEFAULT"$xx):"; echo "to use generated value press [ENTER]:"; else echo "Set dashboard username (config: $ca""$VAR_USERNAME""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_USERNAME=$VAR_TMP; elif [ -z "$VAR_USERNAME" ]; then VAR_USERNAME=$VAR_DEFAULT; fi
		echo "$gn""Set dashboard username: $VAR_USERNAME""$xx"

		echo ''
		VAR_DASHBOARD_PASSWORD=$(cat .env 2>/dev/null | grep DASHBOARD_PASSWORD= | cut -d '=' -f 2)
		VAR_DEFAULT=$(cat /dev/urandom | tr -dc '[:alpha:]' | fold -w ${1:-20} | head -n 1);
		if [ -z "$VAR_DASHBOARD_PASSWORD" ]; then
		echo "Set dashboard password / will be saved as hash ($ca""use generated""$xx):"; echo "to use generated value press [ENTER]:"; else echo "Set dashboard password / will be saved as hash (config: $ca""use existing""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then
		  VAR_PASSWORD=$VAR_TMP
		  echo "$gn""Set dashboard password: new""$xx"
		else
		  if [ -z "$VAR_DASHBOARD_PASSWORD" ]; then
		    VAR_PASSWORD=$VAR_DEFAULT
		    echo "$gn""Set dashboard password: "$VAR_DEFAULT"$xx"
		  else
		    VAR_PASSWORD=''
		    echo "$gn""Set dashboard password: use existing""$xx"
		  fi
		fi	

		echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"
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
			while [ -z "$VAR_ACME_EMAIL" ]; do
				read -r -p 'Set mail for certificat renewal (e.g. info@dlt.green): ' VAR_ACME_EMAIL
			done
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
		VAR_HOST=$(cat .env 2>/dev/null | grep _HOST | cut -d '=' -f 2)
	fi

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"

	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                                 Pull Data                                   ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	docker compose pull

	if [ $VAR_CONF_RESET = 1 ]; then

		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                               Set Creditials                                ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		if [ -n "$VAR_PASSWORD" ]; then
		  VAR_DASHBOARD_PASSWORD=$VAR_PASSWORD
		fi

		echo "DASHBOARD_USERNAME=$VAR_USERNAME" >> .env
		echo "DASHBOARD_PASSWORD=$VAR_DASHBOARD_PASSWORD" >> .env
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

	docker compose up -d

	sleep 3

	RenameContainer

	echo ""
	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"

	if [ -s "/var/lib/$VAR_DIR/data/letsencrypt/acme.json" ]; then SetCertificateGlobal; fi

	clear
	echo ""

	if [ $VAR_CONF_RESET = 1 ]; then

	    echo "--------------------------- INSTALLATION IS FINISH ----------------------------"
	    echo ""
		echo "═══════════════════════════════════════════════════════════════════════════════"
		echo " IOTA-Wasp Dashboard: https://$VAR_HOST:$VAR_IOTA_WASP_HTTPS_PORT"
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

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"

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

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"
	if [ "$VAR_NETWORK" = 2 ]; then VAR_NETWORK=1; SubMenuMaintenance; fi

	echo "Stopping Node... $VAR_DIR"
	if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; if [ -f "/var/lib/$VAR_DIR/docker-compose.yml" ]; then docker compose down >/dev/null 2>&1; fi; fi

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

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"

	CheckConfiguration

	if [ $VAR_CONF_RESET = 1 ]; then

		clear
		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                               Set Parameters                                ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		VAR_HOST=$(cat .env 2>/dev/null | grep GOSHIMMER_HOST= | cut -d '=' -f 2)
		if [ -z "$VAR_HOST" ]; then
		  VAR_HOST=$(echo $VAR_DOMAIN | xargs)
		  if [ -n "$VAR_HOST" ]; then
		    echo "Set domain name (global: $ca""$VAR_HOST""$xx):"; echo "Press [Enter] to use global domain:"
		  else
			echo "Set domain name (example: $ca""vrom.dlt.green""$xx):";
		  fi
		else echo "Set domain name (config: $ca""$VAR_HOST""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_HOST=$VAR_TMP; fi
		CheckDomain "$VAR_HOST"

		echo ''
		VAR_IOTA_GOSHIMMER_HTTPS_PORT=$(cat .env 2>/dev/null >/dev/null 2>&1 | grep GOSHIMMER_HTTPS_PORT= | cut -d '=' -f 2)
		VAR_DEFAULT='446';
		if [ -z "$VAR_IOTA_GOSHIMMER_HTTPS_PORT" ]; then
		  echo "Set dashboard port (default: $ca"$VAR_DEFAULT"$xx):"; echo "Press [Enter] to use default value:"; else echo "Set dashboard port (config: $ca""$VAR_IOTA_GOSHIMMER_HTTPS_PORT""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_IOTA_GOSHIMMER_HTTPS_PORT=$VAR_TMP;  elif [ -z "$VAR_IOTA_GOSHIMMER_HTTPS_PORT" ]; then VAR_IOTA_GOSHIMMER_HTTPS_PORT=$VAR_DEFAULT; fi
		echo "$gn""Set dashboard port: $VAR_IOTA_GOSHIMMER_HTTPS_PORT""$xx"

		echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"
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
			while [ -z "$VAR_ACME_EMAIL" ]; do
				read -r -p 'Set mail for certificat renewal (e.g. info@dlt.green): ' VAR_ACME_EMAIL
			done
			echo "ACME_EMAIL=$VAR_ACME_EMAIL" >> .env
		else
			echo "GOSHIMMER_HTTP_PORT=8083" >> .env
			echo "SSL_CONFIG=certs" >> .env
			echo "GOSHIMMER_SSL_CERT=/etc/letsencrypt/live/$VAR_HOST/fullchain.pem" >> .env
			echo "GOSHIMMER_SSL_KEY=/etc/letsencrypt/live/$VAR_HOST/privkey.pem" >> .env
		fi
	else
		if [ -f .env ]; then sed -i "s/GOSHIMMER_VERSION=.*/GOSHIMMER_VERSION=$VAR_IOTA_GOSHIMMER_VERSION/g" .env; fi

		VAR_HOST=$(cat .env 2>/dev/null | grep _HOST | cut -d '=' -f 2)
	fi

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"

	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                                 Pull Data                                   ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	docker compose pull

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

	docker compose up -d

	sleep 3

	RenameContainer

	echo ""
	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"

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

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"

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

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"
	if [ "$VAR_NETWORK" = 1 ]; then VAR_NETWORK=2; SubMenuMaintenance; fi

	echo "Stopping Node... $VAR_DIR"
	if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; if [ -f "/var/lib/$VAR_DIR/docker-compose.yml" ]; then docker compose down >/dev/null 2>&1; fi; fi

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

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"

	CheckConfiguration

	VAR_SALT=$(cat /dev/urandom | tr -dc '[:alpha:]' | fold -w ${1:-20} | head -n 1)

	if [ $VAR_CONF_RESET = 1 ]; then

		clear
		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                               Set Parameters                                ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		VAR_HOST=$(cat .env 2>/dev/null | grep HORNET_HOST= | cut -d '=' -f 2)
		if [ -z "$VAR_HOST" ]; then
		  VAR_HOST=$(echo $VAR_DOMAIN | xargs)
		  if [ -n "$VAR_HOST" ]; then
		    echo "Set domain name (global: $ca""$VAR_HOST""$xx):"; echo "Press [Enter] to use global domain:"
		  else
			echo "Set domain name (example: $ca""vrom.dlt.builders""$xx):";
		  fi
		else echo "Set domain name (config: $ca""$VAR_HOST""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_HOST=$VAR_TMP; fi
		CheckDomain "$VAR_HOST"

		echo ''
		VAR_SHIMMER_HORNET_HTTPS_PORT=$(cat .env 2>/dev/null | grep HORNET_HTTPS_PORT= | cut -d '=' -f 2)
		VAR_DEFAULT='443';
		if [ -z "$VAR_SHIMMER_HORNET_HTTPS_PORT" ]; then
		  echo "Set dashboard port (default: $ca"$VAR_DEFAULT"$xx):"; echo "Press [Enter] to use default value:"; else echo "Set dashboard port (config: $ca""$VAR_SHIMMER_HORNET_HTTPS_PORT""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_SHIMMER_HORNET_HTTPS_PORT=$VAR_TMP; elif [ -z "$VAR_SHIMMER_HORNET_HTTPS_PORT" ]; then VAR_SHIMMER_HORNET_HTTPS_PORT=$VAR_DEFAULT; fi
		echo "$gn""Set dashboard port: $VAR_SHIMMER_HORNET_HTTPS_PORT""$xx"

		echo ''
		while [ -z "$VAR_SHIMMER_HORNET_PRUNING_SIZE" ]; do
		  VAR_SHIMMER_HORNET_PRUNING_SIZE=$(cat .env 2>/dev/null | grep HORNET_PRUNING_TARGET_SIZE= | cut -d '=' -f 2)
		  if [ -z "$VAR_SHIMMER_HORNET_PRUNING_SIZE" ]; then
		    echo "Set pruning size / max. database size (example: $ca""200GB""$xx):"; else echo "Set pruning size / max. database size (config: $ca""$VAR_SHIMMER_HORNET_PRUNING_SIZE""$xx)"; echo "Press [Enter] to use existing config:"; fi
		  echo "$rd""Available Diskspace: $(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 4)B/$(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 2)B ($(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 5) used) ""$xx"
		  read -r -p '> ' VAR_TMP
		  if [ -n "$VAR_TMP" ]; then VAR_SHIMMER_HORNET_PRUNING_SIZE=$VAR_TMP; fi
		  if ! [ -z "${VAR_SHIMMER_HORNET_PRUNING_SIZE##*B*}" ]; then
		    VAR_SHIMMER_HORNET_PRUNING_SIZE=''
		    echo "$rd""Set pruning size: Please insert with unit!"; echo "$xx"
		  fi
		done
		echo "$gn""Set pruning size: $VAR_SHIMMER_HORNET_PRUNING_SIZE""$xx"

		echo ''
		VAR_SHIMMER_HORNET_POW=$(cat .env 2>/dev/null | grep HORNET_POW_ENABLED= | cut -d '=' -f 2)
		VAR_DEFAULT='true';
		if [ -z "$VAR_SHIMMER_HORNET_POW" ]; then
		  echo "Set PoW / proof of work (default: $ca"$VAR_DEFAULT"$xx):"; echo "Press [Enter] to use default value:"; else echo "Set PoW / proof of work (config: $ca""$VAR_SHIMMER_HORNET_POW""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> Press [P] to enable Proof of Work... Press [X] key to disable... ' VAR_TMP;
		if [ -n "$VAR_TMP" ]; then
		  VAR_SHIMMER_HORNET_POW=$VAR_TMP
		  if  [ "$VAR_SHIMMER_HORNET_POW" = 'p' ] || [ "$VAR_SHIMMER_HORNET_POW" = 'P' ]; then 
		    VAR_SHIMMER_HORNET_POW='true'
		  else
		    VAR_SHIMMER_HORNET_POW='false'
		  fi
		elif [ -z "$VAR_SHIMMER_HORNET_POW" ]; then VAR_SHIMMER_HORNET_POW=$VAR_DEFAULT; fi

		if  [ "$VAR_SHIMMER_HORNET_POW" ]; then
		  echo "$gn""Set PoW / proof of work: $VAR_SHIMMER_HORNET_POW""$xx"
		else
		  echo "$rd""Set PoW / proof of work: $VAR_SHIMMER_HORNET_POW""$xx"		
		fi

		echo ''
		VAR_USERNAME=$(cat .env 2>/dev/null | grep DASHBOARD_USERNAME= | cut -d '=' -f 2)
		VAR_DEFAULT=$(cat /dev/urandom | tr -dc '[:alpha:]' | fold -w ${1:-10} | head -n 1);
		if [ -z "$VAR_USERNAME" ]; then
		echo "Set dashboard username (generated: $ca"$VAR_DEFAULT"$xx):"; echo "to use generated value press [ENTER]:"; else echo "Set dashboard username (config: $ca""$VAR_USERNAME""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_USERNAME=$VAR_TMP; elif [ -z "$VAR_USERNAME" ]; then VAR_USERNAME=$VAR_DEFAULT; fi
		echo "$gn""Set dashboard username: $VAR_USERNAME""$xx"

		echo ''
		VAR_DASHBOARD_PASSWORD=$(cat .env 2>/dev/null | grep DASHBOARD_PASSWORD= | cut -d '=' -f 2)
		VAR_DASHBOARD_SALT=$(cat .env 2>/dev/null | grep DASHBOARD_SALT= | cut -d '=' -f 2)
		VAR_DEFAULT=$(cat /dev/urandom | tr -dc '[:alpha:]' | fold -w ${1:-20} | head -n 1);
		if [ -z "$VAR_DASHBOARD_PASSWORD" ]; then
		echo "Set dashboard password / will be saved as hash ($ca""use generated""$xx):"; echo "to use generated value press [ENTER]:"; else echo "Set dashboard password / will be saved as hash (config: $ca""use existing""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then
		  VAR_PASSWORD=$VAR_TMP
		  echo "$gn""Set dashboard password: new""$xx"
		else
		  if [ -z "$VAR_DASHBOARD_PASSWORD" ]; then
		    VAR_PASSWORD=$VAR_DEFAULT
		    echo "$gn""Set dashboard password: "$VAR_DEFAULT"$xx"
		  else
		    VAR_PASSWORD=''
		    echo "$gn""Set dashboard password: use existing""$xx"
		  fi
		fi

		echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"
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
		echo "RESTAPI_SALT=$VAR_SALT" >> .env

		if [ $VAR_CERT = 0 ]
		then
			echo "HORNET_HTTP_PORT=80" >> .env
			while [ -z "$VAR_ACME_EMAIL" ]; do
				read -r -p 'Set mail for certificat renewal (e.g. info@dlt.green): ' VAR_ACME_EMAIL
			done
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

		VAR_HOST=$(cat .env 2>/dev/null | grep _HOST | cut -d '=' -f 2)
		fgrep -q "RESTAPI_SALT" .env || echo "RESTAPI_SALT=$VAR_SALT" >> .env
	fi

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"

	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                                 Pull Data                                   ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	docker network create shimmer >/dev/null 2>&1
	docker compose pull

	if [ $VAR_CONF_RESET = 1 ]; then

		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                               Set Creditials                                ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		if [ -n "$VAR_PASSWORD" ]; then
		  credentials=$(docker compose run --rm hornet tool pwd-hash --json --password "$VAR_PASSWORD" | sed -e 's/\r//g')
		  VAR_DASHBOARD_PASSWORD=$(echo "$credentials" | jq -r '.passwordHash')
		  VAR_DASHBOARD_SALT=$(echo "$credentials" | jq -r '.passwordSalt')
		fi
		
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

	docker compose up -d

	sleep 3

	RenameContainer

	if [ -n "$VAR_PASSWORD" ]; then
	  if [ $VAR_CONF_RESET = 1 ]; then docker exec -it grafana grafana-cli admin reset-admin-password "$VAR_PASSWORD"; fi
	fi

	echo ""
	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"

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

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"

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

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"
	if [ "$VAR_NETWORK" = 1 ]; then VAR_NETWORK=2; SubMenuMaintenance; fi

	echo "Stopping Node... $VAR_DIR"
	if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; if [ -f "/var/lib/$VAR_DIR/docker-compose.yml" ]; then docker compose down >/dev/null 2>&1; fi; fi

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

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"

	CheckConfiguration

	VAR_WASP_LEDGER_NETWORK='shimmer'

	if [ $VAR_CONF_RESET = 1 ]; then

		clear
		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                               Set Parameters                                ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		VAR_HOST=$(cat .env 2>/dev/null | grep WASP_HOST= | cut -d '=' -f 2)
		if [ -z "$VAR_HOST" ]; then
		  VAR_HOST=$(echo $VAR_DOMAIN | xargs)
		  if [ -n "$VAR_HOST" ]; then
		    echo "Set domain name (global: $ca""$VAR_HOST""$xx):"; echo "Press [Enter] to use global domain:"
		  else
			echo "Set domain name (example: $ca""vrom.dlt.builders""$xx):";
		  fi
		else echo "Set domain name (config: $ca""$VAR_HOST""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_HOST=$VAR_TMP; fi
		CheckDomain "$VAR_HOST"

		echo ''
		VAR_SHIMMER_WASP_HTTPS_PORT=$(cat .env 2>/dev/null | grep WASP_HTTPS_PORT= | cut -d '=' -f 2)
		VAR_DEFAULT='447';
		if [ -z "$VAR_SHIMMER_WASP_HTTPS_PORT" ]; then
		  echo "Set dashboard port (default: $ca"$VAR_DEFAULT"$xx):"; echo "Press [Enter] to use default value:"; else echo "Set dashboard port (config: $ca""$VAR_SHIMMER_WASP_HTTPS_PORT""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_SHIMMER_WASP_HTTPS_PORT=$VAR_TMP; elif [ -z "$VAR_SHIMMER_WASP_HTTPS_PORT" ]; then VAR_SHIMMER_WASP_HTTPS_PORT=$VAR_DEFAULT; fi
		echo "$gn""Set dashboard port: $VAR_SHIMMER_WASP_HTTPS_PORT""$xx"

		echo ''
		VAR_SHIMMER_WASP_API_PORT=$(cat .env 2>/dev/null | grep WASP_API_PORT= | cut -d '=' -f 2)
		VAR_DEFAULT='448';
		if [ -z "$VAR_SHIMMER_WASP_API_PORT" ]; then
		  echo "Set api port (default: $ca"$VAR_DEFAULT"$xx):"; echo "Press [Enter] to use default value:"; else echo "Set api port (config: $ca""$VAR_SHIMMER_WASP_API_PORT""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_SHIMMER_WASP_API_PORT=$VAR_TMP; elif [ -z "$VAR_SHIMMER_WASP_API_PORT" ]; then VAR_SHIMMER_WASP_API_PORT=$VAR_DEFAULT; fi
		echo "$gn""Set api port: $VAR_SHIMMER_WASP_API_PORT""$xx"

		echo ''
		VAR_SHIMMER_WASP_PEERING_PORT=$(cat .env 2>/dev/null | grep WASP_PEERING_PORT= | cut -d '=' -f 2)
		VAR_DEFAULT='4000';
		if [ -z "$VAR_SHIMMER_WASP_PEERING_PORT" ]; then
		  echo "Set peering port (default: $ca"$VAR_DEFAULT"$xx):"; echo "Press [Enter] to use default value:"; else echo "Set peering port (config: $ca""$VAR_SHIMMER_WASP_PEERING_PORT""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_SHIMMER_WASP_PEERING_PORT=$VAR_TMP; elif [ -z "$VAR_SHIMMER_WASP_PEERING_PORT" ]; then VAR_SHIMMER_WASP_PEERING_PORT=$VAR_DEFAULT; fi
		echo "$gn""Set peering port: $VAR_SHIMMER_WASP_PEERING_PORT""$xx"

		echo ''
		VAR_SHIMMER_WASP_NANO_MSG_PORT=$(cat .env 2>/dev/null | grep WASP_NANO_MSG_PORT= | cut -d '=' -f 2)
		VAR_DEFAULT='5550';
		if [ -z "$VAR_SHIMMER_WASP_NANO_MSG_PORT" ]; then
		  echo "Set nano-msg-port (default: $ca"$VAR_DEFAULT"$xx):"; echo "Press [Enter] to use default value:"; else echo "Set nano-msg-port (config: $ca""$VAR_SHIMMER_WASP_NANO_MSG_PORT""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_SHIMMER_WASP_NANO_MSG_PORT=$VAR_TMP; elif [ -z "$VAR_SHIMMER_WASP_NANO_MSG_PORT" ]; then VAR_SHIMMER_WASP_NANO_MSG_PORT=$VAR_DEFAULT; fi
		echo "$gn""Set nano-msg-port: $VAR_SHIMMER_WASP_NANO_MSG_PORT""$xx"

		echo ''
		VAR_USERNAME=$(cat .env 2>/dev/null | grep DASHBOARD_USERNAME= | cut -d '=' -f 2)
		VAR_DEFAULT=$(cat /dev/urandom | tr -dc '[:alpha:]' | fold -w ${1:-10} | head -n 1 | tr '[:upper:]' '[:lower:]');
		if [ -z "$VAR_USERNAME" ]; then
		echo "Set dashboard username (generated: $ca"$VAR_DEFAULT"$xx):"; echo "to use generated value press [ENTER]:"; else echo "Set dashboard username (config: $ca""$VAR_USERNAME""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_USERNAME=$VAR_TMP; elif [ -z "$VAR_USERNAME" ]; then VAR_USERNAME=$VAR_DEFAULT; fi
		echo "$gn""Set dashboard username: $VAR_USERNAME""$xx"

		echo ''
		VAR_DASHBOARD_PASSWORD=$(cat .env 2>/dev/null | grep DASHBOARD_PASSWORD= | cut -d '=' -f 2)
		VAR_DASHBOARD_SALT=$(cat .env 2>/dev/null | grep DASHBOARD_SALT= | cut -d '=' -f 2)
		VAR_DEFAULT=$(cat /dev/urandom | tr -dc '[:alpha:]' | fold -w ${1:-20} | head -n 1);
		if [ -z "$VAR_DASHBOARD_PASSWORD" ]; then
		echo "Set dashboard password / will be saved as hash ($ca""use generated""$xx):"; echo "to use generated value press [ENTER]:"; else echo "Set dashboard password / will be saved as hash (config: $ca""use existing""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then
		  VAR_PASSWORD=$VAR_TMP
		  echo "$gn""Set dashboard password: new""$xx"
		else
		  if [ -z "$VAR_DASHBOARD_PASSWORD" ]; then
		    VAR_PASSWORD=$VAR_DEFAULT
		    echo "$gn""Set dashboard password: "$VAR_DEFAULT"$xx"
		  else
		    VAR_PASSWORD=''
		    echo "$gn""Set dashboard password: use existing""$xx"
		  fi
		fi

		echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"
		CheckCertificate

		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                              Write Parameters                               ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; fi
		if [ -f .env ]; then rm .env; fi

		echo "WASP_VERSION=$VAR_SHIMMER_WASP_VERSION" >> .env
		echo "WASP_CLI_VERSION=$VAR_SHIMMER_WASP_CLI_VERSION" >> .env
		echo "WASP_HOST=$VAR_HOST" >> .env
		echo "WASP_HTTPS_PORT=$VAR_SHIMMER_WASP_HTTPS_PORT" >> .env
		echo "WASP_API_PORT=$VAR_SHIMMER_WASP_API_PORT" >> .env
		echo "WASP_PEERING_PORT=$VAR_SHIMMER_WASP_PEERING_PORT" >> .env
		echo "WASP_NANO_MSG_PORT=$VAR_SHIMMER_WASP_NANO_MSG_PORT" >> .env
		echo "WASP_LEDGER_NETWORK=$VAR_WASP_LEDGER_NETWORK" >> .env

		if [ $VAR_CERT = 0 ]
		then
			echo "WASP_HTTP_PORT=80" >> .env
			while [ -z "$VAR_ACME_EMAIL" ]; do
				read -r -p 'Set mail for certificat renewal (e.g. info@dlt.green): ' VAR_ACME_EMAIL
			done
			echo "ACME_EMAIL=$VAR_ACME_EMAIL" >> .env
		else
			echo "WASP_HTTP_PORT=8087" >> .env
			echo "SSL_CONFIG=certs" >> .env
			echo "WASP_SSL_CERT=/etc/letsencrypt/live/$VAR_HOST/fullchain.pem" >> .env
			echo "WASP_SSL_KEY=/etc/letsencrypt/live/$VAR_HOST/privkey.pem" >> .env
		fi
	else
		if [ -f .env ]; then sed -i "s/WASP_VERSION=.*/WASP_VERSION=$VAR_SHIMMER_WASP_VERSION/g" .env; fi
		VAR_HOST=$(cat .env 2>/dev/null | grep _HOST | cut -d '=' -f 2)
		VAR_SALT=$(cat .env 2>/dev/null | grep DASHBOARD_SALT | cut -d '=' -f 2)
		VAR_CLI=$(cat .env 2>/dev/null | grep WASP_CLI_VERSION | cut -d '=' -f 2)

		if [ -z "$VAR_CLI" ]; then
		    echo "WASP_CLI_VERSION=$VAR_SHIMMER_WASP_CLI_VERSION" >> .env
		fi

		if [ -f .env ]; then sed -i "s/WASP_CLI_VERSION=.*/WASP_CLI_VERSION=$VAR_SHIMMER_WASP_CLI_VERSION/g" .env; fi

		if [ -z "$VAR_SALT" ]; then
		    VAR_PASSWORD=$(cat .env 2>/dev/null | grep DASHBOARD_PASSWORD | cut -d '=' -f 2)

			if [ -d /var/lib/shimmer-hornet ]; then cd /var/lib/shimmer-hornet || VAR_PASSWORD=''; fi
			if [ -n "$VAR_PASSWORD" ]; then
			    credentials=$(docker compose run --rm hornet tool pwd-hash --json --password "$VAR_PASSWORD" | sed -e 's/\r//g')

			    VAR_DASHBOARD_PASSWORD=$(echo "$credentials" | jq -r '.passwordHash')
			    VAR_DASHBOARD_SALT=$(echo "$credentials" | jq -r '.passwordSalt')

			    if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; fi
				
			    if [ -f .env ]; then sed -i "s/DASHBOARD_PASSWORD=.*/DASHBOARD_PASSWORD=$VAR_DASHBOARD_PASSWORD/g" .env; fi
			    echo "DASHBOARD_SALT=$VAR_DASHBOARD_SALT" >> .env

			fi
			if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; fi
		fi
	fi

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"

	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                                 Pull Data                                   ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	docker network create shimmer >/dev/null 2>&1
	docker compose pull

	if [ $VAR_CONF_RESET = 1 ]; then

		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                               Set Creditials                                ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		if [ -n "$VAR_PASSWORD" ]; then
		  if [ -d /var/lib/shimmer-hornet ]; then cd /var/lib/shimmer-hornet || VAR_PASSWORD=''; fi
		  credentials=$(docker compose run --rm hornet tool pwd-hash --json --password "$VAR_PASSWORD" | sed -e 's/\r//g')
		  VAR_DASHBOARD_PASSWORD=$(echo "$credentials" | jq -r '.passwordHash')
		  VAR_DASHBOARD_SALT=$(echo "$credentials" | jq -r '.passwordSalt')
		  if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; fi
		fi

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

	docker compose up -d

	sleep 3

	RenameContainer

	echo ""
	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"

	if [ -s "/var/lib/$VAR_DIR/data/letsencrypt/acme.json" ]; then SetCertificateGlobal; fi

	clear
	echo ""

	if [ $VAR_CONF_RESET = 1 ]; then

	    echo "--------------------------- INSTALLATION IS FINISH ----------------------------"
	    echo ""
		echo "═══════════════════════════════════════════════════════════════════════════════"
		echo " SHIMMER-Wasp Dashboard: https://$VAR_HOST:$VAR_SHIMMER_WASP_HTTPS_PORT"
		echo " SHIMMER-Wasp Dashboard Username: $VAR_USERNAME"
		echo " SHIMMER-Wasp Dashboard Password: <set during install>"
		echo " SHIMMER-Wasp API: https://$VAR_HOST:$VAR_SHIMMER_WASP_API_PORT/info"
		echo " SHIMMER-Wasp peering: $VAR_HOST:$VAR_SHIMMER_WASP_PEERING_PORT"
		echo " SHIMMER-Wasp nano-msg: $VAR_HOST:$VAR_SHIMMER_WASP_NANO_MSG_PORT"
		echo " SHIMMER-Wasp ledger-connection/txstream: local to Shimmer-Hornet"
		echo "═══════════════════════════════════════════════════════════════════════════════"
	else
	    echo "------------------------------ UPDATE IS FINISH - -----------------------------"
	fi
	echo ""

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"

	SubMenuMaintenance
}

Pipe() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║              DLT.GREEN AUTOMATIC PIPE INSTALLATION WITH DOCKER              ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo "$ca"

	docker login

	if grep -q 'auths": {}' ~/.docker/config.json ; then 
		echo "$xx""$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"
		Dashboard
	fi

	echo "$xx""$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║              DLT.GREEN AUTOMATIC PIPE INSTALLATION WITH DOCKER              ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	echo "Stopping Node... $VAR_DIR"
	if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; if [ -f "/var/lib/$VAR_DIR/docker-compose.yml" ]; then docker compose down >/dev/null 2>&1; fi; fi

	echo ""
	echo "Check Directory... /var/lib/$VAR_DIR"

	if [ ! -d /var/lib/$VAR_DIR ]; then mkdir /var/lib/$VAR_DIR || exit; fi
	cd /var/lib/$VAR_DIR || exit

	echo ""
	echo "CleanUp Directory... /var/lib/$VAR_DIR"

	find . -maxdepth 1 -mindepth 1 ! \( -name ".env" -o -name "data" \) -exec rm -rf {} +

	echo ""
	echo "Download Package... install.tar.gz"
	wget -cO - "$PipePackage" -q > install.tar.gz

	if [ "$(shasum -a 256 './install.tar.gz' | cut -d ' ' -f 1)" = "$PipeHash" ]; then
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

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"

	CheckConfiguration

	if [ $VAR_CONF_RESET = 1 ]; then

		clear
		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                               Set Parameters                                ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		VAR_PIPE_PORT=$(cat .env 2>/dev/null | grep PIPE_PORT= | cut -d '=' -f 2)
		VAR_DEFAULT='13266';
		if [ -z "$VAR_PIPE_PORT" ]; then
		  echo "Set node port (default: $ca"$VAR_DEFAULT"$xx):"; echo "Press [Enter] to use default value:"; else echo "Set node port (config: $ca""$VAR_PIPE_PORT""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_PIPE_PORT=$VAR_TMP; elif [ -z "$VAR_PIPE_PORT" ]; then VAR_PIPE_PORT=$VAR_DEFAULT; fi
		echo "$gn""Set node port: $VAR_PIPE_PORT""$xx"

		VAR_PIPE_SEED=$(cat .env 2>/dev/null | grep PIPE_SEED | cut -d '=' -f 2)
		VAR_PIPE_ADDRESS=$(cat .env 2>/dev/null | grep PIPE_ADDRESS | cut -d '=' -f 2)
		
		echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"

		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                              Write Parameters                               ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; fi
		if [ -f .env ]; then rm .env; fi

		echo "PIPE_VERSION=$VAR_PIPE_VERSION" >> .env
		echo "PIPE_PORT=$VAR_PIPE_PORT" >> .env

	else
		if [ -f .env ]; then sed -i "s/PIPE_VERSION=.*/PIPE_VERSION=$VAR_PIPE_VERSION/g" .env; fi
	fi

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"

	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                                 Pull Data                                   ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	docker network create pipe >/dev/null 2>&1
	docker compose pull
	docker logout

	if [ $VAR_CONF_RESET = 1 ]; then

		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                               Set Creditials                                ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		if [ -z "$VAR_PIPE_SEED" ]; then
		  credentials=$(docker compose run --rm pipe --action=keygen)
		  VAR_PIPE_SEED=$(echo "$credentials" | grep 'Seed' | cut -d ' ' -f 2 | tr -d '\r')
		  VAR_PIPE_ADDRESS=$(echo "$credentials" | grep 'Address' | cut -d ' ' -f 2 | tr -d '\r')
		fi
		
		echo "PIPE_SEED=$VAR_PIPE_SEED" >> .env
		echo "PIPE_ADDRESS=$VAR_PIPE_ADDRESS" >> .env
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

		echo ufw allow "$VAR_PIPE_PORT/tcp" && ufw allow "$VAR_PIPE_PORT/tcp"
	fi

	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                                 Start PIPE                                  ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || exit; fi

	docker compose up -d

	sleep 3

	RenameContainer

	echo ""
	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"

	clear
	echo ""

	if [ $VAR_CONF_RESET = 1 ]; then

		echo "--------------------------- INSTALLATION IS FINISH ----------------------------"
		echo ""
		echo "═══════════════════════════════════════════════════════════════════════════════"
		echo " PIPE node-port: $VAR_PIPE_PORT"
		echo " PIPE address: $VAR_PIPE_ADDRESS"		
		echo "═══════════════════════════════════════════════════════════════════════════════"
		echo ""
	else
	    echo "------------------------------ UPDATE IS FINISH - -----------------------------"
	fi
	echo ""

	echo "$fl"; read -r -p 'Press [Enter] key to continue... Press [STRG+C] to cancel... ' W; echo "$xx"

	SubMenuMaintenance
}

RenameContainer() {
	docker container rename iota-hornet_hornet_1 iota-hornet >/dev/null 2>&1
	docker container rename iota-hornet_traefik_1 iota-hornet.traefik >/dev/null 2>&1
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
	docker container rename pipe_1 pipe >/dev/null 2>&1
}

clear

PositionVersion "$VRSN"
VAR_VRN=$text

echo ""
echo "╔═════════════════════════════════════════════════════════════════════════════╗"
echo "║ DLT.GREEN           AUTOMATIC NODE-INSTALLER WITH DOCKER $VAR_VRN ║"
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
