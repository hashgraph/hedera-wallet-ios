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
@testable import HGCApp
import CoreData


class AddAccountViewModelTests: HGCAppTests {
    
    class AddAccountViewModelDelegateImpl : AddAccountViewModelDelegate {
        
        var onDoneButtonTapCalled = false
        var onDeleteButtonTapCalled = false
        var onCancelButtonTapCalled = false
        
        func onDoneButtonTap(_ vm: AddAccountViewModel) {
            onDoneButtonTapCalled = true
        }
        
        func onDeleteButtonTap(_ vm: AddAccountViewModel) {
            onDeleteButtonTapCalled = true
        }
        
        func onCancelButtonTap(_ vm: AddAccountViewModel) {
            onCancelButtonTapCalled = true
        }
    }
    
    var context = CoreDataManager.shared.mainContext
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    private func createTestAccount()->HGCAccount {
        let wallet = createTestWallet()
        let account = NSEntityDescription.insertNewObject(forEntityName: HGCAccount.entityName, into: context) as! HGCAccount
        account.wallet = wallet
        return account
    }
    
    private func createTestWallet()->HGCWallet{
        let wallet = NSEntityDescription.insertNewObject(forEntityName: HGCWallet.entityName, into: context) as! HGCWallet
        return wallet
    }
    
    private func createSUT(account:HGCAccount?, delegate:AddAccountViewModelDelegate = AddAccountViewModelDelegateImpl.init()) -> AddAccountViewModel {
        if let account = account {
            let vm = AddAccountViewModel.init(account: account, delegate: delegate)
            vm.context = context
            return vm
        } else {
            let vm = AddAccountViewModel.init(delegate: delegate)
            vm.context = context
            return vm
        }
    }
    
    func testSaveAccountDetailsOnDoneButton(){
        let account = createTestAccount()
        let vc = createSUT(account: account)
        vc.accountIDString="0.0.1003"
        vc.nickName="XYZ"
        do {
            try vc.onDoneButtonTap()
        } catch{
            print(error)
        }
        if let acnt = vc.account {
            XCTAssertEqual(acnt, account)
        }
        let acntIDStr = vc.accountIDString
        XCTAssertEqual(acntIDStr,"0.0.1003")
        let acntNick = vc.nickName
        XCTAssertEqual(acntNick,"XYZ")
    }
    
    func testCreateAccountOnDoneButton(){
           let vc = createSUT(account: nil)
           vc.accountIDString="0.0.1004"
           vc.nickName="ABC"
           do {
               try vc.onDoneButtonTap()
           } catch{
               print(error)
           }
           let acntIDStr = vc.accountIDString
           XCTAssertEqual(acntIDStr,"0.0.1004")
           let acntNick = vc.nickName
           XCTAssertEqual(acntNick,"ABC")
       }
    
    func testInvalidAccountOnDoneButton(){
           let vc = createSUT(account: nil)
           vc.accountIDString="001001"
           vc.nickName="ABC"
        XCTAssertThrowsError(try vc.onDoneButtonTap())
    }

    func testForPageTitleAdd(){
        let vc = createSUT(account: nil)
        XCTAssertEqual(vc.pageTitle,NSLocalizedString("ADD ACCOUNT", comment: ""))
    }
    
    func testForPageTitleEdit(){
        let account = createTestAccount()
        let vc = createSUT(account: account)
        XCTAssertEqual(vc.pageTitle,NSLocalizedString("EDIT ACCOUNT", comment: ""))
    }
    
    func testHideDeleteButton(){
        let vc = createSUT(account: nil)
        XCTAssertEqual(vc.hideDeleteButton,true)
    }
    
    func testShowDeleteButton(){
        let account = createTestAccount()
        let vc = createSUT(account: account)
        XCTAssertEqual(vc.hideDeleteButton,false)
    }
    
    func testOnDeleteButton(){
        let accnt = createTestAccount()
        let vc = createSUT(account: accnt)
        vc.onDeleteButtonTap()
        XCTAssertEqual(accnt.isFault, true)
    }
    
    func testDelegateDeleteButtonCalled() {
        let accnt = createTestAccount()
        let delegate = AddAccountViewModelDelegateImpl.init()
        let vc = createSUT(account: accnt, delegate: delegate)
        vc.onDeleteButtonTap()
        XCTAssertTrue(delegate.onDeleteButtonTapCalled)
    }
    
    func testDelegateDoneButtonCalled() {
        let delegate = AddAccountViewModelDelegateImpl.init()
        let vc = createSUT(account: nil, delegate: delegate)
        vc.accountIDString="0.0.1004"
        vc.nickName="ABC"
        try? vc.onDoneButtonTap()
        XCTAssertTrue(delegate.onDoneButtonTapCalled)
    }
    
    func testDelegateCancelButtonCalled() {
        let delegate = AddAccountViewModelDelegateImpl.init()
        let vc = createSUT(account: nil, delegate: delegate)
        vc.onCancelButtonTap()
        XCTAssertTrue(delegate.onCancelButtonTapCalled)
    }
}
