#!/usr/bin/env bash

# ########################################
# Some testing RUSTFLAGS
# -e RUSTFLAGS='-Clink-arg=-s' \
# -e RUSTFLAGS='-Clinker=rust-lld -Clink-arg=-s' \
# -e RUSTFLAGS='-Clink-arg=/usr/local/musl/arm-unknown-linux-musleabi/lib/libatomic.a -Clink-arg=-s' \
#
# Adding a custom CFLAG for a specific architecture
# -e CFLAGS_aarch64_unknown_linux_musl="-mno-outline-atomics" \
#
# Use PostgreSQL v14
# -e PQ_LIB_DIR="/usr/local/musl/pq14/lib" \
# ########################################

docker_build() {
  local -r crate="${1}"crate
  local -r cargo_arg="${2}"

  docker run --rm \
    -v "$PWD/test/${crate}:/home/rust/src" \
    -v cargo-cache:/root/.cargo/registry \
    -e RUST_BACKTRACE=1 \
    -e RUSTFLAGS='-Clink-arg=-s' \
    -it "blackdex/rust-musl:x86_64-musl-${RUST_CHANNEL}" \
    bash -c "cargo -vV ; rustc -vV ; cargo build --target=x86_64-unknown-linux-musl ${cargo_arg}"

  cd "test/${crate}" || return
  echo -ne "\n\nTESTING: /target/x86_64-unknown-linux-musl/${RELTYPE}/${crate}\n"
  ./target/x86_64-unknown-linux-musl/"${RELTYPE}/${crate}" ; echo -ne "\nExited with: $?\n"
  set -x
  file "target/x86_64-unknown-linux-musl/${RELTYPE}/${crate}"
  ldd "target/x86_64-unknown-linux-musl/${RELTYPE}/${crate}"
  checksec --file="target/x86_64-unknown-linux-musl/${RELTYPE}/${crate}"
  set +x
  exit 0
}


docker_build_armv7() {
  local -r crate="$1"crate
  local -r cargo_arg="${2}"

  docker run --rm \
    -v "$PWD/test/${crate}:/home/rust/src" \
    -v cargo-cache:/root/.cargo/registry \
    -e RUST_BACKTRACE=1 \
    -e RUSTFLAGS='-Clink-arg=-s' \
    -it "blackdex/rust-musl:armv7-musleabihf-${RUST_CHANNEL}" \
    bash -c "cargo -vV ; rustc -vV ; cargo build --target=armv7-unknown-linux-musleabihf ${cargo_arg}"

  cd "test/${crate}" || return
  echo -ne "\n\nTESTING: /target/armv7-unknown-linux-musleabihf/${RELTYPE}/${crate}\n"
  qemu-arm -cpu cortex-a7 ./target/armv7-unknown-linux-musleabihf/"${RELTYPE}/${crate}" ; echo -ne "\nExited with: $?\n"
  set -x
  file "target/armv7-unknown-linux-musleabihf/${RELTYPE}/${crate}"
  ldd "target/armv7-unknown-linux-musleabihf/${RELTYPE}/${crate}"
  checksec --file="target/armv7-unknown-linux-musleabihf/${RELTYPE}/${crate}"
  set +x
  exit 0
}


docker_build_aarch64() {
  local -r crate="$1"crate
  local -r cargo_arg="${2}"

  docker run --rm \
    -v "$PWD/test/${crate}:/home/rust/src" \
    -v cargo-cache:/root/.cargo/registry \
    -e RUST_BACKTRACE=1 \
    -e RUSTFLAGS='-Clink-arg=-s' \
    -it "blackdex/rust-musl:aarch64-musl-${RUST_CHANNEL}" \
    bash -c "cargo -vV ; rustc -vV ; cargo build --target=aarch64-unknown-linux-musl ${cargo_arg}"

  cd "test/${crate}" || return
  echo -ne "\n\nTESTING: /target/aarch64-unknown-linux-musl/${RELTYPE}/${crate}\n"
  qemu-aarch64 -cpu cortex-a53 ./target/aarch64-unknown-linux-musl/"${RELTYPE}/${crate}" ; echo -ne "\nExited with: $?\n"
  set -x
  file "target/aarch64-unknown-linux-musl/${RELTYPE}/${crate}"
  ldd "target/aarch64-unknown-linux-musl/${RELTYPE}/${crate}"
  checksec --file="target/aarch64-unknown-linux-musl/${RELTYPE}/${crate}"
  set +x
  exit 0
}


