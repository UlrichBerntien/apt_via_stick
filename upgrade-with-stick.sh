#!/usr/bin/env sh

# Skript bei einem Fehler beenden
# Fehler auslösen, wenn Zugriff auf nicht definierte Variable
set -o errexit
set -o nounset


# Benötigt Zugriff auf den Ubuntu Installations und Pakete Stick
stickRoot="/media/$USER/UBUNTU-MATE"
# Die Pakete sind auf dem Stick im Verzeichis
storedDebs="$stickRoot/pool/extra"


apt-get --quiet --yes --print-uris dist-upgrade "$*" |
grep "^'" |
while read -r entryUrl entryFile entryOthers
do
  sudo cp "$storedDebs/$entryFile" /var/cache/apt/archives/
done

sudo apt-get dist-upgrade "$*"
