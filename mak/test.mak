RUST_CHANNEL := "stable"
ARCH=x86_64-musl
VERBOSE=
RELEASE=
FEATURES=

test-plain:
	./test.sh plain
test-curl:
	./test.sh curl
test-serde:
	./test.sh serde
test-rocket:
	./test.sh rocket
test-mimalloc:
	./test.sh mimalloc
test-pq:
	./test.sh pq
test-multi:
	./test.sh multi
test-dieselmulti:
	./test.sh dieselmulti
test-dieselpg:
	./test.sh dieselpg
test-dieselsqlite:
	./test.sh dieselsqlite
test-dieselmysql:
	./test.sh dieselmysql
test-ssl:
	./test.sh ssl
test-zlib:
	./test.sh zlib
test-hyper:
	./test.sh hyper
test-rustls:
	./test.sh rustls

clean-lock:
	sudo find . -iname Cargo.lock -exec rm {} \;
clean-builds:
	sudo find . -mindepth 3 -maxdepth 3 -name target -exec rm -rf {} \;
	sudo rm -vf test/*/main.db
	sudo rm -vf test/*/qemu_*.core

clean: clean-lock clean-builds

test: test-multi test-plain test-ssl test-pq test-serde test-curl test-zlib test-hyper test-rustls test-dieselmulti test-dieselpg test-dieselsqlite test-dieselmysql

.PHONY: test clean clean-lock clean-builds test-multi test-rocket test-mimalloc test-plain test-ssl test-pq test-serde test-curl test-zlib test-hyper test-rustls test-dieselmulti test-dieselpg test-dieselsqlite test-dieselmysql
