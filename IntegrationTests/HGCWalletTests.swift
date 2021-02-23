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

class HGCWalletTests: XCTestCase {
//    func testCreation() {
//        let coreDataManager = MockCoreDataManager.init()
//        HGCWallet.createMasterWallet(signatureAlgorith: Int16(SignatureOption.ED25519.rawValue), coreDataManager: coreDataManager)
//        let wallet = HGCWallet.masterWallet(coreDataManager.mainContext)!
//
//        XCTAssert(wallet.signatureOption() == SignatureOption.ED25519)
//        XCTAssert(wallet.accounts!.count > 0)
//    }
//
    func testCreateNewAccount() {
        let coreDataManager = MockCoreDataManager.init()
        HGCWallet.createMasterWallet(signatureAlgorith: Int16(SignatureOption.ED25519.rawValue), keyDerivation:.bip32, coreDataManager: coreDataManager)
        let wallet = HGCWallet.masterWallet(coreDataManager.mainContext)!
        let account0 = wallet.accounts?.anyObject() as! HGCAccount
        let account1 = wallet.createNewAccount(coreDataManager)
        let account2 = wallet.createNewAccount(coreDataManager)
        
        XCTAssertEqual(account0.accountNumber, 0)
        XCTAssertEqual(account1.accountNumber, 1)
        XCTAssertEqual(account2.accountNumber, 2)
    }
    
    func createNewAccountAndLog() {
        let seed = CryptoUtils.randomSeed();

        if SecureAppSettings.default.setSeed(seed.entropy) {
            HGCWallet.createMasterWallet(signatureAlgorith: Int16(SignatureOption.ED25519.rawValue), accountID: nil, keyDerivation: .bip32)
            CoreDataManager.shared.saveContext()
            let wallet = HGCWallet.masterWallet(CoreDataManager.shared.mainContext)!
            print(wallet.accounts?.anyObject() as! HGCAccount)
            let account0 = wallet.accounts?.anyObject() as! HGCAccount
            XCTAssertEqual(account0.accountNumber, 0)
        }
    }
}
