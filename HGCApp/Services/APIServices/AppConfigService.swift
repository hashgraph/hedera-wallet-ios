//
//  AppConfigService.swift
//  HGCApp
//
//  Created by Surendra  on 29/11/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit

class AppConfigService {
    static let defaultService : AppConfigService = AppConfigService();
    
    func conversionRate() -> Double {
        var rate: Double?
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
    }
    
    func setConversionRate(centEquiv:Int32, hBarEquiv:Int32, expirationTimeSeconds:Int64, isCurrent:Bool) {
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
    
    func updateFeeSchedule() {
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
}
