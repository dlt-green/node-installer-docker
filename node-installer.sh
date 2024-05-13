#!/bin/sh

VRSN="v.4.4.3"
BUILD="20240510_194950"

VAR_DOMAIN=''
VAR_HOST=''
VAR_DIR=''
VAR_CERT=0
VAR_NETWORK=0
VAR_NODE=0
VAR_CONF_RESET=0

# IOTA-HORNET

VAR_IOTA_HORNET_VERSION='2.0.1'
VAR_IOTA_HORNET_UPDATE=1

VAR_IOTA_INX_INDEXER_VERSION='1.0'
VAR_IOTA_INX_MQTT_VERSION='1.0'
VAR_IOTA_INX_PARTICIPATION_VERSION='1.0'
VAR_IOTA_INX_SPAMMER_VERSION='1.0'
VAR_IOTA_INX_POI_VERSION='1.0'
VAR_IOTA_INX_DASHBOARD_VERSION='1.0'

# IOTA-WASP

VAR_IOTA_WASP_VERSION='1.0.3'
VAR_IOTA_WASP_UPDATE=1

VAR_IOTA_WASP_DASHBOARD_VERSION='0.1.9'
VAR_IOTA_WASP_CLI_VERSION='1.0.3'

VAR_IOTA_EVM_ADDR='iota1pzt3mstq6khgc3tl0mwuzk3eqddkryqnpdxmk4nr25re2466uxwm28qqxu5'

# SHIMMER-HORNET

VAR_SHIMMER_HORNET_VERSION='2.0.1'
VAR_SHIMMER_HORNET_UPDATE=1

VAR_SHIMMER_INX_INDEXER_VERSION='1.0'
VAR_SHIMMER_INX_MQTT_VERSION='1.0'
VAR_SHIMMER_INX_PARTICIPATION_VERSION='1.0'
VAR_SHIMMER_INX_SPAMMER_VERSION='1.0'
VAR_SHIMMER_INX_POI_VERSION='1.0'
VAR_SHIMMER_INX_DASHBOARD_VERSION='1.0'

# SHIMMER-WASP

VAR_SHIMMER_WASP_VERSION='1.0.3'
VAR_SHIMMER_WASP_UPDATE=1

VAR_SHIMMER_WASP_DASHBOARD_VERSION='0.1.9'
VAR_SHIMMER_WASP_CLI_VERSION='1.0.3'

VAR_SHIMMER_EVM_ADDR='smr1prxvwqvwf7nru5q5xvh5thwg54zsm2y4wfnk6yk56hj3exxkg92mx20wl3s'

# PLUGINS

VAR_SHIMMER_INX_CHRONICLE_VERSION='1.0.0-rc.4'
VAR_SHIMMER_INX_CHRONICLE_UPDATE=1

VAR_CRON_URL='cd /home && bash -ic "dlt.green'

VAR_CRON_TITLE_1='# DLT.GREEN Node-Installer-Docker: Start all Nodes'
VAR_CRON_TIME_1_1='@reboot sleep '
VAR_CRON_TIME_1_2='60; '
VAR_CRON_JOB_1=' -m s'
VAR_CRON_END_1=' -t 0"'

VAR_CRON_TITLE_2='# DLT.GREEN Node-Installer-Docker: System Maintenance'
VAR_CRON_JOB_2m=' -m 0'
VAR_CRON_JOB_2u=' -m u'
VAR_CRON_END_2=' -t 0 -r 1"'

NODES="iota-hornet iota-wasp shimmer-hornet shimmer-wasp shimmer-plugins/inx-chronicle"

lg='\033[1m'
or='\e[1;33m'
ca='\e[1;96m'
rd='\e[1;91m'
gn='\e[1;92m'
gr='\e[1;90m'
fl='\033[1m'

xx='\033[0m'

opt_time=10
opt_check=1
opt_level='info'

while getopts "m:t:r:c:l:" option
do
  case $option in
     c)
	 case $OPTARG in
	 0|1) opt_check="$OPTARG" ;;
     *) echo "$rd""Invalid Argument for Option -c {0|1}""$xx"
        if [ -f "node-installer.sh" ]; then sudo rm node-installer.sh -f; fi
        exit ;;
	 esac
	 ;;
     m)
	 case $OPTARG in
	 0|1|2|5|6|21|s|u|d) opt_mode="$OPTARG" ;;
     *) echo "$rd""Invalid Argument for Option -m {0|1|2|5|6|21|d|s}""$xx"
        if [ -f "node-installer.sh" ]; then sudo rm node-installer.sh -f; fi
        exit ;;
	 esac
	 ;;
     t)
	 case $OPTARG in
	 0|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20) opt_time="$OPTARG" ;;
     *) echo "$rd""Invalid Argument for Option -t {0-20}""$xx"
        if [ -f "node-installer.sh" ]; then sudo rm node-installer.sh -f; fi
        exit ;;
	 esac
	 ;;
     r)
	 case $OPTARG in
	 0|1) opt_reboot="$OPTARG" ;;
     *) echo "$rd""Invalid Argument for Option -r {0|1}""$xx"
        if [ -f "node-installer.sh" ]; then sudo rm node-installer.sh -f; fi
        exit ;;
	 esac
	 ;;
     l)
	 case $OPTARG in
	 e) opt_level='err!' ;;
	 w) opt_level='warn' ;;
	 i) opt_level='info' ;;
     *) echo "$rd""Invalid Argument for Option -l {i|w|e}""$xx"
        if [ -f "node-installer.sh" ]; then sudo rm node-installer.sh -f; fi
        exit ;;
	 esac
	 ;;
     \?) echo "$rd""Invalid Option""$xx"
        if [ -f "node-installer.sh" ]; then sudo rm node-installer.sh -f; fi
        exit ;;
  esac
done

echo "$xx"

DEBIAN_FRONTEND=noninteractive apt-get install sudo -y -qq >/dev/null 2>&1
DEBIAN_FRONTEND=noninteractive sudo apt-get install curl -y -qq >/dev/null 2>&1

InstallerHash=$(curl -L https://github.com/dlt-green/node-installer-docker/releases/download/$VRSN/checksum.txt) >/dev/null 2>&1

IotaHornetHash='7c2c883715ecb37055828c27a6f22088c97e958ab1a856fadd5af30e3bef30c9'
IotaHornetPackage="https://github.com/dlt-green/node-installer-docker/releases/download/$VRSN/iota-hornet.tar.gz"

IotaWaspHash='59c7bc0806b701c621b0ee1a88676dd6cb372e339186ff96a21cc9d8b271cd2e'
IotaWaspPackage="https://github.com/dlt-green/node-installer-docker/releases/download/$VRSN/iota-wasp.tar.gz"

ShimmerHornetHash='ade74757e453402c979622e618169ba86ff8baf5782af45e70ca13f82ca3df60'
ShimmerHornetPackage="https://github.com/dlt-green/node-installer-docker/releases/download/$VRSN/shimmer-hornet.tar.gz"

ShimmerWaspHash='0419072673e12928acb38a912d56ebaed3058c12f1fc65c7a455b7333a8c7a5d'
ShimmerWaspPackage="https://github.com/dlt-green/node-installer-docker/releases/download/$VRSN/shimmer-wasp.tar.gz"

ShimmerChronicleHash='2bbaa746019e5f75436899d6cac6d3d67996c66ffbce1679afdf48743e78051c'
ShimmerChroniclePackage="https://github.com/dlt-green/node-installer-docker/releases/download/$VRSN/shimmer-chronicle.tar.gz"

if [ "$VRSN" = 'dev-latest' ]; then VRSN=$BUILD; fi

clear
if [ -f "node-installer.sh" ]; then

	fgrep -q "alias dlt.green=" ~/.bash_aliases >/dev/null 2>&1 || (echo "" >> ~/.bash_aliases && echo "# DLT.GREEN Node-Installer-Docker" >> ~/.bash_aliases && echo "alias dlt.green=" >> ~/.bash_aliases)
	if [ -f ~/.bash_aliases ]; then sed -i 's/alias dlt.green=.*/alias dlt.green="sudo wget https:\/\/github.com\/dlt-green\/node-installer-docker\/releases\/latest\/download\/node-installer.sh \&\& sudo sh node-installer.sh"/g' ~/.bash_aliases; fi
	if [ -z "$(cat ~/.bashrc | grep bash_aliases)" ]; then echo 'if [ -f ~/.bash_aliases ]; then . ~/.bash_aliases; fi' >> ~/.bashrc; fi

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

CheckDistribution() {
	tmp="$(cat /etc/issue | cut -d ' ' -f 1)"
	case $tmp in
	'Ubuntu') VAR_DISTRIBUTION='Ubuntu' ;;
	'Debian') VAR_DISTRIBUTION='Debian' ;;
	'Siemens') VAR_DISTRIBUTION='Debian' ;;
	*) echo "$rd"; echo "Distribution $tmp is not supported!"; echo "$xx"; exit ;;
	esac
}

CheckIota() {
	if [ -s "/var/lib/iota-hornet/.env" ];    then VAR_NETWORK=1; fi
	if [ -s "/var/lib/iota-wasp/.env" ];      then VAR_NETWORK=1; fi
}

CheckShimmer() {
	if [ -s "/var/lib/shimmer-hornet/.env" ]; then VAR_NETWORK=2; fi
	if [ -s "/var/lib/shimmer-wasp/.env" ];   then VAR_NETWORK=2; fi
}

CheckAutostart() {
	if ! [ "$(crontab -l | grep -v ^'#' | grep "$VAR_CRON_URL" | grep "$VAR_CRON_JOB_1" | grep "$VAR_CRON_TIME_1_1")" ]
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
		echo "║$rd              !!! Autostart for all Nodes not enabled !!!                    $xx║"
		echo "║                                                                             ║"
		echo "║       in the Moment you must restart your Nodes manually after reboot       ║"
		echo "║                                                                             ║"
		echo "║           press [S] to skip, [X] to enable Autostart, [Q] to quit           ║"
		echo "║                                                                             ║"
		echo "║                       GNU General Public License v3.0                       ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""
		echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] for [X]... [P] to pause / [S] to skip"; echo "$xx"

		case $W in
		s|S) ;;
		q|Q) clear; exit ;;
		*) clear
		     echo "$ca"
		     echo 'Enable Autostart for all Nodes...'
		     echo "$xx"
		     sleep 3

		     if [ "$(crontab -l 2>&1 | grep 'no crontab')" ]; then
		        export EDITOR='nano' && echo "# crontab" | crontab -
		     fi

		     if ! [ "$(crontab -l | grep "$VAR_CRON_URL" | grep "$VAR_CRON_JOB_1")" ]; then
		        (echo "$(crontab -l 2>&1 | grep -e '')" && echo "" && echo "$VAR_CRON_TITLE_1" && echo "$VAR_CRON_TIME_1_1""$VAR_CRON_TIME_1_2""$VAR_CRON_URL""$VAR_CRON_JOB_1""$VAR_CRON_END_1") | crontab -
		     fi

		     if [ "$(crontab -l | grep "$VAR_CRON_URL" | grep "$VAR_CRON_JOB_1" | grep "$VAR_CRON_TIME_1_1")" ]; then
		        echo "$gn""Autostart for all Nodes enabled""$xx"
		     fi

			 echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
			 ;;
		esac
	fi
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
		echo "║          press [S] to skip, [X] to enable the Firewall, [Q] to quit         ║"
		echo "║                                                                             ║"
		echo "║                       GNU General Public License v3.0                       ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""
		echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] for [X]... [P] to pause / [S] to skip"; echo "$xx"

		case $W in
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

			 echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
			 echo ufw allow "$VAR_SSH_PORT/tcp" && ufw allow "$VAR_SSH_PORT/tcp"

			 sudo ufw --force enable

			 echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
			 ;;
		esac
	fi
}

DeleteFirewallPort() {
	while true; do n=$(ufw status numbered | grep "$1" | head -n 1 | awk -F"[][]" '{print $2}');[ "$n" != "" ] || break; yes | ufw delete "$n"; done;
}

PromptMessage() {
	WAIT=$(echo "$1"*10 | bc)
	STTY=$(stty -g)
	printf "$2"
	echo ""
	stty intr '^C' -icanon min 0 time "$WAIT" ignbrk -brkint -ixon isig;read -p '> ' W
	stty "$STTY"

	if [ "$W" = 'P' ] || [ "$W" = 'p' ]; then
		echo "$or"
		echo "Action paused by user..."
		echo "$fl"; echo 'Press [Enter] to continue... Press [C] to cancel';read -p '> ' W
	fi

	if [ "$W" = 'C' ] || [ "$W" = 'c' ]; then
		echo "$rd"
		echo "Action canceled by user..."
		sleep 3
		echo "$xx"
		clear
		VAR_NETWORK=0; VAR_NODE=0; VAR_DIR=''
		DashboardHelper
	fi

	echo "$gn"
	echo "Continue..."
	sleep 3
	echo "$xx"
}

NotifyMessage() {
	NotifyLevel="$1"
	NotifyAlias=$(cat ~/.bash_aliases | grep "alias dlt.green-msg" | cut -d '=' -f 2 | cut -d '"' -f 2 2>/dev/null)
	NotifyDomain=$(echo "$2" | tr -d " ")

	send=1

	if [ "$opt_level" = "err!" ]; then
	case $NotifyLevel in
	info) send=0 ;;
	warn) send=0 ;;
	err!) send=1 ;;
	*) send=1 ;;
	esac
	fi

	if [ "$opt_level" = "warn" ]; then
	case $NotifyLevel in
	info) send=0 ;;
	warn) send=1 ;;
	err!) send=1 ;;
	*) send=1 ;;
	esac
	fi

	if [ "$opt_level" = "info" ]; then
	case $NotifyLevel in
	info) send=1 ;;
	warn) send=1 ;;
	err!) send=1 ;;
	*) send=1 ;;
	esac
	fi

	if [ "$send" = 1 ]; then
	if ! [ "$NotifyAlias" ]; then echo "$or""Send notification not enabled...""$xx"; else
		NotifyResult=$($NotifyAlias """$1 | $NotifyDomain | $3""" 2>/dev/null)
		if [ "$NotifyResult" = 'ok' ]; then echo "$gn""Send notification successfully...""$xx"; else echo "$rd""Send notification failed...""$xx"; fi
	fi
	fi
	sleep 3
}

FormatToBytes() {
	unset bytes;
	if [ -n "$1" ]; then
		unit=$(echo "$1" | sed -e 's/[^a-zA-Z_]//g' | tr '[:lower:]' '[:upper:]');
		value=$(echo "$1" | sed -e "s/$unit//g" | sed "s/,/./g");

		case $unit in
		KB) bytes=$(echo "$value*1024" | bc);;
		MB) bytes=$(echo "$value*1024*1024" | bc);;
		GB) bytes=$(echo "$value*1024*1024*1024" | bc);;
		TB) bytes=$(echo "$value*1024*1024*1024*1024" | bc);;
		PB) bytes=$(echo "$value*1024*1024*1024*1024*1024" | bc);;
		*) bytes=$value;;
		esac
	else
		bytes=0;
	fi
}

FormatFromBytes() {
	unset fbytes;
	if [ -n "$1" ]; then
		fbytes=$(echo "$1" | cut -d '.' -f 1);
		fbytes=$(numfmt --to iec --format "%8f" "$fbytes")B;
		fbytes=$(echo "$fbytes" | sed 's/ *$//g' | sed 's/ //g');
	fi
}

CheckDomain() {
	if [ "$(dig +short "$1")" != "$(curl -s 'https://ipinfo.io/ip')" ]
	then
		echo ""
	    echo "$rd""Attention! Verification of your Domain $VAR_HOST failed! Installation aborted!""$xx"
	    echo "$rd""Maybe you entered a wrong Domain or the DNS is not reachable yet?""$xx"
	    echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
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
		echo "║                            X. Use Let's Encrypt Certificate (recommended)   ║"
		echo "║                                                                             ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""
		echo "$gn""You can receive a free Let's Encrypt Certificate for this Node [X]"
		echo "All other Nodes on this Server will automatically use this Certificate""$xx"
		echo "$rd""Alternatively, you can also use your own Certificate [1]""$xx"
		echo ""
		echo "select menu item: "
		echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"

		case $W in
		1) VAR_CERT=1
		   rm -rf /var/lib/"$VAR_DIR"/data/letsencrypt/* ;;
		*) VAR_CERT=0
		   rm -rf /var/lib/"$VAR_DIR"/data/letsencrypt/* ;;
		esac
	else
		echo "$xx""No global Let's Encrypt Certificate found, generate a new one... "
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
		echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] for [X]... Press [P] to pause / [C] to cancel"; echo "$xx"

		case $W in
		1) echo "$rd""Reset Configuration... ""$xx"
		   VAR_CONF_RESET=1 ;;
		*) echo "$ca""Use existing Configuration... ""$xx"
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
	1) VAR_API="api/core/v2/info"; OBJ=".status.isHealthy" ;;
	2) VAR_API="info"; OBJ=".Version" ;;
	3) VAR_API="info"; OBJ=".tangleTime.synced" ;;
	5) VAR_API="api/core/v2/info"; OBJ=".status.isHealthy" ;;
	6) VAR_API="v1/node/version"; OBJ=".version" ;;
	*) ;;
	esac
	VAR_NodeHealthy=$(curl https://"${VAR_DOMAIN}":"${VAR_PORT}"/"${VAR_API}" --http1.1 -m 3 -s -X GET -H 'Content-Type: application/json' | jq "${OBJ}" 2>/dev/null)
	if [ -z "$VAR_NodeHealthy" ]; then VAR_NodeHealthy=false; fi
}

CheckEventsIota() {
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
	if [ -z "$VAR_RESTAPI_SALT" ]; then echo "$rd""IOTA-Hornet: No Salt found!""$xx"
	else
	   echo "Event IDs can be found at:"
	   echo 'https://github.com/iotaledger/participation-events'
	   echo 'https://github.com/iota-community/governance-participation-events'	   
	   echo "Event Data will be saved locally under '/var/lib/iota-hornet/verify-events'"
	   echo ''
	   echo "Set the Event ID for verifying ($ca""keep empty to verify all Events of your Node""$xx):"
	   read -r -p '> ' EVENTS
	   echo ''

	   ADDR=$(cat .env 2>/dev/null | grep HORNET_HOST | cut -d '=' -f 2)':'$(cat .env 2>/dev/null | grep HORNET_HTTPS_PORT | cut -d '=' -f 2)
	   TOKEN=$(docker compose run --rm hornet tool jwt-api --salt "$VAR_RESTAPI_SALT" | awk '{ print $5 }')
	   echo "$ca""Address: ""$xx""$ADDR"" ($ca""JWT-Token for API Access randomly generated""$xx)"
	   echo ''
	   sleep 5

	   if [ -z "$EVENTS" ]; then
	   EVENTS=$(curl https://"${ADDR}"/api/participation/v1/events --http1.1 -s -X GET -H 'Content-Type: application/json' \
	      -H "Authorization: Bearer ${TOKEN}" | jq -r '.eventIds'); fi

	   for EVENT_ID in $(echo "$EVENTS"  | tr -d '"[] ' | sed 's/,/ /g'); do
	      echo "───────────────────────────────────────────────────────────────────────────────"
	      EVENT_NAME=$(curl https://"${ADDR}"/api/participation/v1/events/"${EVENT_ID}" --http1.1 -s -X GET -H 'Content-Type: application/json' \
	      -H "Authorization: Bearer ${TOKEN}" | jq -r '.name')

	      EVENT_SYMBOL=$(curl https://"${ADDR}"/api/participation/v1/events/"${EVENT_ID}" --http1.1 -s -X GET -H 'Content-Type: application/json' \
	      -H "Authorization: Bearer ${TOKEN}" | jq -r '.payload.symbol')

	      EVENT_STATUS=$(curl https://"${ADDR}"/api/participation/v1/events/"${EVENT_ID}"/status --http1.1 -s -X GET -H 'Content-Type: application/json' \
	      -H "Authorization: Bearer ${TOKEN}" | jq -r '.status')

	      EVENT_CHECKSUM=$(curl https://"${ADDR}"/api/participation/v1/events/"${EVENT_ID}"/status --http1.1 -s -X GET -H 'Content-Type: application/json' \
	      -H "Authorization: Bearer ${TOKEN}" | jq -r '.checksum')

	      EVENT_MILESTONE=$(curl https://"${ADDR}"/api/participation/v1/events/"${EVENT_ID}"/status --http1.1 -s -X GET -H 'Content-Type: application/json' \
	      -H "Authorization: Bearer ${TOKEN}" | jq -r '.milestoneIndex')

	      EVENT_QUESTIONS=$(curl https://"${ADDR}"/api/participation/v1/events/"${EVENT_ID}"/status --http1.1 -s -X GET -H 'Content-Type: application/json' \
	      -H "Authorization: Bearer ${TOKEN}" | jq -r '.questions')

	      echo "$ca""Name: ""$xx""$EVENT_NAME"
		  echo "$ca""Status: ""$xx""$EVENT_STATUS""$ca"" Milestone index: ""$xx""$EVENT_MILESTONE"

	      if [ "$EVENT_STATUS" = "ended" ]; then
	        if [ ! -d /var/lib/$VAR_DIR/verify-events ]; then mkdir /var/lib/$VAR_DIR/verify-events || Dashboard; fi
	        cd /var/lib/$VAR_DIR/verify-events || Dashboard
	        $(curl https://"${ADDR}"/api/participation/v1/admin/events/"${EVENT_ID}"/rewards --http1.1 -s -X GET -H 'Content-Type: application/json' \
	        -H "Authorization: Bearer ${TOKEN}" | jq '.data' > "${EVENT_ID}")
	        echo ""
	        echo "$xx""Event ID: ""$EVENT_ID"

	        if [ $(jq '.totalRewards' "${EVENT_ID}") = 'null' ]; then
			  if [ "$EVENT_SYMBOL" = 'null' ]; then
			    echo "$gn""Checksum: ""$EVENT_CHECKSUM""$xx"
				if [ -n "$EVENT_QUESTIONS" ]; then echo "$EVENT_QUESTIONS" > "${EVENT_ID}"; fi
			  else
			    echo "$rd""Checksum: ""Authentication Error!""$xx"
			  fi
	        else
	          echo "$gn""Checksum: ""$(jq -r '.checksum' "${EVENT_ID}")"
	        fi
	        EVENT_REWARDS="$(jq '.totalRewards' "${EVENT_ID}" 2>/dev/null)"
	      else
	        echo ""
	        echo "$xx""Event ID: ""$EVENT_ID"
	        echo "$rd""Checksum: ""Event not found or not over yet!""$xx"
	        EVENT_REWARDS='not available'
	      fi
	      echo ""
	      echo "$ca""Total rewards: ""$xx""$EVENT_REWARDS""$ca"" Symbol: ""$xx""$EVENT_SYMBOL"
	      echo "───────────────────────────────────────────────────────────────────────────────"
	   done
	fi
	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] for [X]... Press [P] to pause / [C] to cancel"; echo "$xx"
	Dashboard
}

CheckEventsShimmer() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║ DLT.GREEN           AUTOMATIC NODE-INSTALLER WITH DOCKER $VAR_VRN ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo "$ca"
	echo "Verify Event Results..."
	echo "$xx"

	VAR_DIR='shimmer-hornet'

	cd /var/lib/$VAR_DIR >/dev/null 2>&1 || Dashboard;

	VAR_RESTAPI_SALT=$(cat .env 2>/dev/null | grep RESTAPI_SALT | cut -d '=' -f 2);
	if [ -z "$VAR_RESTAPI_SALT" ]; then echo "$rd""Shimmer-Hornet: No Salt found!""$xx"
	else
	   echo "Event IDs can be found at:"
	   echo 'https://github.com/iotaledger/participation-events'
	   echo 'https://github.com/iota-community/governance-participation-events'	 
	   echo "Event Data will be saved locally under '/var/lib/shimmer-hornet/verify-events'"
	   echo ''
	   echo "Set the Event ID for verifying ($ca""keep empty to verify all Events of your Node""$xx):"
	   read -r -p '> ' EVENTS
	   echo ''

	   ADDR=$(cat .env 2>/dev/null | grep HORNET_HOST | cut -d '=' -f 2)':'$(cat .env 2>/dev/null | grep HORNET_HTTPS_PORT | cut -d '=' -f 2)
	   TOKEN=$(docker compose run --rm hornet tool jwt-api --salt "$VAR_RESTAPI_SALT" | awk '{ print $5 }')
	   echo "$ca""Address: ""$xx""$ADDR"" ($ca""JWT-Token for API Access randomly generated""$xx)"
	   echo ''
	   sleep 5

	   if [ -z "$EVENTS" ]; then
	   EVENTS=$(curl https://"${ADDR}"/api/participation/v1/events --http1.1 -s -X GET -H 'Content-Type: application/json' \
	      -H "Authorization: Bearer ${TOKEN}" | jq -r '.eventIds'); fi

	   for EVENT_ID in $(echo "$EVENTS"  | tr -d '"[] ' | sed 's/,/ /g'); do
	      echo "───────────────────────────────────────────────────────────────────────────────"
	      EVENT_NAME=$(curl https://"${ADDR}"/api/participation/v1/events/"${EVENT_ID}" --http1.1 -s -X GET -H 'Content-Type: application/json' \
	      -H "Authorization: Bearer ${TOKEN}" | jq -r '.name')

	      EVENT_SYMBOL=$(curl https://"${ADDR}"/api/participation/v1/events/"${EVENT_ID}" --http1.1 -s -X GET -H 'Content-Type: application/json' \
	      -H "Authorization: Bearer ${TOKEN}" | jq -r '.payload.symbol')

	      EVENT_STATUS=$(curl https://"${ADDR}"/api/participation/v1/events/"${EVENT_ID}"/status --http1.1 -s -X GET -H 'Content-Type: application/json' \
	      -H "Authorization: Bearer ${TOKEN}" | jq -r '.status')

	      EVENT_CHECKSUM=$(curl https://"${ADDR}"/api/participation/v1/events/"${EVENT_ID}"/status --http1.1 -s -X GET -H 'Content-Type: application/json' \
	      -H "Authorization: Bearer ${TOKEN}" | jq -r '.checksum')

	      EVENT_MILESTONE=$(curl https://"${ADDR}"/api/participation/v1/events/"${EVENT_ID}"/status --http1.1 -s -X GET -H 'Content-Type: application/json' \
	      -H "Authorization: Bearer ${TOKEN}" | jq -r '.milestoneIndex')

	      EVENT_QUESTIONS=$(curl https://"${ADDR}"/api/participation/v1/events/"${EVENT_ID}"/status --http1.1 -s -X GET -H 'Content-Type: application/json' \
	      -H "Authorization: Bearer ${TOKEN}" | jq -r '.questions')

	      echo "$ca""Name: ""$xx""$EVENT_NAME"
		  echo "$ca""Status: ""$xx""$EVENT_STATUS""$ca"" Milestone index: ""$xx""$EVENT_MILESTONE"

	      if [ "$EVENT_STATUS" = "ended" ]; then
	        if [ ! -d /var/lib/$VAR_DIR/verify-events ]; then mkdir /var/lib/$VAR_DIR/verify-events || Dashboard; fi
	        cd /var/lib/$VAR_DIR/verify-events || Dashboard
	        $(curl https://"${ADDR}"/api/participation/v1/admin/events/"${EVENT_ID}"/rewards --http1.1 -s -X GET -H 'Content-Type: application/json' \
	        -H "Authorization: Bearer ${TOKEN}" | jq '.data' > "${EVENT_ID}")
	        echo ""
	        echo "$xx""Event ID: ""$EVENT_ID"

	        if [ $(jq '.totalRewards' "${EVENT_ID}") = 'null' ]; then
			  if [ "$EVENT_SYMBOL" = 'null' ]; then
			    echo "$gn""Checksum: ""$EVENT_CHECKSUM""$xx"
				if [ -n "$EVENT_QUESTIONS" ]; then echo "$EVENT_QUESTIONS" > "${EVENT_ID}"; fi
			  else
			    echo "$rd""Checksum: ""Authentication Error!""$xx"
			  fi
	        else
	          echo "$gn""Checksum: ""$(jq -r '.checksum' "${EVENT_ID}")"
	        fi
	        EVENT_REWARDS="$(jq '.totalRewards' "${EVENT_ID}" 2>/dev/null)"
	      else
	        echo ""
	        echo "$xx""Event ID: ""$EVENT_ID"
	        echo "$rd""Checksum: ""Event not found or not over yet!""$xx"
	        EVENT_REWARDS='not available'
	      fi
	      echo ""
	      echo "$ca""Total rewards: ""$xx""$EVENT_REWARDS""$ca"" Symbol: ""$xx""$EVENT_SYMBOL"
	      echo "───────────────────────────────────────────────────────────────────────────────"
	   done
	fi
	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] for [X]... Press [P] to pause / [C] to cancel"; echo "$xx"
	Dashboard
}

CheckNodeUpdates() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                       DLT.GREEN AUTOMATIC NODE UPDATE                       ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"

    VAR_NETWORK=0; VAR_NODE=0; VAR_DIR=''

    INST_VRSN_LIST=$(curl https://api.github.com/repos/dlt-green/node-installer-docker/git/refs/tags | jq -r .[].ref | cut -d / -f 3 | tail -10 | sort -r) >/dev/null 2>&1

    for NODE in $NODES; do

      if [ -f "/var/lib/$NODE/.env" ]; then
        if [ -d "/var/lib/$NODE" ]; then
        cd "/var/lib/$NODE" || exit
        if [ -f "/var/lib/$NODE/docker-compose.yml" ]; then
          if [ "$NODE" = 'iota-hornet' ]; then NODE_VRSN_INST=$(cat .env | grep HORNET_VERSION | cut -d = -f 2); NODE_VRSN_LATEST=$VAR_IOTA_HORNET_VERSION; VAR_NODE=1; fi
          if [ "$NODE" = 'iota-wasp' ]; then NODE_VRSN_INST=$(cat .env | grep WASP_VERSION | cut -d = -f 2); NODE_VRSN_LATEST=$VAR_IOTA_WASP_VERSION; VAR_NODE=2; fi
          if [ "$NODE" = 'shimmer-hornet' ]; then NODE_VRSN_INST=$(cat .env | grep HORNET_VERSION | cut -d = -f 2); NODE_VRSN_LATEST=$VAR_SHIMMER_HORNET_VERSION; VAR_NODE=5; fi
          if [ "$NODE" = 'shimmer-wasp' ]; then NODE_VRSN_INST=$(cat .env | grep WASP_VERSION | cut -d = -f 2); NODE_VRSN_LATEST=$VAR_SHIMMER_WASP_VERSION; VAR_NODE=6; fi
          if [ "$NODE" = 'shimmer-plugins/inx-chronicle' ]; then NODE_VRSN_INST=$(cat .env | grep INX_CHRONICLE_VERSION | cut -d = -f 2); NODE_VRSN_LATEST=$VAR_SHIMMER_INX_CHRONICLE_VERSION; VAR_NODE=21; fi

          for INSTALLER_VRSN in $INST_VRSN_LIST; do

            if [ "$NODE" = 'iota-hornet' ]; then
              NODE_VRSN_TMP=$(curl -Ls https://github.com/dlt-green/node-installer-docker/releases/download/"$INSTALLER_VRSN"/node-installer.sh | grep "^VAR_IOTA_HORNET_VERSION" | cut -d = -f 2 | sed "s|'||g") >/dev/null 2>&1
            fi
            if [ "$NODE" = 'iota-wasp' ]; then
              NODE_VRSN_TMP=$(curl -Ls https://github.com/dlt-green/node-installer-docker/releases/download/"$INSTALLER_VRSN"/node-installer.sh | grep "^VAR_IOTA_WASP_VERSION" | cut -d = -f 2 | sed "s|'||g") >/dev/null 2>&1
            fi
            if [ "$NODE" = 'shimmer-hornet' ]; then
              NODE_VRSN_TMP=$(curl -Ls https://github.com/dlt-green/node-installer-docker/releases/download/"$INSTALLER_VRSN"/node-installer.sh | grep "^VAR_SHIMMER_HORNET_VERSION" | cut -d = -f 2 | sed "s|'||g") >/dev/null 2>&1
            fi
            if [ "$NODE" = 'shimmer-wasp' ]; then
              NODE_VRSN_TMP=$(curl -Ls https://github.com/dlt-green/node-installer-docker/releases/download/"$INSTALLER_VRSN"/node-installer.sh | grep "^VAR_SHIMMER_WASP_VERSION" | cut -d = -f 2 | sed "s|'||g") >/dev/null 2>&1
            fi
            if [ "$NODE" = 'shimmer-plugins/inx-chronicle' ]; then
              NODE_VRSN_TMP=$(curl -Ls https://github.com/dlt-green/node-installer-docker/releases/download/"$INSTALLER_VRSN"/node-installer.sh | grep "^VAR_SHIMMER_INX_CHRONICLE_VERSION" | cut -d = -f 2 | sed "s|'||g") >/dev/null 2>&1
            fi
            if [ "$NODE_VRSN_TMP" = "$NODE_VRSN_INST" ]; then NODE_VRSN_LATEST="$NODE_VRSN_TMP"; fi
            if [ "$NODE_VRSN_INST" = "$NODE_VRSN_LATEST" ]; then NodeUpdate "$INSTALLER_VRSN" "$NODE" "$VAR_NODE"; break;  fi

          done
        fi
        fi
      fi
    done

	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
	if ! [ "$opt_mode" ]; then DashboardHelper; fi
}

NodeUpdate() {
    INST_VRSN_LIST_TMP=$(curl https://api.github.com/repos/dlt-green/node-installer-docker/git/refs/tags | jq -r .[].ref | cut -d / -f 3 | tail -10) >/dev/null 2>&1
	upt=0
    for INSTALLER_VRSN_TMP in $INST_VRSN_LIST_TMP; do
      if [ "$upt" -eq 1 ]; then upt=$(echo "($upt+1)" | bc); fi
      if [ "$upt" -eq 2 ]; then

            if [ "$2" = 'iota-hornet' ]; then
              NODE_VRSN_UPDATE=$(curl -Ls https://github.com/dlt-green/node-installer-docker/releases/download/"$INSTALLER_VRSN_TMP"/node-installer.sh | grep "^VAR_IOTA_HORNET_UPDATE" | cut -d = -f 2 | sed "s|'||g") >/dev/null 2>&1
            fi
            if [ "$2" = 'iota-wasp' ]; then
              NODE_VRSN_UPDATE=$(curl -Ls https://github.com/dlt-green/node-installer-docker/releases/download/"$INSTALLER_VRSN_TMP"/node-installer.sh | grep "^VAR_IOTA_WASP_UPDATE" | cut -d = -f 2 | sed "s|'||g") >/dev/null 2>&1
            fi
            if [ "$2" = 'shimmer-hornet' ]; then
              NODE_VRSN_UPDATE=$(curl -Ls https://github.com/dlt-green/node-installer-docker/releases/download/"$INSTALLER_VRSN_TMP"/node-installer.sh | grep "^VAR_SHIMMER_HORNET_UPDATE" | cut -d = -f 2 | sed "s|'||g") >/dev/null 2>&1
            fi
            if [ "$2" = 'shimmer-wasp' ]; then
              NODE_VRSN_UPDATE=$(curl -Ls https://github.com/dlt-green/node-installer-docker/releases/download/"$INSTALLER_VRSN_TMP"/node-installer.sh | grep "^VAR_SHIMMER_WASP_UPDATE" | cut -d = -f 2 | sed "s|'||g") >/dev/null 2>&1
            fi
            if [ "$2" = 'shimmer-plugins/inx-chronicle' ]; then
              NODE_VRSN_UPDATE=$(curl -Ls https://github.com/dlt-green/node-installer-docker/releases/download/"$INSTALLER_VRSN_TMP"/node-installer.sh | grep "^VAR_SHIMMER_INX_CHRONICLE_UPDATE" | cut -d = -f 2 | sed "s|'||g") >/dev/null 2>&1
            fi
            if [ "$NODE_VRSN_UPDATE" = '1' ]; then
              echo "$ca""DLT.GREEN release $INSTALLER_VRSN_TMP: Update $2... (unattended)" "$xx"
              UPDATE=$(cd /home && sudo wget https://github.com/dlt-green/node-installer-docker/releases/download/"$INSTALLER_VRSN_TMP"/node-installer.sh && sh node-installer.sh -m $3 -t 0 -r 0) >/dev/null 2>&1
            else
              echo "$rd""DLT.GREEN release $INSTALLER_VRSN_TMP: Update $2... (attended)" "$xx"
              if [ "$opt_mode" ]; then
                VAR_STATUS="$2: update available (attended)"
                NotifyMessage "warn" "$VAR_DOMAIN" "$VAR_STATUS"
				break;
              fi
            fi
	  fi

      if [ "$INSTALLER_VRSN_TMP" = "$1" ]; then upt=$(echo "($upt+1)" | bc); fi
    done
}

DebugInfo() {
    clear
    echo ""
    echo "$ca""=== System Information ===""$xx"
    echo "Operating System: $(lsb_release -d | cut -f 2)"
    echo "Kernel Version: $(uname -r)"
    echo "Date and Time: $(date)"
    echo "$ca""=== CPU ===""$xx"
    echo "Model: $(grep 'model name' /proc/cpuinfo | head -n 1 | cut -d ':' -f 2 | sed 's/^[ \t]*//')"
    echo "Number of Processor Cores: $(grep -c processor /proc/cpuinfo)"
    echo "$ca""=== Memory ===""$xx"
    echo "Installed RAM: $(free -h | awk '/Mem/{print $2}')"
    echo "$ca""=== Storage ===""$xx"
    df -h --output=size,used,avail / | awk 'NR==2 {printf "Total: %s, Used: %s, Free: %s\n", $1, $2, $3}'
    echo "$ca""=== Docker ===""$xx"
    docker --version
    echo "$ca""=== Nodes/Plugins ===""$xx"
    for NODE in $NODES; do
        if [ -d "/var/lib/$NODE" ]; then
            cd "/var/lib/$NODE" || exit
            if [ -f .env ]; then
                HOST=$(cat .env 2>/dev/null | grep _HOST | cut -d '=' -f 2)
                VAR_STATUS="$(docker inspect "$(echo "$NODE" | sed 's/\//./g')" | jq -r '.[] .State .Health .Status')" 2>/dev/null
                if [ -z "$VAR_STATUS" ]; then VAR_STATUS="error"; fi
                if [ "$VAR_STATUS" = 'healthy' ]; then VAR_STATUS="$gn"$VAR_STATUS"$xx"; else VAR_STATUS="$rd"$VAR_STATUS"$xx"; fi
                echo "$NODE"": $VAR_STATUS"
                echo "$(cat .env 2>/dev/null | grep 'VERSION\|PRUN' | sed 's/\([A-Z]\)/\L\1/g')"
                if [ "$(cat .env 2>/dev/null | grep SSL_CONFIG | cut -d '=' -f 2)" = 'certs' ]; then
                    TMP="certificate: ""global"
                    if [ -d "/etc/letsencrypt/live/$HOST" ]; then cd "/etc/letsencrypt/live/$HOST" || exit; fi
                    if [ -s "fullchain.pem" ]; then TMP=$TMP" | cert [""$gn""ok""$xx""]"; else TMP=$TMP" | cert [""$rd""error""$xx""]"; fi
                    if [ -s "privkey.pem" ]; then TMP=$TMP" | key [""$gn""ok""$xx""]"; else TMP=$TMP" | key [""$rd""error""$xx""]"; fi
                    echo "$TMP"
                    if [ -s "fullchain.pem" ]; then
                        echo "valid until: ""$(openssl x509 -in "fullchain".pem -noout -enddate | cut -d '=' -f 2)"
                    else echo "valid until: ""$rd""error""$xx"; fi
                else
                    TMP="certificate: ""let's encrypt"
                    if [ -d "/var/lib/$NODE/data/letsencrypt" ]; then cd "/var/lib/$NODE/data/letsencrypt" || exit; fi
                    cat acme.json | jq -r '.myresolver .Certificates[]? | select(.domain.main=="'"$HOST"'") | .certificate' | base64 -d > "$HOST.crt"
                    cat acme.json | jq -r '.myresolver .Certificates[]? | select(.domain.main=="'"$HOST"'") | .key' | base64 -d > "$HOST.key"
                    if [ -s "$HOST.crt" ]; then TMP=$TMP" | cert [""$gn""ok""$xx""]"; else TMP=$TMP" | cert [""$rd""error""$xx""]"; fi
                    if [ -s "$HOST.key" ]; then TMP=$TMP" | key [""$gn""ok""$xx""]"; else TMP=$TMP" | key [""$rd""error""$xx""]"; fi
                    echo "$TMP"
                    if [ -s "$HOST.crt" ]; then
                        echo "valid until: ""$(openssl x509 -in "$HOST".crt -noout -enddate | cut -d '=' -f 2)"
                    else echo "valid until: ""$rd""error""$xx"; fi
                fi
            fi
            echo ""
        fi
    done
    echo "$ca""=== DLT.GREEN Installer  ===""$xx"
    echo "Version: $VRSN"
    echo "Build: $BUILD"
    echo "$ca""=== APT Up-to-date Check ===""$xx"
    apt update > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "APT is up-to-date."
    else
        echo "APT is not up-to-date."
    fi
}

