<a href='https://github.com/repo-reviews/repo-reviews.github.io/blob/main/create.md' target="_blank"><img alt='Github' src='https://img.shields.io/badge/review_me-100000?style=flat&logo=Github&logoColor=white&labelColor=888888&color=555555'/></a>
[![Build](https://github.com/BlackDex/rust-musl/actions/workflows/rust-musl.yml/badge.svg)](https://github.com/BlackDex/rust-musl/actions/workflows/rust-musl.yml)
[![ghcr.io](https://img.shields.io/badge/ghcr.io-download-blue)](https://github.com/BlackDex/rust-musl/pkgs/container/rust-musl)
[![Docker Pulls](https://img.shields.io/docker/pulls/vaultwarden/server.svg)](https://hub.docker.com/r/blackdex/rust-musl)
[![Quay.io](https://img.shields.io/badge/Quay.io-download-blue)](https://quay.io/repository/blackdex/rust-musl)


# rust-musl

This project generates docker images to build static musl binaries using the Rust language.
It has several pre-build C/C++ libraries to either speedup the compile time of the Rust project or make it possible to build a project at all like Diesel with MySQL.

These container images are based upon Ubuntu 22.04 and use GCC v11.2.0 to build both the toolchains and the libraries.<br>
Depending if the Rust version and if MUSL target is 32bit or 64bit it is using MUSL v1.1.24 or v1.2.3. This because changes to `time_t`.<br>
All versions of Rust v1.71.0 and above will all be build with MUSL v1.2.3 since all targets now support this version.

The following libraries are pre-build and marked as `STATIC` already via `ENV` variables so that the Rust Crates know there are static libraries available already.
* OpenSSL v3.0 (`v3.0.12`)
* cURL (`v8.4.0`)
* ZLib (`v1.3`)
* PostgreSQL lib (`v11.22`) and PostgreSQL lib (`v15.5`)
* SQLite (`v3.44.0`)
* MariaDB Connector/C (`v3.3.5`) (MySQL Compatible)


## Available architectures
Both stable and nightly builds are available.
The latest nightly's are always postfixed with `-nightly`, if you want to use a specific date check if the images exists then you can use the `-nightly-YYYY-MM-DD` tag.
Nightly's are build every morning around 9:30 UTC.

For stable you can just use the tags listed below, or add `-stable` to it.
If you want to be sure that you are using a specific stable version you can use `-X.Y.Z` or `-stable-X.Y.Z`.
Stables builds are automatically triggered if there is a new version available.


### OpenSSL v3.0
Since 2023-09-29 i stopped building OpenSSL v1.1.1 since it's EOL.<br>
Now only OpenSSL v3.0 is being build, the tags will be kept for a while.


### PostgreSQL v15
The default PostgreSQL lib used is v11, this might change in the future.<br>
If you want to use v15 you need to overwrite an environment variable so that the postgresql crate will look at the right directory.<br>
<br>
Adding `-e PQ_LIB_DIR="/usr/local/musl/pq15/lib"` at the cli or `ENV PQ_LIB_DIR="/usr/local/musl/pq15/lib"` to your custom build image will trigger the v15 version to be used during the build.


## Usage

As of 2023-04-23 I stopped building `arm-unknown-linux-musleabihf` and `armv5te-unknown-linux-musleabi`.<br>
They do not seem to be used at all. If someone is using them, please open an issue and let me know.<br>

|        Cross Target            |    Docker Tag    |
| ------------------------------ | ---------------- |
| x86\_64-unknown-linux-musl     | x86\_64-musl     |
| armv7-unknown-linux-musleabihf | armv7-musleabihf |
| aarch64-unknown-linux-musl     | aarch64-musl     |
| arm-unknown-linux-musleabi     | arm-musleabi     |

To make use of these images you can either use them as your main `FROM` in your `Dockerfile` or use something like this:


### Container registries

The images are pushed to multiple container registries.

|                       Container Registry                       |
|----------------------------------------------------------------|
| https://hub.docker.com/r/blackdex/rust-musl                    |
| https://quay.io/repository/blackdex/rust-musl                  |
| https://github.com/BlackDex/rust-musl/pkgs/container/rust-musl |


### Using a Dockerfile

```dockerfile
FROM docker.io/blackdex/rust-musl:aarch64-musl as build

COPY . /home/rust/src

# If you want to use PostgreSQL v15 add and uncomment the following ENV
# ENV PQ_LIB_DIR="/usr/local/musl/pq15/lib"

RUN cargo build --release

FROM scratch

WORKDIR /
COPY --from=build /home/rust/src/target/aarch64-unknown-linux-musl/release/my-application-name .

CMD ["/my-application-name"]
```


### Using the CLI

If you want to use PostgreSQL `v15` client library add `-e PQ_LIB_DIR="/usr/local/musl/pq15/lib"` before the `-v "$(pwd)"` argument.

```bash
# First pull the image:
docker pull docker.io/blackdex/rust-musl:aarch64-musl

# Then you could either create an alias
alias rust-musl-builder='docker run --rm -it -v "$(pwd)":/home/rust/src docker.io/blackdex/rust-musl:aarch64-musl'
rust-musl-builder cargo build --release

# Or use it directly
docker run --rm -it -v "$(pwd)":/home/rust/src docker.io/blackdex/rust-musl:aarch64-musl cargo build --release
```

<br>


## Testing

During the automatic build workflow the images are first tested on a Rust projects which test all build C/C++ Libraries using Diesel for the database libraries, and openssl, zlib and curl for the other pre-build libraries.

If the test fails, the image will not be pushed to docker hub.

<br>


## Linking issues (atomic)

Because of some strange bugs/quirks it sometimes happens that on some platforms it reports missing `__atomic*` libraries. The strange thing is, these are available, but for some reason ignored by the linker or rustc (If someone knows a good solution here, please share).<br>
<br>
Because of this some platforms may need a(n) (extra) `RUSTFLAGS` which provides the correct location of the c archive `.a` file.<br>
<br>
This for example happens when using the `mimalloc` crate.

| Cross Target                   |  RUSTFLAG             |
| ------------------------------ | --------------------- |
| arm-unknown-linux-musleabi     | `-Clink-arg=-latomic` |

<br>


## History

I started this project to make it possible for [Vaultwarden](https://github.com/dani-garcia/vaultwarden) to be build statically with all database's supported. SQLite is not really an issue, since that has a bundled option. But PostgreSQL and MariaDB/MySQL do not have a bundled/vendored feature available.

I also wanted to get a better understanding of the whole musl toolchain and Github Actions, which i did.


## Credits

Some projects i got my inspiration from:
* https://github.com/messense/rust-musl-cross
* https://github.com/clux/muslrust
* https://github.com/emk/rust-musl-builder

Projects used to get this working:
* https://github.com/richfelker/musl-cross-make
* https://github.com/rust-embedded/cross


## Docker Hub:

All images can be found here:
* https://hub.docker.com/r/blackdex/rust-musl/
