#!/usr/bin/env bash
set -o nounset
set -o errexit
set -o pipefail
brew install protobuf
git clone https://github.com/grpc/grpc-swift
pushd ./grpc-swift
git checkout nio
make plugins
popd
pod install --verbose
PATH="$(pwd)/grpc-swift:$PATH" ./gen-swift
