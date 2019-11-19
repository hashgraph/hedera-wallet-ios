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

class TransferViewModel {
    var thirdParty = false
    var fromAccount : HGCAccount
    
    var toAccountName:String = ""
    var toAccountID:String = ""
    var toAccountHost:String = ""

    var fee : UInt64 = 0
    var amountUSD : String = ""
    var amountHBar : String = ""
    
    var isQROptionSelected = false
    var isNewSelected = false

    var hasNotes = false
    var notes : String = ""
    
    var request : HGCRequest?
    
    init(fromAccount:HGCAccount, thirdParty:Bool = false, request:HGCRequest? = nil) {
        self.fromAccount = fromAccount
        self.thirdParty = thirdParty
        self.request = request
        if let req = request {
            self.amount = req.amount
            if let toAccount = req.fromAccount {
                self.toAccountName = toAccount.name ?? ""
                self.toAccountID = toAccount.stringRepresentation()
            }
            self.isNewSelected = true
        }
    }
    
    var toAccount:AccountVO? {
        return AccountVO.init(from: toAccountID, name: toAccountName)
    }
    
    var amount:Int64? {
        get {
            if let hBar = Double(amountHBar) {
                return hBar.toTinyBar()
            }
            return nil
        }
        set {
            if let val = newValue {
                self.amountHBar = val.toHBar().formatForInputField()
                self.amountUSD = CurrencyConverter.shared.convertTo$value(val).formatForInputField(maximumFractionDigits: 2)
            } else {
                self.amountHBar = ""
                self.amountUSD = ""
            }
        }
    }
    
    
    func parseQR(_ results:[String]) throws {
        if thirdParty {
            var exchangeInfo : ExchangeInfo? = nil
            for code in results {
                if let info = ExchangeInfo.fromQRCode(code) {
                    exchangeInfo = info
                    break;
                }
            }
            
            if let exchangeInfo = exchangeInfo {
                toAccountName = exchangeInfo.name
                toAccountID = exchangeInfo.accountID.stringRepresentation()
                toAccountHost = exchangeInfo.host
                notes = exchangeInfo.memo ?? ""
                
            } else {
                throw NSLocalizedString("Invalid QR Code", comment: "")
            }
        } else {
            var requestParams : TransferRequestParams? = nil
            for code in results {
                if let parser = TransferRequestParams.init(qrCode: code) {
                    requestParams = parser
                    break;
                }
            }
            
            if let params = requestParams {
                toAccountName = params.name ?? ""
                toAccountID = params.account.stringRepresentation()
                if (params.amount != nil) {
                    amount = params.amount
                }
                
            } else {
                throw NSLocalizedString("Invalid QR Code", comment: "")
            }
        }
    }
    
    func validateParams() -> String? {
        var error : String?
        
        if fromAccount.accountID() == nil {
            error = NSLocalizedString("From account is not lnked", comment: "")
            
        } else if toAccount?.accountID == nil {
            error = NSLocalizedString("Invalid to account ID", comment: "")
            
        } else if amount == nil || amount! <= 0 {
            error = NSLocalizedString("Invalid amount", comment: "")
            
        } else if thirdParty, toAccountHost.trim().isEmpty {
             error = NSLocalizedString("Host cannot be blank", comment: "")
        } else if thirdParty  && ExchangeInfo.toHttpURL(host: toAccountHost) == nil{
            error = "Invalid host"
            /* let validIpAddressRegex = "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$"
            let validHostnameRegex = "^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\\-]*[A-Za-z0-9])$"
            if !(matches(for: validIpAddressRegex, in: toAccountHost).isEmpty && matches(for: validHostnameRegex, in: toAccountHost).isEmpty) {
               error = NSLocalizedString("Invalid host", comment: "")
            }*/
        }
        
        return error
    }
    
    private func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