docker_build_arm() {
  local -r crate="$1"crate
  local -r cargo_arg="${2}"

  docker run --rm \
    -v "$PWD/test/${crate}:/home/rust/src" \
    -v cargo-cache:/root/.cargo/registry \
    -e RUST_BACKTRACE=1 \
    -e RUSTFLAGS='-Clink-arg=-s' \
    -e RUSTFLAGS='-Clink-arg=/usr/local/musl/arm-unknown-linux-musleabi/lib/libatomic.a -Clink-arg=-s' \
    -it "blackdex/rust-musl:arm-musleabi-${RUST_CHANNEL}" \
    bash -c "cargo -vV ; rustc -vV ; cargo build --target=arm-unknown-linux-musleabi ${cargo_arg}"

  cd "test/${crate}" || return
  echo -ne "\n\nTESTING: /target/arm-unknown-linux-musleabi/${RELTYPE}/${crate}\n"
  qemu-arm -cpu arm1176 ./target/arm-unknown-linux-musleabi/"${RELTYPE}/${crate}" ; echo -ne "\nExited with: $?\n"
  set -x
  file "target/arm-unknown-linux-musleabi/${RELTYPE}/${crate}"
  ldd "target/arm-unknown-linux-musleabi/${RELTYPE}/${crate}"
  checksec --file="target/arm-unknown-linux-musleabi/${RELTYPE}/${crate}"
  set +x
  exit 0
}


docker_build_armhf() {
  local -r crate="$1"crate
  local -r cargo_arg="${2}"

  docker run --rm \
    -v "$PWD/test/${crate}:/home/rust/src" \
    -v cargo-cache:/root/.cargo/registry \
    -e RUST_BACKTRACE=1 \
    -e RUSTFLAGS='-Clink-arg=-s' \
    -it "blackdex/rust-musl:arm-musleabihf-${RUST_CHANNEL}" \
    bash -c "cargo -vV ; rustc -vV ; cargo build --target=arm-unknown-linux-musleabihf ${cargo_arg}"

  cd "test/${crate}" || return
  echo -ne "\n\nTESTING: /target/arm-unknown-linux-musleabihf/${RELTYPE}/${crate}\n"
  qemu-arm -cpu arm1136 ./target/arm-unknown-linux-musleabihf/"${RELTYPE}/${crate}" ; echo -ne "\nExited with: $?\n"
  set -x
  file "target/arm-unknown-linux-musleabihf/${RELTYPE}/${crate}"
  ldd "target/arm-unknown-linux-musleabihf/${RELTYPE}/${crate}"
  checksec --file="target/arm-unknown-linux-musleabihf/${RELTYPE}/${crate}"
  set +x
  exit 0
}

# -e RUSTFLAGS='-Clink-arg=/usr/local/musl/armv5te-unknown-linux-musleabi/lib/libatomic.a -Clink-arg=-s' \
docker_build_armv5te() {
  local -r crate="$1"crate
  local -r cargo_arg="${2}"

  docker run --rm \
    -v "$PWD/test/${crate}:/home/rust/src" \
    -v cargo-cache:/root/.cargo/registry \
    -e RUST_BACKTRACE=1 \
    -e RUSTFLAGS='-Clink-arg=-s' \
    -it "blackdex/rust-musl:armv5te-musleabi-${RUST_CHANNEL}" \
    bash -c "cargo -vV ; rustc -vV ; cargo build --target=armv5te-unknown-linux-musleabi ${cargo_arg}"

  cd "test/${crate}" || return
  echo -ne "\n\nTESTING: /target/armv5te-unknown-linux-musleabi/${RELTYPE}/${crate}\n"
  qemu-arm -cpu arm926 ./target/armv5te-unknown-linux-musleabi/"${RELTYPE}/${crate}" ; echo -ne "\nExited with: $?\n"
  set -x
  file "target/armv5te-unknown-linux-musleabi/${RELTYPE}/${crate}"
  ldd "target/armv5te-unknown-linux-musleabi/${RELTYPE}/${crate}"
  checksec --file="target/armv5te-unknown-linux-musleabi/${RELTYPE}/${crate}"
  set +x
  exit 0
}

# ###

if [[ -n "${VERBOSE}" ]]; then
  CARGO_ARG+=" -vv"
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

if [[ "${ARCH}" == "armv7" ]]; then
  docker_build_armv7 "${1}" "${CARGO_ARG}"
elif [[ "${ARCH}" == "aarch64" ]]; then
  docker_build_aarch64 "${1}" "${CARGO_ARG}"
elif [[ "${ARCH}" == "armhf" ]]; then
  docker_build_armhf "${1}" "${CARGO_ARG}"
elif [[ "${ARCH}" == "arm" ]]; then
  docker_build_arm "${1}" "${CARGO_ARG}"
elif [[ "${ARCH}" == "armv5te" ]]; then
  docker_build_armv5te "${1}" "${CARGO_ARG}"
else
  docker_build "${1}" "${CARGO_ARG}"
fi
