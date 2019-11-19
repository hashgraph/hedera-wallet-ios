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

import Foundation
import CoreData

enum KeyDerivation {
    case hgc, bip32
}

enum AccountType: String {
    case auto = "auto"
    case external = "external"
}

extension HGCWallet {
    public static let entityName  = "Wallet"
    public static let typeBip32  = "bip32"

    func keyChain() -> HGCKeyChainProtocol? {
        return WalletHelper.keyChain()
    }
    
    func signatureOption() -> SignatureOption {
        if let option : SignatureOption = SignatureOption(rawValue: Int(self.signatureAlgorithm)) {
            return option
        }
        return .ED25519
    }
    
    var keyDerivationType:KeyDerivation {
        get {
            if let kd = keyDerivation, kd == HGCWallet.typeBip32 {
                return .bip32
            }
            return .hgc
        }
        
        set {
            switch newValue {
            case .hgc:
                keyDerivation = ""
            case .bip32:
                keyDerivation = HGCWallet.typeBip32
            }
        }
    }
    
    class func masterWallet(_ context : NSManagedObjectContext = CoreDataManager.shared.mainContext) -> HGCWallet? {
        let result = try? context.fetch(HGCWallet.fetchRequest() as NSFetchRequest<HGCWallet>)
        return (result?.first)
    }
    
    class func createMasterWallet(signatureAlgorith: Int16, accountID:HGCAccountID? = nil, keyDerivation:KeyDerivation, coreDataManager : CoreDataManagerProtocol = CoreDataManager.shared) {
        let context = coreDataManager.mainContext
        let result = try? context.fetch(HGCWallet.fetchRequest() as NSFetchRequest<HGCWallet>)
        if  result == nil || result?.count == 0 {
            let wallet = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as! HGCWallet
            wallet.walletId = 0
            wallet.signatureAlgorithm = signatureAlgorith
            switch keyDerivation {
            case .hgc:
                wallet.keyDerivation = ""
            case .bip32:
                wallet.keyDerivation = HGCWallet.typeBip32
            
            }
            let acc = wallet.createDefaultAccount(coreDataManager)
            if let accID = accountID {
                acc.updateAccountID(accID)
            }
        }
    }
    
    func createNewAccount(_ coreDataManager : CoreDataManagerProtocol = CoreDataManager.shared) -> HGCAccount {
        let context = coreDataManager.mainContext
        let account = NSEntityDescription.insertNewObject(forEntityName: HGCAccount.entityName, into: context) as! HGCAccount
        account.wallet = self
        account.accountNumber = self.numAccounts
        account.creationDate = Date()
        account.balance = 0
        account.name = ""
        self.numAccounts = account.accountNumber + 1
        return account
    }
    
    func createDefaultAccount(_ coreDataManager : CoreDataManagerProtocol = CoreDataManager.shared) -> HGCAccount {
        let account = self.createNewAccount(coreDataManager)
        account.name = "Default Account"
        return account
    }
    
    @discardableResult
    func createNewExternalAccount(accountID:HGCAccountID, name:String?, _ context : NSManagedObjectContext) -> HGCAccount {
        let account = NSEntityDescription.insertNewObject(forEntityName: HGCAccount.entityName, into: context) as! HGCAccount
        account.wallet = self
        account.accountNumber = -1
        account.creationDate = Date()
        account.balance = 0
        account.name = name ?? ""
        account.accountType = AccountType.external.rawValue
        account.updateAccountID(accountID)
        return account
    }
    
    func allAccounts(accountType:AccountType = .auto, _ orderAsc:Bool = true) -> [HGCAccount] {
        if let set = self.accounts as? Set<HGCAccount> {
            return set.filter({$0.accountType == accountType.rawValue}).sorted { (a1, a2) -> Bool in
                return a1.creationDate!.compare(a2.creationDate!) == (orderAsc ? .orderedAscending : .orderedDescending)
            }
        }
        return [HGCAccount]()
    }
    
    func accountWithPublicKey(_ publicKey:String) -> HGCAccount? {
        if let set = self.accounts?.allObjects as? [HGCAccount] {
            for account in set {
                if publicKey.lowercased() == account.publicKeyString().lowercased() {
                    return account
                }
            }
        }

        return nil
    }
    
    func accountWithAccountID(_ accountID:String) -> HGCAccount? {
         if let set = self.accounts?.allObjects as? [HGCAccount] {
            return set.first { (account) -> Bool in
                if let accID = account.accountID() {
                    if accountID.lowercased() == accID.stringRepresentation().lowercased() {
                        return true
                    }
                }
                return false
            }
        }
        return nil
    }
}
