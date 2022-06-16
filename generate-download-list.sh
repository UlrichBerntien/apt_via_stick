#!/usr/bin/env bash

# Erzeugt eine Liste mit all Dateien die zum Aktualisieren und
# möglichen Installieren der Pakete benötigt werden.
# Die Liste ist vorbereitet für die Verwendung mit 'curl -K'.

# Fehler bei verwendung nicht definierter Variable melden
set -o nounset

# Erzeugt die Listen:
# Liste für alle nicht lokal vorhandenen Pakete
allList="/tmp/allNotLocalDebs.list"
# Liste für alle nicht auf dem Stick vorhandenen Pakete
# Das Format der Liste ist zugeschnitten für einen "curl -K datei"
# Aufruf mit einem Parameter pro Zeile.
missingList="/tmp/missingDebs.list"

# Benötigt Zugriff auf den Ubuntu Installations und Pakete Stick
stickRoot="/media/$USER/UBUNTU-MATE"
# Die Paketliste ist auf dem Stick in der Datei
paketList="$stickRoot/ADD-ONS/add-packages.txt"
# Die Pakete sind auf dem Stick im Verzeichis
storedDebs="$stickRoot/pool/extra"

# Die Liste der zu installierenden Pakete muss existieren
if [[ ! -r $paketList ]]
then
   echo "Paketliste $paketList fehlt"
   exit
fi

# Liste aller Dateien zum Installieren der Pakete
# Durch den Schalter "-L 1" wird apt-get immer nur für ein Paket aufgerufen.
# Ohne diesen Schalter tritt seit Ubuntu 18.10 ein Fehler auf.
grep -v '#' "$paketList" |
xargs -L 1 apt-get --quiet --yes --allow-change-held-packages --print-uris install |
grep "^'" > $allList

# Liste aller Dateien zum Aktualisieren der bereits installierten Pakete.
# Achtung: apt-get liefert einen Fehlercode zurück, wenn keine Dateien
# benötigt werden. Daher arbeitet dieses Skript mit "-e" nicht korrekt.
apt-get --quiet --yes --print-uris dist-upgrade |
grep "^'" >> $allList

# Filtern der Liste aller Dateien:
#    Doppelte Dateien in der Liste entfernen,
#    Die auf dem Stick vorhandenen Dateien nicht laden.
# Ausgabe erfolgt zeilenweise zum Lesen mit "curl -K".
sort --unique $allList |
( while read -r entryUrl entryFile entryOthers
  do
    if [[ ! -f "${storedDebs}/${entryFile}" ]]
    then
       echo "--output $entryFile"
       # apt-get schreibt die URLs in Anführungszeichen,
       # aber curl will die URLs ohne Anführungszeichen.
       echo "--url ${entryUrl//"'"/}"
    fi
  done ) > $missingList
