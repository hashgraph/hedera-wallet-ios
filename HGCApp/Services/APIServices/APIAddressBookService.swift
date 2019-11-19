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
import SwiftyJSON
import CoreData

class APIAddressBookService {
    static let defaultAddressBook : APIAddressBookService = APIAddressBookService.init();
    static let updateFreq:TimeInterval = 60 * 60 * 24 * 2 // every 2 days
    
    func loadAddressBook(_ context:NSManagedObjectContext = CoreDataManager.shared.mainContext) {
        let nodes = HGCNode.getAllNodes(activeOnly: true, context: context)
        if nodes.count <= 0 {
            loadListFromFile(context)
        }
        
        /*DispatchQueue.main.asyncAfter(deadline:.now() + 5) {
            if AppSettings.getLastSyncNodesAt() == nil ||  Date().timeIntervalSince(AppSettings.getLastSyncNodesAt()!) > APIAddressBookService.updateFreq {
                self.updateAddressBook(nil)
            }
        }*/
    }
    
    private func loadListFromFile(_ context:NSManagedObjectContext) {
        let url = Bundle.main.url(forResource: nodeListFileName, withExtension: "")
        do {
            let data = try NSData(contentsOf: url!, options: NSData.ReadingOptions())
            let object = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments)
            if let items = object as? [[String : Any]] {
                var newNodes = [HGCNodeVO]()
                items.forEach { (map) in
                    if let node = HGCNodeVO.init(map:map) {
                        newNodes.append(node)
                    }
                }
                syncDB(newNodes, context)
            }
        } catch {
            
        }
    }
    
    private func syncDB(_ newNodes:[HGCNodeVO], _ context:NSManagedObjectContext) {
        HGCNode.deleteAll(context: context)
        newNodes.forEach { (node) in
            HGCNode.addNode(nodeVO: node, context: context)
        }
        CoreDataManager.save(context: context)
    }
    
    func updateAddressBook(context:NSManagedObjectContext, _ onComplete:((_ error:String?) -> Void)?) {
        if let payer = WalletHelper.defaultPayerAccount(context), payer.accountID() != nil {
            let op = FileContentOperation.init(payerAccount: payer, fileNum: fileNumAddressBook)
            updateAddressBook(op: op, context: context, onComplete)
        }
    }
    
    func updateAddressBook(op:FileContentOperation, context:NSManagedObjectContext, _ onComplete:((_ error:String?) -> Void)?) {
        let queue = BaseOperation.operationQueue
        op.completionBlock = {
            DispatchQueue.main.async {
                if let content = op.fileContent, !content.isEmpty {
                    do {
                        let addressBook = try Proto_NodeAddressBook(serializedData: content)
                        var newNodes = [HGCNodeVO]()
                        for address in addressBook.nodeAddress {
                            if let nodeVO = HGCNodeVO.init(address) {
                                newNodes.append(nodeVO)
                            }
                        }
                        self.syncDB(newNodes, context)
                        AppSettings.setLastSyncNodesAt(Date())
                        if onComplete != nil {
                            onComplete!(nil)
                        }
                    } catch {
                        let e = "Failed to update address book: \(error)"
                        Logger.instance.log(message:e , event: .e)
                        if onComplete != nil {
                            onComplete!("Failed to update address book")
                        }
                    }
                } else {
                    if onComplete != nil {
                        var e = "Failed to update address book."
                        if let error = op.errorMessage {
                            e = e + "\n" + error
                        }
                        onComplete!(e)
                    }
                }
            }
        }
        queue.addOperation(op)
    }
    
//    func updateAddressBook(_ onComplete:((_ error:String?) -> Void)?) {
//        let addressBook = try! Proto_NodeAddressBook(serializedData: "0a170a0e33342e3139372e3231302e3138361a05302e302e330a150a0c332e3231392e3235322e35321a05302e302e340a170a0e33352e3135332e3132332e3133321a05302e302e350a160a0d332e3232302e3139362e3135361a05302e302e36".hexadecimal()!)
//        var newNodes = [HGCNodeVO]()
//        for address in addressBook.nodeAddress {
//            if let nodeVO = HGCNodeVO.init(address) {
//                newNodes.append(nodeVO)
//            }
//        }
//        self.syncDB(newNodes)
//        AppSettings.setLastSyncNodesAt(Date())
//    }
    
    func getActiveNodes(_ context:NSManagedObjectContext = CoreDataManager.shared.mainContext) -> [HGCNodeVO] {
        let nodes = HGCNode.getAllNodes(activeOnly: true, context: context).map({ (node) -> HGCNodeVO in
            return node.nodeVO()
        })
        if nodes.count > 0 {
            return nodes
        }
        // if no nodes return inactive node
        return HGCNode.getAllNodes(activeOnly: false, context: context).map({ (node) -> HGCNodeVO in
            return node.nodeVO()
        })
    }
    
    func getAddressBookString(_ context:NSManagedObjectContext = CoreDataManager.shared.mainContext) -> String {
        var items = [[String: Any?]]()
        let allNodes = HGCNode.getAllNodes(activeOnly: false, context: context)
        allNodes.forEach { (node) in
            var map = [String:Any?]()
            let nodeVO = node.nodeVO()
            map["ip"] = nodeVO.host
            map["port"] = nodeVO.port
            map["accountID"] = nodeVO.accountID.stringRepresentation()
            items.append(map)
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: items, options: JSONSerialization.WritingOptions.init(rawValue: 0))
            let string = String.init(data: data, encoding: .utf8)
            return string!
        } catch {
            Logger.instance.log(message: error.localizedDescription, event: .e)
            return ""
        }
    }

}

class HGCNodeVO {
    let host: String
    let port: Int32
    let accountID:HGCAccountID

    init(host:String, port:Int32, accountID:HGCAccountID) {
        self.host = host
        self.port = port
        self.accountID = accountID
    }
    
    init?(_ address:Proto_NodeAddress) {
        guard let h = String.init(data: address.ipAddress, encoding: .utf8), let a = String.init(data: address.memo, encoding: .utf8), let aid = HGCAccountID.init(from: a) else {
            return nil
        }
        self.port = address.portno == 0 ? defaultPort : address.portno
        self.host = h
        self.accountID = aid
    }
    
    init?(map:[String:Any]) {
        let json = JSON(map)
        self.host = json["host"].stringValue
        self.port = json["port"].int32Value
        self.accountID = HGCAccountID.init(shardId: json["shardNum"].int64Value, realmId: json["realmNum"].int64Value, accountId: json["accountNum"].int64Value)
    }
    
    func address() -> String {
        return host + ":" + port.description
    }
}
