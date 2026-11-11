# Build the toolchain source layer, shared for all four architectures
[group('toolchain')]
[arg('platform_arch', pattern='amd64|arm64')]
toolchain-base $platform_arch=host_arch:
    docker buildx build \
        --progress=plain \
        --platform="linux/${platform_arch}" \
        --target=source \
        --cache-from "type=registry,ref=${LOCAL_REGISTRY}/blackdex/musl-toolchain-buildcache:ubuntu-base-${platform_arch}" \
        --cache-to "type=registry,ref=${LOCAL_REGISTRY}/blackdex/musl-toolchain-buildcache:ubuntu-base-${platform_arch},compression=zstd,compression-level=3,mode=max" \
        -f Dockerfile.crosstool \
        --load \
        .

[arg('platform_arch', pattern='amd64|arm64')]
[arg('tag', pattern='.+-musl|.+-musleabi|.+-musleabihf')]
_toolchain $tag $target $platform_arch $push: (toolchain-base platform_arch)
    docker buildx build \
        --progress=plain \
        --platform="linux/${platform_arch}" \
        --build-arg "TARGET=${target}" \
        -t "${LOCAL_REGISTRY}/blackdex/musl-toolchain:${tag}" \
        -t "${LOCAL_REGISTRY}/blackdex/musl-toolchain:${tag}${TAG_DATE}" \
        --cache-from "type=registry,ref=${LOCAL_REGISTRY}/blackdex/musl-toolchain-buildcache:ubuntu-base-${platform_arch}" \
        --output "type=image,oci-mediatypes=true,compression=zstd,compression-level=3,push=${push}" \
        -f Dockerfile.crosstool \
        --load \
        .

_toolchains $platform_arch $push: \
    (_toolchain "x86_64-musl" "x86_64-unknown-linux-musl" platform_arch push) \
    (_toolchain "aarch64-musl" "aarch64-unknown-linux-musl" platform_arch push) \
    (_toolchain "armv7-musleabihf" "armv7-unknown-linux-musleabihf" platform_arch push) \
    (_toolchain "arm-musleabi" "arm-unknown-linux-musleabi" platform_arch push)

# Build all four toolchains.
[group('toolchain')]
toolchains $platform_arch=host_arch: (_toolchains platform_arch PUSH)

# Build toolchain container for x86_64/amd64
[group('toolchain')]
toolchain-x86_64 $platform_arch=host_arch: (_toolchain "x86_64-musl" "x86_64-unknown-linux-musl" platform_arch PUSH)

# Build toolchain container for aarch64/arm64
[group('toolchain')]
toolchain-aarch64 $platform_arch=host_arch: (_toolchain "aarch64-musl" "aarch64-unknown-linux-musl" platform_arch PUSH)

# Build toolchain container for armv7 (eabihf)
[group('toolchain')]
toolchain-armv7 $platform_arch=host_arch: (_toolchain "armv7-musleabihf" "armv7-unknown-linux-musleabihf" platform_arch PUSH)

# Build toolchain container for armv6 (eabi)
[group('toolchain')]
toolchain-arm $platform_arch=host_arch: (_toolchain "arm-musleabi" "arm-unknown-linux-musleabi" platform_arch PUSH)

# Some aliasses
alias toolchain-amd64 := toolchain-x86_64
alias toolchain-arm64 := toolchain-aarch64
