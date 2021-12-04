#!/usr/bin/env bash

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
  echo -ne "\n\nTESTING: /target/x86_64-unknown-linux-musl/debug/${crate}\n"
  ./target/x86_64-unknown-linux-musl/debug/"${crate}" ; echo -ne "\nExited with: $?\n"
  set -x
  file "target/x86_64-unknown-linux-musl/debug/${crate}"
  ldd "target/x86_64-unknown-linux-musl/debug/${crate}"
  checksec --file="target/x86_64-unknown-linux-musl/debug/${crate}"
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
  echo -ne "\n\nTESTING: /target/armv7-unknown-linux-musleabihf/debug/${crate}\n"
  qemu-arm -cpu cortex-a7 ./target/armv7-unknown-linux-musleabihf/debug/"${crate}" ; echo -ne "\nExited with: $?\n"
  set -x
  file "target/armv7-unknown-linux-musleabihf/debug/${crate}"
  ldd "target/armv7-unknown-linux-musleabihf/debug/${crate}"
  checksec --file="target/armv7-unknown-linux-musleabihf/debug/${crate}"
  set +x
  exit 0
}

docker_build_aarch64() {
  local -r crate="$1"crate
  local -r cargo_arg="${2}"

  # -e RUSTFLAGS='-Clinker=rust-lld -Clink-arg=-s' \

  docker run --rm \
    -v "$PWD/test/${crate}:/home/rust/src" \
    -v cargo-cache:/root/.cargo/registry \
    -e RUST_BACKTRACE=1 \
    -e RUSTFLAGS='-Clink-arg=-s' \
    -it "blackdex/rust-musl:aarch64-musl-${RUST_CHANNEL}" \
    bash -c "cargo -vV ; rustc -vV ; cargo build --target=aarch64-unknown-linux-musl ${cargo_arg}"

  cd "test/${crate}" || return
  echo -ne "\n\nTESTING: /target/aarch64-unknown-linux-musl/debug/${crate}\n"
  qemu-aarch64 -cpu cortex-a53 ./target/aarch64-unknown-linux-musl/debug/"${crate}" ; echo -ne "\nExited with: $?\n"
  set -x
  file "target/aarch64-unknown-linux-musl/debug/${crate}"
  ldd "target/aarch64-unknown-linux-musl/debug/${crate}"
  checksec --file="target/aarch64-unknown-linux-musl/debug/${crate}"
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
  echo -ne "\n\nTESTING: /target/arm-unknown-linux-musleabihf/debug/${crate}\n"
  qemu-arm -cpu arm1136 ./target/arm-unknown-linux-musleabihf/debug/"${crate}" ; echo -ne "\nExited with: $?\n"
  set -x
  file "target/arm-unknown-linux-musleabihf/debug/${crate}"
  ldd "target/arm-unknown-linux-musleabihf/debug/${crate}"
  checksec --file="target/arm-unknown-linux-musleabihf/debug/${crate}"
  set +x
  exit 0
}


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
  echo -ne "\n\nTESTING: /target/armv5te-unknown-linux-musleabi/debug/${crate}\n"
  qemu-arm -cpu arm1136 ./target/armv5te-unknown-linux-musleabi/debug/"${crate}" ; echo -ne "\nExited with: $?\n"
  set -x
  file "target/armv5te-unknown-linux-musleabi/debug/${crate}"
  ldd "target/armv5te-unknown-linux-musleabi/debug/${crate}"
  checksec --file="target/armv5te-unknown-linux-musleabi/debug/${crate}"
  set +x
  exit 0
}


if [[ -n "${VERBOSE}" ]]; then
  MUSL_ARG+=" -vv"
fi

if [[ -z "${RUST_CHANNEL}" ]]; then
  RUST_CHANNEL="stable"
fi

if [[ "${ARCH}" == "armv7" ]]; then
  docker_build_armv7 "${1}" "${MUSL_ARG}"
elif [[ "${ARCH}" == "aarch64" ]]; then
  docker_build_aarch64 "${1}" "${MUSL_ARG}"
elif [[ "${ARCH}" == "armhf" ]]; then
  docker_build_armhf "${1}" "${MUSL_ARG}"
elif [[ "${ARCH}" == "armv5te" ]]; then
  docker_build_armv5te "${1}" "${MUSL_ARG}"
else
  docker_build "${1}" "${MUSL_ARG}"
fi
