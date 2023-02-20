# rust-musl

This project generates docker images to build static musl binaries using the Rust language.
It has several pre-build C/C++ libraries to either speedup the compile time of the Rust project or make it possible to build a project at all like Diesel with MySQL.

These container images are based upon Ubuntu 22.04 and use GCC v11.2.0 to build both the toolchains and the libraries.<br>
Depending if the MUSL target is 32bit or 64bit it is using MUSL v1.1.24 or v1.2.3. This because changes to `time_t`.

The following libraries are pre-build and marked as `STATIC` already via `ENV` variables so that the Rust Crates know there are static libraries available already.
* ZLib (`v1.2.13`)
* OpenSSL v1.1 (`v1.1.1t`) and OpenSSL v3.0 (`v3.0.8`)
* cURL (`v7.88.1`)
* PostgreSQL lib (`v11.19`)
* SQLite (`v3.40.1`)
* MariaDB Connector/C (`v3.3.4`) (MySQL Compatible)

Since 2023-01-14 there is also support for PostreSQL lib `v15`.<br>
Previous images were providing `v14` as an extra lib.<br>
See below on how to use this version instead of the current default `v11`.
* PostgreSQL lib (`v15.2`)


## Available architectures
Both stable and nightly builds are available.
The latest nightly's are always postfixed with `-nightly`, if you want to use a specific date check if the images exists then you can use the `-nightly-YYYY-MM-DD` tag.
Nightly's are build every morning around 9:30 UTC.

For stable you can just use the tags listed below, or add `-stable` to it.
If you want to be sure that you are using a specific stable version you can use `-X.Y.Z` or `-stable-X.Y.Z`.
Stables builds are automatically triggered if there is a new version available.

### OpenSSL v3.0
If you want to use the OpenSSL v3.0 versions, you need to add `-openssl3` as the last postfix for the tag.
The images without an extra postfix are using the default v1.1 version.


## Usage
|        Cross Target            |    Docker Tag    |
| ------------------------------ | ---------------- |
| x86\_64-unknown-linux-musl     | x86\_64-musl     |
| armv7-unknown-linux-musleabihf | armv7-musleabihf |
| aarch64-unknown-linux-musl     | aarch64-musl     |
| arm-unknown-linux-musleabi     | arm-musleabi     |
| arm-unknown-linux-musleabihf   | arm-musleabihf   |
| armv5te-unknown-linux-musleabi | armv5te-musleabi |

To make use of these images you can either use them as your main `FROM` in your `Dockerfile` or use something like this:


### Using a Dockerfile

```dockerfile
FROM blackdex/rust-musl:aarch64-musl as build

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
docker pull blackdex/rust-musl:aarch64-musl

# Then you could either create an alias
alias rust-musl-builder='docker run --rm -it -v "$(pwd)":/home/rust/src blackdex/rust-musl:aarch64-musl'
rust-musl-builder cargo build --release

# Or use it directly
docker run --rm -it -v "$(pwd)":/home/rust/src blackdex/rust-musl:aarch64-musl cargo build --release
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
| arm-unknown-linux-musleabihf   | `-Clink-arg=-latomic` |
| armv5te-unknown-linux-musleabi | `-Clink-arg=-latomic` |

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
