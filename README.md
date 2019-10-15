# Hedera Mobile Wallet Beta-2019

The Hedera HashGraph wallet is a software program that creates, stores and manages private and public keys, it also allows the user to interact with the Hedera Hashgraph Network. This wallet enables users to send and receive payments in Hedera native HBAR crypto currency and also monitor the balance.

This wallet enables management of multiple accounts, integrates with other software components on the Hedera HashgGraph ecosystem of apps.

[View the usage and licensing terms here](license.txt)

## Supported Signature algorithm options

### ED25519

This uses a unique combination of BIP39 and PBKDF2 to generate a sequential keys for the user.

## Branch Policy

## Development Setup

install cocoapods
**gem install cocoapods**

install protoc
**brew install protobuf**

install protobuf swift plugin
**brew install swift-protobuf**

install grpc swift plugin for protoc
https://github.com/grpc/grpc-swift#getting-the-plugins

## Building the Code

run **pod install**

run **./gen-swift**

build from Xcode

## Supported Features
