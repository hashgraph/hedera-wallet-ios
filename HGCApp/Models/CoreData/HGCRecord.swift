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

extension HGCRecord {
    public static let entityName = "Record"
    
    class func allTxn(_ accountID:String?, _ context:NSManagedObjectContext) -> [TransactionVO]? {
        let result = allTxnRecords(accountID, context)
        if result != nil {
            var items = [TransactionVO]()
            for item in result! {
                if let t = TransactionVO.from(item) {
                    items.append(t)
                }
            }
            return items
        }
        
        return nil
    }
    
    class func allTxnRecords(_ accountID:String?, _ context:NSManagedObjectContext) -> [HGCRecord]? {
        let fetchRequest = HGCRecord.fetchRequest() as NSFetchRequest<HGCRecord>
        if accountID != nil {
            let predicate1 = NSPredicate(format: "fromAccountID == %@", accountID!)
            let predicate2 = NSPredicate(format: "toAccountID == %@", accountID!)
            let predicate = NSCompoundPredicate.init(orPredicateWithSubpredicates: [predicate1,predicate2])
            fetchRequest.predicate = predicate
        }
        
        let sortDesc1 = NSSortDescriptor.init(key: "createdDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDesc1]
        let result = try? context.fetch(fetchRequest)
        return result
    }
    
    class func createNewTxn(txnVO:TransactionVO, context: NSManagedObjectContext = CoreDataManager.shared.mainContext) -> HGCRecord {
        let txn = NSEntityDescription.insertNewObject(forEntityName: HGCRecord.entityName, into: context) as! HGCRecord
        txn.createdDate = Date()
        txn.txnID = txnVO.txnID
        txn.fromAccountID = txnVO.fromAccountID
        txn.toAccountID = txnVO.toAccountID
        return txn
    }
    
    @discardableResult
    class func getOrCreateTxn(txn:Proto_Transaction, context: NSManagedObjectContext = CoreDataManager.shared.mainContext) -> HGCRecord {
        let vo = TransactionVO.init(txn)!
        let idStr = vo.txnID
        let fetchRequest = HGCRecord.fetchRequest() as NSFetchRequest<HGCRecord>
        fetchRequest.predicate = NSPredicate(format: "txnID == %@", idStr)

        let result = try? context.fetch(fetchRequest)
        if result == nil || result?.count == 0 {
            let t = self.createNewTxn(txnVO:vo, context: context)
            t.transaction = try? txn.serializedData()
            return t
        } else {
            let t  = (result?.first)!
            t.transaction = try? txn.serializedData()
            return t
        }
    }
    
    @discardableResult
    class func getOrCreateTxn(pTxnRecord:Proto_TransactionRecord, context: NSManagedObjectContext = CoreDataManager.shared.mainContext) -> HGCRecord? {
        if let vo = TransactionVO.init(pTxnRecord) {
            let fetchRequest = HGCRecord.fetchRequest() as NSFetchRequest<HGCRecord>
            fetchRequest.predicate = NSPredicate(format: "txnID == %@", vo.txnID)
            let result = try? context.fetch(fetchRequest)
            if result == nil || result?.count == 0 {
                let t = self.createNewTxn(txnVO:vo,context: context)
                t.response = try? pTxnRecord.serializedData()
                return t
            } else {
                let t = (result?.first)!
                t.response = try? pTxnRecord.serializedData()
                return t
            }
        }
        return nil
    }
}

extension Proto_TransactionID {
    func protoHexRepresentation() -> String! {
        return try! serializedData().hex
    }
}

extension Proto_TransactionID {
    var stringRepresentation:String {
        return [accountID.shardNum.description, accountID.realmNum.description, accountID.accountNum.description].joined(separator: ".") + "@" + [transactionValidStart.nanos.description, transactionValidStart.nanos.description].joined(separator: ".")
    }

}
