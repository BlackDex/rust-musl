# Default use localhost:5000, useful with a local registry for example
# If you want to get the source from somewhere else use `make TOOLCHAIN_REGISTRY=ghcr.io musl-x86_64` for example
TOOLCHAIN_REGISTRY ?= localhost:5000
PLATFORM ?= local

# Define specific target variables
musl-x86_64: TAG=x86_64-musl
musl-aarch64: TAG=aarch64-musl
musl-armv7: TAG=armv7-musleabihf
musl-arm: TAG=arm-musleabi

# Pull the latest musl-base to be used as cache if possible
# Build the musl-base image using the previous image as cache
# For the musl image we use multi-stage docker images.
# So first we build the musl-base part, and after that we will build the the main image.
musl-x86_64 musl-aarch64 musl-armv7 musl-arm:
	docker buildx build \
		--progress=plain \
		--platform=${PLATFORM} \
		--build-arg TOOLCHAIN_REGISTRY=${TOOLCHAIN_REGISTRY} \
		--build-arg IMAGE_TAG=$(TAG) \
		--build-arg RUST_CHANNEL=$(RUST_CHANNEL) \
		-t localhost:5000/blackdex/rust-musl:$(TAG)$(TAG_POSTFIX) \
		-t localhost:5000/blackdex/rust-musl:$(TAG)$(TAG_POSTFIX)$(TAG_DATE) \
		--output type=image,oci-mediatypes=true,compression=zstd,compression-level=3,push=${PUSH} \
		-f Dockerfile.musl-base \
		--load \
		"."

# Target to build all cross toolchains supported
musl: musl-x86_64 musl-aarch64 musl-armv7 musl-arm
.PHONY: musl musl-x86_64 musl-aarch64 musl-armv7 musl-arm

# Build and push all musl targets
push-musl:
	$(MAKE) PUSH=true musl
.PHONY: push-musl

# Build and push a specific targets
push-musl-%:
	$(MAKE) PUSH=true "$(subst push-,,$@)"


# Define the platform for building arm64 base images
arm64-x86_64: PLATFORM=linux/arm64
arm64-x86_64: musl-x86_64
arm64-aarch64: PLATFORM=linux/arm64
arm64-aarch64: musl-aarch64
arm64-armv7: PLATFORM=linux/arm64
arm64-armv7: musl-armv7
arm64-arm: PLATFORM=linux/arm64
arm64-arm: musl-arm

arm64: arm64-x86_64 arm64-aarch64 arm64-armv7 arm64-arm
.PHONY: arm64 arm64-x86_64 arm64-aarch64 arm64-armv7 arm64-arm
