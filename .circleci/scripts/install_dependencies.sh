#!/usr/bin/env bash
set -o nounset
set -o errexit
set -o pipefail
brew install protobuf
brew install swift-protobuf
brew install grpc-swift
pod install --verbose
./gen-swift