SetCertificateGlobal() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║ DLT.GREEN           AUTOMATIC NODE-INSTALLER WITH DOCKER $VAR_VRN ║"
	echo "║""$ca""$VAR_DOMAIN""$xx""║"
	echo "║                                                                             ║"
	echo "║                          1. Use Certificate only for this Node              ║"
	echo "║                          X. Update Certificate for all Nodes (recommended)  ║"
	echo "║                                                                             ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""
	echo "$gn""If you [X] update the Certificate for all Nodes (recommended),"
	echo "every Node on your Server will use this Certificate after restarting it""$xx"
	echo ""
	echo "select menu item: "
	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] for [X]... Press [P] to pause / [C] to cancel"; echo "$xx"
	case $W in
	1) ;;
	*)
	   echo "$ca"'Update Certificate for all Nodes...'"$xx"
	   sleep 15
	   mkdir -p "/etc/letsencrypt/live/$VAR_HOST" || exit
	   cd "/var/lib/$VAR_DIR/data/letsencrypt" || exit
	   cat acme.json | jq -r '.myresolver .Certificates[]? | select(.domain.main=="'"$VAR_HOST"'") | .certificate' | base64 -d > "$VAR_HOST.crt"
	   cat acme.json | jq -r '.myresolver .Certificates[]? | select(.domain.main=="'"$VAR_HOST"'") | .key' | base64 -d > "$VAR_HOST.key"

	   if [ -s "/var/lib/$VAR_DIR/data/letsencrypt/$VAR_HOST.crt" ]; then
	     rm -rf "/etc/letsencrypt/live/$VAR_HOST/*"
	     cp "/var/lib/$VAR_DIR/data/letsencrypt/$VAR_HOST.crt" "/etc/letsencrypt/live/$VAR_HOST/fullchain.pem"
	   fi
	   if [ -s "/var/lib/$VAR_DIR/data/letsencrypt/$VAR_HOST.key" ]; then
	     cp "/var/lib/$VAR_DIR/data/letsencrypt/$VAR_HOST.key" "/etc/letsencrypt/live/$VAR_HOST/privkey.pem"
	     echo "$gn""Global Certificate is now updated for all Nodes""$xx"
	   else
	     echo "$rd""There was an Error on getting a Let's Encrypt Certificate!""$xx"
	     echo "$gn""A default Certificate is now generated only for this Node""$xx"
	   fi
	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] for [X]... Press [P] to pause / [C] to cancel"; echo "$xx"
	   ;;
	esac
}

