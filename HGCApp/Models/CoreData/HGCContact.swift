//
//  HGCContact+CoreDataClass.swift
//  HGCApp
//
//  Created by Surendra  on 23/11/17.
//  Copyright © 2017 HGC. All rights reserved.
//
//

import Foundation
import CoreData

extension HGCContact {
    public static let entityName  = "Contact"
    
    static func getContact(_ address:String) -> HGCContact? {
        let context = CoreDataManager.shared.mainContext
        let fetchRequest = HGCContact.fetchRequest() as NSFetchRequest<HGCContact>
        fetchRequest.predicate = NSPredicate(format: "publicKeyID == %@", address)
        let result = try? context.fetch(fetchRequest)
        if result != nil && (result?.count)! > 0 {
            return result?.first
        }
        return nil
    }
    
    static func getAllContacts() -> [HGCContact] {
        let context = CoreDataManager.shared.mainContext
        let fetchRequest = HGCContact.fetchRequest() as NSFetchRequest<HGCContact>
        let sortDesc1 = NSSortDescriptor.init(key: "name", ascending: false)
        fetchRequest.sortDescriptors = [sortDesc1]
        let result = try? context.fetch(fetchRequest)
        if result != nil {
            return result!
        }
        return []
    }
    
    static func alias(_ accID:String) -> String? {
        if let alias = HGCContact.getContact(accID) {
            return alias.name
        } else if let account = HGCWallet.masterWallet()?.accountWithAccountID(accID) {
            return account.name
        }
        return nil
    }
    
    @discardableResult
    static func addAlias(name:String?, address:String, host:String? = nil) -> HGCContact? {
        if address.isEmpty { return nil}
        if let alias = HGCContact.getContact(address) {
            alias.name = name
            if let host = host {
                alias.host = host
            }
            
            CoreDataManager.shared.saveContext()
            return alias
            
        } else {
            let context = CoreDataManager.shared.mainContext
            let contact = NSEntityDescription.insertNewObject(forEntityName: HGCContact.entityName, into: context) as! HGCContact
            contact.name = name
            contact.publicKeyID = address
            contact.host = host
            CoreDataManager.shared.saveContext()
            return contact
        }
        
    }
    
    private var infoMap:[String:Any] {
        do {
            return try JSONSerialization.jsonObject(with: (self.info ?? "").data(using: .utf8)!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: Any]
        } catch {
            return [:]
        }
    }
    
    private func saveInfo(map:[String:Any]) {
        do {
            let data = try JSONSerialization.data(withJSONObject: map, options: JSONSerialization.WritingOptions.init(rawValue: 0))
            info = String.init(data: data, encoding: .utf8)
        } catch {
            
        }
    }
    
    
    var host:String? {
        get {
            return infoMap["host"] as? String
        }
        set {
            var infoDict = infoMap
            infoDict["host"] = newValue
            saveInfo(map: infoDict)
        }
    }
}
