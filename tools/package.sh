#!/usr/bin/env bash
# Packs every folder under templates/ into dist/gamewe-web-template-<name>-<version>.tar.gz,
# every folder under maps/ into dist/gamewe-web-maps-<game>-<version>.tar.gz
# and writes dist/<archive>.sha256 next to each archive.
#
# Each archive holds one folder, <name>/ or <game>/, so it can be extracted
# straight into /var/lib/gamewe/web/templates or /var/lib/gamewe/web/overviews.
# The archives are reproducible: sorted
# entries, owner 0:0, fixed modes, the time of the last commit and gzip
# without a name or time stamp, so the same commit gives the same checksums.
#
# Usage: tools/package.sh [version]   (default: VERSION, else git describe, else "dev")
set -euo pipefail

cd "$(dirname "$0")/.."

version=${1:-}
if [ -z "$version" ] && [ -f VERSION ]; then
  version=$(tr -d '[:space:]' <VERSION)
fi
if [ -z "$version" ]; then
  version=$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//' || true)
fi
version=${version:-dev}
if ! [[ $version =~ ^[0-9A-Za-z.+-]+$ ]]; then
  echo "package: invalid version '$version'" >&2
  exit 1
fi

mtime=$(git log -1 --format=%ct 2>/dev/null || echo 0)

rm -rf dist
mkdir -p dist

# pack <base> <name> <archive>: <base>/<name>/ as one reproducible archive.
pack() {
  tar --create --format=gnu --sort=name --mtime="@$mtime" \
    --owner=0 --group=0 --numeric-owner --mode='u=rwX,go=rX' \
    -C "$1" "$2" | gzip -9 -n >"$3"
  echo "package: $3"
}

for dir in templates/*/; do
  name=$(basename "$dir")
  pack templates "$name" "dist/gamewe-web-template-$name-$version.tar.gz"
done

for dir in maps/*/; do
  game=$(basename "$dir")
  pack maps "$game" "dist/gamewe-web-maps-$game-$version.tar.gz"
done

# One checksum file per archive, run inside dist/ so the names in it are bare
# and `sha256sum --check <archive>.sha256` works next to the download.
(
  cd dist
  for archive in *.tar.gz; do
    sha256sum -- "$archive" >"$archive.sha256"
    echo "package: dist/$archive.sha256"
  done
)
