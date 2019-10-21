//
//  HGCAccount+CoreDataClass.swift
//  HGCApp
//
//  Created by Surendra  on 23/11/17.
//  Copyright © 2017 HGC. All rights reserved.
//
//

import Foundation
import CoreData

extension Notification.Name {
    static let onAccountUpdate = Notification.Name("onAccountUpdate")
}

extension HGCAccount {
    public static let entityName = "Account"
    
    func key() -> HGCKeyPairProtocol {
        return self.wallet!.keyChain()!.key(at: Int(self.accountNumber))
    }
    
    func getTransactionBuilder() -> TransactionBuilder {
        return TransactionBuilder.init(payerCredentials: key(), payerAccount: accountID()!)
    }
    
    func sign(_ data: Data) -> Data {
        let signature = self.key().signMessage(data)
        return signature!
    }
    
    func publicKeyData() -> Data {
        if self.publicKey == nil {
            self.publicKey = (self.key().publicKeyData)!
        }
        return self.publicKey! as Data
    }
    
    func publicKeyString() -> String {
        return self.publicKeyData().hex
    }
    
    func privateKeyString() -> String {
        let data  = (self.key().privateKeyData)!
        return data.hex
    }
    
    var accountTypeE: AccountType {
        if let s = accountType, let t = AccountType.init(rawValue: s) {
            return t
        }
        return .auto
    }
    
    @discardableResult
    func createTransaction(toAccountID:HGCAccountID?, txn:Proto_Transaction, _ coreDataManager : CoreDataManagerProtocol = CoreDataManager.shared) -> HGCRecord {
        let context = coreDataManager.mainContext
        let record = HGCRecord.getOrCreateTxn(txn:txn, context:context)
        record.fromAccountID = self.accountID()?.stringRepresentation()
        coreDataManager.saveContext()
        return record
    }
    
    func getAllTxn(context:NSManagedObjectContext = CoreDataManager.shared.mainContext) -> [TransactionVO] {
        if let accID = self.accountID() {
            if let result = HGCRecord.allTxn(accID.stringRepresentation(), context) {
                return result
            }
        }
        
        return [TransactionVO]()
    }
    
    // MARK:- Smart Contract Token
    @discardableResult
    func createToken(token:TokenVO, context:NSManagedObjectContext = CoreDataManager.shared.mainContext) -> SCToken {
        let object = NSEntityDescription.insertNewObject(forEntityName: SCToken.entityName, into: context) as! SCToken
        //object.address = token.address
        object.contractID = token.contractID.stringRepresentation()
        object.name = token.name
        object.symbol = token.symbol
        object.decimals = token.decimals
        object.account = self
        return object
    }
}

extension HGCAccount {
    func publicKeyAddress() -> HGCPublickKeyAddress {
        return HGCPublickKeyAddress.init(publicKeyData: self.publicKeyData(), type: self.wallet!.signatureOption())!
    }
    
    func accountID() -> HGCAccountID? {
        if shardId > 0 || realmId > 0 || accountId > 0 {
            return HGCAccountID.init(shardId: shardId, realmId: realmId, accountId: accountId)
        } else {
            return nil
        }
    }
    
    func updateAccountID(_ accId:HGCAccountID) {
        self.shardId = accId.shardId
        self.realmId = accId.realmId
        self.accountId = accId.accountId
    }
    
    func account() -> AccountVO {
        if let accID = accountID() {
            let acc = AccountVO.init(accountID: accID)
            return acc
            
        } else {
            let acc = AccountVO.init(address: publicKeyAddress())
            return acc
        }
    }
    
    func toJSONString(includePrivateKey:Bool) -> String {
        if let data = toJSONData(includePrivateKey: includePrivateKey) {
            let string = String.init(data: data, encoding: .utf8)!
            return string
        } else {
            return ""
        }
    }
    
    func toJSONData(includePrivateKey:Bool) -> Data? {
        var map = [String:Any]()
        map["accountLabel"] = name
        map["accountIndex"] = accountNumber
        if let accID = accountID() {
            map["accountID"] = accID.stringRepresentation()
        }
        map["publicKey"] = publicKeyString()
        if includePrivateKey {
            map["privateKey"] = privateKeyString()
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: map, options: JSONSerialization.WritingOptions.init(rawValue: 0))
            return data
        } catch {
            Logger.instance.log(message: error.localizedDescription, event: .e)
            return nil
        }
    }
    
    func clearData()  {
        // clear balance and records
        balance = 0
        lastBalanceCheck = nil
        let isDefaultAcc = self.accountNumber == 0
        if let accId = self.accountID(), let contextObj = self.managedObjectContext {
            if let records = HGCRecord.allTxnRecords(isDefaultAcc ? nil : accId.stringRepresentation(), contextObj) {
                for record in records {
                    contextObj.delete(record)
                }
            }
        }
    }
}
