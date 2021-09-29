RUST_CHANNEL="stable"
ARCH=x86_64-musl
VERBOSE=

test-plain:
	./test.sh plain
test-curl:
	./test.sh curl
test-serde:
	./test.sh serde
test-rocket:
	if [ -z "$$RUST_CHANNEL" ] || [ "$$RUST_CHANNEL" = "nightly" ]; then \
		./test.sh rocket; \
	fi
test-pq:
	./test.sh pq
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

clean-lock:
	sudo find . -iname Cargo.lock -exec rm {} \;
clean-builds:
	sudo find . -iname Cargo.lock -exec rm {} \;
	sudo find . -mindepth 3 -maxdepth 3 -name target -exec rm -rf {} \;
	sudo rm -f test/dieselsqlitecrate/main.db

clean: clean-lock clean-builds

test: test-plain test-ssl test-pq test-serde test-curl test-zlib test-hyper test-dieselmulti test-dieselpg test-dieselsqlite test-dieselmysql

.PHONY: test clean clean-lock clean-builds test-plain test-ssl test-pq test-serde test-curl test-zlib test-hyper test-dieselmulti test-dieselpg test-dieselsqlite test-dieselmysql
