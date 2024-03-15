# Default use localhost:5000, useful with a local registry for example
# If you want to get the source from somewhere else use `make TOOLCHAIN_REGISTRY=ghcr.io musl-x86_64` for example
TOOLCHAIN_REGISTRY ?= localhost:5000

# Define specific target variables
musl-x86_64: TARGET=x86_64-unknown-linux-musl
musl-x86_64: OPENSSL_ARCH="linux-x86_64 enable-ec_nistp_64_gcc_128"
musl-x86_64: TAG=x86_64-musl

musl-aarch64: TARGET=aarch64-unknown-linux-musl
musl-aarch64: OPENSSL_ARCH=linux-aarch64
musl-aarch64: ARCH_CPPFLAGS="-mno-outline-atomics"
musl-aarch64: TAG=aarch64-musl

musl-armv7: TARGET=armv7-unknown-linux-musleabihf
musl-armv7: OPENSSL_ARCH=linux-armv4
musl-armv7: TAG=armv7-musleabihf

musl-arm: TARGET=arm-unknown-linux-musleabi
musl-arm: OPENSSL_ARCH=linux-armv4
musl-arm: TAG=arm-musleabi

# Pull the latest musl-base to be used as cache if possible
# Build the musl-base image using the previous image as cache
# For the musl image we use multi-stage docker images.
# So first we build the musl-base part, and after that we will build the the main image.
musl-x86_64 musl-aarch64 musl-armv7 musl-arm:
	docker build \
		--progress=plain \
		--build-arg TOOLCHAIN_REGISTRY=${TOOLCHAIN_REGISTRY} \
		--build-arg TARGET=$(TARGET) \
		--build-arg IMAGE_TAG=$(TAG) \
		--build-arg OPENSSL_ARCH=$(OPENSSL_ARCH) \
		--build-arg ARCH_CPPFLAGS=${ARCH_CPPFLAGS} \
		--build-arg RUST_CHANNEL=$(RUST_CHANNEL) \
		-t localhost:5000/blackdex/rust-musl:$(TAG)$(TAG_POSTFIX) \
		-t localhost:5000/blackdex/rust-musl:$(TAG)$(TAG_POSTFIX)$(TAG_DATE) \
		-f Dockerfile.musl-base \
		--load \
		"."
	if [ -n "$$PUSH" ] && [ "$$PUSH" = "true" ]; then \
		docker push localhost:5000/blackdex/rust-musl:$(TAG)$(TAG_POSTFIX) ; \
		docker push localhost:5000/blackdex/rust-musl:$(TAG)$(TAG_POSTFIX)$(TAG_DATE) ; \
	fi

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
