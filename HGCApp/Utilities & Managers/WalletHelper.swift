//
//  WalletHelper.swift
//  HGCApp
//
//  Created by Surendra  on 24/10/17.
//  Copyright © 2017 HGC. All rights reserved.
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