Dashboard() {

	VAR_DOMAIN=''

	VAR_NODE=1; VAR_NodeHealthy=false; VAR_PORT="9999"
	if [ -f "/var/lib/iota-hornet/.env" ]; then
	  VAR_DOMAIN=$(cat /var/lib/iota-hornet/.env | grep _HOST | cut -d '=' -f 2)
	  VAR_PORT=$(cat "/var/lib/iota-hornet/.env" | grep HTTPS_PORT | cut -d '=' -f 2)
	  VAR_IOTA_HORNET_NETWORK=$(cat "/var/lib/iota-hornet/.env" | grep HORNET_NETWORK | cut -d '=' -f 2)
	  if [ -z "$VAR_PORT" ]; then VAR_PORT="9999"; fi; CheckNodeHealthy
	else
	  VAR_IOTA_HORNET_NETWORK='mainnet'
	fi
	if $VAR_NodeHealthy; then ih=$gn; elif [ -d /var/lib/iota-hornet ]; then ih=$rd; else ih=$gr; fi

	VAR_NODE=2; VAR_NodeHealthy=false; VAR_PORT="9999"
	if [ -f "/var/lib/iota-wasp/.env" ]; then
	  VAR_DOMAIN=$(cat /var/lib/iota-wasp/.env | grep _HOST | cut -d '=' -f 2)
	  VAR_PORT=$(cat "/var/lib/iota-wasp/.env" | grep API_PORT | cut -d '=' -f 2)
	  if [ -z "$VAR_PORT" ]; then VAR_PORT="9999"; fi; CheckNodeHealthy
	fi
	if ! [ "$VAR_NodeHealthy" = "false" ]; then iw=$gn; elif [ -d /var/lib/iota-wasp ]; then iw=$rd; else iw=$gr; fi

	VAR_NODE=3; if [ -f "/var/lib/iota-wasp/data/config/wasp-cli/wasp-cli.json" ]; then ic=$gn; elif [ -d /var/lib/iota-wasp ]; then ic=$or; else ic=$gr; fi

	VAR_NODE=5; VAR_NodeHealthy=false; VAR_PORT="9999"
	if [ -f "/var/lib/shimmer-hornet/.env" ]; then
	  VAR_DOMAIN=$(cat /var/lib/shimmer-hornet/.env | grep _HOST | cut -d '=' -f 2)
	  VAR_PORT=$(cat "/var/lib/shimmer-hornet/.env" | grep HTTPS_PORT | cut -d '=' -f 2)
	  VAR_SHIMMER_HORNET_NETWORK=$(cat "/var/lib/shimmer-hornet/.env" | grep HORNET_NETWORK | cut -d '=' -f 2)
	  if [ -z "$VAR_PORT" ]; then VAR_PORT="9999"; fi; CheckNodeHealthy
	else
	  VAR_SHIMMER_HORNET_NETWORK='mainnet'
	fi
	if $VAR_NodeHealthy; then sh=$gn; elif [ -d /var/lib/shimmer-hornet ]; then sh=$rd; else sh=$gr; fi

	VAR_NODE=6; VAR_NodeHealthy=false; VAR_PORT="9999"
	if [ -f "/var/lib/shimmer-wasp/.env" ]; then
	  VAR_DOMAIN=$(cat /var/lib/shimmer-wasp/.env | grep _HOST | cut -d '=' -f 2)
	  VAR_PORT=$(cat "/var/lib/shimmer-wasp/.env" | grep API_PORT | cut -d '=' -f 2)
	  if [ -z "$VAR_PORT" ]; then VAR_PORT="9999"; fi; CheckNodeHealthy
	fi

	if ! [ "$VAR_NodeHealthy" = "false" ]; then sw=$gn; elif [ -d /var/lib/shimmer-wasp ]; then sw=$rd; else sw=$gr; fi

	VAR_NODE=7; if [ -f "/var/lib/shimmer-wasp/data/config/wasp-cli/wasp-cli.json" ]; then sc=$gn; elif [ -d /var/lib/shimmer-wasp ]; then sc=$or; else sc=$gr; fi

	VAR_NODE=0

	if [ "$(crontab -l | grep -v ^'#' | grep "$VAR_CRON_URL" | grep "$VAR_CRON_JOB_1" | grep "$VAR_CRON_TIME_1_1")" ];  then cja=$gn; else cja=$rd; fi
	if [ "$(crontab -l | grep -v ^'#' | grep "$VAR_CRON_URL" | grep "$VAR_CRON_JOB_2m")" ] || [ "$(crontab -l | grep "$VAR_CRON_URL" | grep "$VAR_CRON_JOB_2u")" ];  then cjb=$gn; else cjb=$rd; fi

	if [ "$opt_mode" ]; then VAR_STATUS="installer: $VRSN"; NotifyMessage "info" "$VAR_DOMAIN" "$VAR_STATUS"; fi

	PositionCenter "$VAR_DOMAIN"
	VAR_DOMAIN=$text

	ix=$gr
	if [ "$(docker container inspect -f '{{.State.Status}}' shimmer-plugins'.inx-chronicle' 2>/dev/null)" = 'running' ]; then
	  if [ ix != "$rd" ]; then ix=$gn; fi
	elif [ -d /var/lib/shimmer-plugins/inx-chronicle ]; then ix=$rd; else ix=$gr; fi

	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║ DLT.GREEN           AUTOMATIC NODE-INSTALLER WITH DOCKER $VAR_VRN ║"
	echo "║""$ca""$VAR_DOMAIN""$xx""║"
	echo "║                                                                             ║"
	echo "║           ┌──────────────────┬  IOTA Stardust  ┬──────────────────┐         ║"
	echo "║ ┌─┬────────────────┬─┬────────────────┬─┬──────────────┐ ┌─┬──────────────┐ ║"
	echo "║ │1│     ""$ih""HORNET""$xx""     │2│      ""$iw""WASP""$xx""      │3│   ""$ic""WASP-CLI""$xx""   │ │4│      -       │ ║"
	echo "║ └─┴────────────────┴─┴────────────────┴─┴──────────────┘ └─┴──────────────┘ ║"
	echo "║                                                                             ║"
	echo "║           ┌──────────────────┬ Shimmer ""$(echo "$VAR_SHIMMER_HORNET_NETWORK" | sed 's/.*/\u&/')"" ┬──────────────────┐         ║"
	echo "║ ┌─┬────────────────┬─┬────────────────┬─┬──────────────┐ ┌─┬──────────────┐ ║"
	echo "║ │5│     ""$sh""HORNET""$xx""     │6│      ""$sw""WASP""$xx""      │7│   ""$sc""WASP-CLI""$xx""   │ │8│    ""$ix""PLUGINS""$xx""   │ ║"
	echo "║ └─┴────────────────┴─┴────────────────┴─┴──────────────┘ └─┴──────────────┘ ║"
	echo "║                                                                             ║"
	echo "║    Node-Status:  ""$gn""running | healthy""$xx"" / ""$rd""stopped | unhealthy""$xx"" / ""$gr""not installed""$xx""    ║"
	echo "║                                                                             ║"
	echo "║   [E] Events  [R] Refresh  [""$cja""S""$xx""] Start all Nodes  [""$cjb""M""$xx""] Maintenance  [Q] Quit   ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	if [ "$(crontab -l | grep -v ^'#' | grep "$VAR_CRON_URL" | grep "$VAR_CRON_JOB_2m\|$VAR_CRON_JOB_2u")" ]; then
	  echo "$gr""              maintenance: ""$(printf '%02d' "$(crontab -l | grep -v ^'#' | grep "$VAR_CRON_URL" | grep "$VAR_CRON_JOB_2m\|$VAR_CRON_JOB_2u" | cut -d ' ' -f 2)")"":""$(printf '%02d' "$(crontab -l | grep -v ^'#' | grep "$VAR_CRON_URL" | grep "$VAR_CRON_JOB_2m\|$VAR_CRON_JOB_2u" | cut -d ' ' -f 1)")"" | day: ""$(crontab -l | grep -v ^'#' | grep "$VAR_CRON_URL" | grep "$VAR_CRON_JOB_2m\|$VAR_CRON_JOB_2u" | cut -d ' ' -f 3)"" | month: ""$(crontab -l | grep -v ^'#' | grep "$VAR_CRON_URL" | grep "$VAR_CRON_JOB_2m\|$VAR_CRON_JOB_2u" | cut -d ' ' -f 4)"" | weekday: ""$(crontab -l | grep -v ^'#' | grep "$VAR_CRON_URL" | grep "$VAR_CRON_JOB_2m\|$VAR_CRON_JOB_2u" | cut -d ' ' -f 5)""$xx"
	  echo ""
	else echo ""; fi
	echo "select menu item:"

	if [ "$opt_mode" = 'd' ]; then
	  echo "$ca""unattended: Debugging...""$xx"
	  VAR_STATUS='system: debug'
	  NotifyMessage "info" "$VAR_DOMAIN" "$VAR_STATUS"
	  DebugInfo
	  sleep 3
	  n='q'
	fi

	if [ "$opt_mode" = 0 ] || [ "$opt_mode" = 'u' ]; then
	  echo "$ca""unattended: System Maintenance...""$xx"
	  VAR_STATUS='system: maintenance'
	  NotifyMessage "info" "$VAR_DOMAIN" "$VAR_STATUS"
	  SystemMaintenance
	  if [ "$opt_mode" ]; then opt_mode='s'; fi
	  sleep 3
	fi

	if [ "$opt_mode" = 1 ]; then
	  echo "$ca""unattended: Update IOTA-Hornet...""$xx"
	  VAR_STATUS="iota-hornet $VAR_IOTA_HORNET_NETWORK: update v.$VAR_IOTA_HORNET_VERSION"
	  NotifyMessage "info" "$VAR_DOMAIN" "$VAR_STATUS"
	  sleep 3
	  n='1'
	fi

	if [ "$opt_mode" = 2 ]; then
	  echo "$ca""unattended: Update IOTA-Wasp...""$xx"
	  VAR_STATUS="iota-wasp: update v.$VAR_IOTA_WASP_VERSION"
	  NotifyMessage "info" "$VAR_DOMAIN" "$VAR_STATUS"
	  sleep 3
	  n='2'
	fi

	if [ "$opt_mode" = 5 ]; then
	  echo "$ca""unattended: Update Shimmer-Hornet...""$xx"
	  VAR_STATUS="shimmer-hornet $VAR_SHIMMER_HORNET_NETWORK: update v.$VAR_SHIMMER_HORNET_VERSION"
	  NotifyMessage "info" "$VAR_DOMAIN" "$VAR_STATUS"
	  sleep 3
	  n='5'
	fi

	if [ "$opt_mode" = 6 ]; then
	  echo "$ca""unattended: Update Shimmer-Wasp...""$xx"
	  VAR_STATUS="shimmer-wasp: update v.$VAR_SHIMMER_WASP_VERSION"
	  NotifyMessage "info" "$VAR_DOMAIN" "$VAR_STATUS"
	  sleep 3
	  n='6'
	fi

	if [ "$opt_mode" = 21 ]; then
	  echo "$ca""unattended: Update Shimmer-Plugins/INX-Chronicle...""$xx"
	  VAR_STATUS="shimmer-plugins/inx-chronicle: update v.$VAR_SHIMMER_INX_CHRONICLE_VERSION"
	  NotifyMessage "info" "$VAR_DOMAIN" "$VAR_STATUS"
	  sleep 3
	  n='21'
	fi

	if [ "$opt_mode" = 's' ]; then
	  echo "$ca""unattended: Start all Nodes...""$xx"
	  VAR_STATUS='system: start all nodes'
	  NotifyMessage "info" "$VAR_DOMAIN" "$VAR_STATUS"
	  sleep 3
	  n='s'
	fi

	if ! [ "$opt_mode" ] && ! [ "$n" = 's' ]; then read -r -p '> ' n; fi

	case $n in

	s|S)
	   VAR_NETWORK=0; VAR_NODE=0; VAR_DIR=''
	   clear
	   echo "$ca"
	   echo 'Please wait, starting Nodes can take up to 10 minutes...'
	   echo "$xx"

	   for NODE in $NODES; do
	     if [ -f "/var/lib/$NODE/.env" ]; then
	       if [ -d "/var/lib/$NODE" ]; then
	         cd "/var/lib/$NODE" || exit
	         if [ -f "/var/lib/$NODE/docker-compose.yml" ]; then
	           CheckIota; if [ "$VAR_NETWORK" = 1 ]; then docker network create iota >/dev/null 2>&1; fi
	           CheckShimmer; if [ "$VAR_NETWORK" = 2 ]; then docker network create shimmer >/dev/null 2>&1; fi
			   NETWORK='';
	           if [ "$NODE" = 'iota-hornet' ]; then NETWORK=" $VAR_IOTA_HORNET_NETWORK"; fi
	           if [ "$NODE" = 'shimmer-hornet' ]; then NETWORK=" $VAR_SHIMMER_HORNET_NETWORK"; fi
	           docker compose up -d
	           sleep 60
	           VAR_STATUS="$(docker inspect "$(echo "$NODE" | sed 's/\//./g')" | jq -r '.[] .State .Health .Status')"

	           if [ "$VAR_STATUS" = 'unhealthy' ]; then
	             VAR_STATUS="$NODE$NETWORK: $VAR_STATUS"
	             if [ "$opt_mode" = 's' ]; then NotifyMessage "err!" "$VAR_DOMAIN" "$VAR_STATUS"; fi
	             docker compose stop
	             docker compose pull 2>&1 | grep "Pulled" | sort
	             ./prepare_docker.sh
	             if [ "$NODE" = 'iota-hornet' ]; then
	               VAR_STATUS="$NODE$NETWORK: reset node database"
	               if [ "$opt_mode" = 's' ]; then NotifyMessage "warn" "$VAR_DOMAIN" "$VAR_STATUS"; fi
	               rm -rf /var/lib/"$NODE"/data/storage/"$VAR_IOTA_HORNET_NETWORK"/*
	               rm -rf /var/lib/"$NODE"/data/snapshots/"$VAR_IOTA_HORNET_NETWORK"/*
	               VAR_STATUS="$NODE$NETWORK: import snapshot"
	               if [ "$opt_mode" = 's' ]; then NotifyMessage "info" "$VAR_DOMAIN" "$VAR_STATUS"; fi
	             fi
	             if [ "$NODE" = 'shimmer-hornet' ]; then
	               VAR_STATUS="$NODE$NETWORK: reset node database"
	               if [ "$opt_mode" = 's' ]; then NotifyMessage "warn" "$VAR_DOMAIN" "$VAR_STATUS"; fi
	               rm -rf /var/lib/"$NODE"/data/storage/"$VAR_SHIMMER_HORNET_NETWORK"/*
	               rm -rf /var/lib/"$NODE"/data/snapshots/"$VAR_SHIMMER_HORNET_NETWORK"/*
	               VAR_STATUS="$NODE$NETWORK: import snapshot"
	               if [ "$opt_mode" = 's' ]; then NotifyMessage "info" "$VAR_DOMAIN" "$VAR_STATUS"; fi
	             fi
	             docker compose up -d
	             sleep 60
	             VAR_STATUS="$(docker inspect "$(echo "$NODE" | sed 's/\//./g')" | jq -r '.[] .State .Health .Status')"
	           fi

	           if [ "$NODE" = 'iota-hornet' ]; then
	             VAR_STATUS_HORNET_INX_PARTICIPATION="$(docker inspect "$(echo "iota-hornet.inx-participation" | sed 's/\//./g')" | jq -r '.[] .State .Status')"
	             if ! [ "$VAR_STATUS_HORNET_INX_PARTICIPATION" = 'running' ]; then
	               VAR_STATUS_HORNET_INX_PARTICIPATION="$NODE$NETWORK: participation unhealthy"
	               if [ "$opt_mode" = 's' ]; then NotifyMessage "err!" "$VAR_DOMAIN" "$VAR_STATUS_HORNET_INX_PARTICIPATION"; fi
 	               docker compose stop
	               VAR_STATUS_HORNET_INX_PARTICIPATION="$NODE$NETWORK: reset participation database"
	               if [ "$opt_mode" = 's' ]; then NotifyMessage "warn" "$VAR_DOMAIN" "$VAR_STATUS_HORNET_INX_PARTICIPATION"; fi
	               rm -rf /var/lib/"$NODE"/data/participation/"$VAR_IOTA_HORNET_NETWORK"/participation/*
 	               docker compose up -d
	               sleep 60
	               VAR_STATUS_HORNET_INX_PARTICIPATION="$(docker inspect "$(echo "iota-hornet.inx-participation" | sed 's/\//./g')" | jq -r '.[] .State .Status')"
	               case $VAR_STATUS_HORNET_INX_PARTICIPATION in
					   'running')
					   VAR_STATUS_HORNET_INX_PARTICIPATION="$NODE$NETWORK: participation healthy"
					   if [ "$opt_mode" = 's' ]; then NotifyMessage "info" "$VAR_DOMAIN" "$VAR_STATUS_HORNET_INX_PARTICIPATION"; fi ;;
					   *)
					   VAR_STATUS_HORNET_INX_PARTICIPATION="$NODE$NETWORK: participation unhealthy"
					   if [ "$opt_mode" = 's' ]; then NotifyMessage "err!" "$VAR_DOMAIN" "$VAR_STATUS_HORNET_INX_PARTICIPATION"; fi ;;
	               esac
	             else
	               VAR_STATUS_HORNET_INX_PARTICIPATION="$NODE$NETWORK: participation healthy"
	               if [ "$opt_mode" = 's' ]; then NotifyMessage "info" "$VAR_DOMAIN" "$VAR_STATUS_HORNET_INX_PARTICIPATION"; fi
	             fi
	           fi	

	           if [ "$NODE" = 'shimmer-hornet' ]; then
	             VAR_STATUS_HORNET_INX_PARTICIPATION="$(docker inspect "$(echo "shimmer-hornet.inx-participation" | sed 's/\//./g')" | jq -r '.[] .State .Status')"
	             if ! [ "$VAR_STATUS_HORNET_INX_PARTICIPATION" = 'running' ]; then
	               VAR_STATUS_HORNET_INX_PARTICIPATION="$NODE$NETWORK: participation unhealthy"
	               if [ "$opt_mode" = 's' ]; then NotifyMessage "err!" "$VAR_DOMAIN" "$VAR_STATUS_HORNET_INX_PARTICIPATION"; fi
 	               docker compose stop
	               VAR_STATUS_HORNET_INX_PARTICIPATION="$NODE$NETWORK: reset participation database"
	               if [ "$opt_mode" = 's' ]; then NotifyMessage "warn" "$VAR_DOMAIN" "$VAR_STATUS_HORNET_INX_PARTICIPATION"; fi
	               rm -rf /var/lib/"$NODE"/data/participation/"$VAR_SHIMMER_HORNET_NETWORK"/participation/*
 	               docker compose up -d
	               sleep 60
	               VAR_STATUS_HORNET_INX_PARTICIPATION="$(docker inspect "$(echo "shimmer-hornet.inx-participation" | sed 's/\//./g')" | jq -r '.[] .State .Status')"
	               case $VAR_STATUS_HORNET_INX_PARTICIPATION in
					   'running')
					   VAR_STATUS_HORNET_INX_PARTICIPATION="$NODE$NETWORK: participation healthy"
					   if [ "$opt_mode" = 's' ]; then NotifyMessage "info" "$VAR_DOMAIN" "$VAR_STATUS_HORNET_INX_PARTICIPATION"; fi ;;
					   *)
					   VAR_STATUS_HORNET_INX_PARTICIPATION="$NODE$NETWORK: participation unhealthy"
					   if [ "$opt_mode" = 's' ]; then NotifyMessage "err!" "$VAR_DOMAIN" "$VAR_STATUS_HORNET_INX_PARTICIPATION"; fi ;;
	               esac
	             else
	               VAR_STATUS_HORNET_INX_PARTICIPATION="$NODE$NETWORK: participation healthy"
	               if [ "$opt_mode" = 's' ]; then NotifyMessage "info" "$VAR_DOMAIN" "$VAR_STATUS_HORNET_INX_PARTICIPATION"; fi
	             fi
	           fi

	           case $VAR_STATUS in
	               'null')
	               VAR_STATUS="$NODE$NETWORK: healthcheck missing"
	               if [ "$opt_mode" = 's' ]; then NotifyMessage "warn" "$VAR_DOMAIN" "$VAR_STATUS"; fi ;;
	               'unhealthy')
	               VAR_STATUS="$NODE$NETWORK: $VAR_STATUS"
	               if [ "$opt_mode" = 's' ]; then NotifyMessage "err!" "$VAR_DOMAIN" "$VAR_STATUS"; fi ;;
	               'healthy')
	               VAR_STATUS="$NODE$NETWORK: $VAR_STATUS"
	               if [ "$opt_mode" = 's' ]; then NotifyMessage "info" "$VAR_DOMAIN" "$VAR_STATUS"; fi ;;
	               *)
	               VAR_STATUS="$NODE$NETWORK: $VAR_STATUS"
	               if [ "$opt_mode" = 's' ]; then NotifyMessage "warn" "$VAR_DOMAIN" "$VAR_STATUS"; fi ;;
	           esac
	         fi
	       fi
	     fi
	   done

	   n=''
	   RenameContainer

	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"

	   if [ "$opt_mode" ]; then clear; exit; else DashboardHelper; fi ;;

	u) VAR_NETWORK=0; VAR_NODE=0; VAR_DIR=''
	   CheckNodeUpdates ;;
	1) VAR_NETWORK=1; VAR_NODE=1; VAR_DIR='iota-hornet'
	   if [ "$opt_mode" ]; then IotaHornet; clear; exit; else SubMenuMaintenance; fi ;;
	2) VAR_NETWORK=1; VAR_NODE=2; VAR_DIR='iota-wasp'
	   if [ "$opt_mode" ]; then IotaWasp; clear; exit; else SubMenuMaintenance; fi ;;
	3) VAR_NETWORK=1; VAR_NODE=3; VAR_DIR='iota-wasp'
	   clear
	   echo "$ca"
	   echo 'Please wait, checking for Updates...'
	   echo "$xx"
	   if [ -s "/var/lib/$VAR_DIR/wasp-cli-wrapper.sh" ]; then echo "$ca""Network/Node: $VAR_DIR | $(/var/lib/$VAR_DIR/wasp-cli-wrapper.sh -v)""$xx"; else echo "$ca""Network/Node: $VAR_DIR | wasp-cli not installed""$xx"; fi
	   SubMenuWaspCLI ;;
	4) clear
	   VAR_NETWORK=0; VAR_NODE=0; VAR_DIR=''
	   DashboardHelper ;;
	5) VAR_NETWORK=2; VAR_NODE=5; VAR_DIR='shimmer-hornet'
	   if [ "$opt_mode" ]; then ShimmerHornet; clear; exit; else SubMenuMaintenance; fi ;;
	6) VAR_NETWORK=2; VAR_NODE=6; VAR_DIR='shimmer-wasp'
	   if [ "$opt_mode" ]; then ShimmerWasp; clear; exit; else SubMenuMaintenance; fi ;;
	7) VAR_NETWORK=2; VAR_NODE=7; VAR_DIR='shimmer-wasp'
	   clear
	   echo "$ca"
	   echo 'Please wait, checking for Updates...'
	   echo "$xx"
	   if [ -s "/var/lib/$VAR_DIR/wasp-cli-wrapper.sh" ]; then echo "$ca""Network/Node: $VAR_DIR | $(/var/lib/$VAR_DIR/wasp-cli-wrapper.sh -v)""$xx"; else echo "$ca""Network/Node: $VAR_DIR | wasp-cli not installed""$xx"; fi
	   SubMenuWaspCLI ;;
	8) VAR_NETWORK=2; VAR_NODE=0; VAR_DIR='shimmer-plugins'
	   if [ "$opt_mode" ]; then clear; exit; else SubMenuPlugins; fi ;;
	21) VAR_NETWORK=2; VAR_NODE=21; VAR_DIR='shimmer-plugins/inx-chronicle'
	   if [ "$opt_mode" ]; then ShimmerChronicle; clear; exit; else SubMenuMaintenance; fi ;;
	e|E) clear
	   VAR_NETWORK=0; VAR_NODE=0; VAR_DIR=''
	   if [ -d "/var/lib/iota-hornet" ]; then CheckEventsIota; fi
	   if [ -d "/var/lib/shimmer-hornet" ]; then CheckEventsShimmer; fi
	   ;;
	r|R) clear
	   VAR_NETWORK=0; VAR_NODE=0; VAR_DIR=''
	   DashboardHelper ;;
	q|Q) if [ ! "$opt_mode" = 'd' ]; then clear; else echo ""; fi
	   exit ;;
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
	echo "║                              5. Cron-Jobs                                   ║"
	echo "║                              6. Notify-Me                                   ║"
	echo "║                              7. Debug Information (for reporting an Issue)  ║"
	echo "║                              8. License Information                         ║"	
	echo "║                              X. Management Dashboard                        ║"
	echo "║                              Q. Quit                                        ║"
	echo "║                                                                             ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""
	echo "select menu item: "

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

	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
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
	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
	   MainMenu ;;
	5) SubMenuCronJobs ;;
	6) SubMenuNotifyMe ;;
	7) clear
	   DebugInfo
	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
	   MainMenu ;;
	8) SubMenuLicense ;;
	q|Q) clear; exit ;;
	*) docker --version | grep "Docker version" >/dev/null 2>&1
	   if [ $? -eq 0 ]; then Dashboard; else
  	     echo ""
  	     echo "$rd""Attention! Please install Docker! Loading Dashboard aborted!""$xx"
	     echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
	     MainMenu
       fi;;
	esac
}

SubMenuCronJobs() {

	if [ "$(crontab -l | grep -v ^'#' | grep "$VAR_CRON_TIME_1" | grep "$VAR_CRON_URL" | grep "$VAR_CRON_JOB_1")" ];  then cja=$gn"[✓] "; else cja=$rd"[X] "; fi
	if [ "$(crontab -l | grep -v ^'#' | grep "$VAR_CRON_URL" | grep "$VAR_CRON_JOB_2m")" ] || [ "$(crontab -l | grep -v ^'#' | grep "$VAR_CRON_URL" | grep "$VAR_CRON_JOB_2u")" ]; then cjb=$gn"[✓] "; else cjb=$rd"[X] "; fi
	if [ "$(crontab -l | grep -v ^'#' | grep "$VAR_CRON_URL" | grep "$VAR_CRON_JOB_2u")" ]; then cjc=$gn"[✓] "; else cjc=$rd"[X] "; fi

	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║ DLT.GREEN           AUTOMATIC NODE-INSTALLER WITH DOCKER $VAR_VRN ║"
	echo "║""$ca""$VAR_DOMAIN""$xx""║"
	echo "║                                                                             ║"
	echo "║                              1. ""$cja""Autostart for all Nodes""$xx""                 ║"
	echo "║                              2. ""$cjb""Automatic System Maintenance""$xx""            ║"
	echo "║                              3. ""$cjc""Automatic Node Updates""$xx""                  ║"
	echo "║                              4. ""$cjz""Edit Cron-Jobs""$xx""                              ║"
	echo "║                              X. Management Dashboard                        ║"
	echo "║                                                                             ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""
	echo "select menu item: "

	read -r -p '> ' n
	case $n in
	1) clear
	   if [ "$(crontab -l | grep -v ^'#' | grep "$VAR_CRON_URL" | grep "$VAR_CRON_JOB_1")" ]; then
		  echo "$ca"
		  echo 'Disable Autostart for all Nodes...'
		  echo "$xx"
		  sleep 3
		  (echo "$(echo "$(crontab -l 2>&1)" | grep -v "$VAR_CRON_TITLE_1")" | grep -v "$VAR_CRON_JOB_1") | crontab -
		  if ! [ "$(crontab -l | grep -v ^'#' | grep "$VAR_CRON_URL" | grep "$VAR_CRON_JOB_1")" ]; then
		     echo "$rd""Autostart for all Nodes disabled""$xx"
		  fi
	   else
		  echo "$ca"
		  echo 'Enable Autostart for all Nodes...'
		  echo "$xx"
		  sleep 3

		  if [ "$(crontab -l 2>&1 | grep 'no crontab')" ]; then
		     export EDITOR='nano' && echo "# crontab" | crontab -
		  fi

		  if ! [ "$(crontab -l | grep -v ^'#' | grep "$VAR_CRON_URL" | grep "$VAR_CRON_JOB_1")" ]; then
		     (echo "$(crontab -l 2>&1 | grep -e '')" && echo "" && echo "$VAR_CRON_TITLE_1" && echo "$VAR_CRON_TIME_1_1""$VAR_CRON_TIME_1_2""$VAR_CRON_URL""$VAR_CRON_JOB_1""$VAR_CRON_END_1") | crontab -
		  fi

		  if [ "$(crontab -l | grep -v ^'#' | grep "$VAR_CRON_URL" | grep "$VAR_CRON_JOB_1" | grep "$VAR_CRON_TIME_1_1")" ]; then
		     echo "$gn""Autostart for all Nodes enabled""$xx"
		  fi
	   fi
	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
	   SubMenuCronJobs ;;
	2) clear
	   if [ "$(crontab -l | grep -v ^'#' | grep "$VAR_CRON_URL" | grep "$VAR_CRON_JOB_2m")" ] || [ "$(crontab -l | grep -v ^'#' | grep "$VAR_CRON_URL" | grep "$VAR_CRON_JOB_2u")" ]; then
		  echo "$ca"
		  echo 'Disable Automatic System Maintenance...'
		  echo "$xx"
		  sleep 3
		  (echo "$(echo "$(crontab -l 2>&1)" | grep -v "$VAR_CRON_TITLE_2")" | grep -v "$VAR_CRON_JOB_2m") | crontab -
		  (echo "$(echo "$(crontab -l 2>&1)" | grep -v "$VAR_CRON_TITLE_2")" | grep -v "$VAR_CRON_JOB_2u") | crontab -
		  if ! [ "$(crontab -l | grep -v ^'#' | grep "$VAR_CRON_URL" | grep "$VAR_CRON_JOB_2m")" ] || ! [ "$(crontab -l | grep -v ^'#' | grep "$VAR_CRON_URL" | grep "$VAR_CRON_JOB_2u")" ]; then
		     echo "$rd""Automatic System Maintenance disabled""$xx"
		  fi
	   else
		  echo "$ca"
		  echo 'Enable Automatic System Maintenance...'
		  echo "$xx"
		  unset VAR_CRON_HOUR_2
		  while [ -z "$VAR_CRON_HOUR_2" ]; do
		    VAR_CRON_HOUR_2="$(shuf --random-source='/dev/urandom' -n 1 -i 0-23)"
		    echo "Set Time [Hour] (random: $ca""0-23""$xx""):";
		    read -r -p '> ' VAR_TMP
		    case $VAR_TMP in
		        ''|*[!0-9]*) VAR_TMP=$VAR_CRON_HOUR_2; echo '> '"$VAR_CRON_HOUR_2" ;;
		        *) ;;
		    esac
		    if [ "$VAR_TMP" -lt 0 ] || [ "$VAR_TMP" -gt 59 ]; then echo "$rd""Wrong value!"; echo "$xx"; else VAR_CRON_HOUR_2=$VAR_TMP; echo "$gn"" ✓""$xx"; fi
		  done

		  VAR_CRON_MIN_2="$(shuf --random-source='/dev/urandom' -n 1 -i 0-59)"
		  echo ""
		  echo "Set Time [Minute] (automatic: $ca""0-59""$xx""):"
		  echo '> '"$VAR_CRON_MIN_2"
		  echo "$gn"" ✓""$xx"
		  echo ""

		  sleep 3

		  if [ "$(crontab -l 2>&1 | grep 'no crontab')" ]; then
		     export EDITOR='nano' && echo "# crontab" | crontab -
		  fi

		  if ! [ "$(crontab -l | grep -v ^'#' | grep "$VAR_CRON_URL" | grep "$VAR_CRON_JOB_2m")" ] || ! [ "$(crontab -l | grep -v ^'#' | grep "$VAR_CRON_URL" | grep "$VAR_CRON_JOB_2u")" ]; then
		     (echo "$(crontab -l 2>&1 | grep -e '')" && echo "" && echo "$VAR_CRON_TITLE_2" && echo "$VAR_CRON_MIN_2"" ""$VAR_CRON_HOUR_2"" * * * ""$VAR_CRON_URL""$VAR_CRON_JOB_2m""$VAR_CRON_END_2") | crontab -
		  fi

		  if [ "$(crontab -l | grep -v ^'#' | grep "$VAR_CRON_URL" | grep "$VAR_CRON_JOB_2m")" ] || [ "$(crontab -l | grep -v ^'#' | grep "$VAR_CRON_URL" | grep "$VAR_CRON_JOB_2u")" ]; then
		     echo "$gn""Automatic System Maintenance enabled: ""$(printf '%02d' "$VAR_CRON_HOUR_2")"":""$(printf '%02d' "$VAR_CRON_MIN_2")""$xx"
		  fi
	   fi
	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
	   SubMenuCronJobs ;;
	3) clear
	   tmp=0
	   if [ "$(crontab -l | grep -v ^'#' | grep "$VAR_CRON_URL" | grep "$VAR_CRON_JOB_2u")" ]; then
		  echo "$ca"
		  echo "Disable Automatic Node Updates..."
		  echo "$xx"
		  sleep 3
		  (echo "$(crontab -l | sed 's/dlt.green -m u/dlt.green -m 0/g')") | crontab -
		  if [ "$(crontab -l | grep -v ^'#' | grep "$VAR_CRON_URL" | grep "$VAR_CRON_JOB_2m")" ]; then
			 tmp=1
		     echo "$rd""Automatic Node Updates disabled""$xx"
		  else
			 tmp=1
		     echo "$rd""Error disabling Automatic Node Updates!""$xx"
		  fi
	   else
	   if [ "$(crontab -l | grep -v ^'#' | grep "$VAR_CRON_URL" | grep "$VAR_CRON_JOB_2m")" ]; then
		  echo "$ca"
		  echo "Enable Automatic Node Updates..."
		  echo "$xx"
		  sleep 3
		  (echo "$(crontab -l | sed 's/dlt.green -m 0/dlt.green -m u/g')") | crontab -
		  if [ "$(crontab -l | grep -v ^'#' | grep "$VAR_CRON_URL" | grep "$VAR_CRON_JOB_2u")" ]; then
			 tmp=1
		     echo "$gn""Automatic Node Updates enabled""$xx"
		  else
			 tmp=1
		     echo "$rd""Error enabling Automatic Node Updates!""$xx"
		  fi
	   fi; fi
	   if [ "$tmp" = 0 ]; then
		  echo "$ca"
		  echo "Automatic Node Updates"
		  echo "$xx"
		  sleep 3
		  echo "$rd""Enable Automatic System Maintenance first...""$xx"
	   fi
	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
	   SubMenuCronJobs ;;
	4) clear
	   echo "$ca"
	   echo 'Edit Cron-Jobs:'
	   echo "$xx"
	   if [ "$(crontab -l 2>&1 | grep 'no crontab')" ]; then
  	     export EDITOR='nano' && echo "# crontab" | crontab -
	   fi
	   crontab -e
	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
	   SubMenuCronJobs ;;
	*) MainMenu ;;
	esac
}

SubMenuNotifyMe() {

	nmi=$gr; nmw=$gr; nme=$gr;
	if ! [ "$(crontab -l | grep -v ^'#' | grep "$VAR_CRON_URL" | grep '\-l')" ]; then (echo "$(crontab -l | sed 's/-m/-l i -m/g')") | crontab -; fi
	if [ "$(crontab -l | grep -v ^'#' | grep "$VAR_CRON_URL" | grep '\-l i')" ]; then nmi=$gn; nmw=$or; nme=$rd; fi
	if [ "$(crontab -l | grep -v ^'#' | grep "$VAR_CRON_URL" | grep '\-l w')" ]; then nmw=$or; nme=$rd; fi
	if [ "$(crontab -l | grep -v ^'#' | grep "$VAR_CRON_URL" | grep '\-l e')" ]; then nme=$rd; fi

	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║ DLT.GREEN           AUTOMATIC NODE-INSTALLER WITH DOCKER $VAR_VRN ║"
	echo "║""$ca""$VAR_DOMAIN""$xx""║"
	echo "║                                                                             ║"
	echo "║                              1. Show existing Message Channel               ║"
	echo "║                              2. Activate new Message Channel                ║"
	echo "║                              3. Generate new Message Channel                ║"
	echo "║                              4. Switch Notify-Level: [""$nmi""info""$xx""|""$nmw""warn""$xx""|""$nme""err!""$xx""]       ║"
	echo "║                              5. Revoke Notify-Me                            ║"
	echo "║                              X. Management Dashboard                        ║"
	echo "║                                                                             ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""
	echo "select menu item: "

	read -r -p '> ' n
	case $n in
	1) clear
	   echo "$ca"
	   echo "Show existing Message Channel..."
	   echo "$xx"

	   VAR_NOTIFY_URL='https://notify.run'
	   VAR_NOTIFY_ENDPOINT=$(cat ~/.bash_aliases | grep "msg" | cut -d '=' -f 2 | cut -d ' ' -f 2)
	   VAR_NOTIFY_ID=$(cat ~/.bash_aliases | grep "msg" | cut -d '=' -f 2| cut -d ' ' -f 2 | cut -d '/' -f 4)

	   if [ "$VAR_NOTIFY_ID" ]; then
	     echo "ChannelId:   " "$VAR_NOTIFY_ID"
	     echo "ChannelPage: " "$VAR_NOTIFY_URL/c/$VAR_NOTIFY_ID"
	     echo "Endpoint:    " "$VAR_NOTIFY_ENDPOINT"
	     echo ""
	     qrencode -m 2 -o - -t ANSIUTF8 "$VAR_NOTIFY_ENDPOINT"
 	     echo ""
	   else
	     echo "$rd""No Message Channel generated!""$xx"
	   fi

	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
	   SubMenuNotifyMe ;;
	2) clear
	   echo "$ca"
	   echo "Activate new Message Channel..."
	   echo "$xx"

	   VAR_NOTIFY_URL='https\:\/\/notify.run'

	   VAR_NOTIFY_ID=$(cat ~/.bash_aliases | grep "msg" | cut -d '=' -f 2| cut -d ' ' -f 2 | cut -d '/' -f 4)
	   VAR_NOTIFY=$(curl -X POST https://notify.run/api/register_channel 2>/dev/null);
	   VAR_DEFAULT=$(echo "$VAR_NOTIFY" | jq -r '.channelId')
	   if [ -z "$VAR_NOTIFY_ID" ]; then
	     echo "Set Message Channel (random: $ca""$VAR_DEFAULT""$xx):"; echo "Press [Enter] to use random value:"; else echo "Set Message Channel (config: $ca""$VAR_NOTIFY_ID""$xx)"; echo "Press [Enter] to use existing config:"; fi
	   read -r -p '> ' VAR_TMP
	   if [ -n "$VAR_TMP" ]; then VAR_NOTIFY_ID=$VAR_TMP; elif [ -z "$VAR_NOTIFY_ID" ]; then VAR_NOTIFY_ID=$VAR_DEFAULT; fi
	   echo "$gn""Set Message Channel: $VAR_NOTIFY_ID""$xx"

	   VAR_NOTIFY_ENDPOINT_URL='curl https://notify.run/'"$VAR_NOTIFY_ID"' -d'

	   NotifyResult=$($VAR_NOTIFY_ENDPOINT_URL """info | $VAR_DOMAIN | message channel: activated""" 2>/dev/null)
	   if [ "$NotifyResult" = 'ok' ]; then

	     if [ -f ~/.bash_aliases ]; then
	       headerLine=$(awk '/# DLT.GREEN Node-Installer-Docker/{ print NR; exit }' ~/.bash_aliases)
	       insertLine=$(awk '/dlt.green-msg=/{ print NR; exit }' ~/.bash_aliases)
	       if [ -z "$insertLine" ]; then
	         if [ ! -z "$headerLine" ]; then
	         insertLine=$(($headerLine))
	         sed -i "$insertLine a alias dlt.green-msg=\"""$VAR_NOTIFY_ENDPOINT_URL"""\" ~/.bash_aliases
	         echo "$gn""New Message Channel: activated...""$xx"
	       else
	         echo "$rd""Error activating new Message Channel!""$xx"
	       fi
	     else
	       sed -i 's/alias dlt.green-msg=.*/alias dlt.green-msg="curl '"$VAR_NOTIFY_URL""\/""$VAR_NOTIFY_ID"' -d"/g' ~/.bash_aliases
	       echo "$gn""New Message Channel: activated...""$xx"
	     fi
	   fi

           else echo "$rd""Error activating new Message Channel!""$xx"; fi


	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
	   SubMenuNotifyMe ;;
	3) clear
	   echo "$ca"
	   echo "Generate new Message Channel..."
	   echo "$xx"

	   VAR_NOTIFY_URL='https\:\/\/notify.run'
	   VAR_NOTIFY=$(curl -X POST https://notify.run/api/register_channel 2>/dev/null)

	   echo "ChannelId:   " $(echo "$VAR_NOTIFY" | jq -r '.channelId')
	   echo "ChannelPage: " $(echo "$VAR_NOTIFY" | jq -r '.channel_page')
	   echo "Endpoint:    " $(echo "$VAR_NOTIFY" | jq -r '.endpoint')

	   VAR_NOTIFY_ENDPOINT=$(echo "$VAR_NOTIFY" | jq -r '.endpoint')
	   VAR_NOTIFY_ENDPOINT_URL='curl '$VAR_NOTIFY_ENDPOINT' -d'
	   VAR_NOTIFY_ID=$(echo "$VAR_NOTIFY" | jq -r '.channelId')

	   echo ""
	   qrencode -m 2 -o - -t ANSIUTF8 "$VAR_NOTIFY_ENDPOINT"
	   echo ""

	   if [ -f ~/.bash_aliases ]; then
	     headerLine=$(awk '/# DLT.GREEN Node-Installer-Docker/{ print NR; exit }' ~/.bash_aliases)
	     insertLine=$(awk '/dlt.green-msg=/{ print NR; exit }' ~/.bash_aliases)
	     if [ -z "$insertLine" ]; then
	         if [ ! -z "$headerLine" ]; then
	           insertLine=$(($headerLine))
	         sed -i "$insertLine a alias dlt.green-msg=\"""$VAR_NOTIFY_ENDPOINT_URL"""\" ~/.bash_aliases
	         echo "$gn""New Message Channel generated...""$xx"
	       else
	         echo "$rd""Error generating new Message Channel!""$xx"
	       fi
	     else
	       sed -i 's/alias dlt.green-msg=.*/alias dlt.green-msg="curl '"$VAR_NOTIFY_URL""\/""$VAR_NOTIFY_ID"' -d"/g' ~/.bash_aliases
	       echo "$gn""New Message Channel generated...""$xx"
	     fi
	   fi

	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
	   SubMenuNotifyMe ;;
	4) clear
	   unset tmp
	   if [ "$(crontab -l | grep -v ^'#' | grep "$VAR_CRON_URL" | grep '\-l e')" ] && [ -z "$tmp" ]; then (echo "$(crontab -l | sed 's/-l e/-l i/g')") | crontab -; tmp=1; fi
	   if [ "$(crontab -l | grep -v ^'#' | grep "$VAR_CRON_URL" | grep '\-l w')" ] && [ -z "$tmp" ]; then (echo "$(crontab -l | sed 's/-l w/-l e/g')") | crontab -; tmp=1; fi
	   if [ "$(crontab -l | grep -v ^'#' | grep "$VAR_CRON_URL" | grep '\-l i')" ] && [ -z "$tmp" ]; then (echo "$(crontab -l | sed 's/-l i/-l w/g')") | crontab -; tmp=1; fi
	   SubMenuNotifyMe ;;
	5) clear
	   echo "$ca"
	   echo "Revoke Notify-Me..."
	   echo "$xx"

	   sed -i 's/alias dlt.green-msg=.*//g' ~/.bash_aliases
	   echo "$gn""Notify-Me revoked...""$xx"

	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
	   SubMenuNotifyMe ;;	*) MainMenu ;;
	*) MainMenu ;;
	esac
}

