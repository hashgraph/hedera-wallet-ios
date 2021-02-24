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

import XCTest

@testable import HederaWallet

class EDKeyPairTests: XCTestCase {
    
    func keyPair() -> HGCEdKeyPair {
        let data = "aabbccdd11223344aabbccdd11223344aaaaaaaabbbbcc59aa2244116688bb22".hexadecimal()!
        let keyPair = HGCEdKeyPair.init(seed: data)
        return keyPair
    }
    
    func testSignatureCreation() {
        let message = "3c147d61".hexadecimal()!
        let signature = "2ec2c5393c05fa1b385787631c9e3ef175f72f0882c3d9cbc8d63376b90598d7b51189e8cd36c080e14104413d8640f5d015da3b46e06154e895211ffd8ec109".hexadecimal()
        XCTAssertTrue(signature != nil)
        XCTAssertTrue((keyPair().verify(signature!, message: message as Data)))
    }
    
    func testSignatureVerificationFails() {
        let keyPair = self.keyPair()
        
        let validMessage = "3c147d61".hexadecimal()!
        let vaildSignature = keyPair.signMessage(validMessage)
        XCTAssertFalse((keyPair.verify(vaildSignature!, message: "ccdd1122334aabbccdd11223".hexadecimal()! as Data)))
        XCTAssertFalse((keyPair.verify("23344aaaaaa".hexadecimal()! as Data, message: validMessage as Data)))
    }
    
    func testPublicKeyGeneration() {
        let keyPair = self.keyPair()
        let publicKeyData = keyPair.publicKeyData
        XCTAssert(publicKeyData != nil)
        XCTAssertEqual("720a5e6b5891e2e3226b662681c555d88b53087773d2dae9742eeb69e1aef8ad", publicKeyData?.hex)
    }
    
    func testPrivateKeyGeneration() {
        let keyPair = self.keyPair()
        let privateKeyData = keyPair.privateKeyData
        XCTAssert(privateKeyData != nil)
        XCTAssertEqual(privateKeyData!.count, 64)
        XCTAssertEqual("aabbccdd11223344aabbccdd11223344aaaaaaaabbbbcc59aa2244116688bb22720a5e6b5891e2e3226b662681c555d88b53087773d2dae9742eeb69e1aef8ad", privateKeyData?.hex)

    }
    
    func testWordListFromAndroid() {
        let wordStr1 = "cheese outside tilt amateur curtain manage renew emotion torch album dune easy chaos balcony sort twenty involve other echo age blame urge famous avocado"
        
        let wordStr2 = "nut keep pulse maxim sway fled dog decor astute serve repeal opaque wily lied mosaic slide sour towel core chaos blood insult"
        
        let words24 = wordStr1.trim().components(separatedBy: CharacterSet.init(charactersIn: "\n\t "))
        let words22 = wordStr2.trim().components(separatedBy: CharacterSet.init(charactersIn: "\n\t "))
        let bip32seed:HGCSeed  = HGCSeed.init(bip39Words: words24)
        let preBip32seed:HGCSeed  = HGCSeed.init(words: words22)
        
        let bip32keyPair = EDBip32KeyChain.init(hgcSeed: bip32seed).key(at: 0)
        XCTAssertEqual("99ebc34ab219e8fb1bb14c813803e0a6ebde2c69ca2d729da0e8f9186749648f", bip32keyPair?.publicKeyData.hex)
        XCTAssertEqual("002a26eafcf673fc2d7ccd5d2091fc63993f9548db579677f3e27d5813e63d7499ebc34ab219e8fb1bb14c813803e0a6ebde2c69ca2d729da0e8f9186749648f", bip32keyPair?.privateKeyData.hex)
        
        let preBIP32KeyPair = EDKeyChain.init(hgcSeed: preBip32seed).key(at: 0)
        XCTAssertEqual("485de28538c5f6b627fb5a3dea1bf2386089b79325d6d65a7cd366ef4730d4d8", preBIP32KeyPair?.publicKeyData.hex)
        XCTAssertEqual("819c0f7a3251ad2fe294591c3f89849b4a2e0ab311e32c03f5b29f62dd5af2a8485de28538c5f6b627fb5a3dea1bf2386089b79325d6d65a7cd366ef4730d4d8", preBIP32KeyPair?.privateKeyData.hex)
    }
}
