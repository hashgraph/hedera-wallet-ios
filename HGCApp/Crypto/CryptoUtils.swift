//
//  CryptoUtils.swift
//  HGCApp
//
//  Created by Surendra on 14/04/19.
//  Copyright © 2019 HGC. All rights reserved.
//

import Foundation

class CryptoUtils {
    static func secureRandomBytes(length:Int) -> Data? {
        var keyData = Data(count: length)
        let result = keyData.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, length, $0.baseAddress!)
        }
    
        if result == errSecSuccess {
            return keyData
        } else {
            print("Problem generating random bytes")
            return nil
        }
    }
    
    static func randomSeed() -> HGCSeed {
        return HGCSeed.init(entropy:secureRandomBytes(length: 32))!
    }
    
}
