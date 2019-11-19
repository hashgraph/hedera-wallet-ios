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

class AppSettings: NSObject {
    
    public class func setBiometricLoginEnabled(_ enabled:Bool) {
        UserDefaults.standard.set(enabled, forKey: "bioMetricLoginEnabled")
        UserDefaults.standard.synchronize()
    }
    
    public class func isBiometricLoginEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: "bioMetricLoginEnabled")
    }
    
    public class func setPrefPaymentConfirmation(_ enabled:Bool) {
        UserDefaults.standard.set(enabled, forKey: "PrefPaymentConfirmationNotification")
        UserDefaults.standard.synchronize()
    }
    
    public class func getPrefPaymentConfirmation() -> Bool {
        return UserDefaults.standard.bool(forKey: "PrefPaymentConfirmationNotification")
    }
    
    public class func setPrefReceiveConfirmation(_ enabled:Bool) {
        UserDefaults.standard.set(enabled, forKey: "PrefReceiveFundsNotification")
        UserDefaults.standard.synchronize()
    }
    
    public class func getPrefReceiveConfirmation() -> Bool {
        return UserDefaults.standard.bool(forKey: "PrefReceiveFundsNotification")
    }
    
    public class func setAppUserName(_ name:String) {
        UserDefaults.standard.set(name, forKey: "AppUserName")
        UserDefaults.standard.synchronize()
    }
    
    public class func getAppUserName() -> String? {
        return UserDefaults.standard.string(forKey: "AppUserName")
    }
    
    public class func setRedirectURL(_ url:String) {
        UserDefaults.standard.set(url, forKey: "RedirectURL")
        UserDefaults.standard.synchronize()
    }
    
    public class func getRedirectURL() -> String? {
        return UserDefaults.standard.string(forKey: "RedirectURL")
    }
    
    public class func setBranchParams(_ params:[String:Any]) {
        UserDefaults.standard.set(params, forKey: "BranchParams")
        UserDefaults.standard.synchronize()
    }
    
    public class func getBranchParams() -> [String: Any]? {
        return UserDefaults.standard.dictionary(forKey: "BranchParams")
    }

    public class func askedForQueryCostWarning() -> Bool {
        return UserDefaults.standard.bool(forKey: "AskedForQueryCostWarning")
    }
        
    public class func setAskedForQueryCostWarning(_ enable:Bool) {
        UserDefaults.standard.set(enable, forKey: "AskedForQueryCostWarning")
        UserDefaults.standard.synchronize()
    }
    
    public class func hasShownBip39Mnemonic() -> Bool {
        return UserDefaults.standard.bool(forKey: "HasShownBip39MnemonicV2")
    }
    
    public class func setHasShownBip39Mnemonic() {
        UserDefaults.standard.set(true, forKey: "HasShownBip39MnemonicV2")
        UserDefaults.standard.synchronize()
    }
    
    public class func needsToShownBip39Mnemonic() -> Bool {
        return UserDefaults.standard.bool(forKey: "needsToShownBip39Mnemonic")
    }
    
    public class func setNeedsToShownBip39Mnemonic() {
        UserDefaults.standard.set(true, forKey: "needsToShownBip39Mnemonic")
        UserDefaults.standard.synchronize()
    }
    
    public class func getFeeSchedule() -> Data? {
        return UserDefaults.standard.data(forKey: "feeSchedule")
    }
    
    public class func setFeeSchedule(_ data:Data) {
        UserDefaults.standard.set(data, forKey: "feeSchedule")
        UserDefaults.standard.synchronize()
    }
    
    public class func setDefaultFee(_ fee:UInt64) {
        UserDefaults.standard.set(fee, forKey: "defaultFee")
        UserDefaults.standard.synchronize()
    }
    
    public class func getDefaultFee() -> UInt64? {
        return UserDefaults.standard.object(forKey: "defaultFee") as? UInt64

    }
    
    public class func setExchangeRate(_ centEquiv:Int32, _ hBarEquiv:Int32, _ expirationTime:Int64, _ isCurrent:Bool) {
        let keyRateC = (isCurrent ? "current_" : "") + "exchangeRateCentEquiv"
        let keyRateH = (isCurrent ? "current_" : "") + "exchangeRateHbarEquiv"
        let keyExpireTime = (isCurrent ? "current_" : "") + "exchangeRateExpTimeSeconds"
        UserDefaults.standard.set(centEquiv, forKey: keyRateC)
        UserDefaults.standard.set(hBarEquiv, forKey: keyRateH)
        UserDefaults.standard.set(expirationTime, forKey: keyExpireTime)
        UserDefaults.standard.synchronize()
    }
    
    public class func getExchangeRate(_ isCurrent:Bool) -> (centEquiv:Int32?, hBarEquiv:Int32?, expirationTimeSeconds:Int64?) {
        let keyRateC = (isCurrent ? "current_" : "") + "exchangeRateCentEquiv"
        let keyRateH = (isCurrent ? "current_" : "") + "exchangeRateHbarEquiv"
        let keyExpireTime = (isCurrent ? "current_" : "") + "exchangeRateExpTimeSeconds"
        return (UserDefaults.standard.object(forKey: keyRateC) as? Int32, UserDefaults.standard.object(forKey: keyRateH) as? Int32 , UserDefaults.standard.object(forKey: keyExpireTime) as? Int64)
    }
    
    public class func setExchangeRateData(_ exchange:String, _ data:Data) {
        let keyData = "data_" + exchange
        let keyDate = "date_" + exchange
        UserDefaults.standard.set(data, forKey: keyData)
        UserDefaults.standard.set(Date(), forKey: keyDate)
        UserDefaults.standard.synchronize()
    }
    
    public class func getExchangeRateData(_ exchange:String) ->  (data:Data, date:Date)? {
        let keyData = "data_" + exchange
        let keyDate = "date_" + exchange
        if let data = UserDefaults.standard.object(forKey: keyData) as? Data, let date = UserDefaults.standard.object(forKey: keyDate) as? Date {
            return (data, date)
        }
        return nil
    }
    
    public class func setLastSyncNodesAt(_ date:Date) {
        UserDefaults.standard.set(date, forKey: "lastSyncNodesAt")
        UserDefaults.standard.synchronize()
    }
    
    public class func getLastSyncNodesAt() -> Date? {
        return UserDefaults.standard.object(forKey: "lastSyncNodesAt") as? Date
    }
    
    public class func clear() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }
}
