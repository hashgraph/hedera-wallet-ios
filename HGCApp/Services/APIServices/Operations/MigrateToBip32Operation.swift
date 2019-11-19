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
