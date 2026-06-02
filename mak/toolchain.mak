# Default use localhost:5000, useful with a local registry for example
# If you want to get the source from somewhere else use `make TOOLCHAIN_REGISTRY=ghcr.io musl-x86_64` for example
TOOLCHAIN_REGISTRY ?= localhost:5000
LOCAL_REGISTRY ?= localhost:5000

HOST_ARCH_RAW := $(shell uname -m)
HOST_ARCH := $(subst aarch64,arm64,$(HOST_ARCH_RAW))
HOST_ARCH := $(subst x86_64,amd64,$(HOST_ARCH))

PLATFORM ?= linux/$(HOST_ARCH)

toolchain-base:
	docker buildx build \
		--progress=plain \
		--platform=${PLATFORM} \
		--target=source \
		--cache-from type=registry,ref=${LOCAL_REGISTRY}/blackdex/musl-toolchain-buildcache:ubuntu-base-$${PLATFORM//linux\//} \
		--cache-to type=registry,ref=${LOCAL_REGISTRY}/blackdex/musl-toolchain-buildcache:ubuntu-base-$${PLATFORM//linux\//},compression=zstd,compression-level=9,force-compression=true,mode=max \
		-f Dockerfile.crosstool \
		--load \
		"."

toolchain-base-arm64: PLATFORM=linux/arm64
toolchain-base-arm64: toolchain-base
.PHONY: toolchain-base toolchain-base-arm64

toolchain-x86_64: TAG=x86_64-musl
toolchain-x86_64: TARGET=x86_64-unknown-linux-musl

toolchain-aarch64: TAG=aarch64-musl
toolchain-aarch64: TARGET=aarch64-unknown-linux-musl

toolchain-armv7: TAG=armv7-musleabihf
toolchain-armv7: TARGET=armv7-unknown-linux-musleabihf

toolchain-arm: TAG=arm-musleabi
toolchain-arm: TARGET=arm-unknown-linux-musleabi

# Pull the latest toolchains to be used as cache if possible
# Build the toolchains image using the previous image as cache
toolchain-x86_64 toolchain-aarch64 toolchain-armv7 toolchain-arm: toolchain-base
	docker buildx build \
		--progress=plain \
		--platform=${PLATFORM} \
		--build-arg TARGET=$(TARGET) \
		-t ${LOCAL_REGISTRY}/blackdex/musl-toolchain:$(TAG) \
		-t ${LOCAL_REGISTRY}/blackdex/musl-toolchain:$(TAG)$(TAG_DATE) \
		--cache-from type=registry,ref=${LOCAL_REGISTRY}/blackdex/musl-toolchain-buildcache:ubuntu-base-$${PLATFORM//linux\//} \
		--output type=image,oci-mediatypes=true,compression=zstd,compression-level=3,force-compression=true,push=${PUSH} \
		-f Dockerfile.crosstool \
		--load \
		"."

toolchains: toolchain-x86_64 toolchain-aarch64 toolchain-armv7 toolchain-arm
.PHONY: toolchains toolchain-x86_64 toolchain-aarch64 toolchain-armv7 toolchain-arm

arm64-toolchain-x86_64: PLATFORM=linux/arm64
arm64-toolchain-x86_64: toolchain-x86_64
arm64-toolchain-aarch64: PLATFORM=linux/arm64
arm64-toolchain-aarch64: toolchain-aarch64
arm64-toolchain-armv7: PLATFORM=linux/arm64
arm64-toolchain-armv7: toolchain-armv7
arm64-toolchain-arm: PLATFORM=linux/arm64
arm64-toolchain-arm: toolchain-arm

arm64-toolchains: arm64-toolchain-x86_64 arm64-toolchain-aarch64 arm64-toolchain-armv7 arm64-toolchain-arm
.PHONY: arm64-toolchains arm64-toolchain-x86_64 arm64-toolchain-aarch64 arm64-toolchain-armv7 arm64-toolchain-arm
