#!/usr/bin/env bash

# ########################################
# Some testing RUSTFLAGS
# # Do not use the self-contained musl library, use musl libc of this image instead
# RUSTFLAGS='-Ctarget-feature=+crt-static -Clink-self-contained=no -Cprefer-dynamic=no'
# # Compact the binary a bit more
# RUSTFLAGS='-Clink-arg=-Wl,-z,pack-relative-relocs'
# # Use a different linker
# RUSTFLAGS='-Clinker=rust-lld -Clink-arg=-s'
#
# Adding a custom CFLAG for a specific architecture
# -e CFLAGS_aarch64_unknown_linux_musl="-mno-outline-atomics" \
# ########################################

docker_build() {
  local -r crate="${1}"crate
  local -r target="${2}"
  local -r qemu_cmd="${3}"
  local -r rust_musl_tag="${target/-unknown-linux/}"

  local -r tuid="$(id -u)"
  local -r tgid="$(id -g)"
  local -r cargo_cache="${PWD}/.cache/registry"
  mkdir -p "${cargo_cache}" || {
    echo "Unable to create cargo-cache dir" >&2
    return 1
  }

  set -x
  docker run --rm \
    --user "${tuid}:${tgid}" \
    --read-only \
    --cap-drop=ALL \
    --security-opt=no-new-privileges:true \
    --tmpfs "/tmp:rw,nosuid,nodev,exec,mode=0700,uid=${tuid},gid=${tgid}" \
    -v "${PWD}/test/${crate}:/home/rust/src:rw" \
    -v "${cargo_cache}:/usr/local/cargo/registry:rw" \
    "${DOCKER_UNSET[@]}" \
    "${PQ_LIB_DIR[@]}" \
    "${DOCKER_RUSTFLAGS[@]}" \
    "${DOCKER_ALPINE[@]}" \
    -e RUST_BACKTRACE=full \
    -e TMPDIR=/tmp \
    -it "${IMAGE_REGISTRY}/blackdex/rust-musl:${rust_musl_tag}-${RUST_CHANNEL}" \
    bash -c "
      rm -vf target/${target}/${RELTYPE}/${crate}
      cargo -vV
      rustc -vV
      cargo build --target=${target} ${CARGO_ARG}
    "
  set +x

  cd "test/${crate}" || exit 1
  local -r binary="target/${target}/${RELTYPE}/${crate}"
  local elf_info

  echo -ne "\n\nTESTING: ${binary/test\//}\n"
  if [[ -f "${binary}" ]]; then
    printf "\n# #########################\n"
    ${qemu_cmd} "${binary}" ; echo -ne "\nExited '${crate}' with: $?\n"
    printf "\n# #########################\n"
  else
    echo "Build failed, binary '${binary}' not found"
    exit 1
  fi

  file -b "${binary}" || return 1
  elf_info=$(LC_ALL=C readelf -hW -lW -dW "${binary}") || return 1
  if grep -Eq '^[[:space:]]*INTERP[[:space:]]|\(NEEDED\)' <<< "${elf_info}"; then
    printf '%s\n' "${elf_info}"
    echo "ERROR: Binary requires a dynamic linker or shared libraries." >&2
    return 1
  fi

  echo "Static linking: OK"
  echo "${elf_info}" | grep -e "ELF Header:" -e "Class:" -e "Machine:" -e "Flags:"
  ls -l "${binary}" || return 1
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
  # Else, if PQ_LIB is set to an empty string, unset PQ_LIB_DIR
  PQ_LIB_DIR=(-e "PQ_LIB_DIR=")
else
  # Else, use the defined PQ_LIB version
  PQ_LIB_DIR=(-e "PQ_LIB_DIR=/usr/local/musl/pq${PQ_LIB}/lib")
fi

DOCKER_UNSET=()
if [[ -n "${FEATURES}" ]]; then
  if [[ "${FEATURES}" == *"vendored_openssl"* ]]; then
    DOCKER_UNSET+=(-e "OPENSSL_DIR=")
    DOCKER_UNSET+=(-e "OPENSSL_LIB_DIR=")
    DOCKER_UNSET+=(-e "OPENSSL_INCLUDE_DIR=")
    DOCKER_UNSET+=(-e "DEP_OPENSSL_INCLUDE=")
  fi

  if [[ "${FEATURES}" == *"vendored_sqlite"* || "${FEATURES}" == *"vendored_sqlcipher"* ]]; then
    DOCKER_UNSET+=(-e "SQLITE3_LIB_DIR=")
    DOCKER_UNSET+=(-e "SQLITE3_INCLUDE_DIR=")
  fi

  if [[ "${FEATURES}" == *"vendored_pq"* ]]; then
    DOCKER_UNSET+=(-e "PQ_LIB_DIR=")
  fi
fi

DOCKER_ALPINE=()
if [[ "${FEATURES}" == *"vendored_mysql"* ]]; then
  # Because the Oracle MySQL Client build process does special checks for musl/Alpine support
  # We need to provide an entry as `/etc/alpine-release`.
  # It uses CMake's `EXISTS` which doesn't check if it is a file or directory.
  # This lets the mysqlclient-sys crate build the vendored client library
  DOCKER_ALPINE=(--tmpfs "/etc/alpine-release:ro,nosuid,nodev,noexec,size=1k,mode=0555")
fi

if [[ "${ARCH}" == "armv7" ]]; then
  docker_build "${1}" "armv7-unknown-linux-musleabihf" "qemu-arm-static -cpu cortex-a8,vfp=on -d unimp,guest_errors"
elif [[ "${ARCH}" == "aarch64" || "${ARCH}" == "arm64" ]]; then
  docker_build "${1}" "aarch64-unknown-linux-musl" "qemu-aarch64-static -cpu cortex-a53"
elif [[ "${ARCH}" == "armv6" || "${ARCH}" == "arm" ]]; then
  docker_build "${1}" "arm-unknown-linux-musleabi" "qemu-arm-static -cpu arm1176"
else
  docker_build "${1}" "x86_64-unknown-linux-musl" ""
fi
