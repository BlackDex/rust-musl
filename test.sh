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

  docker run --rm \
    -v "$PWD/test/${crate}:/home/rust/src" \
    -v cargo-cache:/root/.cargo/registry \
    -e PQ_LIB_DIR="/usr/local/musl/pq${PQ_LIB}/lib" \
    -e RUST_BACKTRACE=full \
    -e RUSTFLAGS="-Clink-arg=-s ${RUSTFLAGS}" \
    -it "${IMAGE_REGISTRY}/blackdex/rust-musl:x86_64-musl-${RUST_CHANNEL}" \
    bash -c "rm -vf target/${target}/${RELTYPE}/${crate} ; cargo -vV ; rustc -vV ; cargo build --target=${target} ${CARGO_ARG}"

  cd "test/${crate}" || return
  echo -ne "\n\nTESTING: /target/${target}/${RELTYPE}/${crate}\n"
  ./target/"${target}/${RELTYPE}/${crate}" ; echo -ne "\nExited with: $?\n"
  set -x
  file "target/${target}/${RELTYPE}/${crate}"
  ldd "target/${target}/${RELTYPE}/${crate}"
  checksec --file="target/${target}/${RELTYPE}/${crate}"
  set +x
  exit 0
}


docker_build_armv7() {
  local -r crate="$1"crate
  local -r target=armv7-unknown-linux-musleabihf

  docker run --rm \
    -v "$PWD/test/${crate}:/home/rust/src" \
    -v cargo-cache:/root/.cargo/registry \
    -e PQ_LIB_DIR="/usr/local/musl/pq${PQ_LIB}/lib" \
    -e RUST_BACKTRACE=full \
    -e RUSTFLAGS="-Clink-arg=-s ${RUSTFLAGS}" \
    -it "${IMAGE_REGISTRY}/blackdex/rust-musl:armv7-musleabihf-${RUST_CHANNEL}" \
    bash -c "rm -vf target/${target}/${RELTYPE}/${crate} ; cargo -vV ; rustc -vV ; cargo build --target=${target} ${CARGO_ARG}"

  cd "test/${crate}" || return
  echo -ne "\n\nTESTING: /target/${target}/${RELTYPE}/${crate}\n"
  qemu-arm-static -cpu cortex-a7 ./target/"${target}/${RELTYPE}/${crate}" ; echo -ne "\nExited with: $?\n"
  set -x
  file "target/${target}/${RELTYPE}/${crate}"
  ldd "target/${target}/${RELTYPE}/${crate}"
  checksec --file="target/${target}/${RELTYPE}/${crate}"
  set +x
  exit 0
}


docker_build_aarch64() {
  local -r crate="$1"crate
  local -r target=aarch64-unknown-linux-musl

  docker run --rm \
    -v "$PWD/test/${crate}:/home/rust/src" \
    -v cargo-cache:/root/.cargo/registry \
    -e PQ_LIB_DIR="/usr/local/musl/pq${PQ_LIB}/lib" \
    -e RUST_BACKTRACE=full \
    -e RUSTFLAGS="-Clink-arg=-s ${RUSTFLAGS}" \
    -it "${IMAGE_REGISTRY}/blackdex/rust-musl:aarch64-musl-${RUST_CHANNEL}" \
    bash -c "rm -vf target/${target}/${RELTYPE}/${crate} ; cargo -vV ; rustc -vV ; cargo build --target=${target} ${CARGO_ARG}"

  cd "test/${crate}" || return
  echo -ne "\n\nTESTING: /target/${target}/${RELTYPE}/${crate}\n"
  qemu-aarch64-static -cpu cortex-a53 ./target/"${target}/${RELTYPE}/${crate}" ; echo -ne "\nExited with: $?\n"
  set -x
  file "target/${target}/${RELTYPE}/${crate}"
  ldd "target/${target}/${RELTYPE}/${crate}"
  checksec --file="target/${target}/${RELTYPE}/${crate}"
  set +x
  exit 0
}


docker_build_arm() {
  local -r crate="$1"crate
  local -r target=arm-unknown-linux-musleabi

  docker run --rm \
    -v "$PWD/test/${crate}:/home/rust/src" \
    -v cargo-cache:/root/.cargo/registry \
    -e PQ_LIB_DIR="/usr/local/musl/pq${PQ_LIB}/lib" \
    -e RUST_BACKTRACE=full \
    -e RUSTFLAGS="-Clink-arg=-s ${RUSTFLAGS}" \
    -it "${IMAGE_REGISTRY}/blackdex/rust-musl:arm-musleabi-${RUST_CHANNEL}" \
    bash -c "rm -vf target/${target}/${RELTYPE}/${crate} ; cargo -vV ; rustc -vV ; cargo build --target=${target} ${CARGO_ARG}"

  cd "test/${crate}" || return
  echo -ne "\n\nTESTING: /target/${target}/${RELTYPE}/${crate}\n"
  qemu-arm-static -cpu arm1176 ./target/"${target}/${RELTYPE}/${crate}" ; echo -ne "\nExited with: $?\n"
  set -x
  file "target/${target}/${RELTYPE}/${crate}"
  ldd "target/${target}/${RELTYPE}/${crate}"
  checksec --file="target/${target}/${RELTYPE}/${crate}"
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

if [[ -z "${RUST_CHANNEL}" ]]; then
  RUST_CHANNEL="stable"
fi

if [[ -z "${PQ_LIB}" ]]; then
  PQ_LIB="16"
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