SubMenuLicense() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║ DLT.GREEN           AUTOMATIC NODE-INSTALLER WITH DOCKER $VAR_VRN ║"
	echo "║""$ca""$VAR_DOMAIN""$xx""║"
	echo "║                                                                             ║"
	echo "║                       GNU General Public License v3.0                       ║"
	echo "║                                                                             ║"
	echo "║    https://github.com/dlt-green/node-installer-docker/blob/main/license     ║"
	echo "║                                                                             ║"
	echo "║                                 MIT License                                 ║"
	echo "║                                                                             ║"
	echo "║        https://github.com/notify-run/notify-run-rs/blob/main/LICENSE        ║"
	echo "║                                                                             ║"
	echo "║                              X. Maintenance Menu                            ║"
	echo "║                                                                             ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""
	echo "select menu item: "

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
	echo "║                              4. Reset Node Database                         ║"
	echo "║                              5. Reset Participation Database                ║"
	echo "║                              6. Loading Snapshot                            ║"
	echo "║                              7. Show Logs                                   ║"
	echo "║                              8. Configuration                               ║"
	echo "║                              9. Deinstall/Remove                            ║"
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
	if [ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 21 ]; then
		if [ -f /var/lib/$VAR_DIR/.env ]; then
			if [ $(cat .env 2>/dev/null | grep INX_CHRONICLE_VERSION | cut -d '=' -f 2) = $VAR_SHIMMER_INX_CHRONICLE_VERSION ]; then
				echo "$ca""Network/Plugin: "$(echo $VAR_DIR | sed 's/\-plugins//')" | installed: v."$(cat .env 2>/dev/null | grep INX_CHRONICLE_VERSION | cut -d '=' -f 2)" | up-to-date""$xx"
			else
				echo "$ca""Network/Plugin: "$(echo $VAR_DIR | sed 's/\-plugins//')" | installed: v."$(cat .env 2>/dev/null | grep INX_CHRONICLE_VERSION | cut -d '=' -f 2)" | available: v.$VAR_SHIMMER_INX_CHRONICLE_VERSION""$xx"
			fi
		else
			echo "$ca""Network/Plugin: "$(echo $VAR_DIR | sed 's/\-plugins//')" | available: v.$VAR_SHIMMER_INX_CHRONICLE_VERSION""$xx"
		fi
	fi
	echo "$rd""Available Diskspace: $(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 4)B/$(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 2)B ($(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 5) used) ""$xx"
	echo ""
	echo "select menu item: "

	read -r -p '> ' n
	case $n in
	1) if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 1 ]; then IotaHornet; fi
	   if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 2 ]; then IotaWasp; fi
	   if [ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 5 ]; then ShimmerHornet; fi
	   if [ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 6 ]; then ShimmerWasp; fi
	   if [ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 21 ]; then ShimmerChronicle; fi
	   ;;
	2) echo '(re)starting...'; sleep 3

	   clear
	   echo ""
	   echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	   echo "║                                  Stopping                                   ║"
	   echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	   echo ""

	   if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 1 ]; then docker stop iota-hornet; fi
	   if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 2 ]; then docker stop iota-wasp; fi
	   if [ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 5 ]; then docker stop shimmer-hornet; fi
	   if [ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 6 ]; then docker stop shimmer-wasp; fi
	   if [ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 21 ]; then docker stop shimmer-plugins.inx-chronicle; fi

	   if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuMaintenance; docker compose down; fi

	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"

	   clear
	   echo ""
	   echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	   echo "║                                  Starting                                   ║"
	   echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	   echo ""

	   rm -rf /var/lib/$VAR_DIR/data/peerdb/*
	   if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuMaintenance; docker compose up -d; fi

	   RenameContainer; sleep 3

	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
	   SubMenuMaintenance
	   ;;
	3) echo 'stopping...'; sleep 3

	   clear
	   echo ""
	   echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	   echo "║                                  Stopping                                   ║"
	   echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	   echo ""

	   if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 1 ]; then docker stop iota-hornet; fi
	   if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 2 ]; then docker stop iota-wasp; fi
	   if [ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 5 ]; then docker stop shimmer-hornet; fi
	   if [ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 6 ]; then docker stop shimmer-wasp; fi
	   if [ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 21 ]; then docker stop shimmer-plugins.inx-chronicle; fi

	   if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuMaintenance; docker compose down; fi
	   sleep 3;

	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
	   SubMenuMaintenance
	   ;;
	4) echo 'resetting node database...'; sleep 3

	   clear
	   echo ""
	   echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	   echo "║                                  Stopping                                   ║"
	   echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	   echo ""

	   if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuMaintenance; docker compose down; fi
	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"

	   clear
	   echo ""
	   echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	   echo "║                           Resetting Node Database                           ║"
	   echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	   echo ""

	   echo "done..."

	   if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 1 ]; then
	      rm -rf /var/lib/$VAR_DIR/data/storage/$VAR_IOTA_HORNET_NETWORK/*
	   fi
	   if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 2 ]; then
    	      rm -rf /var/lib/$VAR_DIR/data/waspdb/wal/*
	      rm -rf /var/lib/$VAR_DIR/data/waspdb/chains/data/*
	      rm -rf /var/lib/$VAR_DIR/data/waspdb/chains/consensus/*
	      rm -rf /var/lib/$VAR_DIR/data/waspdb/chains/index/*
	   fi
	   if [ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 5 ]
	   then
	      rm -rf /var/lib/$VAR_DIR/data/storage/$VAR_SHIMMER_HORNET_NETWORK/*
	   fi
	   if [ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 6 ]; then
	      rm -rf /var/lib/$VAR_DIR/data/waspdb/wal/*
	      rm -rf /var/lib/$VAR_DIR/data/waspdb/chains/data/*
	      rm -rf /var/lib/$VAR_DIR/data/waspdb/chains/consensus/*
	      rm -rf /var/lib/$VAR_DIR/data/waspdb/chains/index/*
	   fi

	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"

	   clear
	   echo ""
	   echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	   echo "║                                  Starting                                   ║"
	   echo "╚═════════════════════════════════════════════════════════════════════════════╝"

	   echo "$ca"
	   echo 'Please wait, importing snapshot can take up to 10 minutes...'
	   echo "$xx"

	   if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuMaintenance; docker compose up -d; fi

	   RenameContainer; sleep 3

	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
	   SubMenuMaintenance
	   ;;
	5) echo 'resetting participation database...'; sleep 3

	   clear
	   echo ""
	   echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	   echo "║                                  Stopping                                   ║"
	   echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	   echo ""

	   if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuMaintenance; docker compose down; fi
	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"

	   clear
	   echo ""
	   echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	   echo "║                      Resetting Participation Database                       ║"
	   echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	   echo ""

	   echo "done..."

	   if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 1 ]; then
	      rm -rf /var/lib/$VAR_DIR/data/participation/$VAR_IOTA_HORNET_NETWORK/participation/*
	   fi
	   if [ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 5 ]
	   then
	      rm -rf /var/lib/$VAR_DIR/data/participation/$VAR_SHIMMER_HORNET_NETWORK/participation/*
	   fi

	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"

	   clear
	   echo ""
	   echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	   echo "║                                  Starting                                   ║"
	   echo "╚═════════════════════════════════════════════════════════════════════════════╝"

	   echo "$ca"
	   echo 'Please wait, importing snapshot can take up to 10 minutes...'
	   echo "$xx"

	   if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuMaintenance; docker compose up -d; fi

	   RenameContainer; sleep 3

	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
	   SubMenuMaintenance
	   ;;
	6) echo 'loading...'; sleep 3

	   clear
	   echo ""
	   echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	   echo "║                                  Stopping                                   ║"
	   echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	   echo ""

	   if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuMaintenance; docker compose down; fi
	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"

	   clear
	   echo ""
	   echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	   echo "║                              Download Snapshot                              ║"
	   echo "╚═════════════════════════════════════════════════════════════════════════════╝"

	   echo "$ca"
	   echo 'Please wait, downloading snapshots may take some time...'
	   echo "$xx"

	   if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 1 ]; then
	      rm -rf /var/lib/$VAR_DIR/data/storage/$VAR_IOTA_HORNET_NETWORK/*
	      rm -rf /var/lib/$VAR_DIR/data/snapshots/$VAR_IOTA_HORNET_NETWORK/*

	      echo "Download latest full snapshot... $VAR_IOTA_HORNET_NETWORK"
	      VAR_SNAPSHOT=$(cat /var/lib/$VAR_DIR/data/config/config-"$VAR_IOTA_HORNET_NETWORK".json 2>/dev/null | jq -r '.snapshots.downloadURLs[].full')
	      wget -cO - "$VAR_SNAPSHOT" -q --show-progress --progress=bar > /var/lib/$VAR_DIR/data/snapshots/"$VAR_IOTA_HORNET_NETWORK"/full_snapshot.bin
	      chmod 744 /var/lib/$VAR_DIR/data/snapshots/"$VAR_IOTA_HORNET_NETWORK"/full_snapshot.bin

	      echo ""

	      echo "Download latest delta snapshot... $VAR_IOTA_HORNET_NETWORK"
	      VAR_SNAPSHOT=$(cat /var/lib/$VAR_DIR/data/config/config-"$VAR_IOTA_HORNET_NETWORK".json 2>/dev/null | jq -r '.snapshots.downloadURLs[].delta')
	      wget -cO - "$VAR_SNAPSHOT" -q --show-progress --progress=bar > /var/lib/$VAR_DIR/data/snapshots/"$VAR_IOTA_HORNET_NETWORK"/delta_snapshot.bin
	      chmod 744 /var/lib/$VAR_DIR/data/snapshots/"$VAR_IOTA_HORNET_NETWORK"/delta_snapshot.bin
	   fi

	   if [ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 2 ] && [ $VAR_IOTA_HORNET_NETWORK = 'mainnet' ]; then
	      rm -rf /var/lib/$VAR_DIR/data/waspdb/chains/data/*
	      rm -rf /var/lib/$VAR_DIR/data/waspdb/chains/consensus/*
	      rm -rf /var/lib/$VAR_DIR/data/waspdb/chains/index/*
	      rm -rf /var/lib/$VAR_DIR/data/waspdb/snap/$VAR_IOTA_EVM_ADDR/*

	      VAR_WASP_PRUNING_MIN_STATES_TO_KEEP=$(cat .env 2>/dev/null | grep WASP_PRUNING_MIN_STATES_TO_KEEP= | cut -d '=' -f 2)

	      if [ "$VAR_WASP_PRUNING_MIN_STATES_TO_KEEP" = "0" ]; then
			VAR_EVM_FULL_DB='https://files.stardust-mainnet.iotaledger.net/dbs/wasp/latest-wasp_chains_wal.tgz'
			cd /var/lib/$VAR_DIR/data/waspdb || SubMenuMaintenance
			echo "Download latest full database... latest-wasp_chains_wal"
			wget -q --show-progress --progress=bar $VAR_EVM_FULL_DB -O - | tar xzv
			cd /var/lib/$VAR_DIR || SubMenuMaintenance
	      else
			cd /var/lib/$VAR_DIR/data/waspdb/snap/$VAR_IOTA_EVM_ADDR || SubMenuMaintenance
			VAR_EVM_SNAPSHOT_ID=$(curl -Ls https://files.stardust-mainnet.iotaledger.net/wasp_snapshots/$VAR_IOTA_EVM_ADDR/INDEX)
			VAR_EVM_SNAPSHOT_URL="https://files.stardust-mainnet.iotaledger.net/wasp_snapshots/$VAR_IOTA_EVM_ADDR/$VAR_EVM_SNAPSHOT_ID"
			echo "Download latest snapshot... $VAR_EVM_SNAPSHOT_ID"
			wget -q --show-progress --progress=bar $VAR_EVM_SNAPSHOT_URL
			cd /var/lib/$VAR_DIR || SubMenuMaintenance
	      fi
	      chown -R 65532:65532 /var/lib/"$VAR_DIR"/data
	   fi

	   if [ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 5 ]; then
	      rm -rf /var/lib/$VAR_DIR/data/storage/$VAR_SHIMMER_HORNET_NETWORK/*
	      rm -rf /var/lib/$VAR_DIR/data/snapshots/$VAR_SHIMMER_HORNET_NETWORK/*

	      echo "Download latest full snapshot... $VAR_SHIMMER_HORNET_NETWORK"
	      VAR_SNAPSHOT=$(cat /var/lib/$VAR_DIR/data/config/config-"$VAR_SHIMMER_HORNET_NETWORK".json 2>/dev/null | jq -r '.snapshots.downloadURLs[].full')
	      wget -cO - "$VAR_SNAPSHOT" -q --show-progress --progress=bar > /var/lib/$VAR_DIR/data/snapshots/"$VAR_SHIMMER_HORNET_NETWORK"/full_snapshot.bin
	      chmod 744 /var/lib/$VAR_DIR/data/snapshots/"$VAR_SHIMMER_HORNET_NETWORK"/full_snapshot.bin

	      echo ""

	      echo "Download latest delta snapshot... $VAR_SHIMMER_HORNET_NETWORK"
	      VAR_SNAPSHOT=$(cat /var/lib/$VAR_DIR/data/config/config-"$VAR_SHIMMER_HORNET_NETWORK".json 2>/dev/null | jq -r '.snapshots.downloadURLs[].delta')
	      wget -cO - "$VAR_SNAPSHOT" -q --show-progress --progress=bar > /var/lib/$VAR_DIR/data/snapshots/"$VAR_SHIMMER_HORNET_NETWORK"/delta_snapshot.bin
	      chmod 744 /var/lib/$VAR_DIR/data/snapshots/"$VAR_SHIMMER_HORNET_NETWORK"/delta_snapshot.bin
	   fi

	   if [ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 6 ] && [ $VAR_SHIMMER_HORNET_NETWORK = 'mainnet' ]; then
	      rm -rf /var/lib/$VAR_DIR/data/waspdb/chains/data/*
	      rm -rf /var/lib/$VAR_DIR/data/waspdb/chains/consensus/*
	      rm -rf /var/lib/$VAR_DIR/data/waspdb/chains/index/*
	      rm -rf /var/lib/$VAR_DIR/data/waspdb/snap/$VAR_SHIMMER_EVM_ADDR/*

	      VAR_WASP_PRUNING_MIN_STATES_TO_KEEP=$(cat .env 2>/dev/null | grep WASP_PRUNING_MIN_STATES_TO_KEEP= | cut -d '=' -f 2)

	      if [ "$VAR_WASP_PRUNING_MIN_STATES_TO_KEEP" = "0" ]; then
			VAR_EVM_FULL_DB='https://files.shimmer.shimmer.network/dbs/wasp/latest-wasp_chains_wal.tgz'
			cd /var/lib/$VAR_DIR/data/waspdb || SubMenuMaintenance
			echo "Download latest full database... latest-wasp_chains_wal"
			wget -q --show-progress --progress=bar $VAR_EVM_FULL_DB -O - | tar xzv
			cd /var/lib/$VAR_DIR || SubMenuMaintenance
	      else
			cd /var/lib/$VAR_DIR/data/waspdb/snap/$VAR_SHIMMER_EVM_ADDR || SubMenuMaintenance
			VAR_EVM_SNAPSHOT_ID=$(curl -Ls https://files.shimmer.shimmer.network/wasp_snapshots/$VAR_SHIMMER_EVM_ADDR/INDEX)
			VAR_EVM_SNAPSHOT_URL="https://files.shimmer.shimmer.network/wasp_snapshots/$VAR_SHIMMER_EVM_ADDR/$VAR_EVM_SNAPSHOT_ID"   
			echo "Download latest snapshot... $VAR_EVM_SNAPSHOT_ID"
			wget -q --show-progress --progress=bar $VAR_EVM_SNAPSHOT_URL
			cd /var/lib/$VAR_DIR || SubMenuMaintenance
	      fi
	      chown -R 65532:65532 /var/lib/"$VAR_DIR"/data
	   fi

	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"

	   clear
	   echo ""
	   echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	   echo "║                            Prepare Installation                             ║"
	   echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	   echo ""

	   cd /var/lib/$VAR_DIR || SubMenuMaintenance;
	   ./prepare_docker.sh

	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"

	   clear
	   echo ""
	   echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	   echo "║                                  Starting                                   ║"
	   echo "╚═════════════════════════════════════════════════════════════════════════════╝"

	   echo "$ca"
	   echo 'Please wait, importing snapshot can take up to 10 minutes...'
	   echo "$xx"

	   if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuMaintenance; docker compose up -d; fi

	   RenameContainer

	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
	   SubMenuMaintenance
	   ;;
	7) clear
	   echo ""
	   echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	   echo "║                                    Logs                                     ║"
	   echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	   echo ""

	   VAR_LOGS=$(echo "$VAR_DIR" | sed 's/\//./g')
	   docker logs -f --tail 300 $VAR_LOGS
	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
	   SubMenuMaintenance
	   ;;
	8) SubMenuConfiguration
	   ;;
	9) echo 'deinstall/remove...'; sleep 3
	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
	   clear
	   echo ""
	   echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	   echo "║                                Deinstalling                                 ║"
	   echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	   echo ""

	   if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuMaintenance; docker compose down >/dev/null 2>&1; fi
	   if [ -d /var/lib/$VAR_DIR ]; then rm -rf /var/lib/$VAR_DIR; fi

	   echo "$rd""$VAR_DIR removed from your system!""$xx"
	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
	   SubMenuMaintenance
	   ;;
	*) Dashboard ;;
	esac
}

SubMenuPlugins() {


	if [ "$(docker container inspect -f '{{.State.Status}}' $VAR_DIR'.inx-chronicle' 2>/dev/null)" = 'running' ]; then ixc=$gn; elif [ -d /var/lib/$VAR_DIR/inx-chronicle ]; then ixc=$rd; else ixc=$gr; fi
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║ DLT.GREEN           AUTOMATIC NODE-INSTALLER WITH DOCKER $VAR_VRN ║"
	echo "║""$ca""$VAR_DOMAIN""$xx""║"
	echo "║                                                                             ║"
	echo "║                              1. ""$ixc""INX-CHRONICLE""$xx""                               ║"
	echo "║                              X. Management Dashboard                        ║"
	echo "║                                                                             ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	if [ ! -d /var/lib/$VAR_DIR ]; then mkdir /var/lib/$VAR_DIR || exit; fi
	if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || Dashboard; fi

	echo ""
	echo "select menu item: "

	read -r -p '> ' n
	case $n in
	1) clear

	   cd /var/lib/$VAR_DIR || Dashboard;
	   if [ ! -d /var/lib/$VAR_DIR/inx-chronicle ]; then mkdir /var/lib/$VAR_DIR/inx-chronicle || exit; fi
	   cd /var/lib/$VAR_DIR/inx-chronicle || exit
	   VAR_DIR=$VAR_DIR'/inx-chronicle'
	   VAR_NODE=21;
	   SubMenuMaintenance ;;
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
	if [ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 21 ]; then
		if [ -f /var/lib/$VAR_DIR/.env ]; then
			if [ $(cat .env 2>/dev/null | grep INX_CHRONICLE_VERSION | cut -d '=' -f 2) = $VAR_SHIMMER_INX_CHRONICLE_VERSION ]; then
				echo "$ca""Network/Plugin: "$(echo $VAR_DIR | sed 's/\-plugins//')" | installed: v."$(cat .env 2>/dev/null | grep INX_CHRONICLE_VERSION | cut -d '=' -f 2)" | up-to-date""$xx"
			else
				echo "$ca""Network/Plugin: "$(echo $VAR_DIR | sed 's/\-plugins//')" | installed: v."$(cat .env 2>/dev/null | grep INX_CHRONICLE_VERSION | cut -d '=' -f 2)" | available: v.$VAR_SHIMMER_INX_CHRONICLE_VERSION""$xx"
			fi
		else
			echo "$ca""Network/Plugin: "$(echo $VAR_DIR | sed 's/\-plugins//')" | available: v.$VAR_SHIMMER_INX_CHRONICLE_VERSION""$xx"
		fi
	fi
	echo "$rd""Available Diskspace: $(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 4)B/$(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 2)B ($(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 5) used) ""$xx"
	echo ""
	echo "select menu item: "

	read -r -p '> ' n
	case $n in
	1) clear
	   echo "$ca"
	   echo "Generate JWT-Token..."
	   echo "$xx"

	   cd /var/lib/$VAR_DIR || SubMenuConfiguration;
	   if ([ "$VAR_NETWORK" = 1 ] && [ "$VAR_NODE" = 1 ]) || ([ "$VAR_NETWORK" = 2 ] && [ "$VAR_NODE" = 5 ]); then
		  VAR_RESTAPI_SALT=$(cat .env 2>/dev/null | grep RESTAPI_SALT | cut -d '=' -f 2);
	      if [ -z $VAR_RESTAPI_SALT ]; then echo "$rd""Generate JWT-Token is not supported, please update your Node! ""$xx"
		  else
		     VAR_JWT=$(docker compose run --rm hornet tool jwt-api --salt $VAR_RESTAPI_SALT | awk '{ print $5 }')
		     echo "Your JWT-Token for secured API Access is generated:"
		     echo "$gn"
		     echo "$VAR_JWT""$xx"
		  fi
	   else
	      echo "$rd""Generate JWT-Token is not supported, aborted! ""$xx"
	   fi
	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] for [X]... Press [P] to pause / [C] to cancel"; echo "$xx"
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
		     ./prepare_docker.sh
	         if  [ "$K" = 'P' ]; then echo "$gn"; echo "Proof of Work of your Node successfully enabled""$xx"; else echo "$rd"; echo "Proof of Work of your Node successfully disabled""$xx"; fi
	         echo "$rd""Please restart your Node for the changes to take effect!""$xx"
		  else
	         echo "$rd""Toggle Proof of Work aborted!""$xx"
		  fi
	   else
	      echo "$rd""Toggle Proof of Work is not supported, aborted!""$xx"
	   fi

	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] for [X]... Press [P] to pause / [C] to cancel"; echo "$xx"
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
		     ./prepare_docker.sh
			 VAR_SHIMMER_HORNET_NETWORK=$(cat ".env" | grep HORNET_NETWORK | cut -d '=' -f 2)
	         if  [ "$K" = 'M' ]; then echo "$gn"; echo "Mainnet of your Node successfully enabled""$xx"; else echo "$gn"; echo "Testnet of your Node successfully enabled""$xx"; fi
	         echo "$rd""Please restart your Node for the changes to take effect!""$xx"
		  else
	         echo "$rd""Toggle Network aborted!""$xx"
		  fi
	   else
	      echo "$rd""Toggle Network is not supported, aborted!""$xx"
	   fi
	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] for [X]... Press [P] to pause / [C] to cancel"; echo "$xx"
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
		  ./prepare_docker.sh
		  echo "$gn""Node Alias of your Node successfully set""$xx"
		  echo "$rd""Please restart your Node for the changes to take effect!""$xx"
	   else
	      echo "$rd""Set Node Alias is not supported, aborted!""$xx"
	   fi
	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] for [X]... Press [P] to pause / [C] to cancel"; echo "$xx"
	   SubMenuConfiguration ;;
	5) clear
	   echo "$ca"
	   echo "Edit Node Configuration File (.env)..."
	   echo "$xx"
	   cd /var/lib/$VAR_DIR || SubMenuConfiguration;
       if [ -f .env ]; then
	      nano .env
	      ./prepare_docker.sh
	      echo "$rd""Please restart your Node for the changes to take effect!""$xx"
       fi
	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] for [X]... Press [P] to pause / [C] to cancel"; echo "$xx"
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
	echo "║                              3. Login (Authenticate to Wasp node)           ║"
	echo "║                              4. Initialize a new wallet                     ║"
	echo "║                              5. Show wallet address                         ║"
	echo "║                              6. Show wallet balance                         ║"
	echo "║                              7. Show peering info                           ║"
	echo "║                              8. Show deployed chains                        ║"
	if [ "$VAR_NODE" = 3 ] ; then
	echo "║                              9. Add IOTA-EVM chain                          ║"
	fi
	if [ "$VAR_NODE" = 7 ] ; then
	echo "║                              9. Add Shimmer-EVM chain                       ║"
	fi
	echo "║                             10. Help                                        ║"	
	echo "║                             11. Deinstall/Remove                            ║"
	echo "║                              X. Management Dashboard                        ║"
	echo "║                                                                             ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""
	if [ "$VAR_NODE" = 3 ] || [ "$VAR_NODE" = 7 ]; then
	if [ -s "/var/lib/$VAR_DIR/wasp-cli-wrapper.sh" ]; then echo "$ca""Network/Node: $VAR_DIR | $(/var/lib/$VAR_DIR/wasp-cli-wrapper.sh -v)""$xx"; else echo "$ca""Network/Node: $VAR_DIR | wasp-cli not installed""$xx"; fi; fi
	echo "$rd""Available Diskspace: $(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 4)B/$(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 2)B ($(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 5) used) ""$xx"
	echo ""
	echo "select menu item: "

	read -r -p '> ' n
	case $n in
	1) clear
	   echo "$ca"
	   echo "Install/Prepare Wasp-CLI...$xx"

	   if [ -d /var/lib/$VAR_DIR ]; then
	      if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuWaspCLI; fi
		     if  [ "$VAR_NETWORK" = 2 ]; then
		        echo "$fl"; read -r -p 'Press [F] to enable Faucet... Press [Enter] key to skip... ' F; echo "$xx"
		        if  [ "$F" = 'f' ] && ! [ "$F" = 'F' ]; then
	               fgrep -q "WASP_CLI_FAUCET_ADDRESS" .env || echo "WASP_CLI_FAUCET_ADDRESS=https://faucet.testnet.shimmer.network" >> .env
		        fi
		     fi
		  if [ -f "./prepare_cli.sh" ]; then ./prepare_cli.sh; else echo "$rd""For using Wasp-CLI you must install $VAR_DIR first!""$xx"; fi
	   else
	      echo "$rd""For using Wasp-CLI you must install $VAR_DIR first!""$xx"
	   fi
	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
	   SubMenuWaspCLI
	   ;;
	2) clear
	   if [ -d /var/lib/$VAR_DIR ]; then
	      if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuWaspCLI; fi
          VAR_RUN_WASP_CLI_CMD=''
          echo "$ca"
          if [ -s "/var/lib/$VAR_DIR/wasp-cli-wrapper.sh" ]; then echo "$ca""Network/Node: $VAR_DIR | $(/var/lib/$VAR_DIR/wasp-cli-wrapper.sh -v)""$xx"; else echo "$ca""Network/Node: $VAR_DIR | wasp-cli not installed""$xx"; fi
          echo "$rd""Hint: Quit Wasp-CLI with [q] | Help [-h] | Clear [clear]"
          echo "$xx"
          echo "Set command: (example: $ca""'wasp-cli {commands}' or '{commands}'""$xx):"
		  while ! [ "$VAR_RUN_WASP_CLI_CMD" = 'q' ] && ! [ "$VAR_RUN_WASP_CLI_CMD" = 'Q' ]
	      do
             echo "$ca"
		     read -r -p 'Wasp-CLI > ' VAR_RUN_WASP_CLI_CMD
			 echo "$xx"
		     VAR_RUN_WASP_CLI_CMD=$(echo $VAR_RUN_WASP_CLI_CMD | sed 's/^wasp-cli//g')
			 if [ "$VAR_RUN_WASP_CLI_CMD" = 'clear' ]; then
			    clear
			    echo "$ca"
			    if [ -s "/var/lib/$VAR_DIR/wasp-cli-wrapper.sh" ]; then echo "$ca""Network/Node: $VAR_DIR | $(/var/lib/$VAR_DIR/wasp-cli-wrapper.sh -v)""$xx"; else echo "$ca""Network/Node: $VAR_DIR | wasp-cli not installed""$xx"; fi
			    echo "$rd""Hint: Quit Wasp-CLI with [q] | Help [-h] | Clear [clear]"
			    echo "$xx"
			    echo "Set command: (example: $ca""'wasp-cli {commands}' or '{commands}'""$xx):"
			 fi
			 if ! [ "$VAR_RUN_WASP_CLI_CMD" = 'clear' ] && ! [ "$VAR_RUN_WASP_CLI_CMD" = 'q' ] && ! [ "$VAR_RUN_WASP_CLI_CMD" = 'Q' ]; then
			    if [ -f "./data/config/wasp-cli/wasp-cli.json" ]; then ./wasp-cli-wrapper.sh $VAR_RUN_WASP_CLI_CMD; else echo ""; echo "$rd""For using Wasp-CLI you must install/prepare Wasp-CLI first!""$xx"; fi
			 fi
	      done
	   else
	      echo "$rd""For using Wasp-CLI you must install $VAR_DIR first!""$xx"
	      echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
	   fi
	   SubMenuWaspCLI
	   ;;
	3) clear
	   echo "$ca"
	   echo 'Login (Authenticate to Wasp node)...'
	   echo "$xx"
	   if [ -d /var/lib/$VAR_DIR ]; then
	      if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuWaspCLI; fi
		  if [ -f "./data/config/wasp-cli/wasp-cli.json" ]; then ./wasp-cli-wrapper.sh login; else echo "$rd""For using Wasp-CLI you must install/prepare Wasp-CLI first!""$xx"; fi
	   else
	      echo "$rd""For using Wasp-CLI you must install $VAR_DIR first!""$xx"
	   fi
	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
	   SubMenuWaspCLI
	   ;;
	4) clear
	   echo "$ca"
	   echo 'Initialize a new wallet...'"$xx"
	   if [ -d /var/lib/$VAR_DIR ]; then
	      if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuWaspCLI; fi
		  if [ -f "./data/config/wasp-cli/wasp-cli.json" ]; then ./wasp-cli-wrapper.sh init --overwrite; else echo "$rd""For using Wasp-CLI you must install/prepare Wasp-CLI first!""$xx"; fi
	   else
	      echo "$rd""For using Wasp-CLI you must install $VAR_DIR first!""$xx"
	   fi
	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
	   SubMenuWaspCLI
	   ;;
	5) clear
	   echo "$ca"
	   echo 'Show wallet address...'"$xx"
	   if [ -d /var/lib/$VAR_DIR ]; then
	      if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuWaspCLI; fi
		  if [ -f "./data/config/wasp-cli/wasp-cli.json" ]; then ./wasp-cli-wrapper.sh address; else echo "$rd""For using Wasp-CLI you must install/prepare Wasp-CLI first!""$xx"; fi
	   else
	      echo "$rd""For using Wasp-CLI you must install $VAR_DIR first!""$xx"
	   fi
	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
	   SubMenuWaspCLI
	   ;;
	6) clear
	   echo "$ca"
	   echo 'Show wallet balance...'"$xx"
	   if [ -d /var/lib/$VAR_DIR ]; then
	      if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuWaspCLI; fi
		  if [ -f "./data/config/wasp-cli/wasp-cli.json" ]; then ./wasp-cli-wrapper.sh balance; else echo "$rd""For using Wasp-CLI you must install/prepare Wasp-CLI first!""$xx"; fi
	   else
	      echo "$rd""For using Wasp-CLI you must install $VAR_DIR first!""$xx"
	   fi
	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
	   SubMenuWaspCLI
	   ;;
	7) clear
	   echo "$ca"
	   echo 'Show peering info...'"$xx"
	   if [ -d /var/lib/$VAR_DIR ]; then
	      if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuWaspCLI; fi
		  if [ -f "./data/config/wasp-cli/wasp-cli.json" ]; then ./wasp-cli-wrapper.sh peering info; else echo "$rd""For using Wasp-CLI you must install/prepare Wasp-CLI first!""$xx"; fi
	   else
	      echo "$rd""For using Wasp-CLI you must install $VAR_DIR first!""$xx"
	   fi
	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
	   SubMenuWaspCLI
	   ;;
	8) clear
	   echo "$ca"
	   echo 'Show deployed chains...'"$xx"
	   if [ -d /var/lib/$VAR_DIR ]; then
	      if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuWaspCLI; fi
		  if [ -f "./data/config/wasp-cli/wasp-cli.json" ]; then ./wasp-cli-wrapper.sh chain list; else echo "$rd""For using Wasp-CLI you must install/prepare Wasp-CLI first!""$xx"; fi
	   else
	      echo "$rd""For using Wasp-CLI you must install $VAR_DIR first!""$xx"
	   fi
	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
	   SubMenuWaspCLI
	   ;;
	9) clear
	   if [ "$VAR_NODE" = 3 ] ; then
		echo "$ca"
		echo 'Add IOTA-EVM chain...'"$xx"
		echo "$xx"
		if [ -d /var/lib/$VAR_DIR ]; then
	      if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuWaspCLI; fi
	      if [ -f "./data/config/wasp-cli/wasp-cli.json" ]; then
			PEER1=$(cat .env 2>/dev/null | grep WASP_TRUSTED_ACCESSNODE_1_NAME | cut -d '=' -f 2)
			PEER2=$(cat .env 2>/dev/null | grep WASP_TRUSTED_ACCESSNODE_2_NAME | cut -d '=' -f 2)
			if [ ! -z $PEER1 ] && [ ! -z $PEER2 ]; then
				clear
				echo "$ca"; echo 'Prepare cli...'; echo "$xx"
				./prepare_cli.sh
				echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
				clear
				echo "$ca"; echo 'Login (Authenticate to Wasp node)...'; echo "$xx"
				./wasp-cli-wrapper.sh login
				echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
				clear
				echo "$ca"; echo 'Add IOTA-EVM chain...'"$xx"
				./wasp-cli-wrapper.sh chain add iota-evm $VAR_IOTA_EVM_ADDR
				if [ -n $(cat ./data/waspdb/chains/chain_registry.json 2>/dev/null | grep $VAR_IOTA_EVM_ADDR | cut -d '=' -f 2) ]; then
					echo "$gn"; echo 'IOTA-EVM chain successfully added...'"$xx"
					echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
					clear
					echo "$ca"; echo 'Activate IOTA-EVM chain...'"$xx"
					./wasp-cli-wrapper.sh chain activate --chain iota-evm
					echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
					clear
					echo "$ca"; echo 'Prepare wasp...'; echo "$xx"
					./prepare_docker.sh
					echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
					clear
					echo "$ca"; echo 'Restart wasp...'; echo "$xx"
					docker stop iota-wasp
					docker compose up -d
				else echo "$rd"; echo "Error adding IOTA-EVM chain!""$xx"; fi
			else echo "$rd""Set at least two trusted accessnodes in the wasp config first!""$xx"; fi
	      else echo "$rd""Install/prepare Wasp-CLI first!""$xx"; fi
		else
	      echo "$rd""Install $VAR_DIR first!""$xx"
		fi
	   fi
	   if [ "$VAR_NODE" = 7 ] ; then
		echo "$ca"
		echo 'Add Shimmer-EVM chain...'"$xx"
		echo "$xx"
		if [ -d /var/lib/$VAR_DIR ]; then
	      if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuWaspCLI; fi
	      if [ -f "./data/config/wasp-cli/wasp-cli.json" ]; then
			PEER1=$(cat .env 2>/dev/null | grep WASP_TRUSTED_ACCESSNODE_1_NAME | cut -d '=' -f 2)
			PEER2=$(cat .env 2>/dev/null | grep WASP_TRUSTED_ACCESSNODE_2_NAME | cut -d '=' -f 2)
			if [ ! -z $PEER1 ] && [ ! -z $PEER2 ]; then
				clear
				echo "$ca"; echo 'Prepare cli...'; echo "$xx"
				./prepare_cli.sh
				echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
				clear
				echo "$ca"; echo 'Login (Authenticate to Wasp node)...'; echo "$xx"
				./wasp-cli-wrapper.sh login
				echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
				clear
				echo "$ca"; echo 'Add Shimmer-EVM chain...'"$xx"
				./wasp-cli-wrapper.sh chain add shimmer-evm $VAR_SHIMMER_EVM_ADDR
				if [ -n "$(cat ./data/waspdb/chains/chain_registry.json 2>/dev/null | grep $VAR_SHIMMER_EVM_ADDR | cut -d '=' -f 2)" ]; then
					echo "$gn"; echo 'Shimmer-EVM chain successfully added...'"$xx"
					echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
					clear
					echo "$ca"; echo 'Activate Shimmer-EVM chain...'"$xx"
					./wasp-cli-wrapper.sh chain activate --chain shimmer-evm
					echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
					clear
					echo "$ca"; echo 'Prepare wasp...'; echo "$xx"
					./prepare_docker.sh
					echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
					clear
					echo "$ca"; echo 'Restart wasp...'; echo "$xx"
					docker stop shimmer-wasp
					docker compose up -d
				else echo "$rd"; echo "Error adding Shimmer-EVM chain!""$xx"; fi
			else echo "$rd""Set at least two trusted accessnodes in the wasp config first!""$xx"; fi
	      else echo "$rd""Install/prepare Wasp-CLI first!""$xx"; fi
		else
	      echo "$rd""Install $VAR_DIR first!""$xx"
		fi
	   fi
	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
	   SubMenuWaspCLI
	   ;;
	10) clear
	   echo "$ca"
	   echo 'Help...'"$xx"
	   echo "$xx"
	   if [ -d /var/lib/$VAR_DIR ]; then
	      if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuWaspCLI; fi
		  if [ -f "./data/config/wasp-cli/wasp-cli.json" ]; then ./wasp-cli-wrapper.sh -h; else echo "$rd""For using Wasp-CLI you must install/prepare Wasp-CLI first!""$xx"; fi
	   else
	      echo "$rd""For using Wasp-CLI you must install $VAR_DIR first!""$xx"
	   fi
	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
	   SubMenuWaspCLI
	   ;;
	11) clear
	   echo "$ca"
	   echo 'Deinstall/Remove Wasp-CLI...'
	   echo "$xx"
	   if [ -d /var/lib/$VAR_DIR ]; then
	      if [ -d /var/lib/$VAR_DIR ]; then cd /var/lib/$VAR_DIR || SubMenuWaspCLI; fi
		  if [ -s "./prepare_cli.sh" ]; then ./prepare_cli.sh --uninstall; else echo "$rd""For using Wasp-CLI you must install/prepare Wasp-CLI first!""$xx"; fi
	   else
	      echo "$rd""For using Wasp-CLI you must install $VAR_DIR first!""$xx"
	   fi
	   echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"
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

	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"

	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                       Delete Docker Containers/Images                       ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	docker system prune -f

	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"

	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                      Check necessary Docker Containers                      ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	for NODE in $NODES; do
	  if [ -f "/var/lib/$NODE/.env" ]; then
	    if [ -d "/var/lib/$NODE" ]; then
	      cd "/var/lib/$NODE" || exit
	      if [ -f "/var/lib/$NODE/docker-compose.yml" ]; then
	        CheckIota; if [ "$VAR_NETWORK" = 1 ]; then docker network create iota >/dev/null 2>&1; fi
	        CheckShimmer; if [ "$VAR_NETWORK" = 2 ]; then docker network create shimmer >/dev/null 2>&1; fi
	        docker compose up --no-start
	      fi
	    fi
	  fi
	done

	RenameContainer

	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"

	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                               Check diskspace                               ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	VAR_STATUS='system: diskspace '"$(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 5)"' full'

	if [ "$(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 5 | sed 's/%//g')" -lt 90 ]; then
	  echo "$gn""diskspace: ""$(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 5)"' full'"$xx"
	  if [ "$opt_mode" ]; then NotifyMessage "info" "$VAR_DOMAIN" "$VAR_STATUS"; fi
	fi
	if [ "$(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 5 | sed 's/%//g')" -gt 90 ] && [ "$(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 5 | sed 's/%//g')" -lt 95 ]; then
	  echo "$or""diskspace waring: ""$(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 5)"' full'"$xx"
	  if [ "$opt_mode" ]; then NotifyMessage "warn" "$VAR_DOMAIN" "$VAR_STATUS"; fi
	fi
	if [ "$(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 5 | sed 's/%//g')" -gt 97 ]; then
	  echo "$ge""diskspace critical: ""$(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 5)"' full'"$xx"
	  if [ "$opt_mode" ]; then NotifyMessage "!err" "$VAR_DOMAIN" "$VAR_STATUS"; fi
	fi

	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"

	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                         Stopping Docker Containers                          ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	docker stop $(docker ps -a -q) 2>/dev/null
	if [ "$opt_mode" ]; then
	  VAR_STATUS='system: stop all nodes'
	  NotifyMessage "info" "$VAR_DOMAIN" "$VAR_STATUS"
	fi
	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"

	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                               Updating System                               ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a sudo apt update
	DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a sudo apt upgrade -y
	DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a sudo apt dist-upgrade -y
	DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a sudo apt autoclean -y
	DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a sudo apt autoremove -y

	if [ "$opt_mode" ]; then
	  VAR_STATUS='system: update'
	  NotifyMessage "info" "$VAR_DOMAIN" "$VAR_STATUS"
	fi
	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"

	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║           Update global Certificate from Let's Encrypt Certificate          ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

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
	        rm -rf "/etc/letsencrypt/live/$HOST/*"
	        cp "/var/lib/$NODE/data/letsencrypt/$HOST.crt" "/etc/letsencrypt/live/$HOST/fullchain.pem"
	        if [ -s "/var/lib/$NODE/data/letsencrypt/$HOST.key" ]; then
	          cp "/var/lib/$NODE/data/letsencrypt/$HOST.key" "/etc/letsencrypt/live/$HOST/privkey.pem"
	          echo "$gn""Global Certificate is now updated for all Nodes from $NODE""$xx"
	          echo "valid until: ""$(openssl x509 -in "$HOST".crt -noout -enddate | cut -d '=' -f 2)"
	          if [ "$opt_mode" ]; then
	            VAR_STATUS='ssl-certificate: valid until '"$(openssl x509 -in "$HOST".crt -noout -enddate | cut -d '=' -f 2)"
	            NotifyMessage "info" "$VAR_DOMAIN" "$VAR_STATUS";
	          fi
	          CERT=$(( CERT + 1 ))
	        fi
	      fi
	    fi
	  fi
	done

	if [ $CERT = 0 ]; then
	  echo "$rd""No Let's Encrypt Certificate found, aborted!""$xx"
	  if [ "$opt_mode" ]; then
	      VAR_STATUS="ssl-certificate: no let's encrypt certificate found"
	      NotifyMessage "warn" "$VAR_DOMAIN" "$VAR_STATUS";
	  fi
	fi
	if [ $CERT -gt 1 ]; then echo "$rd";
	  echo "Misconfiguration with Certificates from your Nodes detected""$xx"
	  if [ "$opt_mode" ]; then
	      VAR_STATUS="ssl-certificate: misconfiguration detected!"
	      NotifyMessage "err!" "$VAR_DOMAIN" "$VAR_STATUS";
	  fi
	fi

	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"

	clear
	if [ "$opt_mode" = 'u' ]; then
	  CheckNodeUpdates
	fi

	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║ DLT.GREEN           AUTOMATIC NODE-INSTALLER WITH DOCKER $VAR_VRN ║"
	echo "║""$ca""$VAR_DOMAIN""$xx""║"
	echo "║                                                                             ║"
	echo "║                            1. System Reboot (if necessary, recommended)     ║"
	echo "║                            X. Maintenance Menu                              ║"
	echo "║                                                                             ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""
	echo "$gn""You don't have to stop Nodes installed with the DLT.GREEN Installer,"
	echo "but you must restart them with our Installer after rebooting your System,"
	echo "if you don't have Autostart enabled!""$xx"
	echo ""
	echo "select menu item: "

	if [ "$opt_mode" ]; then if ! [ "$opt_reboot" ]; then opt_reboot=0; fi; fi
	if [ "$opt_reboot" = 1 ]; then n=1; elif [ "$opt_reboot" = 0 ]; then n=0; else read -r -p '> ' n; fi

	case $n in
	1) if [ -f /var/run/reboot-required ]; then
	     echo 'rebooting...'; sleep 3
	     echo "$rd"
	     echo "System rebooted, dont't forget to reconnect and start your Nodes again,"
	     echo "if you don't have Autostart enabled!"
	     echo "$xx"
	     if [ "$opt_mode" ]; then
	       VAR_STATUS='system: reboot'
	       NotifyMessage "info" "$VAR_DOMAIN" "$VAR_STATUS";
	     fi
	     sleep 3
	     sudo reboot
	     n='q'
	   else
	     echo 'rebooting...'; sleep 3
	     echo "$gn"
	     echo "System reboot not necessary, your nodes will be started again!"
	     echo "$xx"
	     if [ "$opt_mode" ]; then
	       VAR_STATUS='system: reboot not necessary'
	       NotifyMessage "info" "$VAR_DOMAIN" "$VAR_STATUS";
	     fi
	     sleep 3
	     n='s'
	     if ! [ "$opt_mode" ]; then DashboardHelper; fi
	   fi ;;
	*) n='s'
		if ! [ "$opt_mode" ]; then DashboardHelper; fi
	   ;;
	esac
}

Docker() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                   DLT.GREEN AUTOMATIC DOCKER INSTALLATION                   ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"

	sudo docker ps -a -q >/dev/null 2>&1

	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                            Prepare docker engine                            ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	DEBIAN_FRONTEND=noninteractive sudo apt-get update

	if [ "$VAR_DISTRIBUTION" = 'Ubuntu' ]; then
		DEBIAN_FRONTEND=noninteractive sudo apt-get install ca-certificates curl gnupg lsb-release
		DEBIAN_FRONTEND=noninteractive sudo mkdir -p /etc/apt/keyrings
		DEBIAN_FRONTEND=noninteractive sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --yes --dearmor -o /etc/apt/keyrings/docker.gpg
		echo \
			"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
			$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	fi

	if [ "$VAR_DISTRIBUTION" = 'Debian' ]; then
		DEBIAN_FRONTEND=noninteractive sudo apt-get install ca-certificates curl
		DEBIAN_FRONTEND=noninteractive sudo install -m 0755 -d /etc/apt/keyrings
		DEBIAN_FRONTEND=noninteractive sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
		DEBIAN_FRONTEND=noninteractive sudo chmod a+r /etc/apt/keyrings/docker.asc
		echo \
			"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
			$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	fi

	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                            Install docker engine                            ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	DEBIAN_FRONTEND=noninteractive sudo apt-get update
	DEBIAN_FRONTEND=noninteractive sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-compose -y

	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"

	if ! [ "$opt_mode" ]; then MainMenu; fi
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

	echo "$ca""Starting Installation or Update...""$xx";
	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear
	if [ "$VAR_NETWORK" = 2 ]; then VAR_NETWORK=1; if [ "$opt_mode" ]; then clear; exit; fi; SubMenuMaintenance; fi

	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                            Prepare Installation                             ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	echo "Stopping... $VAR_DIR"
	if [ -d /var/lib/"$VAR_DIR" ]; then cd /var/lib/"$VAR_DIR" || exit; if [ -f "/var/lib/$VAR_DIR/docker-compose.yml" ]; then docker compose down >/dev/null 2>&1; fi; fi

	echo ""
	echo "Check Directory... /var/lib/$VAR_DIR"

	if [ ! -d /var/lib/"$VAR_DIR" ]; then mkdir /var/lib/"$VAR_DIR" || exit; fi
	cd /var/lib/"$VAR_DIR" || exit

	echo ""
	echo "CleanUp Directory... /var/lib/$VAR_DIR"
	find . -maxdepth 1 -mindepth 1 ! \( -name .env -o -name data \) -exec rm -rf {} +

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

	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

	CheckConfiguration

	VAR_SALT=$(cat /dev/urandom | tr -dc '[:alpha:]' | fold -w "${1:-20}" | head -n 1)

	if [ "$VAR_CONF_RESET" = 1 ]; then

		clear
		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                               Set Parameters                                ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		VAR_HOST=$(cat .env 2>/dev/null | grep HORNET_HOST= | cut -d '=' -f 2)
		if [ -z "$VAR_HOST" ]; then
		  VAR_HOST=$(echo "$VAR_DOMAIN" | xargs)
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
		FormatToBytes $(cat /var/lib/shimmer-hornet/.env 2>/dev/null | grep HORNET_PRUNING_TARGET_SIZE= | cut -d '=' -f 2)
		if [ -z "$bytes" ]; then VAR_SHIMMER_HORNET_PRUNING_SIZE=0; else VAR_SHIMMER_HORNET_PRUNING_SIZE=$bytes; fi
		FormatToBytes "$(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 2)B"
		if [ -z "$bytes" ]; then VAR_DISK_SIZE=0; else VAR_DISK_SIZE=$bytes; fi
		FormatToBytes "$(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 4)B"
		if [ -z "$bytes" ]; then VAR_AVAILABLE_SIZE=0; else VAR_AVAILABLE_SIZE=$bytes; fi
		FormatToBytes "$(df -h /var/lib/"$VAR_DIR" | tail -1 | tr -s ' ' | cut -d ' ' -f 4)B"
		if [ -z "$bytes" ]; then VAR_SELF_SIZE=0; else VAR_SELF_SIZE=$bytes; fi
		CALCULATED_SPACE=$(echo "($VAR_DISK_SIZE-$VAR_SHIMMER_HORNET_PRUNING_SIZE)*9/10" | bc)
		RESERVED_SPACE=$(echo "($VAR_SHIMMER_HORNET_PRUNING_SIZE)" | bc)
		FormatFromBytes "$RESERVED_SPACE"; RESERVED_SPACE=$fbytes
		if [ $(($(echo "$VAR_AVAILABLE_SIZE+$VAR_SELF_SIZE < $CALCULATED_SPACE" | bc))) -eq 1 ]; then CALCULATED_SPACE=$(echo "($VAR_AVAILABLE_SIZE+$VAR_SELF_SIZE)" | bc); fi
		FormatFromBytes "$CALCULATED_SPACE"; CALCULATED_SPACE=$fbytes

		unset VAR_IOTA_HORNET_PRUNING_SIZE
		while [ -z "$VAR_IOTA_HORNET_PRUNING_SIZE" ]; do
		  VAR_IOTA_HORNET_PRUNING_SIZE=$(cat .env 2>/dev/null | grep HORNET_PRUNING_TARGET_SIZE= | cut -d '=' -f 2)
		  if [ -z "$VAR_IOTA_HORNET_PRUNING_SIZE" ]; then
		    echo "Set pruning size / max. storage size (calculated: $ca""$CALCULATED_SPACE""$xx)"; else echo "Set pruning size / max. storage size (config: $ca""$VAR_IOTA_HORNET_PRUNING_SIZE""$xx)"; echo "Press [Enter] to use existing config:"; fi
		  echo "$rd""Available diskspace: $(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 4)B/$(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 2)B ($(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 5) used) ""$xx"
		  echo "$rd""Reserved diskspace through pruning by other nodes: ""$RESERVED_SPACE""$xx"
		  echo "$ca""Calculated pruning size for HORNET (with 10% buffer): ""$CALCULATED_SPACE""$xx"
		  read -r -p '> ' VAR_TMP
		  if [ -n "$VAR_TMP" ]; then VAR_IOTA_HORNET_PRUNING_SIZE=$VAR_TMP; fi
		  if [ -z "$VAR_TMP" ]; then if [ -z "$VAR_IOTA_HORNET_PRUNING_SIZE" ]; then VAR_IOTA_HORNET_PRUNING_SIZE=$CALCULATED_SPACE; fi; fi
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
		VAR_IOTA_HORNET_AUTOPEERING=$(cat .env 2>/dev/null | grep HORNET_AUTOPEERING_ENABLED= | cut -d '=' -f 2)
		VAR_DEFAULT='true'
		if [ -z "$VAR_IOTA_HORNET_AUTOPEERING" ]; then
		  echo "Set autopeering (default: $ca$VAR_DEFAULT$xx):"; echo "Press [Enter] to use default value:"
		else
		  echo "Set autopeering (config: $ca$VAR_IOTA_HORNET_AUTOPEERING$xx)"; echo "Press [Enter] to use existing config:"
		fi
		read -r -p '> Press [E] to enable Autopeering... Press [X] key to disable... ' VAR_TMP;
		if [ -n "$VAR_TMP" ]; then
		  VAR_IOTA_HORNET_AUTOPEERING=$VAR_TMP
		  if  [ "$VAR_IOTA_HORNET_AUTOPEERING" = 'e' ] || [ "$VAR_IOTA_HORNET_AUTOPEERING" = 'E' ]; then
		    VAR_IOTA_HORNET_AUTOPEERING='true'
		  else
		    VAR_IOTA_HORNET_AUTOPEERING='false'
		fi
		elif [ -z "$VAR_IOTA_HORNET_AUTOPEERING" ]; then VAR_IOTA_HORNET_AUTOPEERING=$VAR_DEFAULT; fi

		if  [ "$VAR_IOTA_HORNET_AUTOPEERING" = 'true'  ]; then
		  echo "$gn""Set autopeering: $VAR_IOTA_HORNET_AUTOPEERING""$xx"
		else
		  echo "$rd""Set autopeering: $VAR_IOTA_HORNET_AUTOPEERING""$xx"
		fi

		VAR_IOTA_HORNET_STATIC_NEIGHBORS=$(cat .env 2>/dev/null | grep HORNET_STATIC_NEIGHBORS= | cut -d '=' -f 2)
		if [ "$VAR_IOTA_HORNET_AUTOPEERING" = 'false' ]; then
		echo ''
		VAR_DEFAULT='{nodeName}:/dns/{nodeURL}/tcp/15600/p2p/{nodeId},...';
		if [ -z "$VAR_IOTA_HORNET_STATIC_NEIGHBORS" ]; then
		  echo "Set static neighbor(s) (template: $ca""$VAR_DEFAULT""$xx):"; else echo "Set static neighbor(s) (config: ""$ca""\n""$(echo "$VAR_IOTA_HORNET_STATIC_NEIGHBORS" | tr ',' '\n')""\n""$xx)"; echo "Press [Enter] to use existing config (template: $ca""$VAR_DEFAULT""$xx):"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_IOTA_HORNET_STATIC_NEIGHBORS=$VAR_TMP; elif [ -z "$VAR_IOTA_HORNET_STATIC_NEIGHBORS" ]; then VAR_IOTA_HORNET_STATIC_NEIGHBORS=''; fi
		echo "$gn""Set static neighbor(s): ""\n""$(echo "$VAR_IOTA_HORNET_STATIC_NEIGHBORS" | tr ',' '\n')""$xx"
		fi

		echo ''
		VAR_USERNAME=$(cat .env 2>/dev/null | grep DASHBOARD_USERNAME= | cut -d '=' -f 2)
		VAR_DEFAULT=$(cat /dev/urandom | tr -dc '[:alpha:]' | fold -w "${1:-10}" | head -n 1);
		if [ -z "$VAR_USERNAME" ]; then
		echo "Set dashboard username (generated: $ca""$VAR_DEFAULT""$xx):"; echo "to use generated value press [Enter]:"; else echo "Set dashboard username (config: $ca""$VAR_USERNAME""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_USERNAME=$VAR_TMP; elif [ -z "$VAR_USERNAME" ]; then VAR_USERNAME=$VAR_DEFAULT; fi
		echo "$gn""Set dashboard username: $VAR_USERNAME""$xx"

		echo ''
		VAR_DASHBOARD_PASSWORD=$(cat .env 2>/dev/null | grep DASHBOARD_PASSWORD= | cut -d '=' -f 2)
		VAR_DASHBOARD_SALT=$(cat .env 2>/dev/null | grep DASHBOARD_SALT= | cut -d '=' -f 2)
		VAR_DEFAULT=$(cat /dev/urandom | tr -dc '[:alpha:]' | fold -w "${1:-20}" | head -n 1);
		if [ -z "$VAR_DASHBOARD_PASSWORD" ]; then
		echo "Set dashboard password / will be saved as hash ($ca""use generated""$xx):"; echo "to use generated value press [Enter]:"; else echo "Set dashboard password / will be saved as hash (config: $ca""use existing""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then
		  VAR_PASSWORD=$VAR_TMP
		  echo "$gn""Set dashboard password: new""$xx"
		else
		  if [ -z "$VAR_DASHBOARD_PASSWORD" ]; then
		    VAR_PASSWORD=$VAR_DEFAULT
		    echo "$gn""Set dashboard password: ""$VAR_DEFAULT""$xx"
		  else
		    VAR_PASSWORD=''
		    echo "$gn""Set dashboard password: use existing""$xx"
		  fi
		fi

		echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                              Write Parameters                               ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		if [ "$VAR_IOTA_HORNET_HTTPS_PORT" = "443" ]; then CheckCertificate; else VAR_CERT=1; fi

		if [ -d /var/lib/"$VAR_DIR" ]; then cd /var/lib/"$VAR_DIR" || exit; fi
		if [ -f .env ]; then rm .env; fi

		echo "HORNET_VERSION=$VAR_IOTA_HORNET_VERSION" >> .env

		echo "HORNET_NETWORK=$VAR_IOTA_HORNET_NETWORK" >> .env

		echo "HORNET_HOST=$VAR_HOST" >> .env
		echo "HORNET_PRUNING_TARGET_SIZE=$VAR_IOTA_HORNET_PRUNING_SIZE" >> .env
		echo "HORNET_POW_ENABLED=$VAR_IOTA_HORNET_POW" >> .env
		echo "HORNET_HTTPS_PORT=$VAR_IOTA_HORNET_HTTPS_PORT" >> .env
		echo "HORNET_GOSSIP_PORT=15600" >> .env
		echo "HORNET_AUTOPEERING_ENABLED=$VAR_IOTA_HORNET_AUTOPEERING" >> .env

		if [ "$VAR_IOTA_HORNET_AUTOPEERING" = 'true' ]; then
			echo "HORNET_AUTOPEERING_PORT=14626" >> .env
		fi

		if [ -n "$VAR_IOTA_HORNET_STATIC_NEIGHBORS" ]; then
			echo "HORNET_STATIC_NEIGHBORS=$VAR_IOTA_HORNET_STATIC_NEIGHBORS" >> .env
		fi

		echo "RESTAPI_SALT=$VAR_SALT" >> .env

		if [ "$VAR_CERT" = 0 ]
		then
			echo "HORNET_HTTP_PORT=80" >> .env
			clear
			echo ""
			echo "╔═════════════════════════════════════════════════════════════════════════════╗"
			echo "║                     Retrieve Let's Encrypt Certificate                      ║"
			echo "╚═════════════════════════════════════════════════════════════════════════════╝"
			echo ""

			unset VAR_ACME_EMAIL
				while [ -z "$VAR_ACME_EMAIL" ]; do
			 	 VAR_ACME_EMAIL=$(cat .env 2>/dev/null | grep ACME_EMAIL= | cut -d '=' -f 2)
				  if [ -z "$ACME_EMAIL" ]; then
				    echo "Set mail for certificate renewal:"; else echo "Set mail for certificate renewal (config: $ca""$ACME_EMAIL""$xx)"; echo "Press [Enter] to use existing config:"; fi
				  read -r -p '> ' VAR_TMP
				  if [ -n "$VAR_TMP" ]; then VAR_ACME_EMAIL=$VAR_TMP; fi
				  if ! [ -z "${VAR_ACME_EMAIL##*@*}" ]; then
				    VAR_ACME_EMAIL=''
				    echo "$rd""Set mail for certificate renewal: Please insert correct mail!"; echo "$xx"
				  fi
				done
			echo "$gn""Set mail for certificate renewal: $VAR_ACME_EMAIL""$xx"
			echo "ACME_EMAIL=$VAR_ACME_EMAIL" >> .env
		else
			echo "HORNET_HTTP_PORT=8081" >> .env
			echo "SSL_CONFIG=certs" >> .env
			echo "HORNET_SSL_CERT=/etc/letsencrypt/live/$VAR_HOST/fullchain.pem" >> .env
			echo "HORNET_SSL_KEY=/etc/letsencrypt/live/$VAR_HOST/privkey.pem" >> .env
		fi

		echo "INX_INDEXER_VERSION=$VAR_IOTA_INX_INDEXER_VERSION" >> .env
		echo "INX_MQTT_VERSION=$VAR_IOTA_INX_MQTT_VERSION" >> .env
		echo "INX_PARTICIPATION_VERSION=$VAR_IOTA_INX_PARTICIPATION_VERSION" >> .env
		echo "INX_SPAMMER_VERSION=$VAR_IOTA_INX_SPAMMER_VERSION" >> .env
		echo "INX_POI_VERSION=$VAR_IOTA_INX_POI_VERSION" >> .env
		echo "INX_DASHBOARD_VERSION=$VAR_IOTA_INX_DASHBOARD_VERSION" >> .env

		echo "done..."

	else
		if [ -f .env ]; then sed -i "s/HORNET_VERSION=.*/HORNET_VERSION=$VAR_IOTA_HORNET_VERSION/g" .env; fi
		if [ -f .env ]; then sed -i "s/INX_INDEXER_VERSION=.*/INX_INDEXER_VERSION=$VAR_IOTA_INX_INDEXER_VERSION/g" .env; fi
		if [ -f .env ]; then sed -i "s/INX_MQTT_VERSION=.*/INX_MQTT_VERSION=$VAR_IOTA_INX_MQTT_VERSION/g" .env; fi
		if [ -f .env ]; then sed -i "s/INX_PARTICIPATION_VERSION=.*/INX_PARTICIPATION_VERSION=$VAR_IOTA_INX_PARTICIPATION_VERSION/g" .env; fi
		if [ -f .env ]; then sed -i "s/INX_SPAMMER_VERSION=.*/INX_SPAMMER_VERSION=$VAR_IOTA_INX_SPAMMER_VERSION/g" .env; fi
		if [ -f .env ]; then sed -i "s/INX_POI_VERSION=.*/INX_POI_VERSION=$VAR_IOTA_INX_POI_VERSION/g" .env; fi
		if [ -f .env ]; then sed -i "s/INX_DASHBOARD_VERSION=.*/INX_DASHBOARD_VERSION=$VAR_IOTA_INX_DASHBOARD_VERSION/g" .env; fi

		VAR_IOTA_HORNET_AUTOPEERING=$(cat .env 2>/dev/null | grep HORNET_AUTOPEERING_ENABLED | cut -d '=' -f 2)
		if [ -z "$VAR_IOTA_HORNET_AUTOPEERING" ]; then
		    echo "HORNET_AUTOPEERING_ENABLED=true" >> .env
		fi
   
		VAR_HOST=$(cat .env 2>/dev/null | grep _HOST | cut -d '=' -f 2)
		fgrep -q "RESTAPI_SALT" .env || echo "RESTAPI_SALT=$VAR_SALT" >> .env
	fi

	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                                 Pull Data                                   ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	docker network create iota >/dev/null 2>&1
	docker compose pull 2>&1 | grep "Pulled" | sort

	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

	if [ "$VAR_CONF_RESET" = 1 ]; then

		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                               Set Credentials                               ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		if [ -n "$VAR_PASSWORD" ]; then
		  credentials=$(docker run iotaledger/hornet tool pwd-hash --json --password "$VAR_PASSWORD" | sed -e 's/\r//g') >/dev/null 2>&1
		  VAR_DASHBOARD_PASSWORD=$(echo "$credentials" | jq -r '.passwordHash')
		  VAR_DASHBOARD_SALT=$(echo "$credentials" | jq -r '.passwordSalt')
		  echo "passwordHash: "$VAR_DASHBOARD_PASSWORD
		  echo "passwordSalt: "$VAR_DASHBOARD_SALT  
		else
		  echo "credentials not changed..."
		fi

		echo "DASHBOARD_USERNAME=$VAR_USERNAME" >> .env
		echo "DASHBOARD_PASSWORD=$VAR_DASHBOARD_PASSWORD" >> .env
		echo "DASHBOARD_SALT=$VAR_DASHBOARD_SALT" >> .env

		echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

	fi

	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                               Prepare Docker                                ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	if [ -d /var/lib/"$VAR_DIR" ]; then cd /var/lib/"$VAR_DIR" || exit; fi
	./prepare_docker.sh
	chown -R 65532:65532 /var/lib/"$VAR_DIR"/data

	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

	if [ "$VAR_CONF_RESET" = 1 ]; then

		clear
		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                             Configure Firewall                              ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		if [ "$VAR_CERT" = 0 ]; then echo ufw allow '80/tcp' && ufw allow '80/tcp'; fi

		echo ufw allow "$VAR_IOTA_HORNET_HTTPS_PORT/tcp" && ufw allow "$VAR_IOTA_HORNET_HTTPS_PORT/tcp"
		echo ufw allow '15600/tcp' && ufw allow '15600/tcp'

		if [ "$VAR_IOTA_HORNET_AUTOPEERING" = "true" ]; then
		  echo ufw allow '14626/udp' && ufw allow '14626/udp'
		fi

		echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

		clear
		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                              Download Snapshot                              ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"

		echo "$ca"
		echo 'Please wait, downloading snapshots may take some time...'
		echo "$xx"

		echo "Download latest full snapshot... $VAR_IOTA_HORNET_NETWORK"
		VAR_SNAPSHOT=$(cat /var/lib/"$VAR_DIR"/data/config/config-"$VAR_IOTA_HORNET_NETWORK".json 2>/dev/null | jq -r '.snapshots.downloadURLs[].full')
		wget -cO - "$VAR_SNAPSHOT" -q --show-progress --progress=bar > /var/lib/"$VAR_DIR"/data/snapshots/"$VAR_IOTA_HORNET_NETWORK"/full_snapshot.bin
		chmod 744 /var/lib/"$VAR_DIR"/data/snapshots/"$VAR_IOTA_HORNET_NETWORK"/full_snapshot.bin

		echo ""

		echo "Download latest delta snapshot... $VAR_IOTA_HORNET_NETWORK"
		VAR_SNAPSHOT=$(cat /var/lib/"$VAR_DIR"/data/config/config-"$VAR_IOTA_HORNET_NETWORK".json 2>/dev/null | jq -r '.snapshots.downloadURLs[].delta')
		wget -cO - "$VAR_SNAPSHOT" -q --show-progress --progress=bar > /var/lib/"$VAR_DIR"/data/snapshots/"$VAR_IOTA_HORNET_NETWORK"/delta_snapshot.bin
		chmod 744 /var/lib/"$VAR_DIR"/data/snapshots/"$VAR_IOTA_HORNET_NETWORK"/delta_snapshot.bin

		echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

	fi

	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                                Start Hornet                                 ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"

	if [ -d /var/lib/"$VAR_DIR" ]; then cd /var/lib/"$VAR_DIR" || exit; fi

	echo "$ca"
	echo 'Please wait, if importing snapshot, it can take up to 10 minutes...'
	echo "$xx"

	docker compose up -d

	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                           Set external Parameters                           ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	RenameContainer

	if [ -n "$VAR_PASSWORD" ]; then
	  if [ "$VAR_CONF_RESET" = 1 ]; then docker exec -it grafana grafana-cli admin reset-admin-password "$VAR_PASSWORD"; fi
	else echo 'done...'; VAR_PASSWORD='********'; fi

	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

	if [ -s "/var/lib/$VAR_DIR/data/letsencrypt/acme.json" ]; then SetCertificateGlobal; fi

	clear
	echo ""

	if [ "$VAR_CONF_RESET" = 1 ]; then

		echo "--------------------------- INSTALLATION IS FINISHED --------------------------"
		echo ""
		echo "═══════════════════════════════════════════════════════════════════════════════"
		echo "domain name: $VAR_HOST"
		echo "https port:  $VAR_IOTA_HORNET_HTTPS_PORT"
		echo "-------------------------------------------------------------------------------"
		echo "autopeering: $VAR_IOTA_HORNET_AUTOPEERING"
		echo "-------------------------------------------------------------------------------"
		echo "hornet dashboard: https://$VAR_HOST/dashboard"
		echo "hornet username:  $VAR_USERNAME"
		echo "hornet password:  $VAR_PASSWORD"
		echo "-------------------------------------------------------------------------------"
		echo "api: https://$VAR_HOST:$VAR_IOTA_HORNET_HTTPS_PORT/api/core/v2/info"
		echo "-------------------------------------------------------------------------------"
		echo "grafana dashboard: https://$VAR_HOST/grafana"
		echo "grafana username:  admin"
		echo "grafana password:  <same as hornet password>"
		echo "═══════════════════════════════════════════════════════════════════════════════"
		echo ""
	else
	    echo "------------------------------ UPDATE IS FINISHED -----------------------------"
	    echo ""
	fi

	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

	if ! [ "$opt_mode" ]; then Dashboard; fi
}

