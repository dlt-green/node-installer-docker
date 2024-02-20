![GitHub latest release](https://img.shields.io/github/v/release/dlt-green/node-installer-docker) ![GitHub release date](https://img.shields.io/github/release-date/dlt-green/node-installer-docker) ![GitHub contributors](https://img.shields.io/github/contributors/dlt-green/node-installer-docker) ![GitHub license](https://img.shields.io/github/license/dlt-green/node-installer-docker)

# DLT.GREEN VISION

We are a team of individuals from the IOTA community with a vision to create a DNS server for the IOTA/Shimmer ecosystem, aiming to enhance user experience. Here, "DNS" stands for "Dynamic Node Selection." Our objective is to move away from static node usage in wallets towards dynamic selection based on the situation. The era of static nodes within the IOTA/Shimmer ecosystem is coming to an end. Envision never having to worry about the operational status of nodes. Picture IoT devices autonomously selecting nodes tailored to their specific needs; this could be based on factors such as proof of work, event support, trustworthiness, or available access speed. We prioritize direct data traffic between the wallet and the node itself, bypassing the node pool.

# DLT.GREEN AUTOMATIC NODE-INSTALLER DOCKER

DLT.GREEN Node-Installer-Docker is a script designed to facilitate the installation of IOTA/Shimmer Nodes (Hornet, Wasp). Utilizing Docker in the background, the installation process aims to be accessible to everyone, including beginners, allowing for quick setup of IOTA/Shimmer nodes on either a server or a virtual private server (VPS).

## HARDWARE RECOMMENDATIONS

### Minimum recommendations for nodes

- 8 GB RAM
- 4 CPU cores
- 160 GB storage (SSD)
- Ubuntu 22.04.03 LTS (Jammy Jellyfish) or Debian 12 (Bookworm)

### Minimum recommendations for nodes seeking to track events (such as staking, voting, etc.) or intending to load additional plugins

- 16 GB RAM
- 4+ CPU cores
- 250+ GB storage (SSD)
- Ubuntu 22.04.03 LTS (Jammy Jellyfish) or Debian 12 (Bookworm)

# INSTALLATION

## Important

Nodes should always be configured using the node installer provided by DLT.GREEN. It's not recommended to modify parameters manually, as they won't be considered during updates and will be reset. If you need to add a feature or wish to include a plugin in the installer, you're encouraged to do so. Please report any such requests via our Discord channel to the DLT.GREEN team.

### Prerequisites

Before starting the installation process, ensure you have:

- A server or VPS
- Your own domain

An SSL certificate is automatically generated via Let's Encrypt, but you can also assign your own certificate.

## NODE-INSTALLER Installation

```console
sudo wget https://github.com/dlt-green/node-installer-docker/releases/latest/download/node-installer.sh && sudo sh node-installer.sh
```

## NODE-INSTALLER with GUI

When you run the installer for the first time, an alias is automatically created at the user level, which means that the logged-in user can use this alias as an alternative after starting the installer for the first time:

```console
dlt.green
```

## NODE-INSTALLER unattended

```console
dlt.green [-m mode/optional] [-t time/optional] [-r reboot/optional] [-c checks/optional] [-l logs/optional]
```

- `mode`:
  - `s`: Start all Nodes
  - `0`: Maintenance -> System Updates/Docker Cleanup/Certificate Update (this mode also automatically installs Docker if Docker was not preinstalled)
  - `1`: Update -> IOTA-Hornet
  - `2`: Update -> IOTA-Wasp
  - `5`: Update -> Shimmer-Hornet
  - `6`: Update -> Shimmer-Wasp
  - `u`: Mode 0 with unattended recursive Node Updates (if possible). The last 10 releases in the Github pipeline are supported (older versions are not updated).
- `time`: 0-20 seconds (default: 10)
- `reboot`:
  - `0`: no reboot
  - `1`: system reboot (nodes will be automatically shut down before) (default: 0)
- `checks`:
  - `0`: checks disabled (not recommended)
  - `1`: UFW Firewall and Autostart will be automatically enabled (enforced) (default: 1)
- `logs`:
  - `i`: all logs
  - `w`: only warning and error logs
  - `e`: only error logs
    (default: i)

## Operation

The script is operated by entering the numbers that are displayed in the menu. If you click on the image you will see [video tutorials](https://www.youtube.com/channel/UCg1PgTJ1NzdoS1JYcnJtDUg) for installing IOTA/Shimmer Nodes:

[![Installation](https://github.com/dlt-green/node-installer-docker/assets/89119285/e6bb308b-29a7-48e6-8eac-809e3069139a)](https://www.youtube.com/channel/UCg1PgTJ1NzdoS1JYcnJtDUg)

# Error messages and suggestions

If you find any bugs or have suggestions for improving our script, create an issue on Github or contact our team in our Discord channel.

**Suggestions for improvement:** [Github Issues](https://github.com/dlt-green/node-installer-docker/issues)
**Contact:** [Discord](https://discord.gg/XaBnsE5NGb)

# DISCLAIMER

Please note that using this script is at your own risk and DLT.GREEN is not liable for any damages.

# DISCLOSURE

We would like to point out that this is not a supported installer by the Iota Foundation and you will not receive any support from the IF if you use this installer. You get support in our discord from our team or the community.

# Donations

THIS PROJECT IS DEVELOPED BY DLT.GREEN WITH ITS COMMUNITY.
YOU CAN SUPPORT THIS PROJECT WITH DONATIONS TO THE DLT.GREEN TREASURY:

- IOTA: [`iota1qq7seed74mzvy9g6nj2nj88pm37gf2x5qv35jcun78n86hyzaqcaggy8ewa`](https://explorer.iota.org/mainnet/addr/iota1qq7seed74mzvy9g6nj2nj88pm37gf2x5qv35jcun78n86hyzaqcaggy8ewa)
- Shimmer: [`smr1qzp87wkakd22ld6rvcjuwuvn5usevmvut565y6l32xhfucpemu0extkpws0`](https://explorer.shimmer.network/shimmer/addr/smr1qzp87wkakd22ld6rvcjuwuvn5usevmvut565y6l32xhfucpemu0extkpws0)
- Shimmer EVM: [`0x6c5ab03b8e4b4f9ec591d211411082a7ab925c05`](https://explorer.evm.shimmer.network/address/0x6c5aB03b8E4b4F9ec591D211411082A7ab925C05)
- Soonaverse: [`https://soonaverse.com/member/0x422bed2759f72e7d6ae1e100707ca45e26e9a12c`](https://soonaverse.com/member/0x422bed2759f72e7d6ae1e100707ca45e26e9a12c)