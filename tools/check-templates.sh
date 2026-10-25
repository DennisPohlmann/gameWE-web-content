#!/usr/bin/env bash
# Checks every folder under templates/ against the rules gameWE-web applies
# when it loads a template (templates/README.md of gameWE-web), plus the
# rules of this repository: plain files only, a fixed set of file names,
# valid JSON, no external resources in theme.css.
set -euo pipefail

cd "$(dirname "$0")/.."

fail=0
err() { echo "check-templates: $*" >&2; fail=1; }

[ -d templates ] || { echo "check-templates: templates/ is missing" >&2; exit 1; }

# Nothing in templates/ may be a symbolic link or a special file.
while IFS= read -r -d '' p; do
  err "$p is not a plain file or folder"
done < <(find templates -mindepth 1 ! -type f ! -type d -print0)

count=0
for dir in templates/*/; do
  dir=${dir%/}
  name=${dir#templates/}
  count=$((count + 1))

  if ! [[ $name =~ ^[a-z0-9_-]{1,32}$ ]]; then
    err "$name: folder name must be 1-32 of a-z, 0-9, - and _"
  fi

  while IFS= read -r -d '' f; do
    case ${f#"$dir"/} in
      theme.css | chart.json | template.json) ;;
      *) err "$f: unexpected file (only theme.css, chart.json, template.json)" ;;
    esac
  done < <(find "$dir" -mindepth 1 -print0)

  css=$dir/theme.css
  if [ ! -f "$css" ]; then
    err "$name: theme.css is missing"
  else
    [ "$(wc -c <"$css")" -le 262144 ] || err "$css: larger than 256 KB"
    grep -q 'html\[data-skin\]' "$css" || err "$css: no html[data-skin] block"
    if grep -n -i -E 'url\(|@import|https?:|//[a-z0-9.-]+\.[a-z]' "$css" >&2; then
      err "$css: external resource (url(), @import or an address); templates must not load anything"
    fi
    if grep -n -i -E 'expression\(|javascript:|behavior:|-moz-binding|</?(style|script)' "$css" >&2; then
      err "$css: script-like CSS"
    fi
  fi

  for json in "$dir/chart.json" "$dir/template.json"; do
    [ -f "$json" ] || continue
    jq -e 'type == "object"' "$json" >/dev/null 2>&1 || err "$json: not a JSON object"
  done
  if [ -f "$dir/chart.json" ]; then
    [ "$(wc -c <"$dir/chart.json")" -le 16384 ] || err "$dir/chart.json: larger than 16 KB"
  fi
  if [ -f "$dir/template.json" ]; then
    jq -e '.name | type == "object" and (.de | type == "string") and (.en | type == "string")' \
      "$dir/template.json" >/dev/null 2>&1 || err "$dir/template.json: needs name.de and name.en"
  fi
done

[ "$count" -gt 0 ] || err "no templates found"

if [ "$fail" -ne 0 ]; then
  exit 1
fi
echo "check-templates: $count templates ok"