IotaWasp() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║            DLT.GREEN AUTOMATIC IOTA-WASP INSTALLATION WITH DOCKER           ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""
	echo "$ca""Wasp is an INX-Plugin and can only be installed on the same Server as IOTA!""$xx";
	CheckShimmer
	if [ "$VAR_NETWORK" = 2 ]; then echo "$rd""It's not supported (Security!) to install Nodes from Network"; echo "IOTA and Shimmer on the same Server, deinstall Shimmer Nodes first!""$xx"; fi

	echo "$ca""Starting Installation or Update...""$xx";
	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear
	if [ "$VAR_NETWORK" = 2 ]; then VAR_NETWORK=1; if [ "$opt_mode" ]; then clear; exit; fi; SubMenuMaintenance; fi

	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                            Prepare Installation                             ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""
	echo "Stopping... $VAR_DIR"
	if [ -d /var/lib/"$VAR_DIR" ]; then cd /var/lib/"$VAR_DIR" || exit; if [ -f "/var/lib/$VAR_DIR/docker-compose.yml" ]; then docker compose down >/dev/null 2>&1; fi; fi

	echo ""
	echo "Check Directory... /var/lib/$VAR_DIR"

	if [ ! -d /var/lib/"$VAR_DIR" ]; then mkdir /var/lib/"$VAR_DIR" || exit; fi
	cd /var/lib/"$VAR_DIR" || exit

	echo ""
	echo "CleanUp Directory... /var/lib/$VAR_DIR"
	find . -maxdepth 1 -mindepth 1 ! \( -name .env -o -name data \) -exec rm -rf {} +

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

	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

	CheckConfiguration

	VAR_WASP_LEDGER_NETWORK='iota'

	if [ "$VAR_CONF_RESET" = 1 ]; then

		clear
		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                               Set Parameters                                ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		VAR_HOST=$(cat .env 2>/dev/null | grep WASP_HOST= | cut -d '=' -f 2)
		if [ -z "$VAR_HOST" ]; then
		  VAR_HOST=$(echo "$VAR_DOMAIN" | xargs)
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
		  echo "Set API port (default: $ca"$VAR_DEFAULT"$xx):"; echo "Press [Enter] to use default value:"; else echo "Set API port (config: $ca""$VAR_IOTA_WASP_API_PORT""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_IOTA_WASP_API_PORT=$VAR_TMP; elif [ -z "$VAR_IOTA_WASP_API_PORT" ]; then VAR_IOTA_WASP_API_PORT=$VAR_DEFAULT; fi
		echo "$gn""Set API port: $VAR_IOTA_WASP_API_PORT""$xx"

		echo ''
		VAR_IOTA_WASP_PEERING_PORT=$(cat .env 2>/dev/null | grep WASP_PEERING_PORT= | cut -d '=' -f 2)
		VAR_DEFAULT='4000';
		if [ -z "$VAR_IOTA_WASP_PEERING_PORT" ]; then
		  echo "Set peering port (default: $ca"$VAR_DEFAULT"$xx):"; echo "Press [Enter] to use default value:"; else echo "Set peering port (config: $ca""$VAR_IOTA_WASP_PEERING_PORT""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_IOTA_WASP_PEERING_PORT=$VAR_TMP; elif [ -z "$VAR_IOTA_WASP_PEERING_PORT" ]; then VAR_IOTA_WASP_PEERING_PORT=$VAR_DEFAULT; fi
		echo "$gn""Set peering port: $VAR_IOTA_WASP_PEERING_PORT""$xx"

		echo ''
		VAR_IOTA_WASP_PRUNING_MIN_STATES_TO_KEEP=$(cat .env 2>/dev/null | grep WASP_PRUNING_MIN_STATES_TO_KEEP= | cut -d '=' -f 2)
		VAR_DEFAULT='100000';
		if [ -z "$VAR_IOTA_WASP_PRUNING_MIN_STATES_TO_KEEP" ]; then
		  echo "Set pruning min states to keep (default: $ca"$VAR_DEFAULT"$xx):"; echo "Press [Enter] to use default value:"; else echo "Set pruning min states to keep (config: $ca""$VAR_IOTA_WASP_PRUNING_MIN_STATES_TO_KEEP""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_IOTA_WASP_PRUNING_MIN_STATES_TO_KEEP=$VAR_TMP; elif [ -z "$VAR_IOTA_WASP_PRUNING_MIN_STATES_TO_KEEP" ]; then VAR_IOTA_WASP_PRUNING_MIN_STATES_TO_KEEP=$VAR_DEFAULT; fi
		echo "$gn""Set pruning min states to keep: $VAR_IOTA_WASP_PRUNING_MIN_STATES_TO_KEEP""$xx"

		echo ''
		VAR_USERNAME=$(cat .env 2>/dev/null | grep DASHBOARD_USERNAME= | cut -d '=' -f 2)
		VAR_DEFAULT=$(cat /dev/urandom | tr -dc '[:alpha:]' | fold -w "${1:-10}" | head -n 1 | tr '[:upper:]' '[:lower:]');
		if [ -z "$VAR_USERNAME" ]; then
		echo "Set dashboard username (generated: $ca""$VAR_DEFAULT""$xx):"; echo "to use generated value press [Enter]:"; else echo "Set dashboard username (config: $ca""$VAR_USERNAME""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_USERNAME=$VAR_TMP; elif [ -z "$VAR_USERNAME" ]; then VAR_USERNAME=$VAR_DEFAULT; fi
		echo "$gn""Set dashboard username: $VAR_USERNAME""$xx"

		echo ''
		VAR_DASHBOARD_PASSWORD=$(cat .env 2>/dev/null | grep DASHBOARD_PASSWORD= | cut -d '=' -f 2)
		VAR_DASHBOARD_SALT=$(cat .env 2>/dev/null | grep DASHBOARD_SALT= | cut -d '=' -f 2)
		VAR_DEFAULT=$(cat /dev/urandom | tr -dc '[:alpha:]' | fold -w "${1:-20}" | head -n 1);
		if [ -z "$VAR_DASHBOARD_PASSWORD" ]; then
		echo "Set dashboard password / will be saved as hash ($ca""use generated""$xx):"; echo "to use generated value press [Enter]:"; else echo "Set dashboard password / will be saved as hash (config: $ca""use existing""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then
		  VAR_PASSWORD=$VAR_TMP
		  echo "$gn""Set dashboard password: new""$xx"
		else
		  if [ -z "$VAR_DASHBOARD_PASSWORD" ]; then
		    VAR_PASSWORD=$VAR_DEFAULT
		    echo "$gn""Set dashboard password: ""$VAR_DEFAULT""$xx"
		  else
		    VAR_PASSWORD=''
		    echo "$gn""Set dashboard password: use existing""$xx"
		  fi
		fi

		echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                              Write Parameters                               ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		if [ "$VAR_IOTA_WASP_HTTPS_PORT" = "443" ]; then CheckCertificate; else VAR_CERT=1; fi

		if [ -d /var/lib/"$VAR_DIR" ]; then cd /var/lib/"$VAR_DIR" || exit; fi

		if [ -f .env ]; then
		  WASP_TRUSTED_NODE=$(cat .env | grep WASP_TRUSTED_NODE)
		  WASP_TRUSTED_ACCESSNODE=$(cat .env | grep WASP_TRUSTED_ACCESSNODE)
		rm .env; fi

		echo "WASP_VERSION=$VAR_IOTA_WASP_VERSION" >> .env
		echo "WASP_DASHBOARD_VERSION=$VAR_IOTA_WASP_DASHBOARD_VERSION" >> .env
		echo "WASP_CLI_VERSION=$VAR_IOTA_WASP_CLI_VERSION" >> .env
		echo "WASP_HOST=$VAR_HOST" >> .env
		echo "WASP_HTTPS_PORT=$VAR_IOTA_WASP_HTTPS_PORT" >> .env
		echo "WASP_API_PORT=$VAR_IOTA_WASP_API_PORT" >> .env
		echo "WASP_PEERING_PORT=$VAR_IOTA_WASP_PEERING_PORT" >> .env
		echo "WASP_LEDGER_NETWORK=$VAR_WASP_LEDGER_NETWORK" >> .env
		echo "WASP_PRUNING_MIN_STATES_TO_KEEP=$VAR_IOTA_WASP_PRUNING_MIN_STATES_TO_KEEP" >> .env
		echo "WASP_LOG_LEVEL=debug" >> .env
		echo "WASP_DEBUG_SKIP_HEALTH_CHECK=true" >> .env
		
		if [ "$VAR_CERT" = 0 ]
		then
			echo "WASP_HTTP_PORT=80" >> .env
			clear
			echo ""
			echo "╔═════════════════════════════════════════════════════════════════════════════╗"
			echo "║                     Retrieve Let's Encrypt Certificate                      ║"
			echo "╚═════════════════════════════════════════════════════════════════════════════╝"
			echo ""
			unset VAR_ACME_EMAIL
				while [ -z "$VAR_ACME_EMAIL" ]; do
			 	 VAR_ACME_EMAIL=$(cat .env 2>/dev/null | grep ACME_EMAIL= | cut -d '=' -f 2)
				  if [ -z "$ACME_EMAIL" ]; then
				    echo "Set mail for certificate renewal:"; else echo "Set mail for certificate renewal (config: $ca""$ACME_EMAIL""$xx)"; echo "Press [Enter] to use existing config:"; fi
				  read -r -p '> ' VAR_TMP
				  if [ -n "$VAR_TMP" ]; then VAR_ACME_EMAIL=$VAR_TMP; fi
				  if ! [ -z "${VAR_ACME_EMAIL##*@*}" ]; then
				    VAR_ACME_EMAIL=''
				    echo "$rd""Set mail for certificate renewal: Please insert correct mail!"; echo "$xx"
				  fi
				done
			echo "$gn""Set mail for certificate renewal: $VAR_ACME_EMAIL""$xx"
			echo "ACME_EMAIL=$VAR_ACME_EMAIL" >> .env
		else
			echo "WASP_HTTP_PORT=8082" >> .env
			echo "SSL_CONFIG=certs" >> .env
			echo "WASP_SSL_CERT=/etc/letsencrypt/live/$VAR_HOST/fullchain.pem" >> .env
			echo "WASP_SSL_KEY=/etc/letsencrypt/live/$VAR_HOST/privkey.pem" >> .env
		fi

		echo "done..."

	else
		if [ -f .env ]; then sed -i "s/WASP_VERSION=.*/WASP_VERSION=$VAR_IOTA_WASP_VERSION/g" .env; fi
		VAR_HOST=$(cat .env 2>/dev/null | grep _HOST | cut -d '=' -f 2)
		VAR_DASHBOARD_VERSION=$(cat .env 2>/dev/null | grep WASP_DASHBOARD_VERSION | cut -d '=' -f 2)
		VAR_SALT=$(cat .env 2>/dev/null | grep DASHBOARD_SALT | cut -d '=' -f 2)
		VAR_CLI=$(cat .env 2>/dev/null | grep WASP_CLI_VERSION | cut -d '=' -f 2)

		if [ -z "$VAR_DASHBOARD_VERSION" ]; then
		    echo "WASP_DASHBOARD_VERSION=$VAR_IOTA_WASP_DASHBOARD_VERSION" >> .env
		fi

		if [ -z "$VAR_CLI" ]; then
		    echo "WASP_CLI_VERSION=$VAR_IOTA_WASP_CLI_VERSION" >> .env
		fi

		if [ -f .env ]; then sed -i "s/WASP_CLI_VERSION=.*/WASP_CLI_VERSION=$VAR_IOTA_WASP_CLI_VERSION/g" .env; fi
		if [ -f .env ]; then sed -i "s/WASP_DASHBOARD_VERSION=.*/WASP_DASHBOARD_VERSION=$VAR_IOTA_WASP_DASHBOARD_VERSION/g" .env; fi

		if [ -z "$VAR_SALT" ]; then
		    VAR_PASSWORD=$(cat .env 2>/dev/null | grep DASHBOARD_PASSWORD | cut -d '=' -f 2)

			if [ -d /var/lib/shimmer-hornet ]; then cd /var/lib/shimmer-hornet || VAR_PASSWORD=''; fi
			if [ -n "$VAR_PASSWORD" ]; then
			    credentials=$(docker run iotaledger/hornet tool pwd-hash --json --password "$VAR_PASSWORD" | sed -e 's/\r//g') >/dev/null 2>&1

			    VAR_DASHBOARD_PASSWORD=$(echo "$credentials" | jq -r '.passwordHash')
			    VAR_DASHBOARD_SALT=$(echo "$credentials" | jq -r '.passwordSalt')

			    if [ -d /var/lib/"$VAR_DIR" ]; then cd /var/lib/"$VAR_DIR" || exit; fi

			    if [ -f .env ]; then sed -i "s/DASHBOARD_PASSWORD=.*/DASHBOARD_PASSWORD=$VAR_DASHBOARD_PASSWORD/g" .env; fi
			    echo "DASHBOARD_SALT=$VAR_DASHBOARD_SALT" >> .env

			fi
			if [ -d /var/lib/"$VAR_DIR" ]; then cd /var/lib/"$VAR_DIR" || exit; fi
		fi

	fi

	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                                 Pull Data                                   ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	docker network create iota >/dev/null 2>&1
	docker compose pull 2>&1 | grep "Pulled" | sort

	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

	if [ "$VAR_CONF_RESET" = 1 ]; then

		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                               Set Credentials                               ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		if [ -n "$VAR_PASSWORD" ]; then
		  credentials=$(docker run iotaledger/hornet tool pwd-hash --json --password "$VAR_PASSWORD" | sed -e 's/\r//g') >/dev/null 2>&1
		  VAR_DASHBOARD_PASSWORD=$(echo "$credentials" | jq -r '.passwordHash')
		  VAR_DASHBOARD_SALT=$(echo "$credentials" | jq -r '.passwordSalt')
		  echo "passwordHash: "$VAR_DASHBOARD_PASSWORD
		  echo "passwordSalt: "$VAR_DASHBOARD_SALT  
		else
		  echo "credentials not changed..."
		fi

		echo "DASHBOARD_USERNAME=$VAR_USERNAME" >> .env
		echo "DASHBOARD_PASSWORD=$VAR_DASHBOARD_PASSWORD" >> .env
		echo "DASHBOARD_SALT=$VAR_DASHBOARD_SALT" >> .env

		echo "" >> .env
		echo "### TRUSTED PEERING ACCESSNODES ###" >> .env

		if [ -n "$WASP_TRUSTED_ACCESSNODE" ]; then
		  echo "$WASP_TRUSTED_ACCESSNODE" >> .env	
		fi

		echo "" >> .env
		echo "### TRUSTED PEERING NODES ###" >> .env

		if [ -n "$WASP_TRUSTED_NODE" ]; then
		  echo "$WASP_TRUSTED_NODE" >> .env
		fi

		echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

	fi

	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                               Prepare Docker                                ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	if [ -d /var/lib/"$VAR_DIR" ]; then cd /var/lib/"$VAR_DIR" || exit; fi
	./prepare_docker.sh
	chown -R 65532:65532 /var/lib/"$VAR_DIR"/data

	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

	if [ "$VAR_CONF_RESET" = 1 ]; then

		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                             Configure Firewall                              ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		if [ "$VAR_CERT" = 0 ]; then echo ufw allow '80/tcp' && ufw allow '80/tcp'; fi

		echo ufw allow "$VAR_IOTA_WASP_HTTPS_PORT/tcp" && ufw allow "$VAR_IOTA_WASP_HTTPS_PORT/tcp"
		echo ufw allow "$VAR_IOTA_WASP_API_PORT/tcp" && ufw allow "$VAR_IOTA_WASP_API_PORT/tcp"
		echo ufw allow "$VAR_IOTA_WASP_PEERING_PORT/tcp" && ufw allow "$VAR_IOTA_WASP_PEERING_PORT/tcp"
		echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear
	fi

	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                                 Start Wasp                                  ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	if [ -d /var/lib/"$VAR_DIR" ]; then cd /var/lib/"$VAR_DIR" || exit; fi

	docker compose up -d

	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

	clear
	RenameContainer

	if [ -z "$VAR_PASSWORD" ]; then VAR_PASSWORD='********'; fi

	if [ -s "/var/lib/$VAR_DIR/data/letsencrypt/acme.json" ]; then SetCertificateGlobal; fi

	clear
	echo ""

	if [ "$VAR_CONF_RESET" = 1 ]; then

	    echo "--------------------------- INSTALLATION IS FINISHED --------------------------"
	    echo ""
		echo "═══════════════════════════════════════════════════════════════════════════════"
		echo "domain name: $VAR_HOST"
		echo "https port:  $VAR_IOTA_WASP_HTTPS_PORT"
		echo "-------------------------------------------------------------------------------"
		echo "dashboard username: $VAR_USERNAME"
		echo "dashboard password: $VAR_PASSWORD"
		echo "-------------------------------------------------------------------------------"
		echo "api port: $VAR_IOTA_WASP_API_PORT"
		echo "-------------------------------------------------------------------------------"
		echo "peering port: $VAR_IOTA_WASP_PEERING_PORT"
		echo "-------------------------------------------------------------------------------"
		echo "ledger-connection/txstream: local to iota-hornet"
		echo "═══════════════════════════════════════════════════════════════════════════════"
		echo ""
	else
	    echo "------------------------------ UPDATE IS FINISHED -----------------------------"
	    echo ""
	fi

	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

	if ! [ "$opt_mode" ]; then Dashboard; fi
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

	echo "$ca""Starting Installation or Update...""$xx";
	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear
	if [ "$VAR_NETWORK" = 1 ]; then VAR_NETWORK=2; if [ "$opt_mode" ]; then clear; exit; fi; SubMenuMaintenance; fi

	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                            Prepare Installation                             ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	echo "Stopping... $VAR_DIR"
	if [ -d /var/lib/"$VAR_DIR" ]; then cd /var/lib/"$VAR_DIR" || exit; if [ -f "/var/lib/$VAR_DIR/docker-compose.yml" ]; then docker compose down >/dev/null 2>&1; fi; fi

	echo ""
	echo "Check Directory... /var/lib/$VAR_DIR"

	if [ ! -d /var/lib/"$VAR_DIR" ]; then mkdir /var/lib/"$VAR_DIR" || exit; fi
	cd /var/lib/"$VAR_DIR" || exit

	echo ""
	echo "CleanUp Directory... /var/lib/$VAR_DIR"
	find . -maxdepth 1 -mindepth 1 ! \( -name .env -o -name data \) -exec rm -rf {} +

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

	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

	CheckConfiguration

	VAR_SALT=$(cat /dev/urandom | tr -dc '[:alpha:]' | fold -w "${1:-20}" | head -n 1)

	if [ "$VAR_CONF_RESET" = 1 ]; then

		clear
		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                               Set Parameters                                ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		VAR_HOST=$(cat .env 2>/dev/null | grep HORNET_HOST= | cut -d '=' -f 2)
		if [ -z "$VAR_HOST" ]; then
		  VAR_HOST=$(echo "$VAR_DOMAIN" | xargs)
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
		FormatToBytes $(cat /var/lib/iota-hornet/.env 2>/dev/null | grep HORNET_PRUNING_TARGET_SIZE= | cut -d '=' -f 2)
		if [ -z "$bytes" ]; then VAR_IOTA_HORNET_PRUNING_SIZE=0; else VAR_IOTA_HORNET_PRUNING_SIZE=$bytes; fi
		FormatToBytes "$(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 2)B"
		if [ -z "$bytes" ]; then VAR_DISK_SIZE=0; else VAR_DISK_SIZE=$bytes; fi
		FormatToBytes "$(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 4)B"
		if [ -z "$bytes" ]; then VAR_AVAILABLE_SIZE=0; else VAR_AVAILABLE_SIZE=$bytes; fi
		FormatToBytes "$(df -h /var/lib/"$VAR_DIR" | tail -1 | tr -s ' ' | cut -d ' ' -f 4)B"
		if [ -z "$bytes" ]; then VAR_SELF_SIZE=0; else VAR_SELF_SIZE=$bytes; fi
		CALCULATED_SPACE=$(echo "($VAR_DISK_SIZE-$VAR_IOTA_HORNET_PRUNING_SIZE)*9/10" | bc)
		RESERVED_SPACE=$(echo "($VAR_IOTA_HORNET_PRUNING_SIZE)" | bc)
		FormatFromBytes "$RESERVED_SPACE"; RESERVED_SPACE=$fbytes
		if [ $(($(echo "$VAR_AVAILABLE_SIZE+$VAR_SELF_SIZE < $CALCULATED_SPACE" | bc))) -eq 1 ]; then CALCULATED_SPACE=$(echo "($VAR_AVAILABLE_SIZE+$VAR_SELF_SIZE)" | bc); fi
		FormatFromBytes "$CALCULATED_SPACE"; CALCULATED_SPACE=$fbytes

		unset VAR_SHIMMER_HORNET_PRUNING_SIZE
		while [ -z "$VAR_SHIMMER_HORNET_PRUNING_SIZE" ]; do
		  VAR_SHIMMER_HORNET_PRUNING_SIZE=$(cat .env 2>/dev/null | grep HORNET_PRUNING_TARGET_SIZE= | cut -d '=' -f 2)
		  if [ -z "$VAR_SHIMMER_HORNET_PRUNING_SIZE" ]; then
		    echo "Set pruning size / max. storage size (calculated: $ca""$CALCULATED_SPACE""$xx)"; else echo "Set pruning size / max. storage size (config: $ca""$VAR_SHIMMER_HORNET_PRUNING_SIZE""$xx)"; echo "Press [Enter] to use existing config:"; fi
		  echo "$rd""Available diskspace: $(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 4)B/$(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 2)B ($(df -h ./ | tail -1 | tr -s ' ' | cut -d ' ' -f 5) used) ""$xx"
		  echo "$rd""Reserved diskspace through pruning by other nodes: ""$RESERVED_SPACE""$xx"
		  echo "$ca""Calculated pruning size for HORNET (with 10% buffer): ""$CALCULATED_SPACE""$xx"
		  read -r -p '> ' VAR_TMP
		  if [ -n "$VAR_TMP" ]; then VAR_SHIMMER_HORNET_PRUNING_SIZE=$VAR_TMP; fi
		  if [ -z "$VAR_TMP" ]; then if [ -z "$VAR_SHIMMER_HORNET_PRUNING_SIZE" ]; then VAR_SHIMMER_HORNET_PRUNING_SIZE=$CALCULATED_SPACE; fi; fi
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
		VAR_SHIMMER_HORNET_AUTOPEERING=$(cat .env 2>/dev/null | grep HORNET_AUTOPEERING_ENABLED= | cut -d '=' -f 2)
		VAR_DEFAULT='true'
		if [ -z "$VAR_SHIMMER_HORNET_AUTOPEERING" ]; then
		  echo "Set autopeering (default: $ca$VAR_DEFAULT$xx):"; echo "Press [Enter] to use default value:"
		else
		  echo "Set autopeering (config: $ca$VAR_SHIMMER_HORNET_AUTOPEERING$xx)"; echo "Press [Enter] to use existing config:"
		fi
		read -r -p '> Press [E] to enable Autopeering... Press [X] key to disable... ' VAR_TMP;
		if [ -n "$VAR_TMP" ]; then
		  VAR_SHIMMER_HORNET_AUTOPEERING=$VAR_TMP
		  if  [ "$VAR_SHIMMER_HORNET_AUTOPEERING" = 'e' ] || [ "$VAR_SHIMMER_HORNET_AUTOPEERING" = 'E' ]; then
		    VAR_SHIMMER_HORNET_AUTOPEERING='true'
		  else
		    VAR_SHIMMER_HORNET_AUTOPEERING='false'
		fi
		elif [ -z "$VAR_SHIMMER_HORNET_AUTOPEERING" ]; then VAR_SHIMMER_HORNET_AUTOPEERING=$VAR_DEFAULT; fi

		if  [ "$VAR_SHIMMER_HORNET_AUTOPEERING" = 'true'  ]; then
		  echo "$gn""Set autopeering: $VAR_SHIMMER_HORNET_AUTOPEERING""$xx"
		else
		  echo "$rd""Set autopeering: $VAR_SHIMMER_HORNET_AUTOPEERING""$xx"
		fi

		VAR_SHIMMER_HORNET_STATIC_NEIGHBORS=$(cat .env 2>/dev/null | grep HORNET_STATIC_NEIGHBORS= | cut -d '=' -f 2)
		if [ "$VAR_SHIMMER_HORNET_AUTOPEERING" = 'false' ]; then
		echo ''
		VAR_DEFAULT='{nodeName}:/dns/{nodeURL}/tcp/15600/p2p/{nodeId},...';
		if [ -z "$VAR_SHIMMER_HORNET_STATIC_NEIGHBORS" ]; then
		  echo "Set static neighbor(s) (template: $ca""$VAR_DEFAULT""$xx):"; else echo "Set static neighbor(s) (config: ""$ca""\n""$(echo "$VAR_SHIMMER_HORNET_STATIC_NEIGHBORS" | tr ',' '\n')""\n""$xx)"; echo "Press [Enter] to use existing config (template: $ca""$VAR_DEFAULT""$xx):"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_SHIMMER_HORNET_STATIC_NEIGHBORS=$VAR_TMP; elif [ -z "$VAR_SHIMMER_HORNET_STATIC_NEIGHBORS" ]; then VAR_SHIMMER_HORNET_STATIC_NEIGHBORS=''; fi
		echo "$gn""Set static neighbor(s): ""\n""$(echo "$VAR_SHIMMER_HORNET_STATIC_NEIGHBORS" | tr ',' '\n')""$xx"
		fi

		echo ''
		VAR_USERNAME=$(cat .env 2>/dev/null | grep DASHBOARD_USERNAME= | cut -d '=' -f 2)
		VAR_DEFAULT=$(cat /dev/urandom | tr -dc '[:alpha:]' | fold -w "${1:-10}" | head -n 1);
		if [ -z "$VAR_USERNAME" ]; then
		echo "Set dashboard username (generated: $ca""$VAR_DEFAULT""$xx):"; echo "to use generated value press [Enter]:"; else echo "Set dashboard username (config: $ca""$VAR_USERNAME""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_USERNAME=$VAR_TMP; elif [ -z "$VAR_USERNAME" ]; then VAR_USERNAME=$VAR_DEFAULT; fi
		echo "$gn""Set dashboard username: $VAR_USERNAME""$xx"

		echo ''
		VAR_DASHBOARD_PASSWORD=$(cat .env 2>/dev/null | grep DASHBOARD_PASSWORD= | cut -d '=' -f 2)
		VAR_DASHBOARD_SALT=$(cat .env 2>/dev/null | grep DASHBOARD_SALT= | cut -d '=' -f 2)
		VAR_DEFAULT=$(cat /dev/urandom | tr -dc '[:alpha:]' | fold -w "${1:-20}" | head -n 1);
		if [ -z "$VAR_DASHBOARD_PASSWORD" ]; then
		echo "Set dashboard password / will be saved as hash ($ca""use generated""$xx):"; echo "to use generated value press [Enter]:"; else echo "Set dashboard password / will be saved as hash (config: $ca""use existing""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then
		  VAR_PASSWORD=$VAR_TMP
		  echo "$gn""Set dashboard password: new""$xx"
		else
		  if [ -z "$VAR_DASHBOARD_PASSWORD" ]; then
		    VAR_PASSWORD=$VAR_DEFAULT
		    echo "$gn""Set dashboard password: ""$VAR_DEFAULT""$xx"
		  else
		    VAR_PASSWORD=''
		    echo "$gn""Set dashboard password: use existing""$xx"
		  fi
		fi

		echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                              Write Parameters                               ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		if [ "$VAR_SHIMMER_HORNET_HTTPS_PORT" = "443" ]; then CheckCertificate; else VAR_CERT=1; fi

		if [ -d /var/lib/"$VAR_DIR" ]; then cd /var/lib/"$VAR_DIR" || exit; fi
		if [ -f .env ]; then rm .env; fi

		echo "HORNET_VERSION=$VAR_SHIMMER_HORNET_VERSION" >> .env

		echo "HORNET_NETWORK=$VAR_SHIMMER_HORNET_NETWORK" >> .env

		echo "HORNET_HOST=$VAR_HOST" >> .env
		echo "HORNET_PRUNING_TARGET_SIZE=$VAR_SHIMMER_HORNET_PRUNING_SIZE" >> .env
		echo "HORNET_POW_ENABLED=$VAR_SHIMMER_HORNET_POW" >> .env
		echo "HORNET_HTTPS_PORT=$VAR_SHIMMER_HORNET_HTTPS_PORT" >> .env
		echo "HORNET_GOSSIP_PORT=15600" >> .env
		echo "HORNET_AUTOPEERING_ENABLED=$VAR_SHIMMER_HORNET_AUTOPEERING" >> .env

		if [ "$VAR_SHIMMER_HORNET_AUTOPEERING" = 'true' ]; then
			echo "HORNET_AUTOPEERING_PORT=14626" >> .env
		fi

		if [ -n "$VAR_SHIMMER_HORNET_STATIC_NEIGHBORS" ]; then
			echo "HORNET_STATIC_NEIGHBORS=$VAR_SHIMMER_HORNET_STATIC_NEIGHBORS" >> .env
		fi

		echo "RESTAPI_SALT=$VAR_SALT" >> .env

		if [ "$VAR_CERT" = 0 ]
		then
			echo "HORNET_HTTP_PORT=80" >> .env
			clear
			echo ""
			echo "╔═════════════════════════════════════════════════════════════════════════════╗"
			echo "║                     Retrieve Let's Encrypt Certificate                      ║"
			echo "╚═════════════════════════════════════════════════════════════════════════════╝"
			echo ""

			unset VAR_ACME_EMAIL
				while [ -z "$VAR_ACME_EMAIL" ]; do
			 	 VAR_ACME_EMAIL=$(cat .env 2>/dev/null | grep ACME_EMAIL= | cut -d '=' -f 2)
				  if [ -z "$ACME_EMAIL" ]; then
				    echo "Set mail for certificate renewal:"; else echo "Set mail for certificate renewal (config: $ca""$ACME_EMAIL""$xx)"; echo "Press [Enter] to use existing config:"; fi
				  read -r -p '> ' VAR_TMP
				  if [ -n "$VAR_TMP" ]; then VAR_ACME_EMAIL=$VAR_TMP; fi
				  if ! [ -z "${VAR_ACME_EMAIL##*@*}" ]; then
				    VAR_ACME_EMAIL=''
				    echo "$rd""Set mail for certificate renewal: Please insert correct mail!"; echo "$xx"
				  fi
				done
			echo "$gn""Set mail for certificate renewal: $VAR_ACME_EMAIL""$xx"
			echo "ACME_EMAIL=$VAR_ACME_EMAIL" >> .env
		else
			echo "HORNET_HTTP_PORT=8081" >> .env
			echo "SSL_CONFIG=certs" >> .env
			echo "HORNET_SSL_CERT=/etc/letsencrypt/live/$VAR_HOST/fullchain.pem" >> .env
			echo "HORNET_SSL_KEY=/etc/letsencrypt/live/$VAR_HOST/privkey.pem" >> .env
		fi

		echo "INX_INDEXER_VERSION=$VAR_SHIMMER_INX_INDEXER_VERSION" >> .env
		echo "INX_MQTT_VERSION=$VAR_SHIMMER_INX_MQTT_VERSION" >> .env
		echo "INX_PARTICIPATION_VERSION=$VAR_SHIMMER_INX_PARTICIPATION_VERSION" >> .env
		echo "INX_SPAMMER_VERSION=$VAR_SHIMMER_INX_SPAMMER_VERSION" >> .env
		echo "INX_POI_VERSION=$VAR_SHIMMER_INX_POI_VERSION" >> .env
		echo "INX_DASHBOARD_VERSION=$VAR_SHIMMER_INX_DASHBOARD_VERSION" >> .env

		echo "done..."

	else
		if [ -f .env ]; then sed -i "s/HORNET_VERSION=.*/HORNET_VERSION=$VAR_SHIMMER_HORNET_VERSION/g" .env; fi
		if [ -f .env ]; then sed -i "s/INX_INDEXER_VERSION=.*/INX_INDEXER_VERSION=$VAR_SHIMMER_INX_INDEXER_VERSION/g" .env; fi
		if [ -f .env ]; then sed -i "s/INX_MQTT_VERSION=.*/INX_MQTT_VERSION=$VAR_SHIMMER_INX_MQTT_VERSION/g" .env; fi
		if [ -f .env ]; then sed -i "s/INX_PARTICIPATION_VERSION=.*/INX_PARTICIPATION_VERSION=$VAR_SHIMMER_INX_PARTICIPATION_VERSION/g" .env; fi
		if [ -f .env ]; then sed -i "s/INX_SPAMMER_VERSION=.*/INX_SPAMMER_VERSION=$VAR_SHIMMER_INX_SPAMMER_VERSION/g" .env; fi
		if [ -f .env ]; then sed -i "s/INX_POI_VERSION=.*/INX_POI_VERSION=$VAR_SHIMMER_INX_POI_VERSION/g" .env; fi
		if [ -f .env ]; then sed -i "s/INX_DASHBOARD_VERSION=.*/INX_DASHBOARD_VERSION=$VAR_SHIMMER_INX_DASHBOARD_VERSION/g" .env; fi

		VAR_SHIMMER_HORNET_AUTOPEERING=$(cat .env 2>/dev/null | grep HORNET_AUTOPEERING_ENABLED | cut -d '=' -f 2)
		if [ -z "$VAR_SHIMMER_HORNET_AUTOPEERING" ]; then
		    echo "HORNET_AUTOPEERING_ENABLED=true" >> .env
		fi
  
		VAR_HOST=$(cat .env 2>/dev/null | grep _HOST | cut -d '=' -f 2)
		fgrep -q "RESTAPI_SALT" .env || echo "RESTAPI_SALT=$VAR_SALT" >> .env
	fi

	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                                 Pull Data                                   ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	docker network create shimmer >/dev/null 2>&1
	docker compose pull 2>&1 | grep "Pulled" | sort

	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

	if [ "$VAR_CONF_RESET" = 1 ]; then

		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                               Set Credentials                               ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		if [ -n "$VAR_PASSWORD" ]; then
		  credentials=$(docker run iotaledger/hornet tool pwd-hash --json --password "$VAR_PASSWORD" | sed -e 's/\r//g') >/dev/null 2>&1
		  VAR_DASHBOARD_PASSWORD=$(echo "$credentials" | jq -r '.passwordHash')
		  VAR_DASHBOARD_SALT=$(echo "$credentials" | jq -r '.passwordSalt')
		  echo "passwordHash: "$VAR_DASHBOARD_PASSWORD
		  echo "passwordSalt: "$VAR_DASHBOARD_SALT  
		else
		  echo "credentials not changed..."
		fi

		echo "DASHBOARD_USERNAME=$VAR_USERNAME" >> .env
		echo "DASHBOARD_PASSWORD=$VAR_DASHBOARD_PASSWORD" >> .env
		echo "DASHBOARD_SALT=$VAR_DASHBOARD_SALT" >> .env

		echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

	fi

	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                               Prepare Docker                                ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	if [ -d /var/lib/"$VAR_DIR" ]; then cd /var/lib/"$VAR_DIR" || exit; fi
	./prepare_docker.sh
	chown -R 65532:65532 /var/lib/"$VAR_DIR"/data

	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

	if [ "$VAR_CONF_RESET" = 1 ]; then

		clear
		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                             Configure Firewall                              ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		if [ "$VAR_CERT" = 0 ]; then echo ufw allow '80/tcp' && ufw allow '80/tcp'; fi

		echo ufw allow "$VAR_SHIMMER_HORNET_HTTPS_PORT/tcp" && ufw allow "$VAR_SHIMMER_HORNET_HTTPS_PORT/tcp"
		echo ufw allow '15600/tcp' && ufw allow '15600/tcp'

		if [ "$VAR_SHIMMER_HORNET_AUTOPEERING" = "true" ]; then
		  echo ufw allow '14626/udp' && ufw allow '14626/udp'
		fi

		echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

		clear
		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                              Download Snapshot                              ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"

		echo "$ca"
		echo 'Please wait, downloading snapshots may take some time...'
		echo "$xx"

		echo "Download latest full snapshot... $VAR_SHIMMER_HORNET_NETWORK"
		VAR_SNAPSHOT=$(cat /var/lib/"$VAR_DIR"/data/config/config-"$VAR_SHIMMER_HORNET_NETWORK".json 2>/dev/null | jq -r '.snapshots.downloadURLs[].full')
		wget -cO - "$VAR_SNAPSHOT" -q --show-progress --progress=bar > /var/lib/"$VAR_DIR"/data/snapshots/"$VAR_SHIMMER_HORNET_NETWORK"/full_snapshot.bin
		chmod 744 /var/lib/"$VAR_DIR"/data/snapshots/"$VAR_SHIMMER_HORNET_NETWORK"/full_snapshot.bin

		echo ""

		echo "Download latest delta snapshot... $VAR_SHIMMER_HORNET_NETWORK"
		VAR_SNAPSHOT=$(cat /var/lib/"$VAR_DIR"/data/config/config-"$VAR_SHIMMER_HORNET_NETWORK".json 2>/dev/null | jq -r '.snapshots.downloadURLs[].delta')
		wget -cO - "$VAR_SNAPSHOT" -q --show-progress --progress=bar > /var/lib/"$VAR_DIR"/data/snapshots/"$VAR_SHIMMER_HORNET_NETWORK"/delta_snapshot.bin
		chmod 744 /var/lib/"$VAR_DIR"/data/snapshots/"$VAR_SHIMMER_HORNET_NETWORK"/delta_snapshot.bin

		echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

	fi

	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                                Start Hornet                                 ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"

	if [ -d /var/lib/"$VAR_DIR" ]; then cd /var/lib/"$VAR_DIR" || exit; fi

	echo "$ca"
	echo 'Please wait, if importing snapshot, it can take up to 10 minutes...'
	echo "$xx"

	docker compose up -d

	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                           Set external Parameters                           ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	RenameContainer

	if [ -n "$VAR_PASSWORD" ]; then
	  if [ "$VAR_CONF_RESET" = 1 ]; then docker exec -it grafana grafana-cli admin reset-admin-password "$VAR_PASSWORD"; fi
	else echo 'done...'; VAR_PASSWORD='********'; fi

	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

	if [ -s "/var/lib/$VAR_DIR/data/letsencrypt/acme.json" ]; then SetCertificateGlobal; fi

	clear
	echo ""

	if [ "$VAR_CONF_RESET" = 1 ]; then

		echo "--------------------------- INSTALLATION IS FINISHED --------------------------"
		echo ""
		echo "═══════════════════════════════════════════════════════════════════════════════"
		echo "domain name: $VAR_HOST"
		echo "https port:  $VAR_SHIMMER_HORNET_HTTPS_PORT"
		echo "-------------------------------------------------------------------------------"
		echo "autopeering: $VAR_SHIMMER_HORNET_AUTOPEERING"
		echo "-------------------------------------------------------------------------------"
		echo "hornet dashboard: https://$VAR_HOST/dashboard"
		echo "hornet username:  $VAR_USERNAME"
		echo "hornet password:  $VAR_PASSWORD"
		echo "-------------------------------------------------------------------------------"
		echo "api: https://$VAR_HOST:$VAR_SHIMMER_HORNET_HTTPS_PORT/api/core/v2/info"
		echo "-------------------------------------------------------------------------------"
		echo "grafana dashboard: https://$VAR_HOST/grafana"
		echo "grafana username:  admin"
		echo "grafana password:  <same as hornet password>"
		echo "═══════════════════════════════════════════════════════════════════════════════"
		echo ""
	else
	    echo "------------------------------ UPDATE IS FINISHED -----------------------------"
	    echo ""
	fi

	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

	if ! [ "$opt_mode" ]; then Dashboard; fi
}

