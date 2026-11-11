# Build the musl base layer, shared for all four architectures
[group('musl')]
[arg('platform_arch', pattern='amd64|arm64')]
ubuntu-base $platform_arch=host_arch:
    docker buildx build \
        --progress=plain \
        --platform="linux/${platform_arch}" \
        --target=base \
        --cache-from "type=registry,ref=${LOCAL_REGISTRY}/blackdex/rust-musl-buildcache:${platform_arch}-ubuntu-base" \
        --cache-to "type=registry,ref=${LOCAL_REGISTRY}/blackdex/rust-musl-buildcache:${platform_arch}-ubuntu-base,compression=zstd,compression-level=3,mode=max" \
        -f Dockerfile.musl-base \
        --load \
        .

[arg('platform_arch', pattern='amd64|arm64')]
[arg('tag', pattern='.+-musl|.+-musleabi|.+-musleabihf')]
_musl $tag $platform_arch $push: (ubuntu-base platform_arch)
    docker buildx build \
        --progress=plain \
        --platform="linux/${platform_arch}" \
        --build-arg "TOOLCHAIN_REGISTRY=${TOOLCHAIN_REGISTRY}" \
        --build-arg "IMAGE_TAG=${tag}" \
        --build-arg "RUST_CHANNEL=${BUILD_RUST_CHANNEL}" \
        -t "${LOCAL_REGISTRY}/blackdex/rust-musl:${tag}${TAG_POSTFIX}" \
        -t "${LOCAL_REGISTRY}/blackdex/rust-musl:${tag}${TAG_POSTFIX}${TAG_DATE}" \
        --cache-from "type=registry,ref=${LOCAL_REGISTRY}/blackdex/rust-musl-buildcache:${platform_arch}-ubuntu-base" \
        --cache-from "type=registry,ref=${LOCAL_REGISTRY}/blackdex/rust-musl-buildcache:${platform_arch}-${tag}" \
        --cache-to "type=registry,ref=${LOCAL_REGISTRY}/blackdex/rust-musl-buildcache:${platform_arch}-${tag},compression=zstd,compression-level=3,mode=max" \
        --output "type=image,oci-mediatypes=true,compression=zstd,compression-level=3,push=${push}" \
        -f Dockerfile.musl-base \
        --load \
        .

_musl_all $platform_arch $push: \
    (_musl "x86_64-musl" platform_arch push) \
    (_musl "aarch64-musl" platform_arch push) \
    (_musl "armv7-musleabihf" platform_arch push) \
    (_musl "arm-musleabi" platform_arch push)

# Build all four MUSL images.
[group('musl')]
musls $platform_arch=host_arch: (_musl_all platform_arch PUSH)

# Build rust-musl container for x86_64/amd64
[group('musl')]
musl-x86_64 $platform_arch=host_arch: (_musl "x86_64-musl" platform_arch PUSH)

# Build rust-musl container for aarch64/arm64
[group('musl')]
musl-aarch64 $platform_arch=host_arch: (_musl "aarch64-musl" platform_arch PUSH)

# Build rust-musl container for armv7 (eabihf)
[group('musl')]
musl-armv7 $platform_arch=host_arch: (_musl "armv7-musleabihf" platform_arch PUSH)

# Build rust-musl container for armv6 (eabi)
[group('musl')]
musl-arm $platform_arch=host_arch: (_musl "arm-musleabi" platform_arch PUSH)

# Some aliasses
alias musl-amd64 := musl-x86_64
alias musl-arm64 := musl-aarch64
