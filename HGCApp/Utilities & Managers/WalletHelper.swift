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
import Security
import CoreData

class WalletHelper: NSObject {
    public static let onboardDidSuccess = Notification.Name("onboardDidSuccess")
    
    static func keyChain() -> HGCKeyChainProtocol? {
        guard let wallet = HGCWallet.masterWallet(),
            let seed = SecureAppSettings.default.getSeed() else {
            return nil
        }
        switch wallet.keyDerivationType {
        case .hgc:
            return EDKeyChain.init(hgcSeed: HGCSeed.init(entropy: seed))
        case .bip32:
            return EDBip32KeyChain.init(hgcSeed: HGCSeed.init(entropy: seed))
        }
    }
    
    static func getHGCSeed() -> HGCSeed? {
        guard let seed = SecureAppSettings.default.getSeed(), let hgcSeed = HGCSeed.init(entropy: seed) else {
                return nil
        }
        
        return hgcSeed
    }
    
    static func accountID() -> HGCAccountID? {
        return HGCWallet.masterWallet()?.allAccounts().first?.accountID()
    }
    
    static func syncData() {
        TransactionService.defaultService.updateTransactions()
        BalanceService.defaultService.updateBalances()
    }
    
    static func syncBalance() {
        BalanceService.defaultService.updateBalances()
    }
    
    static func isOnboarded() -> Bool {
        return HGCWallet.masterWallet() != nil
    }
    
    static func canDoBip32Migration() -> Bool {
        if let wallet = HGCWallet.masterWallet() {
            if wallet.keyDerivationType == .hgc, wallet.allAccounts().first?.accountID() != nil {
                return true
            }
        }
        return false
    }

    static func onboard(keyDerivation:KeyDerivation, seed:HGCSeed, accID:HGCAccountID? = nil) -> Bool {
        SecureAppSettings.default.setSeed(seed.entropy)
        HGCWallet.createMasterWallet(signatureAlgorith: Int16(SignatureOption.ED25519.rawValue), accountID: accID, keyDerivation: keyDerivation)
        CoreDataManager.shared.saveContext()
        return true
    }
    
    static func confirmQuit() {
        Globals.showConfirmationAlert(title: NSLocalizedString("Confirm Quit?", comment: ""), message: NSLocalizedString("Are you sure you want to exit?", comment: ""), cancelButtonTitle:NSLocalizedString( "No", comment: ""), actionButtonTitle: NSLocalizedString("Yes", comment: ""), onConfirm: {
            quit()
        }, onDismiss: nil)
    }
    
    static func quit() {
        exit(0)
    }
    
    static func defaultPayerAccount(_ context : NSManagedObjectContext = CoreDataManager.shared.mainContext) -> HGCAccount? {
        return HGCWallet.masterWallet(context)?.allAccounts().first
    }
    
    static func resetWallet() throws {
        // Clear keychain items
        try SecureAppSettings.default.clear()
      
        // Clear DB
        try CoreDataManager.shared.clear()
        
        // Clear app seetings
        AppSettings.clear()
        
        // Rebuild Nodes
        APIAddressBookService.defaultAddressBook.loadAddressBook()
    }
}
