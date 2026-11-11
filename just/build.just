# Show the files sent to Docker as the build context.
check-context:
    printf '%s\n' 'FROM busybox:musl' 'COPY . /build-context' 'WORKDIR /build-context' 'RUN find .' \
        | docker build --progress=plain --no-cache -f - .

import './musl.just'
import './toolchain.just'

# Build all MUSL images.
build $platform_arch=host_arch: (_musl_all platform_arch PUSH)

# Build and push all MUSL images.
build-push $platform_arch=host_arch: (_musl_all platform_arch "true")

# Build toolchains, then MUSL images.
build-all $platform_arch=host_arch: \
    (_toolchains platform_arch PUSH) \
    (_musl_all platform_arch PUSH)

# Build and push toolchains, then MUSL images.
build-push-all $platform_arch=host_arch: \
    (_toolchains platform_arch "true") \
    (_musl_all platform_arch "true")
