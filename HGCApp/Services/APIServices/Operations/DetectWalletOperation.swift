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
            let cost = try getAccountInfoCost(txnBuilder: txnBuilder)
            let pair = try grpc.perform(GetAccountInfoParam.init(accountID, fee: cost), txnBuilder)
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
    
}
