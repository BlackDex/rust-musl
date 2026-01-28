#!/usr/bin/env bash

# ########################################
# Some testing RUSTFLAGS
# -e RUSTFLAGS='-Clink-arg=-s' \
# -e RUSTFLAGS='-Clinker=rust-lld -Clink-arg=-s' \
# -e RUSTFLAGS='-Clink-arg=-latomic -Clink-arg=-s' \
#
# Adding a custom CFLAG for a specific architecture
# -e CFLAGS_aarch64_unknown_linux_musl="-mno-outline-atomics" \
# ########################################

docker_build() {
  local -r crate="${1}"crate
  local -r target=x86_64-unknown-linux-musl

  set -x
  docker run --rm \
    -v "$PWD/test/${crate}:/home/rust/src" \
    -v cargo-cache:/root/.cargo/registry \
    "${PQ_LIB_DIR[@]}" \
    "${DOCKER_RUSTFLAGS[@]}" \
    -e RUST_BACKTRACE=full \
    -it "${IMAGE_REGISTRY}/blackdex/rust-musl:x86_64-musl-${RUST_CHANNEL}" \
    bash -c "rm -vf target/${target}/${RELTYPE}/${crate} ; cargo -vV ; rustc -vV ; cargo build --target=${target} ${CARGO_ARG}"
  set +x

  cd "test/${crate}" || return
  echo -ne "\n\nTESTING: /target/${target}/${RELTYPE}/${crate}\n"
  ./target/"${target}/${RELTYPE}/${crate}" ; echo -ne "\nExited with: $?\n"
  set -x
  file "target/${target}/${RELTYPE}/${crate}"
  ldd "target/${target}/${RELTYPE}/${crate}"
  ls -l "target/${target}/${RELTYPE}/${crate}"
  checksec file "target/${target}/${RELTYPE}/${crate}"
  set +x
  exit 0
}


docker_build_armv7() {
  local -r crate="$1"crate
  local -r target=armv7-unknown-linux-musleabihf

  set -x
  docker run --rm \
    -v "$PWD/test/${crate}:/home/rust/src" \
    -v cargo-cache:/root/.cargo/registry \
    "${PQ_LIB_DIR[@]}" \
    "${DOCKER_RUSTFLAGS[@]}" \
    -e RUST_BACKTRACE=full \
    -it "${IMAGE_REGISTRY}/blackdex/rust-musl:armv7-musleabihf-${RUST_CHANNEL}" \
    bash -c "rm -vf target/${target}/${RELTYPE}/${crate} ; cargo -vV ; rustc -vV ; cargo build --target=${target} ${CARGO_ARG}"
  set +x

  cd "test/${crate}" || return
  echo -ne "\n\nTESTING: /target/${target}/${RELTYPE}/${crate}\n"
  qemu-arm-static -cpu cortex-a8,vfp=on -d unimp,guest_errors ./target/"${target}/${RELTYPE}/${crate}" ; echo -ne "\nExited with: $?\n"
  # qemu-arm-static -cpu cortex-a7,vfp=v4 -d unimp,guest_errors ./target/"${target}/${RELTYPE}/${crate}" ; echo -ne "\nExited with: $?\n"
  set -x
  file "target/${target}/${RELTYPE}/${crate}"
  ldd "target/${target}/${RELTYPE}/${crate}"
  ls -l "target/${target}/${RELTYPE}/${crate}"
  checksec file "target/${target}/${RELTYPE}/${crate}"
  set +x
  exit 0
}


