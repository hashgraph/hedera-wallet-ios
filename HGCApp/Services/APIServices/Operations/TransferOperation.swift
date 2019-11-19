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

class TransferOperation: BaseOperation {
    let param: TransferParam
    let fromAccount: HGCAccount

    init(fromAccount: HGCAccount, param:TransferParam) {
        self.param = param
        self.fromAccount = fromAccount
    }
    
    override func main() {
        super.main()
        
        do {
            let pair = try grpc.perform(param, fromAccount.getTransactionBuilder())
            switch pair.response.nodeTransactionPrecheckCode {
            case .ok:
                let savedTxn = self.saveTransaction(txn:pair.transaction)
                do {
                    let receiptRes = try getReceipt(acc: fromAccount.accountID()!, txnID: pair.transaction.transactionBody().transactionID)
                    savedTxn.receipt = try? receiptRes.serializedData()
                    let status = receiptRes.transactionGetReceipt.receipt.status
                    if status != .success {
                        errorMessage = status.getErrorMessage()
                    }

                } catch {
                    errorMessage = desc(error)
                }
                
            default:
                self.errorMessage = pair.response.nodeTransactionPrecheckCode.getErrorMessage()
            }
            
        } catch {
            Logger.instance.log(message: desc(error), event: .e)
            errorMessage  = desc(error)
        }
        
        CoreDataManager.shared.saveContext()
    }
    
    func saveTransaction(txn: Proto_Transaction) -> HGCRecord {
        let record = self.fromAccount.createTransaction(toAccountID: param.toAccount, txn:txn)
        HGCContact.addAlias(name: param.toAccountName, address: param.toAccount.stringRepresentation())
        return record
    }
}
