//
//  Ed25519Derivation.swift
//  stellarsdk
//
//  Created by Satraj Bambra on 2018-03-07.
//  Copyright © 2018 Soneso. All rights reserved.
//
//  Original: https://github.com/Soneso/stellar-ios-mac-sdk/blob/081b58088d1a7c8f899cf72917a87cf572ca4597/stellarsdk/stellarsdk/crypto/Ed25519Derivation.swift
//
//  Note: see LICENSE.txt in this directory for licensing of the original file.
//
//  Modifications Copyright 2019-2020 Hedera Hashgraph LLC
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import CryptoSwift

public struct Ed25519Derivation {
    public let raw: Data
    public let chainCode: Data

    public init(seed: Data) {
        let output = try! HMAC(key: "ed25519 seed".data(using: .utf8)!.bytes, variant: .sha512).authenticate(seed.bytes)
        self.raw = Data(output[0..<32])
        self.chainCode = Data(output[32..<64])
    }

    private init(privateKey: Data, chainCode: Data) {
        self.raw = privateKey
        self.chainCode = chainCode
    }

    public func derived(at index: UInt32) -> Ed25519Derivation {
        let edge: UInt32 = 0x80000000
        guard (edge & index) == 0 else { fatalError("Invalid index") }

        var data = Data([UInt8(0)])
        data += raw

        var derivingIndex = (edge + index).bigEndian
        data.append(Data(bytes: &derivingIndex,
                         count: MemoryLayout.size(ofValue: derivingIndex)))
        let digest = try! HMAC(key: chainCode.bytes, variant: .sha512).authenticate(data.bytes)

        let derivedPrivateKey = Data(digest[0..<32])
        let derivedChainCode = Data(digest[32..<64])

        return Ed25519Derivation (
            privateKey: derivedPrivateKey,
            chainCode: derivedChainCode
        )
    }
}
