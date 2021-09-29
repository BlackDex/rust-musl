TAG_POSTFIX=
TAG_DATE=-$(shell date +"%Y-%m-%d")

# Check if there is a specific rust nightly date given and adjust the variables accordingly
ifeq ($(findstring nightly-20,$(RUST_CHANNEL)),nightly-20)
	TAG_POSTFIX=-$(RUST_CHANNEL)
	TAG_DATE=
else ifeq ($(RUST_CHANNEL),nightly)
	TAG_POSTFIX=-nightly
	RUST_CHANNEL=nightly$(TAG_DATE)
endif

# Toolchain Makefile
include mak/toolchain.mak

# GNU Base Image Makefile
include mak/gnu.mak

# MUSL Images Makefile
include mak/musl.mak

build: build-gnu build-musl
build-push: build-push-gnu build-push-musl
.PHONY: build build-push

build-all: build-toolchains build-gnu build-musl
build-push-all: build-push-toolchains build-push-gnu build-push-musl
.PHONY: build-all build-push-all
