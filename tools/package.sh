#!/usr/bin/env bash
# Packs every folder under templates/ into dist/gamewe-web-template-<name>-<version>.tar.gz
# and writes dist/SHA256SUMS over all archives.
#
# Each archive holds one folder, <name>/, so it can be extracted straight into
# the TEMPLATES_DIR of gameWE-web. The archives are reproducible: sorted
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

for dir in templates/*/; do
  name=$(basename "$dir")
  out=dist/gamewe-web-template-$name-$version.tar.gz
  tar --create --format=gnu --sort=name --mtime="@$mtime" \
    --owner=0 --group=0 --numeric-owner --mode='u=rwX,go=rX' \
    -C templates "$name" | gzip -9 -n >"$out"
  echo "package: $out"
done

(cd dist && sha256sum -- *.tar.gz >SHA256SUMS)
echo "package: dist/SHA256SUMS"
