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

let kHGCCurrencySymbol = "ℏ"
let kUSDCurrencySymbol = "$"
let hBarMaxFractions:Int = 8
let hBarToTinyBar:Int64 = 100000000

class CurrencyConverter: NSObject {
    static let shared : CurrencyConverter = CurrencyConverter();
    
    func convertToTinyBar(_ value$:Double) -> Int64 {
        return Double(value$/AppConfigService.defaultService.conversionRate()).toTinyBar()
    }
    
    func convertToHBar(_ value$:Double) -> Double {
        return Double(value$/AppConfigService.defaultService.conversionRate())
    }
    
    func convertTo$value(_ tinyBars:Int64) -> Double {
        return Double(tinyBars.toHBar() * AppConfigService.defaultService.conversionRate())
    }
    
    func convertTo$value(_ tinyBars:UInt64) -> Double {
        return Double(tinyBars.toHBar() * AppConfigService.defaultService.conversionRate())
    }
    
    func convertTo$value(hBar:Double) -> Double {
        return Double(hBar * AppConfigService.defaultService.conversionRate())
    }
}

extension Double {
    func toTinyBar() -> Int64 {
         return Int64((self * Double(hBarToTinyBar)))
     }
}

extension Int64 {
    func toHBar() -> Double {
        return Double(self)/Double(hBarToTinyBar)
    }
}

extension UInt64 {
    func toHBar() -> Double {
        return Double(self)/Double(hBarToTinyBar)
    }
}

// Number String formatters

extension Double {
    func formatForInputField(maximumFractionDigits:Int = hBarMaxFractions) -> String {
        let formatter = NumberFormatter.init()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = maximumFractionDigits
        formatter.roundingMode = .halfUp
        formatter.decimalSeparator = "."
        formatter.groupingSize = 3
        formatter.groupingSeparator = ""
        formatter.generatesDecimalNumbers = true
        let s = formatter.string(from: self as NSNumber) ?? self.description
        return s
    }
    
    func formatHGCShort(includeSymbol:Bool = false) -> String {
        return formatHGC(includeSymbol: includeSymbol, maximumFractionDigits:6)
    }
    
    func formatHGC(includeSymbol:Bool = false, maximumFractionDigits:Int = hBarMaxFractions) -> String {
        let formatter = NumberFormatter.init()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = maximumFractionDigits
        formatter.roundingMode = .halfUp
        formatter.decimalSeparator = "."
        formatter.groupingSize = 3
        formatter.groupingSeparator = ","
        formatter.generatesDecimalNumbers = true
        let convertedPrice = formatter.string(from: self as NSNumber)
        return includeSymbol ? convertedPrice! + kHGCCurrencySymbol : convertedPrice!
    }
    
    func formatUSD(includeSymbol:Bool = true) -> String {
        let formatter = NumberFormatter.init()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.roundingMode = .down
        formatter.decimalSeparator = "."
        formatter.groupingSize = 3
        formatter.groupingSeparator = ","
        formatter.generatesDecimalNumbers = true
        let convertedPrice = formatter.string(from: self as NSNumber)!
        return includeSymbol ? kUSDCurrencySymbol + convertedPrice : convertedPrice
    }
    
    func formatExchangeRate() -> String {
         let formatter = NumberFormatter.init()
         formatter.numberStyle = .decimal
         formatter.minimumFractionDigits = 2
         formatter.maximumFractionDigits = 4
         formatter.roundingMode = .halfUp
         formatter.decimalSeparator = "."
         formatter.groupingSize = 3
         formatter.groupingSeparator = ","
         formatter.generatesDecimalNumbers = true
       let convertedPrice = formatter.string(from: self as NSNumber) ?? self.description
         return convertedPrice
    }
}

