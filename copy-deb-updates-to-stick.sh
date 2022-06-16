#! /usr/bin/env sh

# Kopiere Paketlisten und neue Pakete aus dem Cache
# auf den USB Stick

# Exit on error, treat unset variable as error
set -o errexit
set -o nounset

# Wurzel-Verzeichnis des USB-Sticks
TargetRoot=/media/$USER/UBUNTU-MATE
# Verzeichnis mit dem Paketlisten auf dem USB-Stick
TargetLists=$TargetRoot/ADD-ONS/var-lib-apt-lists
# Verzeichnis mit den Paketen auf dem USB-Stick
TargetDebs=$TargetRoot/pool/extra

# Kontrolle ob verwendete Verzeichnisse existieren
for TestPath in $TargetRoot $TargetLists $TargetDebs
do
   if test ! -e "$TestPath"; then
      echo "Verzeichnis $TestPath fehlt"
      exit 1
   fi
done

# Aktualisieren der Listen
# -v: Verbose
# -c: Skip based on checksum
# -d: Transfer directory without recursing
# -p: Copy permissions
# -t: Preserve modification times
rsync -vcdpt --exclude=lock --exclude=partial /var/lib/apt/lists/ "$TargetLists"

# Aktualisieren der Pakete
rsync -vcdpt --exclude=lock --exclude=partial /var/cache/apt/archives/ "$TargetDebs"

# Filesystem Caches schreiben, damit alle Dateien auf dem USB-Stich sind
sync
