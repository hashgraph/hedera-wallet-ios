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

import Foundation

protocol SecureAppSettingsProtocol {
    func getSeed() -> Data?
}

class SecureAppSettings : SecureAppSettingsProtocol {
    private static let keyWalletPin = "walletPin"
    private static let keySeed = "hgc-seed"
    
    static let `default` : SecureAppSettings = SecureAppSettings();
    
    private func saveObject(_ object:Any, forKey:String) {
        KeychainWrapper.save(object, forKey: forKey)
    }
    
    private func getObject(_ key:String) -> Any? {
        return KeychainWrapper.loadObject(forKey: key)
    }
    
    private func getString(_ key: String) -> String? {
        if let value = getObject(key) as? String {
            return value
        }
        return nil
    }
    
    private func getNumber(_ key: String) -> Int16? {
        if let value = getObject(key) as? Int16 {
            return value
        }
        return nil
    }
    
    private func getData(_ key: String) -> Data? {
        if let value = getObject(key) as? Data {
            return value
        }
        return nil
    }
    
    public func setSeed(_ seed:Data) {
        saveObject(seed, forKey: SecureAppSettings.keySeed)
    }
    
    public func getSeed() -> Data? {
        return getData(SecureAppSettings.keySeed)
    }
    
    public func setPIN(_ pin:String) {
        saveObject(pin, forKey: SecureAppSettings.keyWalletPin)
    }
    
    public func getPIN() -> String? {
        return getString(SecureAppSettings.keyWalletPin)
    }
    
    public func clear() throws {
        if getSeed() != nil && !KeychainWrapper.deleteObject(forKey: SecureAppSettings.keySeed) {
            throw NSError.init(domain: "Fail to clear seed", code: 0, userInfo: nil)
        }
        KeychainWrapper.deleteObject(forKey: SecureAppSettings.keyWalletPin)
    }
}
