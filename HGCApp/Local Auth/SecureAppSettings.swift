//
//  SecureAppSettings.swift
//  HGCApp
//
//  Created by Surendra on 24/11/17.
//  Copyright © 2017 HGC. All rights reserved.
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
