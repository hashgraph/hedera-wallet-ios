//
//  Copyright 2020 Hedera Hashgraph LLC
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

class SeedKeyTests: XCTestCase {
    let aSeed = Data(base64Encoded: "0123456789ABCDEF")!

    override func setUp() {
        let _ = SeedKey.delete()
    }

    func testCreateDelete() {
        let _ = SeedKey(createIfMissing: true)
        XCTAssertTrue(SeedKey.delete() ?? false)
    }

    func testEncodeDecode() {
        let keyOpt = SeedKey(createIfMissing: true)
        XCTAssertNotNil(keyOpt)
        if let key = keyOpt {
            let encryptedSeedOpt = key.encrypt(aSeed)
            XCTAssertNotNil(encryptedSeedOpt)
            if let encryptedSeed = encryptedSeedOpt {
                let decryptedSeedOpt = key.decrypt(encryptedSeed)
                XCTAssertEqual(.some(aSeed), decryptedSeedOpt)
            }
        }
        XCTAssertTrue(SeedKey.delete() ?? false)
    }

    func testInit() {
        let keyOpt = SeedKey(createIfMissing: false)
        XCTAssertNil(keyOpt)
        let keyOpt2 = SeedKey()
        XCTAssertNil(keyOpt2)
        let keyOpt3 = SeedKey(createIfMissing: true)
        XCTAssertNotNil(keyOpt3)
        let keyOpt4 = SeedKey(createIfMissing: true)
        XCTAssertNotNil(keyOpt4)
        XCTAssertTrue(SeedKey.delete() ?? false)
    }

    func testEncode() {
        let keyOpt = SeedKey(createIfMissing: true)
        XCTAssertNotNil(keyOpt)
        guard let key = keyOpt else {
            return
        }
        let encryptedSeedOpt = key.encrypt(aSeed)
        XCTAssertNotNil(encryptedSeedOpt)
        let encryptedSeedOpt2 = key.encrypt(Data())
        XCTAssertNil(encryptedSeedOpt2)
        XCTAssertTrue(SeedKey.delete() ?? false)
    }

    func testDecode() {
        let keyOpt = SeedKey(createIfMissing: true)
        XCTAssertNotNil(keyOpt)
        guard let key = keyOpt else {
            return
        }
        let decryptedOpt = key.decrypt(Data())
        XCTAssertNil(decryptedOpt)
        XCTAssertTrue(SeedKey.delete() ?? false)
    }
}
