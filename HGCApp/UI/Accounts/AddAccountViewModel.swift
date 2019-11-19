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

import UIKit
import CoreData

protocol AddAccountViewModelDelegate : class {
    func onDoneButtonTap(_ vm:AddAccountViewModel)
    func onDeleteButtonTap(_ vm:AddAccountViewModel)
    func onCancelButtonTap(_ vm:AddAccountViewModel)
}

class AddAccountViewModel {
    weak var delegate:AddAccountViewModelDelegate?
    var accountIDString = ""
    var nickName = ""
    var account:HGCAccount?
    var context:NSManagedObjectContext = CoreDataManager.shared.mainContext
    
    var editMode:Bool {
        return account != nil
    }
    
    var pageTitle: String {
        return editMode ?  NSLocalizedString("EDIT ACCOUNT", comment: "") : NSLocalizedString("ADD ACCOUNT", comment: "")
    }
    
    var hideDeleteButton:Bool {
        return !editMode
    }
    
    init(delegate:AddAccountViewModelDelegate) {
        self.delegate = delegate
    }
    
    init(account:HGCAccount, delegate:AddAccountViewModelDelegate) {
        nickName = account.name ?? ""
        accountIDString = account.accountID()?.stringRepresentation() ?? ""
        self.account = account
        self.delegate = delegate
    }
    
    var accountID:HGCAccountID? {
        return HGCAccountID.init(from: accountIDString)
    }
    
    func onDoneButtonTap() throws {
        guard let accId = accountID else {
            throw NSLocalizedString("Please enter a valid account ID", comment: "")
        }
        if let account = account {
            account.updateAccountID(accId)
            account.name = nickName
            CoreDataManager.save(context: account.managedObjectContext!)
        } else {
            account = HGCWallet.masterWallet()?.createNewExternalAccount(accountID: accId, name: nickName, context)
            CoreDataManager.save(context: context)
        }
        delegate?.onDoneButtonTap(self)
    }
    
    func onDeleteButtonTap() {
        if let account = account {
            context.delete(account)
            CoreDataManager.save(context: context)
        }
        delegate?.onDeleteButtonTap(self)
    }
    
    func onCancelButtonTap() {
        delegate?.onCancelButtonTap(self)
    }
}
