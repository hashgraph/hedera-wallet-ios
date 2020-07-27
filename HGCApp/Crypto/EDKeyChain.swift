//
//  Copyright 2019 Hedera Hashgraph LLC
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

import UIKit
import CommonCrypto
import CryptoSwift
import Ed25519

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
    var keyPair:KeyPair
    
    init(seed:Data) {
        self.seed = seed
        let edSeed = try? Seed.init(bytes: seed.bytes)
        var counter = 5;
        keyPair = KeyPair.init(seed: edSeed!)
        while keyPair.publicKey.bytes.isEmpty, counter > 0 {
            sleep(1)
            keyPair = KeyPair.init(seed: edSeed!)
            counter-=1;
        }
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