docker_build_aarch64() {
  local -r crate="$1"crate
  local -r target=aarch64-unknown-linux-musl

  set -x
  docker run --rm \
    -v "$PWD/test/${crate}:/home/rust/src" \
    -v cargo-cache:/root/.cargo/registry \
    "${PQ_LIB_DIR[@]}" \
    "${DOCKER_RUSTFLAGS[@]}" \
    -e RUST_BACKTRACE=full \
    -it "${IMAGE_REGISTRY}/blackdex/rust-musl:aarch64-musl-${RUST_CHANNEL}" \
    bash -c "rm -vf target/${target}/${RELTYPE}/${crate} ; cargo -vV ; rustc -vV ; cargo build --target=${target} ${CARGO_ARG}"
  set +x

  cd "test/${crate}" || return
  echo -ne "\n\nTESTING: /target/${target}/${RELTYPE}/${crate}\n"
  qemu-aarch64-static -cpu cortex-a53 ./target/"${target}/${RELTYPE}/${crate}" ; echo -ne "\nExited with: $?\n"
  set -x
  file "target/${target}/${RELTYPE}/${crate}"
  ldd "target/${target}/${RELTYPE}/${crate}"
  ls -l "target/${target}/${RELTYPE}/${crate}"
  checksec file "target/${target}/${RELTYPE}/${crate}"
  set +x
  exit 0
}


docker_build_arm() {
  local -r crate="$1"crate
  local -r target=arm-unknown-linux-musleabi

  set -x
  docker run --rm \
    -v "$PWD/test/${crate}:/home/rust/src" \
    -v cargo-cache:/root/.cargo/registry \
    "${PQ_LIB_DIR[@]}" \
    "${DOCKER_RUSTFLAGS[@]}" \
    -e RUST_BACKTRACE=full \
    -it "${IMAGE_REGISTRY}/blackdex/rust-musl:arm-musleabi-${RUST_CHANNEL}" \
    bash -c "rm -vf target/${target}/${RELTYPE}/${crate} ; cargo -vV ; rustc -vV ; cargo build --target=${target} ${CARGO_ARG}"
  set +x

  cd "test/${crate}" || return
  echo -ne "\n\nTESTING: /target/${target}/${RELTYPE}/${crate}\n"
  qemu-arm-static -cpu arm1176 ./target/"${target}/${RELTYPE}/${crate}" ; echo -ne "\nExited with: $?\n"
  set -x
  file "target/${target}/${RELTYPE}/${crate}"
  ldd "target/${target}/${RELTYPE}/${crate}"
  ls -l "target/${target}/${RELTYPE}/${crate}"
  checksec file "target/${target}/${RELTYPE}/${crate}"
  set +x
  exit 0
}

# ###

if [[ -n "${VERBOSE}" ]]; then
  CARGO_ARG+=" -vvv"
fi

if [[ -n "${RELEASE}" ]]; then
  CARGO_ARG+=" --release"
  RELTYPE="release"
else
  RELTYPE="debug"
fi

if [[ -n "${FEATURES}" ]]; then
  CARGO_ARG+=" --features ${FEATURES}"
fi

if [[ -n "${XTRA_ARG}" ]]; then
  CARGO_ARG+=" ${XTRA_ARG}"
fi

if [[ -z "${RUST_CHANNEL}" ]]; then
  RUST_CHANNEL="stable"
fi

DOCKER_RUSTFLAGS=()
if [[ -n "${RUSTFLAGS}" ]]; then
  DOCKER_RUSTFLAGS=(-e "RUSTFLAGS=${RUSTFLAGS}")
fi

# If PQ_LIB is unset, use the image default
if [[ -z "${PQ_LIB+set}" ]]; then
  PQ_LIB_DIR=()
elif [[ -z "${PQ_LIB-unset}" ]]; then
  # Else, if PQ_LIB is set to an empty string unset PQ_LIB_DIR
  PQ_LIB_DIR=(-e "PQ_LIB_DIR=")
else
  # Else, use the defined PQ_LIB version
  PQ_LIB_DIR=(-e "PQ_LIB_DIR=/usr/local/musl/pq${PQ_LIB}/lib")
fi

if [[ "${ARCH}" == "armv7" ]]; then
  docker_build_armv7 "${1}"
elif [[ "${ARCH}" == "aarch64" || "${ARCH}" == "arm64" ]]; then
  docker_build_aarch64 "${1}"
elif [[ "${ARCH}" == "armv6" || "${ARCH}" == "arm" ]]; then
  docker_build_arm "${1}"
else
  docker_build "${1}"
fi
