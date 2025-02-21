[![GHA Build](https://img.shields.io/github/actions/workflow/status/BlackDex/rust-musl/rust-musl.yml?style=for-the-badge&logo=github&logoColor=fff&label=Build%20Workflow)](https://github.com/BlackDex/rust-musl/actions/workflows/rust-musl.yml)
[![ghcr.io](https://img.shields.io/badge/ghcr.io-download-005AA4?style=for-the-badge&logo=github&logoColor=fff&cacheSeconds=14400)](https://quay.io/repository/blackdex/rust-musl)
[![Docker Pulls](https://img.shields.io/docker/pulls/blackdex/rust-musl.svg?style=for-the-badge&logo=docker&logoColor=fff&color=005AA4&label=docker.io%20pulls)](https://hub.docker.com/r/blackdex/rust-musl)
[![Quay.io](https://img.shields.io/badge/quay.io-download-005AA4?style=for-the-badge&logo=redhat&cacheSeconds=14400)](https://quay.io/repository/blackdex/rust-musl) <br>

# rust-musl

This project generates docker images to build static musl binaries using the Rust language.
It has several pre-build C/C++ libraries to either speedup the compile time of the Rust project or make it possible to build a project at all like Diesel with MySQL.

These container images are based upon Ubuntu 22.04 and use GCC v11.2.0 to build both the toolchains and the libraries.<br>
Since 2024-03-15 all images are build using musl v1.2.5 using https://github.com/richfelker/musl-cross-make.<br>
And since 2025-02-15 all images are available for amd64 and arm64 platforms.

The following libraries are pre-build and marked as `STATIC` already via `ENV` variables so that the Rust Crates know there are static libraries available already.
* OpenSSL (`v3.0.16`)
* cURL (`v8.12.1`)
* ZLib (`v1.3.1`)
* PostgreSQL lib (`v16.8`) + (`v17.4`) and (`v15.12`)
* SQLite (`v3.49.1`)
* MariaDB Connector/C (`v3.3.11`) (MySQL Compatible)
* libxml2 (`v2.13.6`)

## Available architectures

Both stable and nightly builds are available.
The latest nightly's are always postfixed with `-nightly`, if you want to use a specific date check if the images exists then you can use the `-nightly-YYYY-MM-DD` tag.
Nightly's are build every morning around 9:30 UTC.

For stable you can just use the tags listed below, or add `-stable` to it.
If you want to be sure that you are using a specific stable version you can use `-X.Y.Z` or `-stable-X.Y.Z`.
Stables builds are automatically triggered if there is a new version available.

> [!TIP]
> **2025-02-15:**
> Created aarch64 (arm64) images as base container!<br>
> From this day on you can also build on aarch64 (arm64) architectures like on a Raspberry Pi 4 or 5.<br>
> Or even use the GitHub arm64 runners (Which are used to build the containers for this repo too).<br>
> This means that you can build x86_64 (amd64) binaries on an aarch64 (arm64) host.<br>
> The OCI images are multi-platform containers and all should work the same for both platforms.

### OpenSSL v3.0

> [!NOTE]
> **2024-03-15:**
> I stopped adding the `-openssl3` postfix to the tags.

> [!NOTE]
> **2023-09-29:**
> I stopped building OpenSSL v1.1.1 since it's EOL.<br>
> Now only OpenSSL v3.0 is being build.

### PostgreSQL v16 & v17 & v15

The default PostgreSQL lib used is v16.<br>
If you want to use v17 or v15 you need to overwrite an environment variable so that the postgresql crate will look at the right directory.<br>
<br>
Adding `-e PQ_LIB_DIR="/usr/local/musl/pq17/lib"` at the cli or `ENV PQ_LIB_DIR="/usr/local/musl/pq17/lib"` to your custom build image will trigger the v17 version to be used during the build.

> [!NOTE]
> **2025-02-18:**
> Building libpq v17 besides v15 and v16

> [!NOTE]
> **2024-11-26:**
> Stopped building libpq v11, it has been deprecated for a while now.

> [!NOTE]
> **2024-08-08:**
> libpq v16 is now the default version. v15 and v11 are still build and available.

> [!NOTE]
> **2024-08-02:**
> In some situations it could be that the libpq v11 was still used. Depending if during the compilation of the code other crates added the main library path as a search path after `pq-sys` did, which caused rustc to use a different libpq.a.<br>
> This has been solved now by moving the library file for v11 to a separate directory also. The default directory is changed and should not cause any issues unless you set the `PQ_LIB_DIR` variable your self to anything else then the v15 directory.

<br>

## Usage

> [!WARNING]
> **2023-04-23:**
> Stopped building `arm-unknown-linux-musleabihf` and `armv5te-unknown-linux-musleabi`.<br>
> They do not seem to be used at all. If someone is using them, please open an issue and let me know.

<br>

|        Cross Target            |    Docker Tag    |
| ------------------------------ | ---------------- |
| x86\_64-unknown-linux-musl     | x86\_64-musl     |
| armv7-unknown-linux-musleabihf | armv7-musleabihf |
| aarch64-unknown-linux-musl     | aarch64-musl     |
| arm-unknown-linux-musleabi     | arm-musleabi     |

To make use of these images you can either use them as your main `FROM` in your `Dockerfile` or use something like this:

<br>

### Container registries

The images are pushed to multiple container registries.

|                       Container Registry                       |
|----------------------------------------------------------------|
| https://hub.docker.com/r/blackdex/rust-musl                    |
| https://quay.io/repository/blackdex/rust-musl                  |
| https://github.com/BlackDex/rust-musl/pkgs/container/rust-musl |

<br>

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

<br>

### Using the CLI

If you want to use PostgreSQL `v17` client library add `-e PQ_LIB_DIR="/usr/local/musl/pq17/lib"` before the `-v "$(pwd)"` argument.

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

### Using as GitHub Actions container

You can also use these images as a GitHub Actions container.<br>
A very simple way looks like this to build aarch64 binaries.

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

Since 2025-02-15 you can verify all my images using the `gh` client.<br>

For example, to verify the aarch64 v1.84.1 image.
```bash
gh attestation verify --owner BlackDex oci://ghcr.io/blackdex/rust-musl:aarch64-musl-stable-1.84.1
```

### Using a different allocator

Sometimes musl based binaries are slower than glibc based binaries.<br>
This is mostly because of the Memory Allocator (malloc) which just isn't that fast.<br>
One way to improve the performance is to use a different allocator within your Rust project.<br>
For example, Vaultwarden uses [MiMalloc](https://github.com/microsoft/mimalloc) via [mimalloc_rust](https://github.com/purpleprotocol/mimalloc_rust).<br>
Other Memory Allocators exists too, just see which one fits your application the best.<br>
The tests done after building are testing the MiMalloc crate.

## Testing

During the automatic build workflow the images are first tested on a Rust projects which test all build C/C++ Libraries using Diesel for the database libraries, and openssl, zlib and curl for the other pre-build libraries.

If the test fails, the image will not be pushed to docker hub.

<br>

## Linking issues (atomic)

Because of some strange bugs/quirks it sometimes happens that on some platforms it reports missing `__atomic*` libraries. The strange thing is, these are available, but for some reason ignored by the linker or rustc (If someone knows a good solution here, please share).<br>
<br>
Because of this some platforms may need a(n) (extra) `RUSTFLAGS` which provides the correct location of the c archive `.a` file.<br>

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
