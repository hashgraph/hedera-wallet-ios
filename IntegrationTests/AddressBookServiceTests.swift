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
import CoreData

class AddressBookServiceTests: XCTestCase {
    
    var context = MockCoreDataManager.init().mainContext
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testLoadBundleAddressBook() {
        let sut = APIAddressBookService.init()
        XCTAssertEqual(0, sut.getActiveNodes(context).count)
        
        sut.loadAddressBook(context)
        let nodes = sut.getActiveNodes(context)
        XCTAssertLessThan(0, nodes.count)
    }

//    func testUpdateAddressBookFromRemote() {
//        let sut = APIAddressBookService.init()
//        sut.loadAddressBook(context)
//
//        HGCWallet.createMasterWallet(signatureAlgorith: Int16(SignatureOption.ED25519.rawValue), keyDerivation: .bip32)
//
//        let op = FileContentOperation.init(payerAccount: WalletHelper.defaultPayerAccount()!, fileNum: 0)
//        var response = Proto_Response.init()
//        response.fileGetContents.header.nodeTransactionPrecheckCode = .ok
//        response.fileGetContents.fileContents.contents = "0a170a0e33342e3139372e3231302e3138361a05302e302e330a150a0c332e3231392e3235322e35321a05302e302e340a170a0e33352e3135332e3132332e3133321a05302e302e350a160a0d332e3232302e3139362e3135361a05302e302e36".hexadecimal()!
//        let grpc = MockRPC.init()
//        grpc.queryResponse = response
//        op.grpc = grpc
//        let expectation = XCTestExpectation(description: "thread switching")
//        sut.updateAddressBook(op: op, context: context) { (e) in
//            expectation.fulfill()
//        }
//        wait(for: [expectation], timeout: 1.0)
//        let nodes = sut.getActiveNodes(context)
//        XCTAssertEqual(3, nodes.count)
//    }
}
