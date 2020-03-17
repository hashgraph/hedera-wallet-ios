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

class SecureAppSettingsTests: XCTestCase {
    let seed = "a totally valid seed".data(using: .utf8)!
    let encryptedSeed = "I am encrypted".data(using: .utf8)!

    override func setUp() {
        let _ = SecureAppSettings.default.clear()
    }

    func testClearNothing() {
        XCTAssertTrue(SecureAppSettings.default.clear())
    }

    func testCreateReadDeleteSeed() {
        let didSet = SecureAppSettings.default.setSeed(seed)
        XCTAssertTrue(didSet)
        if !didSet {
            return
        }
        let actualSeedOpt = SecureAppSettings.default.getSeed()
        XCTAssertEqual(.some(seed), actualSeedOpt)
        XCTAssertTrue(SecureAppSettings.default.clear())
    }

    func testMigrateSeed() {
        XCTAssertTrue(SecureAppSettings.default.oldSetSeed(seed))
        let actualSeedOpt = SecureAppSettings.default.getSeed()
        XCTAssertEqual(.some(seed), actualSeedOpt)
        XCTAssertNotNil(SeedFile.read())
        XCTAssertNotNil(SeedKey(createIfMissing: false))
        XCTAssertNil(SecureAppSettings.default.oldGetSeed())
        XCTAssertTrue(SecureAppSettings.default.clear())
    }

    func testMissingSeedKey() {
        let didSet = SecureAppSettings.default.setSeed(seed)
        XCTAssertTrue(didSet)
        if !didSet {
            return
        }
        let didDelete = SeedKey.delete()
        XCTAssertEqual(.some(true), didDelete)
        XCTAssertNil(SecureAppSettings.default.getSeed())
        XCTAssertTrue(SecureAppSettings.default.clear())
    }

    func testMissingSeedFile() {
        let didSet = SecureAppSettings.default.setSeed(seed)
        XCTAssertTrue(didSet)
        if !didSet {
            return
        }
        let didDelete = SeedFile.delete()
        XCTAssertEqual(.some(true), didDelete)
        XCTAssertNil(SecureAppSettings.default.getSeed())
        XCTAssertTrue(SecureAppSettings.default.clear())
    }

    func testingBadSeedFile() {
        let didSet = SecureAppSettings.default.setSeed(seed)
        XCTAssertTrue(didSet)
        if !didSet {
            return
        }
        let writeResult = SeedFile.create(encryptedSeed)
        XCTAssertTrue(writeResult)
        XCTAssertNil(SecureAppSettings.default.getSeed())
        XCTAssertTrue(SecureAppSettings.default.clear())
    }
}
