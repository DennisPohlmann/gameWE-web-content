# gameWE web content
#
#   make check     check every template in templates/ and every map picture in maps/
#   make package   dist/gamewe-web-template-<name>-<version>.tar.gz,
#                  dist/gamewe-web-maps-<game>-<version>.tar.gz and dist/SHA256SUMS
#   make verify    check dist/ against dist/SHA256SUMS
#   make clean     remove dist/

VERSION ?=

.PHONY: all check package verify clean

all: check package

check:
	bash tools/check-templates.sh
	bash tools/check-maps.sh

package: check
	bash tools/package.sh $(VERSION)

verify:
	cd dist && sha256sum --check --strict SHA256SUMS

clean:
	rm -rf dist
