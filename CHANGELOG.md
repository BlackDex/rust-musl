# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
We do not use Semantic Versioning, because our images are tagged based on Rust releases and nightly/build-dates.

For maximum stablity, use images with tags like `blackdex/rust-musl:aarch64-musl-1.96.0`, `blackdex/rust-musl:arm-musleabi-stable-1.96.0` or `blackdex/rust-musl:x86\_64-musl-nightly-2026-06-02`.<br>
These may occasionally be rebuilt, but only while they're "current", or possibly if they're recent and serious security issues are discovered in a library.

---


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
  - Update crosstools-ng to latest commit
  - Build GCC v15.3.0 toolchains
  - Updated binutils to v2.46.1
  - Kernel v5.15 LTS headers updated to the latest version
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
  - Added attest's for the toolchain images
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
  - Attest `rust-musl` container images so you can verify if the container is really build via GitHub via my repo


## 2024-11-26

### Removed
  - Removed `libpq` v11, it has been deprecated for a while now


## 2024-08-08

### Changed
  - `libpq` v16 is now the default version


## 2024-08-02

### Fixed
  - Possibility of wrong Postgres library being used.<br>
    In some situations it could be that the libpq v11 was still used. Depending if during the compilation of the code other crates added the main library path as a search path after `pq-sys` did, which caused rustc to use a different libpq.a.<br>
This has been solved now by moving the library file for v11 to a separate directory also. The default directory is changed and should not cause any issues unless you set the `PQ_LIB_DIR` variable your self to anything else then the v15 directory.


## 2024-03-15

### Changed
 - Stop adding `-openssl3` postfix to the tags


## 2023-09-29

### Removed
 - OpenSSL v1.1.1 since it's EOL


## 2023-04-23

### Removed
 - `arm-unknown-linux-musleabihf` and `armv5te-unknown-linux-musleabi`.
   They do not seem to be used at all. If someone is using them, please open an issue and let me know.
