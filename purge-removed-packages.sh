#!/usr/bin/env sh
# Purge removed packges.

# Exit script if a command fails, unset variable used
set -o errexit
set -o nounset

# Store list of packages to purge in a temporary file
buffer_file=$(mktemp)

# Generate list of packages to purge, one package per line.
# A package is identified by name and architecture because
# on a amd64 system amd64 and i386 packages are possible.
dpkg-query --show --showformat='${Status}\t${Package}:${Architecture}\n' |
awk --field-separator="\t" '/deinstall ok/ { print $2 }' > "$buffer_file"

# Exit if list is empty
if [ ! -s "$buffer_file" ]; then
   echo "no deinstalled packages found, no package to purge"
   rm "$buffer_file"
   exit
fi

# Print the list of the packages and ask before purge
xargs --arg-file "$buffer_file" --no-run-if-empty --delimiter="\n" dpkg --list
read -r -p "Purge the listed packages (y|n)?" answer
if [ "$answer" = "y" ]; then
   xargs --arg-file "$buffer_file" --no-run-if-empty --delimiter="\n" sudo dpkg --purge
fi
rm "$buffer_file"