ShimmerWasp() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║          DLT.GREEN AUTOMATIC SHIMMER-WASP INSTALLATION WITH DOCKER          ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""
	echo "$ca""Wasp is an INX-Plugin and can only be installed on the same Server as Shimmer!""$xx";
	CheckIota
	if [ "$VAR_NETWORK" = 1 ]; then echo "$rd""It's not supported (Security!) to install Nodes from Network"; echo "Shimmer and IOTA on the same Server, deinstall IOTA Nodes first!""$xx"; fi

	echo "$ca""Starting Installation or Update...""$xx";
	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear
	if [ "$VAR_NETWORK" = 1 ]; then VAR_NETWORK=2; if [ "$opt_mode" ]; then clear; exit; fi; SubMenuMaintenance; fi

	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                            Prepare Installation                             ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""
	echo "Stopping... $VAR_DIR"
	if [ -d /var/lib/"$VAR_DIR" ]; then cd /var/lib/"$VAR_DIR" || exit; if [ -f "/var/lib/$VAR_DIR/docker-compose.yml" ]; then docker compose down >/dev/null 2>&1; fi; fi

	echo ""
	echo "Check Directory... /var/lib/$VAR_DIR"

	if [ ! -d /var/lib/"$VAR_DIR" ]; then mkdir /var/lib/"$VAR_DIR" || exit; fi
	cd /var/lib/"$VAR_DIR" || exit

	echo ""
	echo "CleanUp Directory... /var/lib/$VAR_DIR"
	find . -maxdepth 1 -mindepth 1 ! \( -name .env -o -name data \) -exec rm -rf {} +

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

	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

	CheckConfiguration

	VAR_WASP_LEDGER_NETWORK='shimmer'

	if [ "$VAR_CONF_RESET" = 1 ]; then

		clear
		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                               Set Parameters                                ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		VAR_HOST=$(cat .env 2>/dev/null | grep WASP_HOST= | cut -d '=' -f 2)
		if [ -z "$VAR_HOST" ]; then
		  VAR_HOST=$(echo "$VAR_DOMAIN" | xargs)
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
		  echo "Set API port (default: $ca"$VAR_DEFAULT"$xx):"; echo "Press [Enter] to use default value:"; else echo "Set API port (config: $ca""$VAR_SHIMMER_WASP_API_PORT""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_SHIMMER_WASP_API_PORT=$VAR_TMP; elif [ -z "$VAR_SHIMMER_WASP_API_PORT" ]; then VAR_SHIMMER_WASP_API_PORT=$VAR_DEFAULT; fi
		echo "$gn""Set API port: $VAR_SHIMMER_WASP_API_PORT""$xx"

		echo ''
		VAR_SHIMMER_WASP_PEERING_PORT=$(cat .env 2>/dev/null | grep WASP_PEERING_PORT= | cut -d '=' -f 2)
		VAR_DEFAULT='4000';
		if [ -z "$VAR_SHIMMER_WASP_PEERING_PORT" ]; then
		  echo "Set peering port (default: $ca"$VAR_DEFAULT"$xx):"; echo "Press [Enter] to use default value:"; else echo "Set peering port (config: $ca""$VAR_SHIMMER_WASP_PEERING_PORT""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_SHIMMER_WASP_PEERING_PORT=$VAR_TMP; elif [ -z "$VAR_SHIMMER_WASP_PEERING_PORT" ]; then VAR_SHIMMER_WASP_PEERING_PORT=$VAR_DEFAULT; fi
		echo "$gn""Set peering port: $VAR_SHIMMER_WASP_PEERING_PORT""$xx"

		echo ''
		VAR_SHIMMER_WASP_PRUNING_MIN_STATES_TO_KEEP=$(cat .env 2>/dev/null | grep WASP_PRUNING_MIN_STATES_TO_KEEP= | cut -d '=' -f 2)
		VAR_DEFAULT='100000';
		if [ -z "$VAR_SHIMMER_WASP_PRUNING_MIN_STATES_TO_KEEP" ]; then
		  echo "Set pruning min states to keep (default: $ca"$VAR_DEFAULT"$xx):"; echo "Press [Enter] to use default value:"; else echo "Set pruning min states to keep (config: $ca""$VAR_SHIMMER_WASP_PRUNING_MIN_STATES_TO_KEEP""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_SHIMMER_WASP_PRUNING_MIN_STATES_TO_KEEP=$VAR_TMP; elif [ -z "$VAR_SHIMMER_WASP_PRUNING_MIN_STATES_TO_KEEP" ]; then VAR_SHIMMER_WASP_PRUNING_MIN_STATES_TO_KEEP=$VAR_DEFAULT; fi
		echo "$gn""Set pruning min states to keep: $VAR_SHIMMER_WASP_PRUNING_MIN_STATES_TO_KEEP""$xx"

		echo ''
		VAR_USERNAME=$(cat .env 2>/dev/null | grep DASHBOARD_USERNAME= | cut -d '=' -f 2)
		VAR_DEFAULT=$(cat /dev/urandom | tr -dc '[:alpha:]' | fold -w "${1:-10}" | head -n 1 | tr '[:upper:]' '[:lower:]');
		if [ -z "$VAR_USERNAME" ]; then
		echo "Set dashboard username (generated: $ca""$VAR_DEFAULT""$xx):"; echo "to use generated value press [Enter]:"; else echo "Set dashboard username (config: $ca""$VAR_USERNAME""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_USERNAME=$VAR_TMP; elif [ -z "$VAR_USERNAME" ]; then VAR_USERNAME=$VAR_DEFAULT; fi
		echo "$gn""Set dashboard username: $VAR_USERNAME""$xx"

		echo ''
		VAR_DASHBOARD_PASSWORD=$(cat .env 2>/dev/null | grep DASHBOARD_PASSWORD= | cut -d '=' -f 2)
		VAR_DASHBOARD_SALT=$(cat .env 2>/dev/null | grep DASHBOARD_SALT= | cut -d '=' -f 2)
		VAR_DEFAULT=$(cat /dev/urandom | tr -dc '[:alpha:]' | fold -w "${1:-20}" | head -n 1);
		if [ -z "$VAR_DASHBOARD_PASSWORD" ]; then
		echo "Set dashboard password / will be saved as hash ($ca""use generated""$xx):"; echo "to use generated value press [Enter]:"; else echo "Set dashboard password / will be saved as hash (config: $ca""use existing""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then
		  VAR_PASSWORD=$VAR_TMP
		  echo "$gn""Set dashboard password: new""$xx"
		else
		  if [ -z "$VAR_DASHBOARD_PASSWORD" ]; then
		    VAR_PASSWORD=$VAR_DEFAULT
		    echo "$gn""Set dashboard password: ""$VAR_DEFAULT""$xx"
		  else
		    VAR_PASSWORD=''
		    echo "$gn""Set dashboard password: use existing""$xx"
		  fi
		fi

		echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                              Write Parameters                               ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		if [ "$VAR_SHIMMER_WASP_HTTPS_PORT" = "443" ]; then CheckCertificate; else VAR_CERT=1; fi

		if [ -d /var/lib/"$VAR_DIR" ]; then cd /var/lib/"$VAR_DIR" || exit; fi

		if [ -f .env ]; then
		  WASP_TRUSTED_NODE=$(cat .env | grep WASP_TRUSTED_NODE)
		  WASP_TRUSTED_ACCESSNODE=$(cat .env | grep WASP_TRUSTED_ACCESSNODE)
		rm .env; fi

		echo "WASP_VERSION=$VAR_SHIMMER_WASP_VERSION" >> .env
		echo "WASP_DASHBOARD_VERSION=$VAR_SHIMMER_WASP_DASHBOARD_VERSION" >> .env
		echo "WASP_CLI_VERSION=$VAR_SHIMMER_WASP_CLI_VERSION" >> .env
		echo "WASP_HOST=$VAR_HOST" >> .env
		echo "WASP_HTTPS_PORT=$VAR_SHIMMER_WASP_HTTPS_PORT" >> .env
		echo "WASP_API_PORT=$VAR_SHIMMER_WASP_API_PORT" >> .env
		echo "WASP_PEERING_PORT=$VAR_SHIMMER_WASP_PEERING_PORT" >> .env
		echo "WASP_LEDGER_NETWORK=$VAR_WASP_LEDGER_NETWORK" >> .env
		echo "WASP_PRUNING_MIN_STATES_TO_KEEP=$VAR_SHIMMER_WASP_PRUNING_MIN_STATES_TO_KEEP" >> .env
		echo "WASP_LOG_LEVEL=debug" >> .env
		echo "WASP_DEBUG_SKIP_HEALTH_CHECK=true" >> .env
		
		if [ "$VAR_CERT" = 0 ]
		then
			echo "WASP_HTTP_PORT=80" >> .env
			clear
			echo ""
			echo "╔═════════════════════════════════════════════════════════════════════════════╗"
			echo "║                     Retrieve Let's Encrypt Certificate                      ║"
			echo "╚═════════════════════════════════════════════════════════════════════════════╝"
			echo ""
			unset VAR_ACME_EMAIL
				while [ -z "$VAR_ACME_EMAIL" ]; do
			 	 VAR_ACME_EMAIL=$(cat .env 2>/dev/null | grep ACME_EMAIL= | cut -d '=' -f 2)
				  if [ -z "$ACME_EMAIL" ]; then
				    echo "Set mail for certificate renewal:"; else echo "Set mail for certificate renewal (config: $ca""$ACME_EMAIL""$xx)"; echo "Press [Enter] to use existing config:"; fi
				  read -r -p '> ' VAR_TMP
				  if [ -n "$VAR_TMP" ]; then VAR_ACME_EMAIL=$VAR_TMP; fi
				  if ! [ -z "${VAR_ACME_EMAIL##*@*}" ]; then
				    VAR_ACME_EMAIL=''
				    echo "$rd""Set mail for certificate renewal: Please insert correct mail!"; echo "$xx"
				  fi
				done
			echo "$gn""Set mail for certificate renewal: $VAR_ACME_EMAIL""$xx"
			echo "ACME_EMAIL=$VAR_ACME_EMAIL" >> .env
		else
			echo "WASP_HTTP_PORT=8082" >> .env
			echo "SSL_CONFIG=certs" >> .env
			echo "WASP_SSL_CERT=/etc/letsencrypt/live/$VAR_HOST/fullchain.pem" >> .env
			echo "WASP_SSL_KEY=/etc/letsencrypt/live/$VAR_HOST/privkey.pem" >> .env
		fi

		echo "done..."

	else
		if [ -f .env ]; then sed -i "s/WASP_VERSION=.*/WASP_VERSION=$VAR_SHIMMER_WASP_VERSION/g" .env; fi
		VAR_HOST=$(cat .env 2>/dev/null | grep _HOST | cut -d '=' -f 2)
		VAR_DASHBOARD_VERSION=$(cat .env 2>/dev/null | grep WASP_DASHBOARD_VERSION | cut -d '=' -f 2)
		VAR_SALT=$(cat .env 2>/dev/null | grep DASHBOARD_SALT | cut -d '=' -f 2)
		VAR_CLI=$(cat .env 2>/dev/null | grep WASP_CLI_VERSION | cut -d '=' -f 2)

		if [ -z "$VAR_DASHBOARD_VERSION" ]; then
		    echo "WASP_DASHBOARD_VERSION=$VAR_SHIMMER_WASP_DASHBOARD_VERSION" >> .env
		fi

		if [ -z "$VAR_CLI" ]; then
		    echo "WASP_CLI_VERSION=$VAR_SHIMMER_WASP_CLI_VERSION" >> .env
		fi

		if [ -f .env ]; then sed -i "s/WASP_CLI_VERSION=.*/WASP_CLI_VERSION=$VAR_SHIMMER_WASP_CLI_VERSION/g" .env; fi
		if [ -f .env ]; then sed -i "s/WASP_DASHBOARD_VERSION=.*/WASP_DASHBOARD_VERSION=$VAR_SHIMMER_WASP_DASHBOARD_VERSION/g" .env; fi

		if [ -z "$VAR_SALT" ]; then
		    VAR_PASSWORD=$(cat .env 2>/dev/null | grep DASHBOARD_PASSWORD | cut -d '=' -f 2)

			if [ -d /var/lib/shimmer-hornet ]; then cd /var/lib/shimmer-hornet || VAR_PASSWORD=''; fi
			if [ -n "$VAR_PASSWORD" ]; then
			    credentials=$(docker run iotaledger/hornet tool pwd-hash --json --password "$VAR_PASSWORD" | sed -e 's/\r//g') >/dev/null 2>&1

			    VAR_DASHBOARD_PASSWORD=$(echo "$credentials" | jq -r '.passwordHash')
			    VAR_DASHBOARD_SALT=$(echo "$credentials" | jq -r '.passwordSalt')

			    if [ -d /var/lib/"$VAR_DIR" ]; then cd /var/lib/"$VAR_DIR" || exit; fi

			    if [ -f .env ]; then sed -i "s/DASHBOARD_PASSWORD=.*/DASHBOARD_PASSWORD=$VAR_DASHBOARD_PASSWORD/g" .env; fi
			    echo "DASHBOARD_SALT=$VAR_DASHBOARD_SALT" >> .env

			fi
			if [ -d /var/lib/"$VAR_DIR" ]; then cd /var/lib/"$VAR_DIR" || exit; fi
		fi

	fi

	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                                 Pull Data                                   ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	docker network create shimmer >/dev/null 2>&1
	docker compose pull 2>&1 | grep "Pulled" | sort

	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

	if [ "$VAR_CONF_RESET" = 1 ]; then

		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                               Set Credentials                               ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		if [ -n "$VAR_PASSWORD" ]; then
		  credentials=$(docker run iotaledger/hornet tool pwd-hash --json --password "$VAR_PASSWORD" | sed -e 's/\r//g') >/dev/null 2>&1
		  VAR_DASHBOARD_PASSWORD=$(echo "$credentials" | jq -r '.passwordHash')
		  VAR_DASHBOARD_SALT=$(echo "$credentials" | jq -r '.passwordSalt')
		  echo "passwordHash: "$VAR_DASHBOARD_PASSWORD
		  echo "passwordSalt: "$VAR_DASHBOARD_SALT  
		else
		  echo "credentials not changed..."
		fi

		echo "DASHBOARD_USERNAME=$VAR_USERNAME" >> .env
		echo "DASHBOARD_PASSWORD=$VAR_DASHBOARD_PASSWORD" >> .env
		echo "DASHBOARD_SALT=$VAR_DASHBOARD_SALT" >> .env

		echo "" >> .env
		echo "### TRUSTED PEERING ACCESSNODES ###" >> .env

		if [ -n "$WASP_TRUSTED_ACCESSNODE" ]; then
		  echo "$WASP_TRUSTED_ACCESSNODE" >> .env	
		else
		  if [ -n "$(cat ./data/waspdb/chains/chain_registry.json 2>/dev/null | grep smr1prxvwqvwf7nru5q5xvh5thwg54zsm2y4wfnk6yk56hj3exxkg92mx20wl | cut -d '=' -f 2)" ]; then
			echo "$WASP_TRUSTED_NODE" | sed -e 's/WASP_TRUSTED_NODE_/WASP_TRUSTED_ACCESSNODE_/g' >> .env
			unset WASP_TRUSTED_NODE
		  fi
		fi

		echo "" >> .env
		echo "### TRUSTED PEERING NODES ###" >> .env

		if [ -n "$WASP_TRUSTED_NODE" ]; then
		  echo "$WASP_TRUSTED_NODE" >> .env
		fi

		echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

	else
		WASP_TRUSTED_ACCESSNODE=$(cat .env | grep WASP_TRUSTED_ACCESSNODE)
		if [ -z "$WASP_TRUSTED_ACCESSNODE" ]; then
		  if [ -n "$(cat ./data/waspdb/chains/chain_registry.json 2>/dev/null | grep smr1prxvwqvwf7nru5q5xvh5thwg54zsm2y4wfnk6yk56hj3exxkg92mx20wl | cut -d '=' -f 2)" ]; then
			sed -i 's/WASP_TRUSTED_NODE_/WASP_TRUSTED_ACCESSNODE_/g' .env
		  fi
		fi
	fi

	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                               Prepare Docker                                ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	if [ -d /var/lib/"$VAR_DIR" ]; then cd /var/lib/"$VAR_DIR" || exit; fi
	./prepare_docker.sh
	chown -R 65532:65532 /var/lib/"$VAR_DIR"/data

	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

	if [ "$VAR_CONF_RESET" = 1 ]; then

		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                             Configure Firewall                              ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		if [ "$VAR_CERT" = 0 ]; then echo ufw allow '80/tcp' && ufw allow '80/tcp'; fi

		echo ufw allow "$VAR_SHIMMER_WASP_HTTPS_PORT/tcp" && ufw allow "$VAR_SHIMMER_WASP_HTTPS_PORT/tcp"
		echo ufw allow "$VAR_SHIMMER_WASP_API_PORT/tcp" && ufw allow "$VAR_SHIMMER_WASP_API_PORT/tcp"
		echo ufw allow "$VAR_SHIMMER_WASP_PEERING_PORT/tcp" && ufw allow "$VAR_SHIMMER_WASP_PEERING_PORT/tcp"
		echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear
	fi

	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                                 Start Wasp                                  ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	if [ -d /var/lib/"$VAR_DIR" ]; then cd /var/lib/"$VAR_DIR" || exit; fi

	docker compose up -d

	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

	clear
	RenameContainer

	if [ -z "$VAR_PASSWORD" ]; then VAR_PASSWORD='********'; fi

	if [ -s "/var/lib/$VAR_DIR/data/letsencrypt/acme.json" ]; then SetCertificateGlobal; fi

	clear
	echo ""

	if [ "$VAR_CONF_RESET" = 1 ]; then

	    echo "--------------------------- INSTALLATION IS FINISHED --------------------------"
	    echo ""
		echo "═══════════════════════════════════════════════════════════════════════════════"
		echo "domain name: $VAR_HOST"
		echo "https port:  $VAR_SHIMMER_WASP_HTTPS_PORT"
		echo "-------------------------------------------------------------------------------"
		echo "dashboard username: $VAR_USERNAME"
		echo "dashboard password: $VAR_PASSWORD"
		echo "-------------------------------------------------------------------------------"
		echo "api port: $VAR_SHIMMER_WASP_API_PORT"
		echo "-------------------------------------------------------------------------------"
		echo "peering port: $VAR_SHIMMER_WASP_PEERING_PORT"
		echo "-------------------------------------------------------------------------------"
		echo "ledger-connection/txstream: local to shimmer-hornet"
		echo "═══════════════════════════════════════════════════════════════════════════════"
		echo ""
	else
	    echo "------------------------------ UPDATE IS FINISHED -----------------------------"
	    echo ""
	fi

	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

	if ! [ "$opt_mode" ]; then Dashboard; fi
}

