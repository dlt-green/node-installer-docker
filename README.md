![GitHub latest release](https://img.shields.io/github/v/release/dlt-green/Node-Installer-docker)
![GitHub release date](https://img.shields.io/github/release-date/dlt-green/Node-Installer-docker)
![GitHub contributors](https://img.shields.io/github/contributors/dlt-green/Node-Installer-docker)
![GitHub license](https://img.shields.io/github/license/dlt-green/Node-Installer-docker)

# DLT.GREEN Vision

We are a team of individuals from the IOTA community with a vision to create a DNS server for the IOTA/Shimmer ecosystem, aiming to enhance user experience. Here, "DNS" stands for "Dynamic Node Selection." Our objective is to move away from static node usage in wallets towards dynamic selection based on the situation. The era of static nodes within the IOTA/Shimmer ecosystem is coming to an end. Envision never having to worry about the operational status of nodes. Picture IoT devices autonomously selecting nodes tailored to their specific needs; this could be based on factors such as proof of work, event support, trustworthiness, or available access speed. We prioritize direct data traffic between the wallet and the node itself, bypassing the node pool.

## DLT.GREEN Automatic Node-Installer for Docker

The DLT.GREEN Node-Installer-Docker provides an easy-to-use script that streamlines the setup of IOTA/Shimmer Nodes (Hornet, Wasp). With Docker running behind the scenes, our installation process is designed to be user-friendly, catering to both novices and seasoned users interested in deploying IOTA/Shimmer nodes on a server or virtual private server (VPS).

### Hardware Recommendations

#### For Standard Nodes
- **RAM:** 8 GB minimum
- **CPU Cores:** 4
- **Storage:** 160 GB SSD minimum
- **Operating System:** Ubuntu 22.04.04 LTS (Jammy Jellyfish) or Debian 12 (Bookworm)

#### For Event-Tracking Nodes or Additional Plugins
- **RAM:** 16 GB minimum
- **CPU Cores:** 6+
- **Storage:** 250 GB SSD minimum
- **Operating System:** Ubuntu 22.04.04 LTS (Jammy Jellyfish) or Debian 12 (Bookworm)

## Installation Guide

### Prerequisites
Before commencing with the installation:
- Ensure you have access to a server or VPS.
- Secure your own domain name.
Note: SSL certificates will be generated via Let's Encrypt automatically, but you can also use your own certificate.

### Installing Node-Installer

Execute the following command in your console:
```console
sudo wget https://github.com/dlt-green/node-installer-docker/releases/latest/download/node-installer.sh && sudo sh node-installer.sh
```

### Node-Installer with GUI

After running the installer for the first time, it creates an alias accessible at the user level:
```console
dlt.green
```

### Node-Installer Unattended Mode

To run the Node-Installer in unattended mode, use the following syntax with optional flags:
```console
dlt.green [-m mode/optional] [-t time/optional] [-r reboot/optional] [-c checks/optional] [-l logs/optional]
```

Each flag represents a different configuration option:

- `mode`: Sets the operation mode of the installer.
   - `s`: Start all Nodes.
   - `0`: Maintenance – Performs system updates, Docker cleanup, and certificate update. Installs Docker if not present.
   - `1`: Update – Updates IOTA-Hornet nodes.
   - `2`: Update – Updates IOTA-Wasp nodes.
   - `5`: Update – Updates Shimmer-Hornet nodes.
   - `6`: Update – Updates Shimmer-Wasp nodes.
   - `u`: Executes Mode 0 and performs unattended recursive Node Updates when possible. Supports the last 10 releases in the GitHub pipeline (older versions are not updated).
   - `d`: Debugging with output to CLI
- `time`: Sets the delay in seconds before executing an action (0-20 seconds, default: 10).
- `reboot`:
   - `0`: No reboot after operations.
   - `1`: Executes a system reboot (only if necessary) with automatic node shutdown prior to it (default: 0).
- `checks`:
   - `0`: Disables checks (not recommended).
   - `1`: Enforces UFW Firewall and Autostart setup (default: 1).
- `logs`:
   - `i`: Displays all logs.
   - `w`: Shows only warnings and errors in logs.
   - `e`: Shows only errors in logs (default: i).

Utilize these options according to your needs to automate node management tasks efficiently.

### Node-Installer Automatic Maintenance and Automatic Node Update Mode

There is an option to automate automatic system relevant updates, during which the nodes are terminated in the meantime. In addition, the nodes themselves can also be updated automatically. The installer's Github pipeline is used chronologically for the updates. In exceptional cases, manual intervention must be carried out, but you will be notified via a notification service if activated. If necessary, the server will be automatically restarted and the nodes are then also automatically restarted.

### Node-Installer Notification Mode

There is an option to receive status reports from automated processes of your nodes. You do not have to register or reveal any of your personal data. These notifications are delivered directly to your mobile or desktop device using our in-house push notification service. To receive notifications on your phone, install the app, either via Google Play, F-Droid or Apple. Once installed, open it and add the shown MessageId in the installer (Notify-Me) to a topic. In the settings of each topic you can define also your own description.

The notification level can be set in the installation menu [ info | warn | err! ]. In addition, depending on the notification level, messages are sent with different priorities. This means that information is sent and a log is available, but it is not disruptive due to the frequency. Warnings and errors then immediately raise an alarm with pushes. If necessary, the sleep mode on the cell phone can also be interrupted in the event of errors. 

#### Mobile App:

![image](https://github.com/dlt-green/node-installer-docker/assets/89119285/4c9b3831-bf3e-44c8-998c-37f8d51ca720)   ![image](https://github.com/dlt-green/node-installer-docker/assets/89119285/9b14705e-b9e0-4166-b14e-9b0fb4f6fee5)


[![image](https://github.com/dlt-green/node-installer-docker/assets/89119285/db8a1d0f-c7e8-4048-992f-14a24de674c3)](https://play.google.com/store/apps/details?id=io.heckel.ntfy) [![image](https://github.com/dlt-green/node-installer-docker/assets/89119285/c9670c2e-ef99-46e1-9dac-fbf6d53a48c9)](https://f-droid.org/en/packages/io.heckel.ntfy/) [![image](https://github.com/dlt-green/node-installer-docker/assets/89119285/78ce7ad3-3502-4130-b951-3c4ac103d471)](https://apps.apple.com/us/app/ntfy/id1625396347)

#### Desktop:

![image](https://github.com/dlt-green/node-installer-docker/assets/89119285/cbbe1dfe-b647-45f4-9c77-a629031136ea)

### Operation Tutorial

For a visual aid on installing IOTA/Shimmer Nodes using our script, visit our [video tutorials](https://www.youtube.com/channel/UCg1PgTJ1NzdoS1JYcnJtDUg).

[![Installation Video Tutorial](https://github.com/dlt-green/Node-Installer-docker/assets/89119285/e6bb308b-29a7-48e6-8eac-809e3069139a)](https://www.youtube.com/channel/UCg1PgTJ1NzdoS1JYcnJtDUg)

## Feedback and Support

Encounter an issue or have suggestions? Please create a Github issue or reach out to our team on Discord.

**Improvement Suggestions:** [Github Issues](https://github.com/dlt-green/Node-Installer-docker/issues)

**Contact Us:** [Discord](https://discord.gg/XaBnsE5NGb)

## Disclaimer

Use of this script is at your own risk. DLT.GREEN assumes no responsibility for any damages incurred.

## Disclosure

This is an independent installer not endorsed by the Iota Foundation; thus, IF support will not be available. However, our team and community offer support through our Discord.

## Donations

DLT.GREEN and its community proudly develop this project. Support us with donations:

**IOTA**: [`iota1qq7seed74mzvy9g6nj2nj88pm37gf2x5qv35jcun78n86hyzaqcaggy8ewa`](https://explorer.iota.org/mainnet/addr/iota1qq7seed74mzvy9g6nj2nj88pm37gf2x5qv35jcun78n86hyzaqcaggy8ewa)

**Shimmer**: [`smr1qzp87wkakd22ld6rvcjuwuvn5usevmvut565y6l32xhfucpemu0extkpws0`](https://explorer.shimmer.network/shimmer/addr/smr1qzp87wkakd22ld6rvcjuwuvn5usevmvut565y6l32xhfucpemu0extkpws0)

**Shimmer EVM**: [`0x6c5ab03b8e4b4f9ec591d211411082a7ab925c05`](https://explorer.evm.shimmer.network/address/0x6c5aB03b8E4b4F9ec591D211411082A7ab925C05)

**Soonaverse**: [`https://soonaverse.com/member/0x422bed2759f72e7d6ae1e100707ca45e26e9a12c`](https://soonaverse.com/member/0x422bed2759f72e7d6ae1e100707ca45e26e9a12c)
