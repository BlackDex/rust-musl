[![GHA Build](https://img.shields.io/github/actions/workflow/status/BlackDex/rust-musl/rust-musl.yml?style=for-the-badge&logo=github&logoColor=fff&label=Build%20Workflow)](https://github.com/BlackDex/rust-musl/actions/workflows/rust-musl.yml)
[![ghcr.io](https://img.shields.io/badge/ghcr.io-download-005AA4?style=for-the-badge&logo=github&logoColor=fff&cacheSeconds=14400)](https://github.com/BlackDex/rust-musl/pkgs/container/rust-musl)
[![Docker Pulls](https://img.shields.io/docker/pulls/blackdex/rust-musl.svg?style=for-the-badge&logo=docker&logoColor=fff&color=005AA4&label=docker.io%20pulls)](https://hub.docker.com/r/blackdex/rust-musl)
[![Quay.io](https://img.shields.io/badge/quay.io-download-005AA4?style=for-the-badge&logo=redhat&cacheSeconds=14400)](https://quay.io/repository/blackdex/rust-musl) <br>

# rust-musl

This project generates Docker images to build static musl binaries using the Rust language.
It has several pre-build C/C++ libraries to either speedup the compile time of the Rust project or make it possible to build a project at all like Diesel with MySQL.

These container images are based upon Ubuntu 26.04 and use GCC v15.2.0 to build the toolchains and GCC v15.3.0 for the libraries.<br>
Since 2026-06 all images are built using musl v1.2.6 using https://github.com/crosstool-ng/crosstool-ng.<br>
And since 2025-02-15 all images are available for amd64 and arm64 host platforms.

The following libraries are pre-built and marked as `STATIC` already via `ENV` variables so that the Rust Crates know there are static libraries available already.
* ZLib (`v1.3.2`)
* OpenSSL (`v3.5.8`)
* cURL (`v8.23.0`)
* sccache (`0.18.0`)
* PostgreSQL lib (`v17.11`) + (`v18.6`), (`v16.15`) and (`v15.19`)
* SQLite (`v3.54.1`)
* MariaDB Connector/C (`v3.4.8`) (MySQL Compatible)
* libxml2 (`v2.15.4`)


## Changelog

To see the changes, check out the [Changelog](./CHANGELOG.md)


## Available architectures

Both stable and nightly builds are available.
The latest nightly's are always suffixed with `-nightly`, if you want to use a specific date, check whether the image exists then use the `-nightly-YYYY-MM-DD` tag.
Nightly's are built every morning around 9:30 UTC (If GitHub Allows it).

For stable you can just use the tags listed below, or add `-stable` to it.
If you want to be sure that you are using a specific stable version you can use `-X.Y.Z` or `-stable-X.Y.Z`.
Stables builds are triggered automatically when a new version is available.

> [!TIP]
> **2025-02-15:**
> Created aarch64 (arm64) images as base containers!<br>
> From this day on you can also build on aarch64 (arm64) architectures like on a Raspberry Pi 4 or 5.<br>
> Or even use the GitHub arm64 runners (which are also used to build the containers for this repo).<br>
> This means that you can build x86_64 (amd64) binaries on an aarch64 (arm64) host.<br>
> The OCI images are multi-platform containers and all should work the same for both platforms.


### PostgreSQL v18 & v17 & v16 & v15

The default PostgreSQL lib used is `v17`.<br>
If you want to use `v18` or `v15` you need to overwrite an environment variable so that the `pq-sys` crate will look at the right directory.<br>
<br>
Adding `-e PQ_LIB_DIR="/usr/local/musl/pq18/lib"` at the cli or `ENV PQ_LIB_DIR="/usr/local/musl/pq18/lib"` to your custom build image will trigger the v18 version to be used during the build.

<br>

## Usage

|        Cross Target            |  Container Tag   |
| ------------------------------ | ---------------- |
| x86\_64-unknown-linux-musl     | x86\_64-musl     |
| armv7-unknown-linux-musleabihf | armv7-musleabihf |
| aarch64-unknown-linux-musl     | aarch64-musl     |
| arm-unknown-linux-musleabi     | arm-musleabi     |

To make use of these images you can either use them as your main `FROM` in your `Dockerfile`.

<br>

### Container registries

The images are pushed to multiple container registries.

|                       Container Registry                       |
|----------------------------------------------------------------|
| https://github.com/BlackDex/rust-musl/pkgs/container/rust-musl |
| https://hub.docker.com/r/blackdex/rust-musl                    |
| https://quay.io/repository/blackdex/rust-musl                  |

<br>

### Using a Dockerfile

```dockerfile
FROM ghcr.io/blackdex/rust-musl:aarch64-musl AS build

COPY . /home/rust/src

# If you want to use PostgreSQL v18 add and uncomment the following ENV
# ENV PQ_LIB_DIR="/usr/local/musl/pq18/lib"

RUN cargo build --release

FROM scratch

WORKDIR /
COPY --from=build /home/rust/src/target/aarch64-unknown-linux-musl/release/my-application-name .

CMD ["/my-application-name"]
```

<br>

### Using the CLI

If you want to use the PostgreSQL `v18` client library add `-e PQ_LIB_DIR="/usr/local/musl/pq18/lib"` before the `-v "$(pwd)"` argument.

```bash
# First pull the image:
docker pull ghcr.io/blackdex/rust-musl:aarch64-musl

# Then you could either create an alias
alias rust-musl-builder='docker run --rm -it -v "$(pwd)":/home/rust/src ghcr.io/blackdex/rust-musl:aarch64-musl'
rust-musl-builder cargo build --release

# Or use it directly
docker run --rm -it -v "$(pwd)":/home/rust/src ghcr.io/blackdex/rust-musl:aarch64-musl cargo build --release
```

<br>

### Using as GitHub Actions container

You can also use these images as a GitHub Actions container.<br>
A simple workflow to build aarch64 binaries looks like this.

```yaml
name: "Build container"

on:
  push:
    branches:
     - main

jobs:
  build_container:
    runs-on: ubuntu-latest
    container: ghcr.io/blackdex/rust-musl:aarch64-musl-stable
    steps:
      - uses: actions/checkout@v4
      - name: Build
        run: |
          cargo build --release
```

<br>

## Tips

### Verify container images

You can verify all my images using the `gh` client.

For example, to verify the aarch64 v1.96.0 image.
```bash
gh attestation verify --owner BlackDex oci://ghcr.io/blackdex/rust-musl:aarch64-musl-stable-1.96.0
```

### Using a different allocator

Sometimes musl based binaries are slower than glibc based binaries.<br>
This is mostly because of the memory allocator (malloc) which is not that fast.<br>
One way to improve the performance is to use a different allocator within your Rust project.<br>
For example, Vaultwarden uses [MiMalloc](https://github.com/microsoft/mimalloc) via [mimalloc_rust](https://github.com/purpleprotocol/mimalloc_rust).<br>
Other memory allocators exists too, just see which one fits your application the best.<br>
The tests that run after building also test the MiMalloc crate.

### Building bundled (vendored) MySQL from mysqlclient-sys crate

If you want to build the bundled/vendored Oracle MySQL Client Library provided by the [mysqlclient-sys](https://github.com/sgrif/mysqlclient-sys) crate, you need to add a special file to the container so that the cmake build script thinks the host runs Alpine. This enables special handling that is done for musl based compilers. It is as simple as just run `touch /etc/alpine-release` before you run any `cargo build` action.
<br>
In the `test.sh` script this is done automatically when the `vendored_mysql` feature is used for testing.
<br>
Note that Oracle MySQL can only be built on 64bit architectures, and thus will only work on amd64/x86_64 or arm64/aarch64 builds.

## Testing

During the automatic build workflow the images are first tested with Rust projects that test all built C/C++ Libraries using Diesel for the database libraries, and openssl, zlib and curl for the other pre-built libraries.

If the test fails, the image will not be pushed to Docker Hub.

<br>

## Linking issues (atomic)

Because of some strange bugs/quirks it sometimes happens that on some platforms the linker reports missing `__atomic*` symbols. The strange thing is, these are available, but for some reason ignored by the linker or rustc (if someone knows a good solution here, please share).<br>
<br>
Because of this some platforms need an extra `RUSTFLAGS` which provides the correct location of the c archive `.a` file.<br>

| Cross Target                   |  RUSTFLAG             |
| ------------------------------ | --------------------- |
| arm-unknown-linux-musleabi     | `-Clink-arg=-latomic` |

<br>

## History

I started this project to make it possible for [Vaultwarden](https://github.com/dani-garcia/vaultwarden) to be built statically with all supported databases. SQLite is not really an issue, since that has a bundled option. But PostgreSQL and MariaDB/MySQL do not have a bundled/vendored feature available or not for all architectures.

I also wanted to get a better understanding of the whole musl toolchain and Github Actions, which I did.

## Credits

Some projects I got my inspiration from:
* https://github.com/messense/rust-musl-cross
* https://github.com/clux/muslrust
* https://github.com/emk/rust-musl-builder

Projects used to get this working:
* https://github.com/crosstool-ng/crosstool-ng
* https://github.com/cross-rs/cross

Other links for projects used in the past:
* https://github.com/richfelker/musl-cross-make
