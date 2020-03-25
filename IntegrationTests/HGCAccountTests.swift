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

class HGCAccountTests: XCTestCase {
    
//    static func createATestAccount (_ coreDataManager: MockCoreDataManager) {
//        let entropy = "aabbccdd11223344aabbccdd11223344aaaaaaaabbbbcc".hexadecimal()!
//        let seed = HGCSeed.init(entropy: entropy)!
//        SecureAppSettings.default.setSeed(seed.data)
//        HGCWallet.createMasterWallet(signatureAlgorith: Int16(SignatureOption.ED25519.rawValue), coreDataManager: coreDataManager)
//    }
//    
//    func testAccount() {
//        let coreDataManager = MockCoreDataManager.init()
//        HGCAccountTests.createATestAccount(coreDataManager)
//        let wallet = HGCWallet.masterWallet(coreDataManager.mainContext)!
//        let account = wallet.accounts?.anyObject() as! HGCAccount
//        XCTAssert(account.publicKeyString().count > 20)
//        XCTAssert(account.privateKeyString().count > 20)
//        
//        account.createTransaction(toAddress: "0x34a342aacc22", toName: "testToName", amount: 100, requestId: "100",coreDataManager)
//        account.createTransaction(toAddress: "0x34a342aacc22", toName: "testToName", amount: 100, requestId: "101",coreDataManager)
//        XCTAssertEqual(account.getAllTxn(context:coreDataManager.mainContext).count, 2)
//        
//        SecureAppSettings.default.clearSeed()
//    }
}
