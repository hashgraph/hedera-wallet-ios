//
//  Ed25519Derivation.swift
//  HGCApp
//
//  Created by Surendra on 23/05/19.
//  Copyright © 2019 HGC. All rights reserved.
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
