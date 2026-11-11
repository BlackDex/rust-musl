# Allow the following ENV's to be added after `just`
RUSTFLAGS := env("RUSTFLAGS", "UNDEF")
PQ_LIB := env("PQ_LIB", "UNDEF")
VERBOSE := env("VERBOSE", "UNDEF")
RELEASE := env("RELEASE", "UNDEF")
FEATURES := env("FEATURES", "UNDEF")
ARCH := env("ARCH", "amd64")

_test $crate:
    # Conditionally add test.sh environment variables
    {{ if ARCH == "UNDEF" { "" } else { "ARCH=" + quote(ARCH) } }} \
    {{ if RUSTFLAGS == "UNDEF" { "" } else { "RUSTFLAGS=" + quote(RUSTFLAGS) } }} \
    {{ if PQ_LIB == "UNDEF" { "" } else { "PQ_LIB=" + quote(PQ_LIB) } }} \
    {{ if VERBOSE == "UNDEF" { "" } else { "VERBOSE=" + quote(VERBOSE) } }} \
    {{ if RELEASE == "UNDEF" { "" } else { "RELEASE=" + quote(RELEASE) } }} \
    {{ if FEATURES == "UNDEF" { "" } else { "FEATURES=" + quote(FEATURES) } }} \
    ./test.sh "$crate"

[group('test')]
test-curl: (_test 'curl')
[group('test')]
test-dieselmulti: (_test 'dieselmulti')
[group('test')]
test-dieselmysql: (_test 'dieselmysql')
[group('test')]
test-dieselpg: (_test 'dieselpg')
[group('test')]
test-dieselsqlite: (_test 'dieselsqlite')
[group('test')]
test-hyper: (_test 'hyper')
[group('test')]
test-mimalloc: (_test 'mimalloc')
[group('test')]
test-multi: (_test 'multi')
[group('test')]
test-plain: (_test 'plain')
[group('test')]
test-pq: (_test 'pq')
[group('test')]
test-rocket: (_test 'rocket')
[group('test')]
test-rustls: (_test 'rustls')
[group('test')]
test-serde: (_test 'serde')
[group('test')]
test-ssl: (_test 'ssl')
[group('test')]
test-xml: (_test 'xml')
[group('test')]
test-zlib: (_test 'zlib')

[group('test')]
test: test-multi test-curl test-dieselmysql test-dieselpg test-dieselsqlite test-hyper test-mimalloc test-plain test-pq test-rustls test-serde test-ssl test-xml test-zlib

[group('clean')]
[arg('clean_cache', long='cache', short='c', value='true')]
[script]
clean $clean_cache='false':
    mkdir -p "${PWD}/.cache"
    docker run --rm \
        --network=none \
        --user="$(id -u):$(id -g)" \
        --read-only \
        --cap-drop=ALL \
        --security-opt=no-new-privileges:true \
        -e CLEAN_CACHE="${clean_cache}" \
        -v="${PWD}/.cache:/.cache:rw" \
        -v="${PWD}/test:/test:rw" \
        busybox:musl \
        sh -euc '
            if [ "${CLEAN_CACHE}" = "true" ]; then
                printf "Cleaning Cache\n"
                rm -rf /.cache/registry
            fi
            printf "Cleaning Tests\n"
            find /test -iname Cargo.lock -print -exec rm -f {} +;
            find /test -mindepth 2 -maxdepth 2 -type d -name target -print -exec rm -rf {} +;
            rm -vf /test/*/main.db
            rm -vf /test/*/qemu_*.core
        '
