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
}
