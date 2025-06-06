TAG_POSTFIX=-stable
TAG_DATE=-$(shell date +"%Y-%m-%d")
PUSH ?= false

# Check if there is a specific rust nightly date given and adjust the variables accordingly
ifeq ($(findstring nightly-20,$(RUST_CHANNEL)),nightly-20)
	TAG_POSTFIX=-$(RUST_CHANNEL)
	TAG_DATE=
else ifeq ($(RUST_CHANNEL),nightly)
	TAG_POSTFIX=-nightly
	RUST_CHANNEL=nightly$(TAG_DATE)
endif

## This script can be used to see which files are transferred during a `COPY . /`
check-context:
	echo -e "FROM busybox\nCOPY . /build-context\nWORKDIR /build-context\nRUN find .\n" \
	| docker build --progress=plain --no-cache -f - .
.PHONY: check-context

# Toolchain Makefile
include mak/toolchain.mak

# MUSL Images Makefile
include mak/musl.mak

build: musl
build-push: push-musl
.PHONY: build build-push

build-all: toolchains musl
build-push-all: push-toolchains push-musl
.PHONY: build-all build-push-all
