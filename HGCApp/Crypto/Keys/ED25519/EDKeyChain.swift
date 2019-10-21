//
//  EDKeyChain.swift
//  HGCApp
//
//  Created by Surendra  on 19/04/18.
//  Copyright © 2018 HGC. All rights reserved.
//

import UIKit
import CommonCrypto
import CryptoSwift

class EDKeyChain : HGCKeyChainProtocol {
    private var hgcSeed : HGCSeed
    
    init(hgcSeed:HGCSeed) {
        self.hgcSeed = hgcSeed
    }
    
    func key(at index: Int) -> HGCKeyPairProtocol! {
        let seedData = EDKeyChain.deriveKey(fromSeed: hgcSeed.entropy, for: index, ofLength: 32)!
        
        return HGCEdKeyPair.init(seed: seedData)
    }
    
    private static func deriveKey(fromSeed seed: Data, for index: Int, ofLength keyLength: Int) -> Data? {
        var index = index
        var password = seed
        
        password.append(Data(bytes: &index,
                             count: MemoryLayout.size(ofValue: index)))
        let salt = Data.init(hex: "ff")
        return Data.init(try! PKCS5.PBKDF2(password: password.bytes, salt: salt.bytes, iterations: 2048, keyLength: keyLength, variant: .sha512).calculate())
    }
}

class EDBip32KeyChain : HGCKeyChainProtocol {
    private var hgcSeed : HGCSeed
    
    init(hgcSeed:HGCSeed) {
        self.hgcSeed = hgcSeed
    }
    
    func key(at index: Int) -> HGCKeyPairProtocol! {
        let words = Mnemonic.init(entropy: hgcSeed.entropy)!.words
        let seed = Mnemonic.seed(forWords: words, password: "")!
        let ckd = Ed25519Derivation.init(seed: seed).derived(at: 44).derived(at: 3030).derived(at: 0).derived(at: 0).derived(at: UInt32(index))
        return HGCEdKeyPair.init(seed: ckd.raw)
    }

}

class HGCEdKeyPair : HGCKeyPairProtocol {
    let seed:Data
    let keyPair:EdKeyPair
    
    init(seed:Data) {
        self.seed = seed
        let edSeed = try? EdSeed.init(bytes: seed.bytes)
        keyPair = EdKeyPair.init(seed: edSeed!)
    }
    
    public var publicKeyData: Data! {
        return Data.init(keyPair.publicKey.bytes)
    }
    
    public var privateKeyData: Data! {
        return seed + publicKeyData
    }
    
    public var publicKeyString: String! {
        return Data.init(keyPair.publicKey.bytes).hex
    }
    
    public var privateKeyString: String! {
        return privateKeyData.hex
    }
    
    public func signMessage(_ message: Data!) -> Data! {
        return  Data.init(keyPair.sign(message.bytes()))
    }
    
    public func verify(_ signature: Data!, message: Data!) -> Bool {
        do {
            let isVerified = try keyPair.verify(signature: signature.bytes(), message: message.bytes())
            return isVerified
        } catch {
            return false
        }
    }
}

