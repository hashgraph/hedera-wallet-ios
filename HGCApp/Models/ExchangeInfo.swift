//
//  Copyright 2019-2020 Hedera Hashgraph LLC
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

/// Helper data to facilitate an exchange of HBAR between this wallet and another.
struct ExchangeInfo: Equatable {

    let accountID: HGCAccountID
    let name: String
    let host: String
    let memo: String?

    /// Load from a QR code represented as a string.
    static func fromQRCode(_ code: String) -> ExchangeInfo? {
        let components = code.components(separatedBy: ",")
        guard components.count > 3,
            let accountID = HGCAccountID.init(from: components[3]) else {
            return nil
        }
        
        var memo: String? = nil
        if components.count > 4 {
            memo = components[4]
        }
        let name = components[0]
        let host = components[1] + ":" + components[2]
        return ExchangeInfo(accountID: accountID, name: name, host: host, memo:memo)
    }
    
    static func toHttpURL(host: String) -> URL? {
        if host.starts(with: "http://") || host.starts(with: "https://") {
            return URL.init(string: host)
        }
        return URL.init(string: "http://" + host)
    }
}
