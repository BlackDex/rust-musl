# Default use localhost:5000, useful with a local registry for example
# If you want to get the source from somewhere else use `make IMAGE_REGISTRY=ghcr.io test-multi` for example
IMAGE_REGISTRY ?= localhost:5000
RUST_CHANNEL ?= stable
ARCH ?= x86_64
VERBOSE=
RELEASE=
FEATURES=

export IMAGE_REGISTRY
export RUST_CHANNEL
export ARCH

test-curl:
	./test.sh curl
test-dieselmulti:
	./test.sh dieselmulti
test-dieselmysql:
	./test.sh dieselmysql
test-dieselpg:
	./test.sh dieselpg
test-dieselsqlite:
	./test.sh dieselsqlite
test-hyper:
	./test.sh hyper
test-mimalloc:
	./test.sh mimalloc
test-multi:
	./test.sh multi
test-plain:
	./test.sh plain
test-pq:
	./test.sh pq
test-rocket:
	./test.sh rocket
test-rustls:
	./test.sh rustls
test-serde:
	./test.sh serde
test-ssl:
	./test.sh ssl
test-xml:
	./test.sh xml
test-zlib:
	./test.sh zlib

clean-lock:
	sudo find . -iname Cargo.lock -exec rm {} \;
clean-builds:
	sudo find . -mindepth 3 -maxdepth 3 -name target -exec rm -rf {} \;
	sudo rm -vf test/*/main.db
	sudo rm -vf test/*/qemu_*.core

clean: clean-lock clean-builds

test: test-curl test-dieselmulti test-dieselmysql test-dieselpg test-dieselsqlite test-hyper test-mimalloc test-multi test-plain test-pq test-rustls test-serde test-ssl test-xml test-zlib

.PHONY: test clean clean-lock clean-builds test-curl test-dieselmulti test-dieselmysql test-dieselpg test-dieselsqlite test-hyper test-mimalloc test-multi test-plain test-pq test-rocket test-rustls test-serde test-ssl test-xml test-zlib