ShimmerChronicle() {
	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║     DLT.GREEN AUTOMATIC SHIMMER-INX-CHRONICLE INSTALLATION WITH DOCKER      ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""
	echo "$ca""Chronicle is a INX-Plugin and can only installed on the same Server as Shimmer!""$xx";
	CheckIota
	if [ "$VAR_NETWORK" = 1 ]; then echo "$rd""It's not supported (Security!) to install Nodes from Network"; echo "Shimmer and IOTA on the same Server, deinstall IOTA Nodes first!""$xx"; fi

	echo "$ca""Starting Installation or Update...""$xx";
	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear
	if [ "$VAR_NETWORK" = 1 ]; then VAR_NETWORK=2; if [ "$opt_mode" ]; then clear; exit; fi; SubMenuMaintenance; fi

	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                            Prepare Installation                             ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""
	echo "Stopping... $VAR_DIR"
	if [ -d /var/lib/"$VAR_DIR" ]; then cd /var/lib/"$VAR_DIR" || exit; if [ -f "/var/lib/$VAR_DIR/docker-compose.yml" ]; then docker compose down >/dev/null 2>&1; fi; fi

	echo ""
	echo "Check Directory... /var/lib/$VAR_DIR"

	if [ ! -d /var/lib/"$VAR_DIR" ]; then mkdir /var/lib/"$VAR_DIR" || exit; fi
	cd /var/lib/"$VAR_DIR" || exit

	echo "CleanUp Directory... /var/lib/$VAR_DIR"
	find . -maxdepth 1 -mindepth 1 ! \( -name .env -o -name data \) -exec rm -rf {} +

	echo ""
	echo "Download Package... install.tar.gz"
	wget -cO - "$ShimmerChroniclePackage" -q > install.tar.gz

	if [ "$(shasum -a 256 './install.tar.gz' | cut -d ' ' -f 1)" = "$ShimmerChronicleHash" ]; then
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

	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; echo "$xx"

	CheckConfiguration

	VAR_SHIMMER_INX_CHRONICLE_LEDGER_NETWORK='shimmer'

	if [ "$VAR_CONF_RESET" = 1 ]; then

		clear
		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                               Set Parameters                                ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		VAR_HOST=$(cat .env 2>/dev/null | grep INX_CHRONICLE_HOST= | cut -d '=' -f 2)
		if [ -z "$VAR_HOST" ]; then
		  VAR_HOST=$(echo "$VAR_DOMAIN" | xargs)
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
		VAR_SHIMMER_INX_CHRONICLE_HTTPS_PORT=$(cat .env 2>/dev/null | grep INX_CHRONICLE_HTTPS_PORT= | cut -d '=' -f 2)
		VAR_DEFAULT='449';
		if [ -z "$VAR_SHIMMER_INX_CHRONICLE_HTTPS_PORT" ]; then
		  echo "Set https port (default: $ca"$VAR_DEFAULT"$xx):"; echo "Press [Enter] to use default value:"; else echo "Set https port (config: $ca""$VAR_SHIMMER_INX_CHRONICLE_HTTPS_PORT""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_SHIMMER_INX_CHRONICLE_HTTPS_PORT=$VAR_TMP; elif [ -z "$VAR_SHIMMER_INX_CHRONICLE_HTTPS_PORT" ]; then VAR_SHIMMER_INX_CHRONICLE_HTTPS_PORT=$VAR_DEFAULT; fi
		echo "$gn""Set https port: $VAR_SHIMMER_INX_CHRONICLE_HTTPS_PORT""$xx"

		echo ''
		VAR_SHIMMER_INX_CHRONICLE_MONGODB_USERNAME=$(cat .env 2>/dev/null | grep INX_CHRONICLE_MONGODB_USERNAME= | cut -d '=' -f 2)
		VAR_DEFAULT=$(cat /dev/urandom | tr -dc '[:alpha:]' | fold -w "${1:-10}" | head -n 1 | tr '[:upper:]' '[:lower:]');
		if [ -z "$VAR_SHIMMER_INX_CHRONICLE_MONGODB_USERNAME" ]; then
		echo "Set MongoDB username (generated: $ca""$VAR_DEFAULT""$xx):"; echo "to use generated value press [Enter]:"; else echo "Set MongoDB username (config: $ca""$VAR_SHIMMER_INX_CHRONICLE_MONGODB_USERNAME""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_SHIMMER_INX_CHRONICLE_MONGODB_USERNAME=$VAR_TMP; elif [ -z "$VAR_SHIMMER_INX_CHRONICLE_MONGODB_USERNAME" ]; then VAR_SHIMMER_INX_CHRONICLE_MONGODB_USERNAME=$VAR_DEFAULT; fi
		echo "$gn""Set MongoDB username: $VAR_SHIMMER_INX_CHRONICLE_MONGODB_USERNAME""$xx"

		echo ''
		VAR_SHIMMER_INX_CHRONICLE_MONGODB_PASSWORD=$(cat .env 2>/dev/null | grep INX_CHRONICLE_MONGODB_PASSWORD= | cut -d '=' -f 2)
		VAR_DEFAULT=$(cat /dev/urandom | tr -dc '[:alpha:]' | fold -w "${1:-20}" | head -n 1 | tr '[:upper:]' '[:lower:]');
		if [ -z "$VAR_SHIMMER_INX_CHRONICLE_MONGODB_PASSWORD" ]; then
		echo "Set MongoDB password (generated: $ca""$VAR_DEFAULT""$xx):"; echo "to use generated value press [Enter]:"; else echo "Set MongoDB password (config: $ca""$VAR_SHIMMER_INX_CHRONICLE_MONGODB_PASSWORD""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_SHIMMER_INX_CHRONICLE_MONGODB_PASSWORD=$VAR_TMP; elif [ -z "$VAR_SHIMMER_INX_CHRONICLE_MONGODB_PASSWORD" ]; then VAR_SHIMMER_INX_CHRONICLE_MONGODB_PASSWORD=$VAR_DEFAULT; fi
		echo "$gn""Set MongoDB password: $VAR_SHIMMER_INX_CHRONICLE_MONGODB_PASSWORD""$xx"

		echo ''
		VAR_SHIMMER_INX_CHRONICLE_INFLUXDB_USERNAME=$(cat .env 2>/dev/null | grep INX_CHRONICLE_INFLUXDB_USERNAME= | cut -d '=' -f 2)
		VAR_DEFAULT=$(cat /dev/urandom | tr -dc '[:alpha:]' | fold -w "${1:-10}" | head -n 1 | tr '[:upper:]' '[:lower:]');
		if [ -z "$VAR_SHIMMER_INX_CHRONICLE_INFLUXDB_USERNAME" ]; then
		echo "Set InfluxDB username (generated: $ca""$VAR_DEFAULT""$xx):"; echo "to use generated value press [Enter]:"; else echo "Set InfluxDB username (config: $ca""$VAR_SHIMMER_INX_CHRONICLE_INFLUXDB_USERNAME""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_SHIMMER_INX_CHRONICLE_INFLUXDB_USERNAME=$VAR_TMP; elif [ -z "$VAR_SHIMMER_INX_CHRONICLE_INFLUXDB_USERNAME" ]; then VAR_SHIMMER_INX_CHRONICLE_INFLUXDB_USERNAME=$VAR_DEFAULT; fi
		echo "$gn""Set InfluxDB username: $VAR_SHIMMER_INX_CHRONICLE_INFLUXDB_USERNAME""$xx"

		echo ''
		VAR_SHIMMER_INX_CHRONICLE_INFLUXDB_PASSWORD=$(cat .env 2>/dev/null | grep INX_CHRONICLE_INFLUXDB_PASSWORD= | cut -d '=' -f 2)
		VAR_DEFAULT=$(cat /dev/urandom | tr -dc '[:alpha:]' | fold -w "${1:-20}" | head -n 1 | tr '[:upper:]' '[:lower:]');
		if [ -z "$VAR_SHIMMER_INX_CHRONICLE_INFLUXDB_PASSWORD" ]; then
		echo "Set InfluxDB password (generated: $ca""$VAR_DEFAULT""$xx):"; echo "to use generated value press [Enter]:"; else echo "Set InfluxDB password (config: $ca""$VAR_SHIMMER_INX_CHRONICLE_INFLUXDB_PASSWORD""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_SHIMMER_INX_CHRONICLE_INFLUXDB_PASSWORD=$VAR_TMP; elif [ -z "$VAR_SHIMMER_INX_CHRONICLE_INFLUXDB_PASSWORD" ]; then VAR_SHIMMER_INX_CHRONICLE_INFLUXDB_PASSWORD=$VAR_DEFAULT; fi
		echo "$gn""Set InfluxDB password: $VAR_SHIMMER_INX_CHRONICLE_INFLUXDB_PASSWORD""$xx"

		echo ''
		VAR_SHIMMER_INX_CHRONICLE_INFLUXDB_TOKEN=$(cat .env 2>/dev/null | grep INX_CHRONICLE_INFLUXDB_TOKEN= | cut -d '=' -f 2)
		VAR_DEFAULT=$(cat /dev/urandom | tr -dc '[:alpha:]' | fold -w "${1:-20}" | head -n 1 | tr '[:upper:]' '[:lower:]');
		if [ -z "$VAR_SHIMMER_INX_CHRONICLE_INFLUXDB_TOKEN" ]; then
		echo "Set InfluxDB token (generated: $ca""$VAR_DEFAULT""$xx):"; echo "to use generated value press [Enter]:"; else echo "Set InfluxDB token (config: $ca""$VAR_SHIMMER_INX_CHRONICLE_INFLUXDB_TOKEN""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_SHIMMER_INX_CHRONICLE_INFLUXDB_TOKEN=$VAR_TMP; elif [ -z "$VAR_SHIMMER_INX_CHRONICLE_INFLUXDB_TOKEN" ]; then VAR_SHIMMER_INX_CHRONICLE_INFLUXDB_TOKEN=$VAR_DEFAULT; fi
		echo "$gn""Set InfluxDB password: $VAR_SHIMMER_INX_CHRONICLE_INFLUXDB_TOKEN""$xx"

		echo ''
		VAR_SHIMMER_INX_CHRONICLE_JWT_SALT=$(cat .env 2>/dev/null | grep INX_CHRONICLE_JWT_SALT= | cut -d '=' -f 2)
		VAR_DEFAULT=$(cat /dev/urandom | tr -dc '[:alpha:]' | fold -w "${1:-10}" | head -n 1 | tr '[:upper:]' '[:lower:]');
		if [ -z "$VAR_SHIMMER_INX_CHRONICLE_JWT_SALT" ]; then
		echo "Set JWT salt (generated: $ca""$VAR_DEFAULT""$xx):"; echo "to use generated value press [Enter]:"; else echo "Set JWT salt (config: $ca""$VAR_SHIMMER_INX_CHRONICLE_JWT_SALT""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_SHIMMER_INX_CHRONICLE_JWT_SALT=$VAR_TMP; elif [ -z "$VAR_SHIMMER_INX_CHRONICLE_JWT_SALT" ]; then VAR_SHIMMER_INX_CHRONICLE_JWT_SALT=$VAR_DEFAULT; fi
		echo "$gn""Set JWT salt: $VAR_SHIMMER_INX_CHRONICLE_JWT_SALT""$xx"

		echo ''
		VAR_SHIMMER_INX_CHRONICLE_JWT_PASSWORD=$(cat .env 2>/dev/null | grep INX_CHRONICLE_JWT_PASSWORD= | cut -d '=' -f 2)
		VAR_DEFAULT=$(cat /dev/urandom | tr -dc '[:alpha:]' | fold -w "${1:-20}" | head -n 1 | tr '[:upper:]' '[:lower:]');
		if [ -z "$VAR_SHIMMER_INX_CHRONICLE_JWT_PASSWORD" ]; then
		echo "Set JWT password (generated: $ca""$VAR_DEFAULT""$xx):"; echo "to use generated value press [Enter]:"; else echo "Set JWT password (config: $ca""$VAR_SHIMMER_INX_CHRONICLE_JWT_PASSWORD""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_SHIMMER_INX_CHRONICLE_JWT_PASSWORD=$VAR_TMP; elif [ -z "$VAR_SHIMMER_INX_CHRONICLE_JWT_PASSWORD" ]; then VAR_SHIMMER_INX_CHRONICLE_JWT_PASSWORD=$VAR_DEFAULT; fi
		echo "$gn""Set JWT password: $VAR_SHIMMER_INX_CHRONICLE_JWT_PASSWORD""$xx"

		echo ''
		VAR_SHIMMER_INX_CHRONICLE_GRAFANA_ADMIN_PASSWORD=$(cat .env 2>/dev/null | grep INX_CHRONICLE_GRAFANA_ADMIN_PASSWORD= | cut -d '=' -f 2)
		VAR_DEFAULT=$(cat /dev/urandom | tr -dc '[:alpha:]' | fold -w "${1:-20}" | head -n 1 | tr '[:upper:]' '[:lower:]');
		if [ -z "$VAR_SHIMMER_INX_CHRONICLE_GRAFANA_ADMIN_PASSWORD" ]; then
		echo "Set grafana password (generated: $ca""$VAR_DEFAULT""$xx):"; echo "to use generated value press [Enter]:"; else echo "Set grafana password (config: $ca""$VAR_SHIMMER_INX_CHRONICLE_GRAFANA_ADMIN_PASSWORD""$xx)"; echo "Press [Enter] to use existing config:"; fi
		read -r -p '> ' VAR_TMP
		if [ -n "$VAR_TMP" ]; then VAR_SHIMMER_INX_CHRONICLE_GRAFANA_ADMIN_PASSWORD=$VAR_TMP; elif [ -z "$VAR_SHIMMER_INX_CHRONICLE_GRAFANA_ADMIN_PASSWORD" ]; then VAR_SHIMMER_INX_CHRONICLE_GRAFANA_ADMIN_PASSWORD=$VAR_DEFAULT; fi
		echo "$gn""Set grafana password: $VAR_SHIMMER_INX_CHRONICLE_GRAFANA_ADMIN_PASSWORD""$xx"

		echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                              Write Parameters                               ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		if [ "$VAR_SHIMMER_INX_CHRONICLE_HTTPS_PORT" = "443" ]; then CheckCertificate; else VAR_CERT=1; fi

		if [ -d /var/lib/"$VAR_DIR" ]; then cd /var/lib/"$VAR_DIR" || exit; fi
		if [ -f .env ]; then rm .env; fi

		echo "COMPOSE_PROFILES=metrics,debug" >> .env
		echo "INX_CHRONICLE_VERSION=$VAR_SHIMMER_INX_CHRONICLE_VERSION" >> .env
		echo "INX_CHRONICLE_HOST=$VAR_HOST" >> .env
		echo "INX_CHRONICLE_HTTPS_PORT=$VAR_SHIMMER_INX_CHRONICLE_HTTPS_PORT" >> .env
		echo "INX_CHRONICLE_LEDGER_NETWORK=$VAR_SHIMMER_INX_CHRONICLE_LEDGER_NETWORK" >> .env
		echo "INX_CHRONICLE_GRAFANA_ADMIN_PASSWORD=$VAR_SHIMMER_INX_CHRONICLE_GRAFANA_ADMIN_PASSWORD" >> .env

		if [ "$VAR_CERT" = 0 ]
		then
			echo "INX_CHRONICLE_HTTP_PORT=80" >> .env
			clear
			echo ""
			echo "╔═════════════════════════════════════════════════════════════════════════════╗"
			echo "║                     Retrieve Let's Encrypt Certificate                      ║"
			echo "╚═════════════════════════════════════════════════════════════════════════════╝"
			echo ""
			unset VAR_ACME_EMAIL
				while [ -z "$VAR_ACME_EMAIL" ]; do
			 	 VAR_ACME_EMAIL=$(cat .env 2>/dev/null | grep ACME_EMAIL= | cut -d '=' -f 2)
				  if [ -z "$ACME_EMAIL" ]; then
				    echo "Set mail for certificate renewal:"; else echo "Set mail for certificate renewal (config: $ca""$ACME_EMAIL""$xx)"; echo "Press [Enter] to use existing config:"; fi
				  read -r -p '> ' VAR_TMP
				  if [ -n "$VAR_TMP" ]; then VAR_ACME_EMAIL=$VAR_TMP; fi
				  if ! [ -z "${VAR_ACME_EMAIL##*@*}" ]; then
				    VAR_ACME_EMAIL=''
				    echo "$rd""Set mail for certificate renewal: Please insert correct mail!"; echo "$xx"
				  fi
				done
			echo "$gn""Set mail for certificate renewal: $VAR_ACME_EMAIL""$xx"
			echo "ACME_EMAIL=$VAR_ACME_EMAIL" >> .env
		else
			echo "INX_CHRONICLE_HTTP_PORT=8084" >> .env
			echo "SSL_CONFIG=certs" >> .env
			echo "INX_CHRONICLE_SSL_CERT=/etc/letsencrypt/live/$VAR_HOST/fullchain.pem" >> .env
			echo "INX_CHRONICLE_SSL_KEY=/etc/letsencrypt/live/$VAR_HOST/privkey.pem" >> .env
		fi

		echo "done..."

	else
		if [ -f .env ]; then sed -i "s/INX_CHRONICLE_VERSION=.*/INX_CHRONICLE_VERSION=$VAR_SHIMMER_INX_CHRONICLE_VERSION/g" .env; fi
		VAR_HOST=$(cat .env 2>/dev/null | grep _HOST | cut -d '=' -f 2)
	fi

	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"

	clear
	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                                 Pull Data                                   ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	docker network create shimmer >/dev/null 2>&1
	docker compose pull 2>&1 | grep "Pulled" | sort

	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

	if [ "$VAR_CONF_RESET" = 1 ]; then

		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                               Set Credentials                               ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		echo "INX_CHRONICLE_MONGODB_USERNAME=$VAR_SHIMMER_INX_CHRONICLE_MONGODB_USERNAME" >> .env
		echo "INX_CHRONICLE_MONGODB_PASSWORD=$VAR_SHIMMER_INX_CHRONICLE_MONGODB_PASSWORD" >> .env
		echo "INX_CHRONICLE_INFLUXDB_USERNAME=$VAR_SHIMMER_INX_CHRONICLE_INFLUXDB_USERNAME" >> .env
		echo "INX_CHRONICLE_INFLUXDB_PASSWORD=$VAR_SHIMMER_INX_CHRONICLE_INFLUXDB_PASSWORD" >> .env
		echo "INX_CHRONICLE_INFLUXDB_TOKEN=$VAR_SHIMMER_INX_CHRONICLE_INFLUXDB_TOKEN" >> .env
		echo "INX_CHRONICLE_JWT_SALT=$VAR_SHIMMER_INX_CHRONICLE_JWT_SALT" >> .env
		echo "INX_CHRONICLE_JWT_PASSWORD=$VAR_SHIMMER_INX_CHRONICLE_JWT_PASSWORD" >> .env

		echo "done..."

		echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear
	fi

	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                               Prepare Docker                                ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	if [ -d /var/lib/"$VAR_DIR" ]; then cd /var/lib/"$VAR_DIR" || exit; fi
	./prepare_docker.sh
	chown -R 65532:65532 /var/lib/"$VAR_DIR"/data

	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

	if [ "$VAR_CONF_RESET" = 1 ]; then

		echo ""
		echo "╔═════════════════════════════════════════════════════════════════════════════╗"
		echo "║                             Configure Firewall                              ║"
		echo "╚═════════════════════════════════════════════════════════════════════════════╝"
		echo ""

		if [ "$VAR_CERT" = 0 ]; then echo ufw allow '80/tcp' && ufw allow '80/tcp'; fi

		echo ufw allow "$VAR_SHIMMER_INX_CHRONICLE_HTTPS_PORT/tcp" && ufw allow "$VAR_SHIMMER_INX_CHRONICLE_HTTPS_PORT/tcp"
		echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear
	fi

	echo ""
	echo "╔═════════════════════════════════════════════════════════════════════════════╗"
	echo "║                             Start INX-Chronicle                             ║"
	echo "╚═════════════════════════════════════════════════════════════════════════════╝"
	echo ""

	if [ -d /var/lib/"$VAR_DIR" ]; then cd /var/lib/"$VAR_DIR" || exit; fi

	docker compose up -d

	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"; clear

	clear
	RenameContainer

	if [ -s "/var/lib/$VAR_DIR/data/letsencrypt/acme.json" ]; then SetCertificateGlobal; fi

	clear
	echo ""

	if [ "$VAR_CONF_RESET" = 1 ]; then

	    echo "--------------------------- INSTALLATION IS FINISHED --------------------------"
	    echo ""
		echo "═══════════════════════════════════════════════════════════════════════════════"
		echo "domain name: $VAR_HOST"
		echo "https port:  $VAR_SHIMMER_INX_CHRONICLE_HTTPS_PORT"
		echo "-------------------------------------------------------------------------------"
		echo "mongoDB username: $VAR_SHIMMER_INX_CHRONICLE_MONGODB_USERNAME"
		echo "mongoDB password: $VAR_SHIMMER_INX_CHRONICLE_MONGODB_PASSWORD"
		echo "-------------------------------------------------------------------------------"
		echo "influxDB username: $VAR_SHIMMER_INX_CHRONICLE_INFLUXDB_USERNAME"
		echo "influxDB password: $VAR_SHIMMER_INX_CHRONICLE_INFLUXDB_PASSWORD"
		echo "influxDB token:    $VAR_SHIMMER_INX_CHRONICLE_INFLUXDB_TOKEN"
		echo "-------------------------------------------------------------------------------"
		echo "JWT salt:     $VAR_SHIMMER_INX_CHRONICLE_JWT_SALT"
		echo "JWT password: $VAR_SHIMMER_INX_CHRONICLE_JWT_PASSWORD"
		echo "-------------------------------------------------------------------------------"
		echo "grafana password: $VAR_SHIMMER_INX_CHRONICLE_GRAFANA_ADMIN_PASSWORD"
		echo "-------------------------------------------------------------------------------"
		echo "ledger-connection/txstream: local to shimmer-hornet"
		echo "═══════════════════════════════════════════════════════════════════════════════"
	else
	    echo "------------------------------ UPDATE IS FINISHED -----------------------------"
	    echo ""
	fi

	echo "$fl"; PromptMessage "$opt_time" "Press [Enter] / wait ["$opt_time"s] to continue... Press [P] to pause / [C] to cancel"; echo "$xx"

	if ! [ "$opt_mode" ]; then SubMenuMaintenance; fi
}

