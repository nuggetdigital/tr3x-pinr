#!/bin/bash

wd=$(dirname ${BASH_SOURCE[0]})

source $wd/../../.env

export RUST_LOG=trace
export IPFS_PATH=$wd/sandbox/ipfs-dump

killall prxy ipfs

set -Eeu

mkdir -p $IPFS_PATH
rm -rf $IPFS_PATH/*

curl --proto '=https' --tlsv1.2 -fsSL \
  https://github.com/nuggetdigital/ipfs-pinr/releases/download/v0.8.0/go-ipfs-v0.8.0+dss3-v0.7.0-x86_64-unknown-linux-gnu.gz \
| gunzip \
> $wd/sandbox/ipfs

chmod +x $wd/sandbox/ipfs

$wd/sandbox/ipfs init -p server,lowpower

cargo build --release --manifest-path=$wd/../Cargo.toml
cargo run --release --manifest-path=$wd/../Cargo.toml &

$wd/sandbox/ipfs daemon