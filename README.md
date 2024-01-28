![GitHub latest release)](https://img.shields.io/github/v/release/dlt-green/node-installer-docker) ![GitHub release date](https://img.shields.io/github/release-date/dlt-green/node-installer-docker) ![GitHub](https://img.shields.io/github/contributors/dlt-green/node-installer-docker) ![GitHub](https://img.shields.io/github/license/dlt-green/node-installer-docker)

# DLT.GREEN VISION
We are a team of people from the IOTA community who have set themselves the vision of creating a DNS server for the IOTA/Shimmer ecosystem to improve the user experience. “DNS” stands for “Dynamic Node Selection”. Our goal is that a wallet no longer works with a static node, but rather that this can change depending on the situation. The time of static nodes into the IOTA/Shimmer ecosystem is over. Imagine never having to worry about whether the nodes is working or not. Imagine devices in the IOT that fully automatically select the node for their individual purpose; this can be, for example, based on proof of work, support for various events, trustworthiness or available access speed. It is important to us that the actual data traffic is routed between the wallet and the node itself and not via the node pool.

# DLT.GREEN AUTOMATIC NODE-INSTALLER DOCKER
DLT.GREEN Node-Installer-Docker is a script for installing IOTA/Shimmer Nodes (Hornet, Wasp). The installation takes place with Docker in the background and should enable everyone, even beginners, to set up IOTA/Shimmer nodes on a server or a virtual private server (VPS) in a short time.

# HARDWARE RECOMMENDATIONS
### Minimum recommendation for a node
 - 8 GB RAM 
 - 4 CPU Kerne
 - 160 GB Speicher (SSD)
 - Ubuntu 22.04 LTS

### Minimum recommendation for nodes that also want to track events (staking, voting, etc.) or want to load additional plugins
 - 16 GB RAM 
 - 4+ CPU Kerne 
 - 250+ GB Speicher (SSD)
 - Ubuntu 22.04 LTS

# Installation
### Important
The nodes should always be configured using the node installer provided by DLT.GREEN. It is not advisable to make changes to the parameters yourself, as your own parameters are not taken into account during an update and are therefore reset.
If any feature needs to be added or you want to add a plugin to the installer, you are welcome. Please report this via our Discord to dlt.green team.

### A server or VPS and your own domain must be available before installation begins.
An SSL certificate is automatically generated via Let's Encrypt, but you can also assign your own certificate.

#

### NODE-INSTALLER Installation
```console
sudo wget https://github.com/dlt-green/node-installer-docker/releases/latest/download/node-installer.sh && sudo sh node-installer.sh
```

### NODE-INSTALLER with GUI

When you run the installer for the first time, an alias is automatically created at user level, which means that the logged in user can use this alias as an alternative after starting the installer for the first time:

```console
dlt.green
```
### NODE-INSTALLER unattended

```
dlt.green [-m mode/optional] [-t time/optional] [-r reboot/optional] [-c checks/optional]
```

```
mode: s: Start all Nodes
mode: 0: Maintenance -> System Updates/Docker Cleanup/Certificate Update
         this mode also automatically installs Docker if Docker was not preinstalled
mode: 1: Update -> IOTA-Hornet
mode: 2: Update -> IOTA-Wasp
mode: 5: Update -> Shimmer-Hornet
mode: 6: Update -> Shimmer-Wasp
```

```
mode: u: mode 0 with unattended recursive Node Updates (if possible)
         the last 10 releases in the Guthub pipeline are supported (older versions are not updated)
```

```
time: 0-20 seconds
default: 10
```

```
reboot: 0: no reboot
reboot: 1: system reboot (nodes will be automatically shut down before)
default: 0
```

```
checks: 0: checks disabled (not recommended)
checks: 1: UFW Firewall and Autostart will be automatically enabled (enforced)
default: 1
```

### Operation
The script is operated by entering the numbers that are displayed in the menu.
If you click on the image you will see <a href="https://www.youtube.com/channel/UCg1PgTJ1NzdoS1JYcnJtDUg">video tutorials</a> for installing IOTA/Shimmer Nodes:

<div align="left">
      <a href="https://www.youtube.com/channel/UCg1PgTJ1NzdoS1JYcnJtDUg">
      <img src="https://github.com/dlt-green/node-installer-docker/assets/89119285/bb3afc0b-7534-4963-b920-cb01fc4e38ef"
      alt="Installation">
      </a>
</div>

# Error messages and suggestions
If you found any bugs or have suggestions for improving our script, create an issue on Github or contact our team in our Discord channel

<b>Suggestions for improvement: <a href="https://github.com/dlt-green/node-installer-docker/issues">Github Issues</a></b><br>
<b>Contact: <a href="https://discord.gg/XaBnsE5NGb">Discord</a></b>

# Disclaimer
Please note that using this script is at your own risk and DLT.GREEN is not liable for any damages.

# Disclosure
We would like to point out that this is not a supported installer by the Iota Foundation and you will not receive any support from the IF if you use this installer.
You get support in our discord from our team or the community

# Donations
THIS PROJECT IS DEVELOPED BY DLT.GREEN WITH ITS COMMUNITY.  
YOU CAN SUPPORT THIS PROJECT WITH DONATIONS TO THE DLT.GREEN TREASURY:  
https://explorer.iota.org/mainnet/addr/iota1qznzkq2n6kakps36s7w0z0gmuf0p70x647ghqshlfjlumqrld49l7zemavy
https://soonaverse.com/member/0x422bed2759f72e7d6ae1e100707ca45e26e9a12c
