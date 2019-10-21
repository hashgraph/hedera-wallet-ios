//
//  EDKeyPairTests.swift
//  HGCAppTests
//
//  Created by Surendra  on 11/05/18.
//  Copyright © 2018 HGC. All rights reserved.
//

import XCTest

@testable import HGCApp

class EDKeyPairTests: HGCAppTests {
    
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
