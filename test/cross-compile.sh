#!/usr/bin/env bash

# Copyright 2021 Contributors to the Parsec project.
# SPDX-License-Identifier: Apache-2.0

set -xeuf -o pipefail

# x86_64 (host)
cargo build --features "pkcs11-provider, mbed-crypto-provider, tpm-provider, unix-peer-credentials-authenticator, direct-authenticator" \
	--release \
	--target x86_64-unknown-linux-gnu \
	--config 'target.x86_64-unknown-linux-gnu.linker="x86_64-linux-gnu-gcc"'

# The "jwt-svid-authenticator" feature is not included yet because of a cross compilation
# problem of BoringSSL. See https://github.com/tikv/grpc-rs/issues/536. Once resolved,
# "all-authenticators" will be used again.

# Allow the `pkg-config` crate to cross-compile
export PKG_CONFIG_ALLOW_CROSS=1
# Make the `pkg-config` crate use our wrapper
export PKG_CONFIG=$(pwd)/test/pkg-config

# Set the SYSROOT used by pkg-config
export SYSROOT=/tmp/arm-linux-gnueabihf
# Add the correct libcrypto to the linking process
export RUSTFLAGS="-lcrypto -L/tmp/arm-linux-gnueabihf/lib"
cargo build --features "pkcs11-provider, mbed-crypto-provider, tpm-provider, unix-peer-credentials-authenticator, direct-authenticator" \
	--release \
	--target armv7-unknown-linux-gnueabihf \
	--config 'target.armv7-unknown-linux-gnueabihf.linker="arm-linux-gnueabihf-gcc"'

# ---------------------------------
# target: arm-unknown-linux-gnueabi
# ---------------------------------
#
# Set the SYSROOT used by pkg-config
export SYSROOT=/tmp/arm-linux-gnueabi
# Add the correct libcrypto to the linking process
export RUSTFLAGS="-lcrypto -L/tmp/arm-linux-gnueabi/lib"
cargo build --features "pkcs11-provider, mbed-crypto-provider, tpm-provider, unix-peer-credentials-authenticator, direct-authenticator" \
	--release \
	--target arm-unknown-linux-gnueabi \
	--config 'target.arm-unknown-linux-gnueabi.linker="arm-linux-gnueabi-gcc"'


export SYSROOT=/tmp/aarch64-linux-gnu
export RUSTFLAGS="-lcrypto -L/tmp/aarch64-linux-gnu/lib"
# Pull in the TS code (but don't fail if it does not work)
git submodule update --init || echo "Warning: Failed to update submodule"
cargo build --features "pkcs11-provider, mbed-crypto-provider, tpm-provider, trusted-service-provider, unix-peer-credentials-authenticator, direct-authenticator" \
	--release \
	--target aarch64-unknown-linux-gnu \
	--config 'target.aarch64-unknown-linux-gnu.linker="aarch64-linux-gnu-gcc"'

# This is needed because for some reason the i686/i386 libs aren't picked up if we don't toss them around just before...
apt install -y libc6-dev-i386-amd64-cross
export SYSROOT=/tmp/i686-linux-gnu
export RUSTFLAGS="-lcrypto -L/tmp/i686-linux-gnu/lib"
cargo build --release --features "pkcs11-provider, mbed-crypto-provider, tpm-provider, unix-peer-credentials-authenticator, direct-authenticator, tss-esapi/generate-bindings" --target i686-unknown-linux-gnu

# -----------------------------------
# target: riscv64gc-unknown-linux-gnu
# -----------------------------------
#
# Set the SYSROOT used by pkg-config
export SYSROOT=/tmp/arm-linux-gnueabi
# Add the correct libcrypto to the linking process
export RUSTFLAGS="-lcrypto -L/tmp/riscv64-linux-gnu/lib"
cargo build --features "pkcs11-provider, mbed-crypto-provider, tpm-provider, unix-peer-credentials-authenticator, direct-authenticator" \
	--release \
	--target riscv64gc-unknown-linux-gnu \
	--config 'target.riscv64gc-unknown-linux-gnu.linker="riscv64-linux-gnu-gcc"'
