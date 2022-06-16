#!/usr/bin/env sh

# Skript bei einem Fehler beenden
# Fehler auslösen, wenn Zugriff auf nicht definierte Variable
set -o errexit
set -o nounset

# Benötigt Zugriff auf den Ubuntu Installations und Pakete Stick
stickRoot="/media/$USER/UBUNTU-MATE"
# Die Listen sind in einem Verzeichnis auf dem Stick
storedLists="$stickRoot/ADD-ONS/var-lib-apt-lists"

# Arbeiten in einem temporären Verzeichnis
workDir=$(mktemp -d -t apt_lists.XXXXXXXXXX)

# Das partial Verzeichnis wird nicht benötigt.
if test -d "$storedLists/partial"; then
   rm -r "$storedLists/partial"
fi
# Alle Listen vom Stick kopieren
rsync -a "$storedLists/ $workDir"
# Zugriffsrechte so setzen, wie sie nach dem Kopieren ins Ziel sein sollen
chmod o+rX -R "$workDir"

# Die Attribute der kopierten Listen anpassen
# nach dem Kopieren aus dem FAT Dateisystem haben die Dateien +x gesetzt.
chmod a=r,u=rw "$workDir/*"
sudo chown root:root "$workDir" "$workDir/*"

# nur die geänderten Listen in das apt Verzeichnis kopieren
sudo rsync -act "$workDir/" /var/lib/apt/lists/

# Aufräumen, das temporäre Verzeichnis löschen
sudo chown "$USER" "$workDir"
rm -r -f "$workDir"
