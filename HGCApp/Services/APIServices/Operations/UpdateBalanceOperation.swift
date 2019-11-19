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
import SwiftGRPC

class UpdateBalanceOperation : BaseOperation {
    private var coreDataManager = CoreDataManager.shared
    var accounts:[HGCAccount]
    
    init(accounts:[HGCAccount]) {
        self.accounts = accounts
    }
    
    override func main() {
        super.main()
        NotificationCenter.default.post(name: .onBalanceServiceStateChanged, object: nil)
        self.fetchBalance(accounts: accounts)
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.01) {
            NotificationCenter.default.post(name: .onBalanceServiceStateChanged, object: nil)
        }
        
        DispatchQueue.main.async {
            self.coreDataManager.saveContext()
        }
        
    }
    
    private func fetchBalance(accounts : [HGCAccount]) {
        if accounts.count <= 0 { return }
        let payerAccountID = HGCAccountID.init(from: "0.0.0")!
        var errors = Set<String>()
        for account in accounts {
            if let accID = account.accountID() {
                do {
                    let txnBuilder = TransactionBuilder.init(payerCredentials: nil, payerAccount: payerAccountID)
                    let param = GetBalanceParam.init(accID)
                    let response = try grpc.perform(param, txnBuilder)
                    let status = response.response.cryptogetAccountBalance.header.nodeTransactionPrecheckCode
                    switch status {
                    case .ok:
                        let bal = response.response.cryptogetAccountBalance
                        account.balance = Int64(bal.balance)
                        account.lastBalanceCheck = Date()
                        break
                    case .invalidAccountID, .accountDeleted, .accountIDDoesNotExist:
                        account.clearData()
                        fallthrough
                    default:
                        errors.insert("\(status.getErrorMessage()) \(accID.stringRepresentation())")
                    }
                    
                } catch {
                    errors.insert(desc(error))
                    Logger.instance.log(message:desc(error), event: .e)
                    break
                }
            }
        }
        if !errors.isEmpty {
            errorMessage = errors.joined(separator: "\n")
        }
    }
}
