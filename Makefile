SHELL := bash
.SHELLFLAGS := -eo pipefail -c

# Load .env variables if the file exists
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

# We need buildx support for our Dockerfile's
export DOCKER_BUILDKIT=1

RUST_CHANNEL=stable

info:
	# Makefile info
	@echo
	@echo build-toolchains:
	@echo \ Builds all the GCC MUSL Toolchain needed for cross-compiling. This takes a long long time.
	@echo
	@echo \# The following toolchain targets are supported:
	@echo \ build-toolchain-x86_64 build-toolchain-aarch64 build-toolchain-armv7 build-toolchain-arm build-toolchain-armhf build-toolchain-armv5te
	@echo
	@echo build-musl:
	@echo \ Builds all the MUSL images for all supported targets
	@echo
	@echo \# The following musl targets are supported:
	@echo \ build-musl-x86_64 build-musl-aarch64 build-musl-armv7 build-musl-arm build-musl-armhf build-musl-armv5te
	@echo
	@echo build:
	@echo \ Builds MUSL images
	@echo
	@echo build-all:
	@echo \ Build Toolchains and MUSL.
	@echo
	@echo \# Variables which can be used:
	@echo \ RUST_CHANNEL \# This can be either \'stable\' or \'nightly\', and for \'nightly\' you could add a specific date
	@echo
.PHONY: info

# Include main building make definitions
include mak/build.mak

# Include testing make definitions
include mak/test.mak
