#! /usr/bin/env bash

set -euo pipefail

n
paru -Sy

cd ~/sonstige/tmp/artifacts/
ls -la

GIT=${1:-"no"}

if [[ "$GIT" = "git" ]]; then
  echo todo
  exit 1
else
  echo "non-git"
  paru -U "./$(pkgversion-latest-by-prefix.sh zfs-linux)" "./$(pkgversion-latest-by-prefix.sh zfs-linux-headers)" "./$(pkgversion-latest-by-prefix.sh zfs-utils)" # "./$(pkgversion-latest-by-prefix.sh zfs-utils-debug)"
fi

# reinstall linux to make sure mkinitcpio is triggered, sometimes it doesn't after gpu drivers update (theoretically shouldn't be needed if mkinitcpio hooks work properly)
paru -Syu linux linux-headers linux-api-headers
