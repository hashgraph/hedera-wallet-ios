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

extension URLComponents {
    static func customURLComponents() -> URLComponents {
        var urlComponents = URLComponents.init()
        urlComponents.scheme = "https"
        urlComponents.host = isDevMode ? "hedera.test-app.link" : "hedera.app.link"
        urlComponents.path = isDevMode ? "/OYEncK9sLQ" : "/5vuEEQhtLQ"
        return urlComponents
    }
}

enum URLIntent {
    case transferRequest
    case linkAccountRequest
    case linkAccount
}

protocol IntentParams {
    init?(_ params: [String: Any])
    init?(_ url: URL)
}

protocol URLConvertible {
    func asURL(_ compressed:Bool) -> URL
}

protocol QRCodeConvertible {
    func asQRCode() -> String
    init?(qrCode:String)
}

struct TransferRequestParams: IntentParams, URLConvertible, QRCodeConvertible {
    var account : HGCAccountID
    var amount : Int64?
    var note : String?
    var notify  = false
    var name : String?
    
    init(account:HGCAccountID, name:String? = nil, amount:Int64? = nil, note:String? = nil, notify:Bool = false ) {
        self.account = account
        self.name = name
        self.amount = amount
        self.note = note
        self.notify = notify
    }
    
    init?(qrCode: String) {
        if let url = URL.init(string: qrCode) {
            self.init(url)
        } else {
            return nil
        }
    }
    
    init?(_ paramUrl: URL) {
        var accID : String?
        var isValidUrl = false
        if let urlComponents = URLComponents.init(url: paramUrl, resolvingAgainstBaseURL: false) {
            
            if let items = urlComponents.queryItems {
                for item in items {
                    
                    if item.name == "action"{
                        if item.value == "payRequest" {
                            isValidUrl = true
                        } else {
                            break
                        }
                        
                    } else if item.name == "acc" {
                        accID = item.value
                        
                    } else if item.name == "name" {
                        self.name = item.value
                        
                    } else if item.name == "a" && item.value != nil {
                        self.amount = Int64(item.value!)
                        
                    } else if item.name == "n" {
                        self.note = item.value
                        
                    } else if item.name == "nr" && item.value != nil {
                        self.notify = item.value == "1"
                    }
                }
            }
        }
        
        if isValidUrl, let acc = HGCAccountID.init(from: accID) {
            self.account = acc
        } else {
            return nil
        }
    }
    
    init?(_ params: [String: Any]) {
        let json = JSON(params)
        let acc = json["acc"].stringValue
        guard let action = json["action"].string,
            action == "payRequest",
            let a = HGCAccountID.init(from: acc) else {
                return nil
        }
        self.account = a
        self.name = json["name"].string
        self.note = json["n"].string
        self.amount = json["a"].int64Value
        
    }
    
    func asURL(_ compressed: Bool) -> URL {
        var urlComponents = URLComponents.customURLComponents()
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem.init(name: "acc", value: account.stringRepresentation()))
        queryItems.append(URLQueryItem.init(name: "action", value: "payRequest"))
        if self.name != nil && !(self.name?.isEmpty)! {
            queryItems.append(URLQueryItem.init(name: "name", value: self.name!))
        }
        if self.amount != nil && self.amount! > 0 {
            queryItems.append(URLQueryItem.init(name: "a", value: self.amount?.description))
        }
        if self.note != nil && !(self.note?.isEmpty)! {
            queryItems.append(URLQueryItem.init(name: "n", value: self.note))
        }
        if self.notify {
            queryItems.append(URLQueryItem.init(name: "nr", value:"1"))
        }
        
        urlComponents.queryItems = queryItems
        if let url = urlComponents.url {
            return url
        }
        return urlComponents.url!
    }
    
    func asQRCode() -> String {
        return asURL(false).absoluteString
    }
}

struct CreateAccountRequestParams: IntentParams, URLConvertible, QRCodeConvertible {
    var publicKey : HGCPublickKeyAddress
    var initialAmount : Int64?
    private static let action = "caRequest"
    
    init(publicKey:HGCPublickKeyAddress, initialAmount:Int64? = nil) {
        self.publicKey = publicKey
        self.initialAmount = initialAmount
    }
    
    init?(qrCode: String) {
        if let pk = HGCPublickKeyAddress.init(from: qrCode) {
            self.init(publicKey:pk)
        } else if let url = URL.init(string: qrCode) {
            self.init(url)
        } else {
            return nil
        }
    }
    
