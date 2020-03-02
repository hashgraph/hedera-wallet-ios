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

extension Notification.Name {
    static let onExchangeRateChange = Notification.Name("onExchangeRateChange")
}

class AppConfigService {
    static let defaultService : AppConfigService = AppConfigService();
    private var exchangeRate:Double = 0.12
    private let exchanges : [Exchange:String] = [.bittrex:bittrex, .okcoin:okcoin, .liquid:liquid]

    init() {
        loadExchangeRate()
    }
    
    func conversionRate() -> Double {
        /*var rate: Double?
        let current = AppSettings.getExchangeRate(true)
        let next = AppSettings.getExchangeRate(false)
        if let expireTime = current.expirationTimeSeconds, Date().timeIntervalSince1970 < TimeInterval(expireTime), let c = current.centEquiv, let h = current.hBarEquiv {
            rate = Double(c)/Double(h)
        } else if let c = next.centEquiv, let h = next.hBarEquiv {
            rate = Double(c)/Double(h)
        }
        
        if let rate = rate {
            return rate/100
        }
        // 1 hbar = $0.12
        return 0.12
    */
        return exchangeRate
    }
    
    private func setConversionRate(centEquiv:Int32, hBarEquiv:Int32, expirationTimeSeconds:Int64, isCurrent:Bool) {
        if let expTime = AppSettings.getExchangeRate(isCurrent).expirationTimeSeconds, expTime > expirationTimeSeconds {
            return
        }
        AppSettings.setExchangeRate(centEquiv, hBarEquiv, expirationTimeSeconds, isCurrent)
    }
    
    func setConversionRate(receipt:Proto_TransactionReceipt) {
        let currentRate = receipt.exchangeRate.currentRate
        let nextRate = receipt.exchangeRate.currentRate
        setConversionRate(centEquiv: currentRate.centEquiv, hBarEquiv:currentRate.hbarEquiv, expirationTimeSeconds: currentRate.expirationTime.seconds, isCurrent: true)
        setConversionRate(centEquiv: nextRate.centEquiv,hBarEquiv:nextRate.hbarEquiv, expirationTimeSeconds: nextRate.expirationTime.seconds, isCurrent: false)
    }
    
    var fee: UInt64 {
        if let fee = AppSettings.getDefaultFee() {
            return fee
        }
        return defaultFee
    }
    
    private func updateFeeSchedule() {
        if let payer = WalletHelper.defaultPayerAccount(), payer.accountID() != nil {
            let queue = BaseOperation.operationQueue
            let op = FileContentOperation.init(payerAccount: payer, fileNum: fileNumFeeSchedule)
            op.completionBlock = {
                if let content = op.fileContent, !content.isEmpty {
                    do {
                        _ = try Proto_CurrentAndNextFeeSchedule(serializedData: content)
                        AppSettings.setFeeSchedule(content)
                        
                    } catch {
                        Logger.instance.log(message: "Failed to update fee schedule: \(error)", event: .e)
                    }
                }
            }
            queue.addOperation(op)
        }
    }

    func updateExchangeRate(_ onComplete:((_ error:String?) -> Void)? = nil) {
        for key in exchanges.keys {
               var request = URLRequest.init(url: URL.init(string: exchanges[key]!)!)
               request.timeoutInterval = 15
               let task = URLSession.shared.dataTask(with: request) { (data, urlResponse, error) in
                       DispatchQueue.main.async {
                        if error == nil, let res = urlResponse as? HTTPURLResponse, (res.statusCode >= 200 || res.statusCode < 300), let data = data {
                            AppSettings.setExchangeRateData(key.rawValue, data)
                            self.loadExchangeRate()
                            Logger.instance.log(message:"Exchange rates from \(key.rawValue) >> \(JSON(data))", event: .i)
                           } else {
                               if let error = error {
                                   Logger.instance.log(message:"Failed to load exchange rate for \(key.rawValue) " + error.localizedDescription, event: .e)
                                   
                               } else {
                                Logger.instance.log(message:"Failed to load exchange rate for \(key.rawValue)", event: .e)
                               }
                           }
                        onComplete?(nil)
                       }
                   }
                   task.resume()
               }
    }

    /// Load our exchange rate property with the median of all exchange rates that were reported to us.
    private func loadExchangeRate() {
        let rates: [Double] = getAllRates().compactMap{ $0.last }.sorted()
        guard !rates.isEmpty else { return }
        let lowerMedianIndex = rates.count / 2
        let offset = rates.count % 2 == 0 ? 1 : 0
        exchangeRate = (rates[lowerMedianIndex] + rates[lowerMedianIndex - offset]) / 2
    }
    
    func getAllRates() -> [ExchangeRateInfo] {
        var rates:[ExchangeRateInfo] = []
        let sortedKeys = exchanges.keys.sorted { $0.rawValue.localizedCaseInsensitiveCompare($1.rawValue) == ComparisonResult.orderedAscending }
        for key in sortedKeys {
            if let item = AppSettings.getExchangeRateData(key.rawValue) {
                let json = JSON(item.data)
                let info = ExchangeRateInfo.init(exchange: key, json: json, date: item.date)
                rates.append(info)
            }
        }
        return rates
    }
}
