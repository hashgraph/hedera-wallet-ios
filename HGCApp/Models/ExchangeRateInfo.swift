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

import SwiftyJSON

enum Exchange: String {
      case bittrex
      case okcoin
      case liquid
}

class ExchangeRateInfo: NSObject {
    let exchangeName:String
    let lastUpdatedDate:Date?
    var last:Double?
    var bid:Double?
    var ask:Double?
    
    init(exchange:Exchange, json:JSON, date:Date? = nil) {
        switch exchange {
        case .bittrex:
            exchangeName = "Bittrex"
            let last = json["result"]["Last"].doubleValue
            if last > 0 {
                self.last = last
            }
            let bid = json["result"]["Bid"].doubleValue
            if bid > 0 {
                self.bid = bid
            }
            let ask = json["result"]["Ask"].doubleValue
            if ask > 0 {
                self.ask = ask
            }
        case .liquid:
            exchangeName = "Liquid"
            let last = json["last_traded_price"].doubleValue
            if last > 0 {
                self.last = last
            }
            let bid = json["market_bid"].doubleValue
            if bid > 0 {
                self.bid = bid
            }
            let ask = json["market_ask"].doubleValue
            if ask > 0 {
                self.ask = ask
            }
        case .okcoin:
            exchangeName = "OKCoin"
            let last = json["last"].doubleValue
            if last > 0 {
                self.last = last
            }
            let bid = json["bid"].doubleValue
            if bid > 0 {
                self.bid = bid
            }
            let ask = json["ask"].doubleValue
            if ask > 0 {
                self.ask = ask
            }
        }
        self.lastUpdatedDate = date
    }
}
