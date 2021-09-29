# ARCH_COMMON_CONFIG are based upon the `"COMMON_CONFIG +=` additions extracted
# from the MUSL Dockerfiles here: https://github.com/rust-embedded/cross/tree/master/docker

build-toolchain-x86_64: TARGET=x86_64-unknown-linux-musl
build-toolchain-x86_64: RUST_MUSL_MAKE_CONFIG=config.mak
build-toolchain-x86_64: TAG=x86_64-musl

build-toolchain-aarch64: TARGET=aarch64-unknown-linux-musl
build-toolchain-aarch64: RUST_MUSL_MAKE_CONFIG=config.mak
build-toolchain-aarch64: TAG=aarch64-musl

build-toolchain-armv7: TARGET=armv7-unknown-linux-musleabihf
build-toolchain-armv7: RUST_MUSL_MAKE_CONFIG=config32.mak
build-toolchain-armv7: ARCH_COMMON_CONFIG="--with-arch=armv7-a --with-float=hard --with-mode=thumb --with-fpu=vfp"
build-toolchain-armv7: TAG=armv7-musleabihf

build-toolchain-arm: TARGET=arm-unknown-linux-musleabi
build-toolchain-arm: RUST_MUSL_MAKE_CONFIG=config32.mak
build-toolchain-arm: ARCH_COMMON_CONFIG="--with-arch=armv6 --with-float=soft --with-mode=arm"
build-toolchain-arm: TAG=arm-musleabi

build-toolchain-armhf: TARGET=arm-unknown-linux-musleabihf
build-toolchain-armhf: RUST_MUSL_MAKE_CONFIG=config32.mak
build-toolchain-armhf: ARCH_COMMON_CONFIG="--with-arch=armv6 --with-float=hard --with-mode=arm --with-fpu=vfp"
build-toolchain-armhf: TAG=arm-musleabihf

build-toolchain-armv5te: TARGET=armv5te-unknown-linux-musleabi
build-toolchain-armv5te: RUST_MUSL_MAKE_CONFIG=config32.mak
build-toolchain-armv5te: ARCH_COMMON_CONFIG="--with-arch=armv5te --with-float=soft --with-mode=arm"
build-toolchain-armv5te: TAG=armv5te-musleabi

# Pull the latest toolchains to be used as cache if possible
# Build the toolchains image using the previous image as cache
build-toolchain-x86_64 build-toolchain-aarch64 build-toolchain-armv7 build-toolchain-arm build-toolchain-armhf build-toolchain-armv5te:
	if ! docker image inspect blackdex/musl-toolchain:$(TAG) > /dev/null 2>&1 ; then \
		docker pull blackdex/musl-toolchain:$(TAG) || true ; \
	fi
	docker build \
		--progress=plain \
		--build-arg TARGET=$(TARGET) \
		--build-arg ARCH_COMMON_CONFIG=$(ARCH_COMMON_CONFIG) \
		--build-arg RUST_MUSL_MAKE_CONFIG=$(RUST_MUSL_MAKE_CONFIG) \
		--cache-from blackdex/musl-toolchain:$(TAG) \
		-t blackdex/musl-toolchain:$(TAG) \
		-t blackdex/musl-toolchain:$(TAG)$(TAG_DATE) \
		-f Dockerfile.toolchain \
		"."
	if [ -n "$$PUSH" ] && [ "$$PUSH" = "true" ]; then \
		docker push blackdex/musl-toolchain:$(TAG) ; \
		docker push blackdex/musl-toolchain:$(TAG)$(TAG_DATE) ; \
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