    init?(_ paramUrl: URL) {
        var publicKeyString : String?
        var isValidUrl = false
        if let urlComponents = URLComponents.init(url: paramUrl, resolvingAgainstBaseURL: false) {
            
            if let items = urlComponents.queryItems {
                for item in items {
                    
                    if item.name == "action"{
                        if item.value == CreateAccountRequestParams.action {
                            isValidUrl = true
                        } else {
                            break
                        }
                        
                    } else if item.name == "pubKey" {
                        publicKeyString = item.value
                        
                    } else if item.name == "a" && item.value != nil {
                        self.initialAmount = Int64(item.value!)
                    }
                }
            }
        }
        
        if isValidUrl, let pk = HGCPublickKeyAddress.init(from: publicKeyString) {
            self.publicKey = pk
        } else {
            return nil
        }
    }
    
    init?(_ params: [String: Any]) {
        let json = JSON(params)
        let publicKeyString = json["pubKey"].stringValue
        guard let action = json["action"].string,
            action == CreateAccountRequestParams.action,
            let a = HGCPublickKeyAddress.init(from: publicKeyString) else {
                return nil
        }
        self.publicKey = a
        self.initialAmount = json["a"].int64Value
        
    }
    
    func asURL(_ compressed: Bool) -> URL {
        var urlComponents = URLComponents.customURLComponents()
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem.init(name: "pubKey", value: publicKey.stringRepresentation()))
        queryItems.append(URLQueryItem.init(name: "action", value:CreateAccountRequestParams.action))
        if self.initialAmount != nil && self.initialAmount! > 0 {
            queryItems.append(URLQueryItem.init(name: "a", value: self.initialAmount?.description))
        }
        
        urlComponents.queryItems = queryItems
        if let url = urlComponents.url {
            return url
        }
        return urlComponents.url!
    }
    
    func asQRCode() -> String {
        return asURL(false).absoluteString
    }
}

struct LinkAccountRequestParams: IntentParams {
    let callback:URL
    let redirect:String?
    
    init?(_ paramURL: URL) {
        return nil
    }
    
    init?(_ params: [String: Any]) {
        let json = JSON(params)
        guard let action = json["action"].string,
            action == "requestPublicKey",
            let callbackStr = json["callback"].string,
            let callbackUrl = URL.init(string: callbackStr) else {
            return nil
        }
        self.callback = callbackUrl
        self.redirect = json["redirect"].string
    }
}

struct LinkAccountParams: IntentParams {
    var account : HGCAccountID
    var address : HGCPublickKeyAddress
    var redirect:String?
    
    init?(_ paramURL: URL) {
        return nil
    }
    
    init?(_ params: [String: Any]) {
        let json = JSON(params)
        let realmNum = json["realmNum"].int64Value
        let shardNum = json["shardNum"].int64Value
        let accountNum = json["accountNum"].int64Value
        guard let action = json["action"].string,
            (action == "recvAccountId" || action == "setAccountId"),
            (realmNum != 0 || shardNum != 0 || accountNum != 0),
            let publicKey = json["publicKey"].string,
            let address = HGCPublickKeyAddress.init(hex: publicKey) else {
                return nil
        }
        self.account = HGCAccountID.init(shardId: shardNum, realmId: realmNum, accountId: accountNum)
        self.address = address
        self.redirect = json["redirect"].string
    }
}

struct IntentParser {
    let intentParams:IntentParams
    let intent:URLIntent
    
    init?(_ paramUrl:URL) {
        if let i = LinkAccountParams.init(paramUrl) {
            intent = .linkAccount
            intentParams = i
        } else if let i = LinkAccountRequestParams.init(paramUrl) {
            intent = .linkAccountRequest
            intentParams = i
        } else if let i = TransferRequestParams.init(paramUrl) {
            intent = .transferRequest
            intentParams = i
        } else {
            return nil
        }
    }
    
    init?(_ params:[String:Any]) {
        if let i = LinkAccountParams.init(params) {
            intent = .linkAccount
            intentParams = i
        } else if let i = LinkAccountRequestParams.init(params) {
            intent = .linkAccountRequest
            intentParams = i
        } else if let i = TransferRequestParams.init(params) {
            intent = .transferRequest
            intentParams = i
        } else {
            return nil
        }
    }
}

class TXNRequestShareItem: NSObject, UIActivityItemSource {
    
    var url : URL
    init(url: URL) {
        self.url = url
    }
    
    func htmlLink() -> String {
        let string = "<html><body><a href=\"\(self.url.absoluteString)\">\(self.url.absoluteString)</a></body></html>"
        return string
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return self.url
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        if let type = activityType {
            if type == .mail || type.rawValue.lowercased().contains("gmail") {
                return self.htmlLink()
            } 
        }
        
        return self.url
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return ""
    }
    
}
