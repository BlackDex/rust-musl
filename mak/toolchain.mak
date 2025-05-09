# ARCH_COMMON_CONFIG are based upon the `"COMMON_CONFIG +=` additions extracted
# from the MUSL Dockerfiles here: https://github.com/rust-embedded/cross/tree/master/docker

toolchain-x86_64: TARGET=x86_64-unknown-linux-musl
toolchain-x86_64: TAG=x86_64-musl

toolchain-aarch64: TARGET=aarch64-unknown-linux-musl
toolchain-aarch64: TAG=aarch64-musl

toolchain-armv7: TARGET=armv7-unknown-linux-musleabihf
toolchain-armv7: ARCH_COMMON_CONFIG="--with-arch=armv7-a --with-float=hard --with-mode=thumb --with-fpu=vfp"
toolchain-armv7: TAG=armv7-musleabihf

toolchain-arm: TARGET=arm-unknown-linux-musleabi
toolchain-arm: ARCH_COMMON_CONFIG="--with-arch=armv6 --with-float=soft --with-mode=arm"
toolchain-arm: TAG=arm-musleabi

# Pull the latest toolchains to be used as cache if possible
# Build the toolchains image using the previous image as cache
toolchain-x86_64 toolchain-aarch64 toolchain-armv7 toolchain-arm:
	docker buildx build \
		--progress=plain \
		--build-arg TARGET=$(TARGET) \
		--build-arg ARCH_COMMON_CONFIG=$(ARCH_COMMON_CONFIG) \
		-t localhost:5000/blackdex/musl-toolchain:$(TAG) \
		-t localhost:5000/blackdex/musl-toolchain:$(TAG)$(TAG_DATE) \
		-f Dockerfile.toolchain \
		--load \
		"."
	if [ -n "$$PUSH" ] && [ "$$PUSH" = "true" ]; then \
		docker push localhost:5000/blackdex/musl-toolchain:$(TAG) ; \
		docker push localhost:5000/blackdex/musl-toolchain:$(TAG)$(TAG_DATE) ; \
	fi

toolchains: toolchain-x86_64 toolchain-aarch64 toolchain-armv7 toolchain-arm
.PHONY: toolchains toolchain-x86_64 toolchain-aarch64 toolchain-armv7 toolchain-arm

# Build and push all musl-cross targets
push-toolchains:
	$(MAKE) PUSH=true toolchains
.PHONY: toolchains-push

# Build and push a specific targets
push-toolchain-%:
	$(MAKE) PUSH=true "$(subst push-,,$@)"
