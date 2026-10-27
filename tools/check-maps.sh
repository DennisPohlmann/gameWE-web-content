#!/usr/bin/env bash
# Checks every folder under maps/ against the rules gameWE-web applies when it
# reads map pictures from /var/lib/gamewe/web/overviews (before 0.36.0 from
# OVERVIEWS_DIR): one folder per game code, in it <map>.png (the picture) and <map>.json (its calibration), lower-case names,
# plain files only, PNG at most 8 MB, JSON at most 64 KB.
set -euo pipefail

cd "$(dirname "$0")/.."

fail=0
err() { echo "check-maps: $*" >&2; fail=1; }

[ -d maps ] || { echo "check-maps: maps/ is missing" >&2; exit 1; }

# Nothing in maps/ may be a symbolic link or a special file.
while IFS= read -r -d '' p; do
  err "$p is not a plain file or folder"
done < <(find maps -mindepth 1 ! -type f ! -type d -print0)

# Only game folders directly under maps/.
while IFS= read -r -d '' p; do
  err "$p: only game folders belong directly in maps/"
done < <(find maps -mindepth 1 -maxdepth 1 ! -type d -print0)

png_magic=$(printf '\211PNG\r\n\032\n' | od -An -tx1 | tr -d ' \n')

games=0
total=0
for dir in maps/*/; do
  dir=${dir%/}
  game=${dir#maps/}
  games=$((games + 1))
  count=0

  if ! [[ $game =~ ^[a-z0-9][a-z0-9_-]{0,31}$ ]]; then
    err "$game: folder name must match ^[a-z0-9][a-z0-9_-]{0,31}\$ (a game code)"
  fi

  while IFS= read -r -d '' f; do
    name=${f#"$dir"/}
    case $name in
      */*) err "$f: no subfolders in a game folder"; continue ;;
      *.png | *.json) ;;
      *) err "$f: unexpected file (only <map>.png and <map>.json)"; continue ;;
    esac
    map=${name%.*}
    if ! [[ $map =~ ^[a-z0-9_.+-]+$ ]]; then
      err "$f: map name must be lower case a-z, 0-9, _ . + -"
    fi

    if [[ $name == *.png ]]; then
      count=$((count + 1))
      [ "$(wc -c <"$f")" -le 8388608 ] || err "$f: larger than 8 MB"
      [ "$(head -c 8 "$f" | od -An -tx1 | tr -d ' \n')" = "$png_magic" ] || err "$f: not a PNG"
      [ -f "$dir/$map.json" ] || err "$f: $map.json (calibration) is missing"
    else
      [ "$(wc -c <"$f")" -le 65536 ] || err "$f: larger than 64 KB"
      jq -e 'type == "object"
        and (.pos_x | type == "number") and (.pos_y | type == "number")
        and (.scale | type == "number") and .scale > 0' "$f" >/dev/null 2>&1 ||
        err "$f: needs numbers pos_x, pos_y and scale > 0"
      [ -f "$dir/$map.png" ] || err "$f: $map.png (picture) is missing"
    fi
  done < <(find "$dir" -mindepth 1 -print0)

  [ "$count" -gt 0 ] || err "$game: no map pictures"
  total=$((total + count))
done

if [ "$fail" -ne 0 ]; then
  exit 1
fi
echo "check-maps: $total maps in $games games ok"
