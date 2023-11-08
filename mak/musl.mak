# Define specific target variables
build-musl-x86_64: TARGET=x86_64-unknown-linux-musl
build-musl-x86_64: OPENSSL_ARCH="linux-x86_64 enable-ec_nistp_64_gcc_128"
build-musl-x86_64: TAG=x86_64-musl

build-musl-aarch64: TARGET=aarch64-unknown-linux-musl
build-musl-aarch64: OPENSSL_ARCH=linux-aarch64
build-musl-aarch64: TAG=aarch64-musl

build-musl-armv7: TARGET=armv7-unknown-linux-musleabihf
build-musl-armv7: OPENSSL_ARCH=linux-armv4
build-musl-armv7: TAG=armv7-musleabihf

build-musl-arm: TARGET=arm-unknown-linux-musleabi
build-musl-arm: OPENSSL_ARCH=linux-armv4
build-musl-arm: TAG=arm-musleabi

build-musl-armhf: TARGET=arm-unknown-linux-musleabihf
build-musl-armhf: OPENSSL_ARCH=linux-armv4
build-musl-armhf: TAG=arm-musleabihf

build-musl-armv5te: TARGET=armv5te-unknown-linux-musleabi
build-musl-armv5te: OPENSSL_ARCH=linux-armv4
build-musl-armv5te: TAG=armv5te-musleabi

# Pull the latest musl-base to be used as cache if possible
# Build the musl-base image using the previous image as cache
# For the musl image we use multi-stage docker images.
# So first we build the musl-base part, and after that we will build the the main image.
build-musl-x86_64 build-musl-aarch64 build-musl-armv7 build-musl-arm build-musl-armhf build-musl-armv5te:
	docker buildx build \
		--progress=plain \
		--build-arg TARGET=$(TARGET) \
		--build-arg IMAGE_TAG=$(TAG) \
		--build-arg OPENSSL_ARCH=$(OPENSSL_ARCH) \
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
build-musl: build-musl-x86_64 build-musl-aarch64 build-musl-armv7 build-musl-arm build-musl-armhf build-musl-armv5te

.PHONY: build-musl build-musl-x86_64 build-musl-aarch64 build-musl-armv7 build-musl-arm build-musl-armhf build-musl-armv5te

# Build and push all musl targets
build-push-musl:
	$(MAKE) PUSH=true build-musl
.PHONY: build-push-musl

# Build and push a specific targets
build-push-musl-%:
	$(MAKE) PUSH=true "$(subst push-,,$@)"
