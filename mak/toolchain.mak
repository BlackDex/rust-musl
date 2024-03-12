# ARCH_COMMON_CONFIG are based upon the `"COMMON_CONFIG +=` additions extracted
# from the MUSL Dockerfiles here: https://github.com/rust-embedded/cross/tree/master/docker

build-toolchain-x86_64: TARGET=x86_64-unknown-linux-musl
build-toolchain-x86_64: TAG=x86_64-musl

build-toolchain-aarch64: TARGET=aarch64-unknown-linux-musl
build-toolchain-aarch64: TAG=aarch64-musl

build-toolchain-armv7: TARGET=armv7-unknown-linux-musleabihf
build-toolchain-armv7: TAG=armv7-musleabihf

build-toolchain-arm: TARGET=arm-unknown-linux-musleabi
build-toolchain-arm: TAG=arm-musleabi

build-toolchain-armhf: TARGET=arm-unknown-linux-musleabihf
build-toolchain-armhf: TAG=arm-musleabihf

build-toolchain-armv5te: TARGET=armv5te-unknown-linux-musleabi
build-toolchain-armv5te: TAG=armv5te-musleabi

# Pull the latest toolchains to be used as cache if possible
# Build the toolchains image using the previous image as cache
build-toolchain-x86_64 build-toolchain-aarch64 build-toolchain-armv7 build-toolchain-arm build-toolchain-armhf build-toolchain-armv5te:
	docker build \
		--progress=plain \
		--build-arg TARGET=$(TARGET) \
		-t ghcr.io/blackdex/musl-toolchain:$(TAG) \
		-t ghcr.io/blackdex/musl-toolchain:$(TAG)${TAG_POSTFIX} \
		-t ghcr.io/blackdex/musl-toolchain:$(TAG)${TAG_POSTFIX}$(TAG_DATE) \
		-t localhost:5000/musl-toolchain:$(TAG)${TAG_POSTFIX} \
		-t localhost:5000/blackdex/musl-toolchain:$(TAG)${TAG_POSTFIX}$(TAG_DATE) \
		-f Dockerfile.toolchain \
		--load \
		"."
	if [ -n "$$PUSH" ] && [ "$$PUSH" = "true" ]; then \
		docker push localhost:5000/blackdex/musl-toolchain:$(TAG)${TAG_POSTFIX} ; \
		docker push localhost:5000/blackdex/musl-toolchain:$(TAG)${TAG_POSTFIX}$(TAG_DATE) ; \
	fi

build-toolchains: build-toolchain-x86_64 build-toolchain-aarch64 build-toolchain-armv7 build-toolchain-arm build-toolchain-armhf build-toolchain-armv5te
.PHONY: build-toolchains build-toolchain-x86_64 build-toolchain-aarch64 build-toolchain-armv7 build-toolchain-arm build-toolchain-armhf build-toolchain-armv5te

# Build and push all musl-cross targets
build-push-toolchains:
	$(MAKE) PUSH=true build-toolchains
.PHONY: build-push-toolchains

# Build and push a specific targets
build-push-toolchain-%:
	$(MAKE) PUSH=true "$(subst push-,,$@)"
