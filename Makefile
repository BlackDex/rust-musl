SHELL := /usr/bin/env bash
RUST_CHANNEL=stable

info:
	# Makefile info
	@echo
	@echo render:
	@echo \ Renders the Dockerfiles for GNU and MUSL.
	@echo
	@echo build-toolchains:
	@echo \ Builds the GCC MUSL Toolchain needed for cross-compiling. This takes a long long time.
	@echo
	@echo \# The following make targets can be used to build the representing image
	@echo build-gnu:
	@echo \ Builds the base GNU Image with the same versioned libraries as used for MUSL
	@echo
	@echo build-musl:
	@echo \ Builds all the MUSL Images using the GNU base image for all supported targets
	@echo
	@echo \# The following targets are supported:
	@echo \ build-musl-x86_64 build-musl-aarch64 build-musl-armv7 build-musl-arm build-musl-armhf build-musl-armv5te
	@echo
	@echo build:
	@echo \ Builds both GNU and MUSL
	@echo
	@echo build-all:
	@echo \ Build Toolchain, GNU and MUSL.
	@echo
	@echo \# Variables which can be used:
	@echo \ RUST_CHANNEL \# This can be either \'stable\' or \'nightly\', and for \'nightly\' you could add a specific date
	@echo 

# Render Dockerfile.gnu-base and Dockerfile.musl-base via the jinja2 Dockerfile.j2 template
render:
	./render_template Dockerfile.j2 '{"base": "gnu"}' > "Dockerfile.gnu-base"
	./render_template Dockerfile.j2 '{"base": "musl"}' > "Dockerfile.musl-base"

include Makefile.build

include Makefile.test
