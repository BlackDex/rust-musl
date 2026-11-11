set shell := ["bash", "-euo", "pipefail", "-c"]
set dotenv-load
set default-list

export LOCAL_REGISTRY := env("LOCAL_REGISTRY", "localhost:5000")
export TOOLCHAIN_REGISTRY := env("TOOLCHAIN_REGISTRY", "localhost:5000")
export IMAGE_REGISTRY := env("IMAGE_REGISTRY", "localhost:5000")

export RUST_CHANNEL := env("RUST_CHANNEL", "stable")

PUSH := env("PUSH", "false")
host_arch := replace(replace(arch(), "aarch64", "arm64"), "x86_64", "amd64")
today := datetime("%Y-%m-%d")

export BUILD_RUST_CHANNEL := if RUST_CHANNEL == "nightly" { "nightly-" + today } else { RUST_CHANNEL }
export TAG_POSTFIX := if RUST_CHANNEL =~ '^nightly($|-20)' { "-" + RUST_CHANNEL } else { "-stable" }
export TAG_DATE := if RUST_CHANNEL =~ '^nightly-20' { "" } else { "-" + today }

import 'just/act.just'
import 'just/build.just'
import 'just/test.just'
