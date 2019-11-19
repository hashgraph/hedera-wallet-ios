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

struct TokenVO {
    let contractID: HGCAccountID
    let name: String
    let symbol: String
    let decimals: Int16
    init?(map:[String:Any]) {
        guard let idStr = map["contractID"] as? String,
            let accID = HGCAccountID.init(from: idStr),
            let name = map["name"] as? String,
            let symbol = map["symbol"] as? String,
            let decimals = map["decimals"] as? Int16 else {
                return nil
        }
        self.init(contractID:accID, name: name, symbol: symbol, decimals: decimals)
    }
    
    init(contractID:HGCAccountID, name:String, symbol:String, decimals:Int16) {
        self.contractID = contractID
        self.name = name
        self.symbol = symbol
        self.decimals = decimals
    }
    
    func multiplier() -> Double {
        return pow(Double(10), Double(decimals))
    }
}
