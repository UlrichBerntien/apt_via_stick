#!/usr/bin/env bash

# Erzeugt ein Script mit dem die Dateien für ein Update der Paketlisten
# geladen und entpackt werden.

# Bei einem Fehler das Skript sofort beenden (-e)
# Fehler bei verwendung nicht definierter Variable melden (-u)
set -o errexit
set -o nounset

# Skript für das Laden und Entpacken der Paketlisten
scriptFile="/tmp/updateload.sh"

# Liste aller Dateien zum Aktualisieren der Paketliste
apt-get --quiet --yes --print-uris update |
# Die Zeilen mit URLs selektieren
grep ^\' |
# Liste einlesen und Skript für jeden Eintrag erstellen
( while read -r entryUrl entryFile entryOthers
  do
    # ggf. komprimierte Dateien entpacken
    case $entryUrl in
      *.xz\')
           compression="xz"
           entryFile=$entryFile".xz" ;;
      *.gz\')
           compression="gz"
           entryFile=$entryFile".gz" ;;
      *.z\')
           compression="gz"
           entryFile=$entryFile".z" ;;
      *)
           compression="" ;;
    esac
    # apt-get schreibt die URLs in Anführungszeichen,
    # aber curl will die URLs ohne Anführungszeichen.
    # Mit dem Schalter --location folgt curl auch den
    # 'file moved' Angaben des Servers.
    echo "curl --location --output $entryFile --url ${entryUrl//"'"/}"
    case $compression in
       xz)
           echo "xz --decompress $entryFile" ;;
       gz)
           echo "gzip --decompress $entryFile" ;;
    esac
  done ) > $scriptFile

