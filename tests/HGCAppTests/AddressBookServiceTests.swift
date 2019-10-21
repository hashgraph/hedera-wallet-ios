//
//  AddressBookServiceTests.swift
//  HGCAppTests
//
//  Created by Surendra on 08/10/19.
//  Copyright © 2019 HGC. All rights reserved.
//

import XCTest
@testable import HGCApp
import CoreData

class AddressBookServiceTests: HGCAppTests {
    
    var context = MockCoreDataManager.init().mainContext
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testLoadBundleAddressBook() {
        let sut = APIAddressBookService.init()
        assert(sut.getActiveNodes(context).count == 0)
        
        sut.loadAddressBook(context)
        let nodes = sut.getActiveNodes(context)
        assert(nodes.count > 0)
    }
    
    func testUpdateAddressBookFromRemote() {
        let sut = APIAddressBookService.init()
        sut.loadAddressBook(context)
        
        HGCWallet.createMasterWallet(signatureAlgorith: Int16(SignatureOption.ED25519.rawValue), keyDerivation: .bip32)
        
        let op = FileContentOperation.init(payerAccount: WalletHelper.defaultPayerAccount()!, fileNum: 0)
        var response = Proto_Response.init()
        response.fileGetContents.header.nodeTransactionPrecheckCode = .ok
        response.fileGetContents.fileContents.contents = "0a170a0e33342e3139372e3231302e3138361a05302e302e330a150a0c332e3231392e3235322e35321a05302e302e340a170a0e33352e3135332e3132332e3133321a05302e302e350a160a0d332e3232302e3139362e3135361a05302e302e36".hexadecimal()!
        let grpc = MockRPC.init()
        grpc.queryResponse = response
        op.grpc = grpc
        let expectation = XCTestExpectation(description: "thread switching")
        sut.updateAddressBook(op: op, context: context) { (e) in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        let nodes = sut.getActiveNodes(context)
        assert(nodes.count == 3)
    }

}
