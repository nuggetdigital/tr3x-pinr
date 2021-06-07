#!/bin/bash

set -Eeu

export PRXY_FROM_PORT=5000
export PRXY_TO_PORT=5001
export RUST_LOG=trace
export IPFS_PATH=./sandbox

cargo build --release
cargo run --release &
rm -rf $IPFS_PATH/*
ipfs init -p server,lowpower
ipfs daemon