RenameContainer() {
	docker container rename iota-hornet_hornet_1 iota-hornet >/dev/null 2>&1
	docker container rename iota-hornet_traefik_1 iota-hornet.traefik >/dev/null 2>&1
	docker container rename iota-hornet_inx-participation_1 iota-hornet.inx-participation >/dev/null 2>&1
	docker container rename iota-hornet_inx-dashboard_1 iota-hornet.inx-dashboard >/dev/null 2>&1
	docker container rename iota-hornet_inx-indexer_1 iota-hornet.inx-indexer >/dev/null 2>&1
	docker container rename iota-hornet_inx-poi_1 iota-hornet.inx-poi >/dev/null 2>&1
	docker container rename iota-hornet_inx-spammer_1 iota-hornet.inx-spammer >/dev/null 2>&1
	docker container rename iota-hornet_inx-mqtt_1 iota-hornet.inx-mqtt >/dev/null 2>&1
	docker container rename iota-wasp_traefik_1 iota-wasp.traefik >/dev/null 2>&1
	docker container rename iota-wasp_wasp_1 iota-wasp >/dev/null 2>&1
	docker container rename iota-hornet_grafana_1 grafana >/dev/null 2>&1
	docker container rename iota-hornet_prometheus_1 prometheus >/dev/null 2>&1

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

	docker container rename shimmer-inx-chronicle shimmer-plugins.inx-chronicle >/dev/null 2>&1
	docker container rename shimmer-inx-chronicle.traefik shimmer-plugins.inx-chronicle.traefik >/dev/null 2>&1
	docker container rename shimmer-inx-chronicle.influxdb shimmer-plugins.inx-chronicle.influxdb >/dev/null 2>&1
	docker container rename shimmer-inx-chronicle.mongo shimmer-plugins.inx-chronicle.mongo >/dev/null 2>&1
	docker container rename shimmer-inx-chronicle.mongo-express shimmer-plugins.inx-chronicle.mongo-express >/dev/null 2>&1
	docker container rename shimmer-inx-chronicle.grafana shimmer-plugins.inx-chronicle.grafana >/dev/null 2>&1
	docker container rename shimmer-inx-chronicle.telegraf shimmer-plugins.inx-chronicle.telegraf >/dev/null 2>&1

}

clear

CheckDistribution
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
echo "║                          for IOTA/Shimmer Nodes                             ║"
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
echo "  $gr""$(cat /etc/issue | cut -d ' ' -f 1)"" | m=\"$opt_mode\" | t=\"$opt_time\" | r=\"$opt_reboot\" | c=\"$opt_check\" | l=\"$opt_level\"""$xx"

DEBIAN_FRONTEND=noninteractive sudo apt update >/dev/null 2>&1
DEBIAN_FRONTEND=noninteractive sudo apt-get install qrencode nano curl jq expect dnsutils ufw bc -y -qq >/dev/null 2>&1

sleep 1

if [ "$opt_check" = 1 ]; then
	CheckFirewall
	CheckAutostart
fi

if docker --version | grep "Docker version" >/dev/null 2>&1; then
    Dashboard
else
    if [ "$opt_mode" ]; then
        echo "Unattended: Install Docker..."
        Docker
        Dashboard
    else
        MainMenu
    fi
fi
