#!/usr/bin/env bash
# The checks of the CI job "build" (.github/workflows/build.yml), run
# locally, e.g. from the pre-push hook (tools/install-hooks.sh): check the
# templates and map pictures, pack them and verify the archives.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
make check
make package
make verify
printf '\ncheck-all: ok\n'
