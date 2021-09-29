# Pull the latest gnu-base to be used as cache if possible
# Build the gnu-base image using the previous image as cache
build-gnu:
	if ! docker image inspect blackdex/rust-musl:gnu-base > /dev/null 2>&1 ; then \
		docker pull blackdex/rust-musl:gnu-base || true ; \
	fi
	docker build \
		--progress=plain \
		-f Dockerfile.gnu-base \
		-t blackdex/rust-musl:gnu-base \
		-t blackdex/rust-musl:gnu-base$(TAG_DATE) \
		"."
	if [ -n "$$PUSH" ] && [ "$$PUSH" = "true" ]; then \
		docker push blackdex/rust-musl:gnu-base ; \
		docker push blackdex/rust-musl:gnu-base$(TAG_DATE) ; \
	fi
.PHONY: build-gnu

# Build and push all musl targets
build-push-gnu:
	$(MAKE) PUSH=true build-gnu
.PHONY: .build-push-gnu
