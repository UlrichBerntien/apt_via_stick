#! /usr/bin/env bash

# Erzeugt ein Script um alte Pakete auf dem Stick zu löschen.
# Die Pakete werden nicht direkt gelöscht, damit das erzeugte
# Skript kontrolliert werden kann vor dem Löschen.

# Exit on error, treat unset variable as error
set -o errexit
set -o nounset

# Wurzel-Verzeichnis des USB-Sticks
TargetRoot=/media/$USER/UBUNTU-MATE
# Verzeichnis mit den Paketen auf dem USB-Stick
TargetDebs=$TargetRoot/pool/extra

# Kontrolle ob verwendete Verzeichnisse existieren
for TestPath in $TargetRoot $TargetDebs; do
   if [[ ! -e $TestPath ]]
   then
      echo "Verzeichnis $TestPath fehlt"
      exit 1
   fi
done

# Liste der aktuellen Pakete erstellen
dpkg-scanpackages "$TargetDebs" 2> /tmp/scan.error.txt |
   awk -e '/Filename:/ {print $2}' > /tmp/list-current-debs.txt
neededDebs=$(</tmp/list-current-debs.txt)

for name in "$TargetDebs"/*.deb; do
   if [[ ! $neededDebs == *$name* ]]; then
      echo "rm $name"
      fi
done > /tmp/remove-not-used-debs.sh
