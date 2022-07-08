![GitHub latest release)](https://img.shields.io/github/v/release/dlt-green/node-installer-docker) ![GitHub release date](https://img.shields.io/github/release-date/dlt-green/node-installer-docker) ![GitHub](https://img.shields.io/github/contributors/dlt-green/node-installer-docker) ![GitHub](https://img.shields.io/github/license/dlt-green/node-installer-docker)

# DLT.GREEN VISION
Wir sind ein Team von Leuten aus der IOTA Community, welches sich die Vision gesetzt hat, einen DNS Server für das IOTA Ecosystem zur Verbesserung des Nutzererlebnisses ins Leben zu rufen. Dabei steht „DNS“ für „Dynamic Node Selection“. Unser Ziel ist es, dass eine Wallet nicht mehr mit einem statischen Zugangspunkt arbeitet, sondern sich dieser je nach Situation ändern kann. Die Zeit von statischen Zugangspunkten in das IOTA Ecosystem ist vorbei. Stellen Sie sich vor, nie mehr darüber nachzudenken, ob der Zugangspunkt funktioniert oder nicht. Stellen Sie sich Geräte in der IOT vor, welche sich vollautomatisch die Node für ihren individuellen Einsatzzweck aussuchen, dies kann z.B. nach Proof of Work, Unterstützung verschiedener Events, nach Vertrauenswürdigkeit oder nach verfügbarer Zugangsgeschwindigkeit sein. Dabei ist uns wichtig, dass der eigentliche Datenverkehr dann zwischen der Wallet und der Node selbst und nicht über den NodePool geführt wird.

# DLT.GREEN AUTOMATIC NODE-INSTALLER DOCKER
DLT.GREEN Node-Installer ist ein Skript zur Installation von Iota Nodes (Bee, Hornet, GoShimmer und Wasp). Die Installation erfolgt mit Docker im Hintergrund und soll es jedem, auch Anfängern, ermöglichen in kurzer Zeit Iota Nodes auf einem Server oder einem Virtual Private Server (VPS) einrichten zu können.

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

### Ein Server oder VPS muss vorhanden sein, bevor mit der Installation begonnen wird.

#

### NODE-INSTALLER ausführen
```console
sudo wget https://dlt.green/downloads/node-installer.sh && sh node-installer.sh
```

### Bedienung
Die Bedienung des Skripts erfolgt über die Eingabe der Zahlen, welche im Menü angezeigt werden.

![image](https://user-images.githubusercontent.com/89119285/174690387-d5e3ff9a-7058-47ec-9eed-34ccfc178139.png)

# Fehlermeldungen und Vorschläge
Wenn du Fehler gefunden hast oder Verbesserungsvorschläge für unser Skript hast, erstelle ein Issue auf Github oder wende dich an unser Team in unserem Discord Channel

<b>Verbesserungsvorschläge: <a href="https://github.com/dlt-green/node-installer-docker/issues">Github Issues</a></b><br>
<b>Kontakt: <a href="https://discord.com/invite/jcjtARQuG2">Discord</a></b>

# Disclaimer
Bitte beachten, dass die Verwendung dieses Skripts auf eigenes Risiko erfolgt und DLT.GREEN für eventuelle Schäden nicht haftet.
