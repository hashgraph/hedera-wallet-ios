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

class SecureAppSettings: SecureAppSettingsProtocol {
    private static let keyWalletPin = "walletPin"
    private static let oldKeySeed = "hgc-seed"
    
    static let `default` = SecureAppSettings()
    
    private func saveObject(_ object: Any, forKey: String) -> Bool {
        let didSave = KFKeychain.save(object, forKey: forKey)
        return didSave
    }
    
    private func getObject(_ key: String) -> Any? {
        return KFKeychain.loadObject(forKey: key)
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
    
    public func setSeed(_ seed: Data) -> Bool {
        guard let key = SeedKey(createIfMissing: true) else {
            return false
        }
        guard let encryptedSeed = key.encrypt(seed) else {
            return false
        }
        if !SeedFile.create(encryptedSeed) {
            return false
        }
        let didDelete = KFKeychain.deleteObject(forKey: SecureAppSettings.oldKeySeed)
        if didDelete {
            Logger.instance.log(message: "Deleted old seed in Keychain", event: .i)
        }
        return true
    }
    
    public func getSeed() -> Data? {
        let encryptedSeedOpt = SeedFile.read()
        let keyOpt = SeedKey(createIfMissing: false)
        if let encryptedSeed = encryptedSeedOpt, let key = keyOpt {
            guard let seed = key.decrypt(encryptedSeed) else {
                return nil
            }
            return seed
        }
        else {
            let seed = getData(SecureAppSettings.oldKeySeed)
            if case .some(let realSeed) = seed {
                Logger.instance.log(message: "Found seed in deprecated Keychain", event: .i)
                if setSeed(realSeed) {
                    Logger.instance.log(message: "Successfully migrated seed to file", event: .i)
                    let didDelete = KFKeychain.deleteObject(forKey: SecureAppSettings.oldKeySeed)
                    if !didDelete {
                        Logger.instance.log(message: "Unable to delete seed in deprecated storage", event: .w)
                    }
                }
                else {
                    Logger.instance.log(message: "Unable to migrate seed to file", event: .e)
                    // TODO: better handle opportunity to recover
                    return nil
                }
            }
            return seed
        }
    }
    
    public func setPIN(_ pin: String) {
        saveObject(pin, forKey: SecureAppSettings.keyWalletPin)
    }
    
    public func getPIN() -> String? {
        return getString(SecureAppSettings.keyWalletPin)
    }
    
    public func clear() -> Bool {
        // TODO: better logging
        var success = true
        success = (SeedFile.delete() != nil) && success
        if getObject(SecureAppSettings.oldKeySeed) != nil {
            success = KFKeychain.deleteObject(forKey: SecureAppSettings.oldKeySeed) && success
        }
        if getObject(SecureAppSettings.keyWalletPin) != nil {
            success = KFKeychain.deleteObject(forKey: SecureAppSettings.keyWalletPin) && success
        }
        return success
    }

    // Deprecated but available for testing

    public func oldSetSeed(_ seed: Data) -> Bool {
        let didSet = saveObject(seed, forKey: SecureAppSettings.oldKeySeed)
        return didSet
    }

    public func oldGetSeed() -> Data? {
        let seed = getData(SecureAppSettings.oldKeySeed)
        return seed
    }
}
