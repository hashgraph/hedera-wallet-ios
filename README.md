# Hedera Mobile Wallet Beta-2019

The Hedera HashGraph wallet is a software program that creates, stores and manages private and public keys, it also allows the user to interact with the Hedera Hashgraph Network. This wallet enables users to send and receive payments in Hedera native HBAR crypto currency and also monitor the balance.

This wallet enables management of multiple accounts, integrates with other software components on the Hedera HashgGraph ecosystem of apps.

[View the usage and licensing terms here](license.txt)

## Supported Signature algorithm options

### ED25519

This uses a unique combination of BIP39 and PBKDF2 to generate a sequential keys for the user.

## Development Setup

Have XCode and Homebrew already installed prior to this setup.

Make sure to follow these instructions in a terminal running `bash`.

install "user" ruby

```brew install ruby
printf 'export RUBY_HOME=/usr/local/opt/ruby/bin/ruby\n' >> ~/.bash_profile
# Review your ~/.gem/ruby/ directory to make sure '2.6.0' is the latest.
printf 'export GEM_HOME=~/.gem/ruby/2.6.0' >> ~/.bash_profile
printf 'export PATH=$RUBY_HOME:$GEM_HOME:$PATH' >> ~/.bash_profile
# Either 'source' the commands, below, or reopen bash.
source ~/.bash_profile```

Install Cocoapods.

```gem install cocoapods --user-install```

Install `protoc`, its protobuf Swift plugin, and the gRPC Swift plugin.

```brew install protobuf swift-protobuf grpc-swift```

## Building the Code

run `pod install`

run `./gen-swift`

Build from Xcode.

## Supported Features

1. BIP39 Key Management
2. Account Details
3. Request payments
4. Pay / Transfer HBars
5. Account Creation
6. Update & Change keys
7. Get Records
8. Fees Customization
