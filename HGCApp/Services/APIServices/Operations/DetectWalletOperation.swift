//
//  DetectWalletOperation.swift
//  HGCApp
//
//  Created by Surendra on 31/05/19.
//  Copyright © 2019 HGC. All rights reserved.
//

import UIKit

class DetectWalletOperation: BaseOperation {
    let entropy:HGCSeed
    let accountID:HGCAccountID
    var keyDerivation:KeyDerivation? = nil
    
    init(entropy:HGCSeed, accountID:HGCAccountID) {
        self.entropy = entropy
        self.accountID = accountID
    }
    
    override func main() {
        super.main()
        let bip32Key = EDBip32KeyChain.init(hgcSeed: entropy).key(at: 0)!
        let customKey = EDKeyChain.init(hgcSeed: entropy).key(at: 0)!
        do {
            _ = try getAccountInfo(keyPair: customKey)
            keyDerivation = .hgc
            
        } catch {
            self.errorMessage = desc(error)
            do {
                _ = try getAccountInfo(keyPair: bip32Key)
                keyDerivation = KeyDerivation.bip32
            } catch  {
                self.errorMessage = desc(error)
            }
        }
    }
    
    private func getAccountInfo(keyPair:HGCKeyPairProtocol) throws -> Bool {
        do {
            let txnBuilder = TransactionBuilder.init(payerCredentials: keyPair, payerAccount: accountID)
            let pair = try grpc.perform(GetAccountInfoParam.init(accountID), txnBuilder)
            let status = pair.response.cryptoGetInfo.header.nodeTransactionPrecheckCode
            switch status {
            case .ok:
                return true
            default:
                throw status.getErrorMessage()
            }
            
        } catch {
            Logger.instance.log(message:desc(error), event: .e)
            throw error
        }
    }
}
