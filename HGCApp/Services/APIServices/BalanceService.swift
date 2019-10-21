//
//  BalanceService.swift
//  HGCApp
//
//  Created by Surendra  on 29/11/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let onBalanceUpdate = Notification.Name("onAccountBalanceUpdate")
    static let onBalanceServiceStateChanged = Notification.Name("onBalanceServiceStateChanged")
}

class BalanceService: NSObject {
    static let defaultService : BalanceService = BalanceService();
    private var operation : UpdateBalanceOperation?
    
    func isRunning() -> Bool {
        return operation?.isExecuting ?? false
    }
    
    func updateBalances() {
        if hasOperation() {
            return
        }
        if let accounts = HGCWallet.masterWallet()?.allAccounts() {
            let op = UpdateBalanceOperation(accounts: accounts)
            op.completionBlock = {
                OperationQueue.main.addOperation {
                    if let errorMsg = op.errorMessage {
                        Globals.showGenericErrorAlert(title: "Failed to update balance", message: errorMsg)
                    }
                }
            }
            BaseOperation.operationQueue.addOperation(op)
            operation = op
        }
        
    }
    
    func hasOperation() -> Bool {
        for operation in BaseOperation.operationQueue.operations {
            if operation is UpdateBalanceOperation {
                return true
            }
        }
        return false
    }
}
