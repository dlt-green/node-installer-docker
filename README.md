![GitHub latest release)](https://img.shields.io/github/v/release/dlt-green/node-installer-docker) ![GitHub release date](https://img.shields.io/github/release-date/dlt-green/node-installer-docker) ![GitHub](https://img.shields.io/github/contributors/dlt-green/node-installer-docker) ![GitHub](https://img.shields.io/github/license/dlt-green/node-installer-docker)

# DLT.GREEN VISION
Wir sind ein Team von Leuten aus der IOTA Community, welches sich die Vision gesetzt hat, einen DNS Server für das IOTA Ecosystem zur Verbesserung des Nutzererlebnisses ins Leben zu rufen. Dabei steht „DNS“ für „Dynamic Node Selection“. Unser Ziel ist es, dass eine Wallet nicht mehr mit einem statischen Zugangspunkt arbeitet, sondern sich dieser je nach Situation ändern kann. Die Zeit von statischen Zugangspunkten in das IOTA Ecosystem ist vorbei. Stellen Sie sich vor, nie mehr darüber nachzudenken, ob der Zugangspunkt funktioniert oder nicht. Stellen Sie sich Geräte in der IOT vor, welche sich vollautomatisch die Node für ihren individuellen Einsatzzweck aussuchen, dies kann z.B. nach Proof of Work, Unterstützung verschiedener Events, nach Vertrauenswürdigkeit oder nach verfügbarer Zugangsgeschwindigkeit sein. Dabei ist uns wichtig, dass der eigentliche Datenverkehr dann zwischen der Wallet und der Node selbst und nicht über den NodePool geführt wird.

# DLT.GREEN AUTOMATIC NODE-INSTALLER DOCKER
DLT.GREEN Node-Installer ist ein Skript zur Installation von IOTA/Shimmer Nodes (Hornet, Wasp). Die Installation erfolgt mit Docker im Hintergrund und soll es jedem, auch Anfängern, ermöglichen in kurzer Zeit Iota Nodes auf einem Server oder einem Virtual Private Server (VPS) einrichten zu können.

# Voraussetzungen
### Mindestanforderungen für eine Node
 - 8 GB RAM 
 - 4 CPU Kerne
 - 160 GB Speicher (SSD)
 - Ubuntu 22.04 LTS

### Mindestanforderungen für Nodes die auch Events (Staking, Voting, etc.) tracken möchten
 - 16 GB RAM 
 - 4+ CPU Kerne 
 - 250+ GB Speicher (SSD)
 - Ubuntu 22.04 LTS

# Installation
### Wichtig
Die Konfiguration der Nodes sollte immer über den von DLT.GREEN bereitgestellten Node-Installer erfolgen. Es ist nicht ratsam Veränderungen an den Parametern zu machen, da die eingestellten direkten Parameter bei einem Update nicht berücksichtigt werden und somit zurückgesetzt werden.

### Ein Server oder VPS und eine eigene Domain muss vorhanden sein, bevor mit der Installation begonnen wird.
Es wird automatisch ein SSL Zertifikat über Let's Encrypt generiert, es kann jedoch auch ein eigenes Zertifikat zugewiesen werden.

#

### NODE-INSTALLER Installation
```console
sudo wget https://github.com/dlt-green/node-installer-docker/releases/latest/download/node-installer.sh && sudo sh node-installer.sh
```

### NODE-INSTALLER mit GUI

Mit dem erstmaligen ausführen des Installers wird automatisch ein Alias auf Benutzerebene angelegt, bedeutet, dass under dem angemeldeten Benutzer nach dem erstmaligen starten des Installers alternativ dieser Alias verwendet werden kann:

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
         this mode is experimental in the moment
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

### Bedienung
Die Bedienung des Skripts erfolgt über die Eingabe der Zahlen, welche im Menü angezeigt werden.  
Wenn Sie auf das Bild klicken, sehen Sie <a href="https://www.youtube.com/channel/UCg1PgTJ1NzdoS1JYcnJtDUg">Video-Tutorials</a> für die Installation von IOTA und Shimmer Nodes:

<div align="left">
      <a href="https://www.youtube.com/channel/UCg1PgTJ1NzdoS1JYcnJtDUg">
      <img src="https://github.com/dlt-green/node-installer-docker/assets/89119285/bb3afc0b-7534-4963-b920-cb01fc4e38ef"
      alt="Installation">
      </a>
</div>

# Fehlermeldungen und Vorschläge
Wenn du Fehler gefunden hast oder Verbesserungsvorschläge für unser Skript hast, erstelle ein Issue auf Github oder wende dich an unser Team in unserem Discord Channel

<b>Verbesserungsvorschläge: <a href="https://github.com/dlt-green/node-installer-docker/issues">Github Issues</a></b><br>
<b>Kontakt: <a href="https://discord.gg/XaBnsE5NGb">Discord</a></b>

# Disclaimer
Bitte beachten, dass die Verwendung dieses Skripts auf eigenes Risiko erfolgt und DLT.GREEN für eventuelle Schäden nicht haftet.

# Disclosure
IT'S NO OFFICIAL INSTALLER FROM IF - YOU WILL GET NO SUPPORT BY IF WHEN YOU USE IT  
BUT YOU WILL GET SUPPORT BY DLT.GREEN IN OUR DISCORD

# Donations
THIS PROJECT IS DEVELOPED BY DLT.GREEN WITH ITS COMMUNITY.  
YOU CAN SUPPORT THIS PROJECT WITH DONATIONS TO THE DLT.GREEN TREASURY:  
https://explorer.iota.org/mainnet/addr/iota1qznzkq2n6kakps36s7w0z0gmuf0p70x647ghqshlfjlumqrld49l7zemavy
https://soonaverse.com/member/0x422bed2759f72e7d6ae1e100707ca45e26e9a12c
