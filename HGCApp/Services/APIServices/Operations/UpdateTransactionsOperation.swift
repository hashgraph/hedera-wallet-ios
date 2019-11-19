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

extension String : Error {
    
}

class UpdateTransactionsOperation : BaseOperation {
    private var coreDataManager = CoreDataManager.shared
    
    override func main() {
        super.main()
        NotificationCenter.default.post(name: .onTransactionsServiceStateChanged, object: nil)
        let context = coreDataManager.mainContext
        if let wallet = HGCWallet.masterWallet(context) {
            self.fetchHistory(accounts: wallet.allAccounts(), context:context)
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.01) {
            NotificationCenter.default.post(name: .onTransactionsServiceStateChanged, object: nil)
        }
    }
    
    private func fetchHistory(accounts : [HGCAccount], context:NSManagedObjectContext) {
        if accounts.count <= 0 { return }
        let payerAccount = accounts.first!
        var errors = Set<String>()
        for account in accounts {
            if let accID = account.account().accountID {
                do {
                    let fee = try fetchCost(payerAccount, accID)
                    let pair = try grpc.perform(GetAccountRecordParam.init(accID, fee:fee), payerAccount.getTransactionBuilder())
                    let status = pair.response.cryptoGetAccountRecords.header.nodeTransactionPrecheckCode
                    switch status {
                    case .ok:
                        let records = pair.response.cryptoGetAccountRecords.records
                        for record in records {
                            HGCRecord.getOrCreateTxn(pTxnRecord: record, context: context)
                            AppConfigService.defaultService.setConversionRate(receipt: record.receipt)
                        }
                    case .payerAccountNotFound:
                        errors.insert("\(NSLocalizedString("payerAccountNotFound", comment: "")) \(payerAccount.accountID()!.stringRepresentation())")
                        break
                    case .invalidAccountID:
                        errors.insert("\(NSLocalizedString("invalidAccountID", comment: "")) \(accID.stringRepresentation())")
                        break
                    default:
                        errors.insert(status.getErrorMessage())
                    }

                } catch {
                    if let err = error as? String {
                        errors.insert(err)
                    } else {
                        errors.insert(desc(error))
                    }
                }
            }
        }
        
        coreDataManager.saveContext()
        NotificationCenter.default.post(name: .onTransactionsUpdate, object: nil)
        
        if !errors.isEmpty {
            errorMessage = errors.joined(separator: "\n")
        }
    }
    
    private func fetchCost(_ payerAccount:HGCAccount, _ accID:HGCAccountID) throws -> UInt64 {
        do {
            let pair = try grpc.perform(GetAccountRecordParam.init(accID), payerAccount.getTransactionBuilder())
                   let status = pair.response.cryptoGetAccountRecords.header.nodeTransactionPrecheckCode
            switch status {
            case .ok:
                return pair.response.cryptoGetAccountRecords.header.cost
            case .payerAccountNotFound:
                throw "\(NSLocalizedString("payerAccountNotFound", comment: "")) \(payerAccount.accountID()!.stringRepresentation())"
            case .invalidAccountID:
                throw "\(NSLocalizedString("invalidAccountID", comment: "")) \(accID.stringRepresentation())"
            default:
                throw status.getErrorMessage()
            }
            
        } catch {
            Logger.instance.log(message: desc(error), event: .e)
            throw error
        }
    }
}
