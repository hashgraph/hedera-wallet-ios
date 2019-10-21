//
//  UpdateBalanceOperation.swift
//  HGCApp
//
//  Created by Surendra on 26/08/18.
//  Copyright © 2018 HGC. All rights reserved.
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
                    case .invalidAccountID:
                        account.clearData()
                        errors.insert("\(NSLocalizedString("invalidAccountID", comment: "")) \(accID.stringRepresentation())")
                    case .payerAccountNotFound:
                        account.clearData()
                        errors.insert("\(NSLocalizedString("payerAccountNotFound", comment: "")) \(accID.stringRepresentation())")
                        break
                    default:
                        errors.insert(status.getErrorMessage())
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
