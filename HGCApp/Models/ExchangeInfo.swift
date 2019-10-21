//
//  ExchangeInfo.swift
//  HGCApp
//
//  Created by Surendra on 01/05/19.
//  Copyright © 2019 HGC. All rights reserved.
//

import UIKit

struct ExchangeInfo {
    let accountID:HGCAccountID
    let name:String
    let host:String
    let memo:String?
    
    static func fromQRCode(_ code:String) -> ExchangeInfo? {
        let components = code.components(separatedBy: ",")
        guard components.count > 3,
            let accountID =  HGCAccountID.init(from: components[3]) else {
            return nil
        }
        
        var memo:String? = nil
        if components.count > 4 {
            memo = components[4]
        }
        let name = components[0]
        let host = components[1] + ":" + components[2]
        return ExchangeInfo(accountID: accountID, name: name, host: host, memo:memo)
    }
    
    static func toHttpURL(host:String) -> URL? {
        if host.starts(with: "http://") || host.starts(with: "https://") {
            return URL.init(string: host)
        }
        return URL.init(string: "http://" + host)
    }
}
