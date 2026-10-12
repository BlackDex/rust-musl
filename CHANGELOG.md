# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
We do not use Semantic Versioning, because our images are tagged based on Rust releases and nightly/build-dates.

For maximum stability, use images with tags like `blackdex/rust-musl:aarch64-musl-1.96.0`, `blackdex/rust-musl:arm-musleabi-stable-1.96.0` or `blackdex/rust-musl:x86\_64-musl-nightly-2026-06-02`.<br>
These may occasionally be rebuilt, but only while they are "current", or possibly if they're recent and serious security issues are discovered in a library.

---


## 2026-09-30
  - Updated SQLite to v3.54.0
  - Update GitHub Actions


## 2026-09-30
  - Updated OpenSSL to v3.5.9
  - Updated MariaDB to v3.4.11


## 2026-09-24/25
  * Toolchain:
    - Updated crosstool-ng to the latest commit
      * Updated binutils to v2.47
      * Updated Kernel v5.15 LTS headers to the latest version

  * Rust-Musl:
    - Updated toolchain tag
    - Adjusted `update_libs.py` to fetch Alpine versions again
    - Added `enable-ec_nistp_64_gcc_128` for `aarch64` to the OpenSSL build arg
    - Added [Fortify Headers](https://github.com/jvoisin/fortify-headers) to be used during builds
    - Allow building with `-Clink-self-contained=no` by providing the correct static library for libunwind
    - Remove lto flags, this was not really used, and doesn't really have impact on the Rust binary
    - Added `-latomic` to all libraries for `arm-unknown-linux-musleabi`
    - Make sure that MariaDB embeds the correct OpenSSL symbols. This is useful for building with the `mysqlclient-sys` crate
    - Fixed building with cmake or cmake-rs if `-static` is added
    - Added a chapter in the README regarding building `mysqlclient-sys` bundled/vendored client
      Also adjusted the `test.sh` script to detect this feature and apply the fix
    - Updated sccache to v0.18
    - Updated libxml2 to v2.15.4

  * General:
    - Updated GitHub Actions
    - Enable special fixes for Cortex-A53 chips during aarch64 toolchain build


## 2026-09-03
  - Updated cURL to v8.22.0


## 2026-08-26
  - Updated OpenSSL to v3.5.8
  - Updated GitHub Actions


## 2026-08-13
  - Updated PostgreSQL to v15.19, v16.15, v17.11 and v18.6
  - Updated sccache to v0.17.0
  - Switched zlib download to GitHub


## 2026-07-25
  - Updated SQLite to v3.53.4
  - Fixed a strange bug found via Vaultwarden using a database backend over TLS/SSL.
    In the end it was an issue with the compilation of OpenSSL.
    Apparently if the configure state of OpenSSL finds `-static` inside the `LD_FLAGS` it runs `disable('static', 'pic', 'threads')`.
    This causes `threading` to be disabled, which in the end causes several weird issue in a sporadic way, and causes tools using it have issues.<br><br>
    A disclaimer for this specific fix, I used an LLM to troubleshoot this hard to figure-out issue. To be more precise, I used Claude Opus 5 for this.
    I only used it as a sparring partner, and it never ever edited any file, and I made all the changes my self after verifying.
    This helped me finding this issue in about 3 hours, while i might very well would have spend 3 days or more to find it because of all the changed parts on both this image, and both Vaultwarden and all the different crates it uses.


## 2026-07-21
  - Remove `config.toml` and use `CARGO_TARGET_` environment variables instead
  - Also add the `NM_<triple>` to point to the correct nm binary
  - Updated GitHub Actions


## 2026-07-07
  - Update SQLite to v3.53.3


## 2026-06-26
  - Adjusted the `toolchain.cmake` file to work with this image.
    If crates used cmake to build code, it could happen that it did not found the pre-compiled libraries.
    By creating a custom file which basically does the same as all `TARGET_` environment variables this works again.
    Tested this by building `mysqlclient-sys` using the `bundled` feature.


## 2026-06-25
  - Update cURL to v8.21.0
  - Update MariaDB to v3.4.9 with 1 commit reverted
    This commit breaks Diesel migrations and some other features


## 2026-06-19
  - Update crosstool-ng to latest commit
  - Build GCC v15.3.0 toolchains
  - Updated binutils to v2.46.1
  - Updated Kernel v5.15 LTS headers to the latest version
  - Updated sccache to v0.16.0
  - Fixed some CPPFLAGS and LDFLAGS parameters, some were pointing to a wrong directory
  - Updated GitHub Workflows

## 2026-06-10

### Changed
  - Update OpenSSL to v3.5.7


## 2026-06-04

### Changed
  - Build libraries with the new toolchain
  - Updated GitHub Workflows
  - Updated all test crates to edition 2024
  - Updated/Fixed some testing crates
  - Updated SQLite to v3.53.2


## 2026-06-02

### Changed
  - Switched to Crosstool-NG to build the toolchains
  - Updated GitHub Workflows
  - Added attestations for the toolchain images
  - Created this Changelog


## 2025-11 - 2026-06

### Changed
  - Updated libraries once they were available
  - Updated GitHub Actions once they were available


## 2025-11-14

### Changed
  - Use GCC Toolchain v15.1.0


## 2025-10-12

### Added
  - Added `libpq` v18

### Changed
  - Set `libpq` v17 as default


## 2025-07-23

### Changed
  - Updated musl-cross-make and use gcc v14.3.0 and binutils v2.44


## 2025-07-02

### Changed
  - Use OpenSSL v3.5.x LTS


## 2025-02-18

### Added
  - Added `libpq` v17


## 2025-02-15

### Added
  - Build images for aarch64 (arm64) hosts. Now you can build x86_64 binaries on your Raspberry Pi.
  - Attest `rust-musl` container images so you can verify if the container is really built via GitHub via my repo


## 2024-11-26

### Removed
  - Removed `libpq` v11, it was deprecated for a while now


## 2024-08-08

### Changed
  - `libpq` v16 is now the default version


## 2024-08-02

### Fixed
  - Possibility of wrong Postgres library being used.<br>
    In some situations it could be that the libpq v11 was still used. This depended on whether, during the compilation of the code other crates added the main library path as a search path after `pq-sys` did, which caused rustc to use a different `libpq.a`.<br>
    This is now solved by moving the library file for v11 to a separate directory also. The default directory is changed and should not cause any issues unless you set the `PQ_LIB_DIR` variable yourself to anything else then the v15 directory.


## 2024-03-15

### Changed
 - Stop adding `-openssl3` postfix to the tags


## 2023-09-29

### Removed
 - OpenSSL v1.1.1 since it is EOL


## 2023-04-23

### Removed
 - `arm-unknown-linux-musleabihf` and `armv5te-unknown-linux-musleabi`.
   They do not seem to be used at all. If someone is using them, please open an issue and let me know.
