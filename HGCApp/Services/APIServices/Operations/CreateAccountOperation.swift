//
//  CreateAccountOperation.swift
//  HGCApp
//
//  Created by Surendra on 28/07/19.
//  Copyright © 2019 HGC. All rights reserved.
//

import UIKit

class CreateAccountOperation: BaseOperation {
    let params: CreateAccountParams
    let fromAccount:HGCAccount
    private (set) var accountID: HGCAccountID? = nil
    
    init(params: CreateAccountParams, fromAccount:HGCAccount) {
        self.params = params
        self.fromAccount = fromAccount
    }
    
    override func main() {
        super.main()
        
        do {
            let pair = try grpc.perform(params, fromAccount.getTransactionBuilder())
            Logger.instance.log(message: pair.response.textFormatString(), event: .i)
            switch pair.response.nodeTransactionPrecheckCode {
            case .ok:
                let savedTxn = self.saveTransaction(txn:pair.transaction)
                do {
                    let receiptRes = try getReceipt(acc: fromAccount.accountID()!, txnID: pair.transaction.transactionBody().transactionID)
                    savedTxn.receipt = try? receiptRes.serializedData()
                    let status = receiptRes.transactionGetReceipt.receipt.status
                    if status != .success {
                        errorMessage = status.getErrorMessage()
                    } else {
                        let accID = receiptRes.transactionGetReceipt.receipt.accountID.hgcAccountID()
                        accountID = accID
                        saveContact(accountID: accID)
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
        let record = fromAccount.createTransaction(toAccountID: nil, txn:txn)
        return record
    }
    
    func saveContact(accountID:HGCAccountID) {
        HGCContact.addAlias(name: "", address: accountID.stringRepresentation())
    }
}
