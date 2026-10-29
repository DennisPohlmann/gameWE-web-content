# gameWE web content
#
#   make check     check every template in templates/ and every map picture in maps/
#   make package   dist/gamewe-web-template-<name>-<version>.tar.gz,
#                  dist/gamewe-web-maps-<game>-<version>.tar.gz and dist/SHA256SUMS
#   make verify    check dist/ against dist/SHA256SUMS
#   make clean     remove dist/
#   make modern [WEB=../web]        regenerate the modern-* templates with the
#                                   generator of a gameWE-web checkout
#   make modern-check [WEB=../web]  exit 1 if one is out of date for it

VERSION ?=
WEB ?= ../web

.PHONY: all check package verify clean modern modern-check

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

modern:
	node $(WEB)/scripts/modern-templates.mjs --variants generator/modern-variants.json --out templates

modern-check:
	node $(WEB)/scripts/modern-templates.mjs --variants generator/modern-variants.json --out templates --check
