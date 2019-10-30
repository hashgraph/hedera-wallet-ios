//
//  MigrateToBip32Operation.swift
//  HGCApp
//
//  Created by Surendra on 01/06/19.
//  Copyright © 2019 HGC. All rights reserved.
//

import UIKit

class MigrateToBip32Operation: BaseOperation {
    enum MigrateStatus {
        case failedUpdate, failedNetwork, failedVerfiyKeyUpdate, failedConsensus, success
    }
    
    let oldKey:HGCKeyPairProtocol
    let newKey:HGCKeyPairProtocol
    let accountID:HGCAccountID
    let verifyOnly:Bool

    var mStatus:MigrateStatus = .failedUpdate
    
    init(oldKey:HGCKeyPairProtocol, newKey:HGCKeyPairProtocol,  accountID:HGCAccountID, verifyOnly:Bool = false) {
        self.oldKey = oldKey
        self.newKey = newKey
        self.accountID = accountID
        self.verifyOnly = verifyOnly
        super.init()
        grpc.timeout = 10
    }
    
    override func main() {
        super.main()
        
        do {
            if verifyOnly {
                _ = try getAccountInfo(keyPair: newKey)
                // Migration success
                mStatus = .success
                
            } else {
                try updateAccount(keyPair: oldKey, bip32KeyPair: newKey)
                _ = try getAccountInfo(keyPair: newKey)
                // Migration success
                mStatus = .success
            }
            
        } catch {
            Logger.instance.log(message:desc(error), event: .e)
            if error.isRPCError {
                mStatus = .failedNetwork
            }
            self.errorMessage = desc(error)
        }
        
    }
    
    private func getAccountInfo(keyPair:HGCKeyPairProtocol) throws -> Bool {
        let txnBuilder = TransactionBuilder.init(payerCredentials: keyPair, payerAccount: accountID)
        let cost = try getAccountInfoCost(txnBuilder: txnBuilder)
        let pair = try grpc.perform(GetAccountInfoParam.init(accountID, fee: cost), txnBuilder)
        let status = pair.response.cryptoGetInfo.header.nodeTransactionPrecheckCode
        switch status {
        case .ok:
            return true
        default:
            mStatus = .failedVerfiyKeyUpdate
            throw status.getErrorMessage()
        }
    }
    
    private func getAccountInfoCost(txnBuilder:TransactionBuilder) throws -> UInt64 {
         let pair = try grpc.perform(GetAccountInfoParam.init(accountID), txnBuilder)
                let status = pair.response.cryptoGetInfo.header.nodeTransactionPrecheckCode
         switch status {
         case .ok:
             return pair.response.cryptoGetInfo.header.cost
         default:
             throw status.getErrorMessage()
         }
     }
    
    private func updateAccount(keyPair:HGCKeyPairProtocol, bip32KeyPair:HGCKeyPairProtocol) throws {
        let txnBuilder = TransactionBuilder.init(payerCredentials: keyPair, payerAccount: accountID)
        let param = UpdateAccountParam.init(bip32KeyPair)
        let pair = try grpc.perform(param, txnBuilder)
        let response = pair.response
        let txn = pair.transaction
        let status = response.nodeTransactionPrecheckCode
        switch status {
        case .ok:
            let receiptRes = try getReceipt(acc: accountID, txnID: txn.transactionBody().transactionID)
            let status = receiptRes.transactionGetReceipt.receipt.status
            if status != .success {
                throw status.getErrorMessage()
            } else {
                mStatus = .failedConsensus
            }
            
        default:
            mStatus = .failedUpdate
            throw status.getErrorMessage()
        }
    }
}
