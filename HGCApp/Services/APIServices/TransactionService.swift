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

extension Notification.Name {
    static let onTransactionsUpdate = Notification.Name("onTransactionsUpdate")
    static let onTransactionsServiceStateChanged = Notification.Name("onTransactionsServiceStateChanged")
}

class TransactionService {
    
    static let defaultService : TransactionService = TransactionService();
    private var coreDataManager : CoreDataManagerProtocol
    private var operation : UpdateTransactionsOperation?

    init( coreDataManager: CoreDataManagerProtocol = CoreDataManager.shared) {
        self.coreDataManager = coreDataManager
    }
    
    public func isRunning() -> Bool {
        return operation?.isExecuting ?? false
    }
    
    func updateTransactions() {
        if hasOperation() {
            return
        }
        
        let op = UpdateTransactionsOperation()
        op.completionBlock = {
            OperationQueue.main.addOperation {
                if let errorMsg = op.errorMessage {
                    Globals.showGenericErrorAlert(title: "Failed to update transaction records", message: errorMsg)
                }
            }
        }
        BaseOperation.operationQueue.addOperation(op)
        operation = op
    }
    
    func hasOperation() -> Bool {
        for operation in BaseOperation.operationQueue.operations {
            if operation is UpdateTransactionsOperation {
                return true
            }
        }
        return false
    }
}
