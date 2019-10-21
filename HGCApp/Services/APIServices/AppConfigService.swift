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
        if let rate = AppSettings.getExchangeRate() {
            return Double(rate)/100
        }
        // 1 hbar = $0.12
        return 0.12
    }
    
    func setConversionRate(centEquiv:Int32, expirationTimeSeconds:Int64) {
        if let expTime = AppSettings.getExchangeRateExpireTime(), expTime > expirationTimeSeconds {
            return
        }
        
        AppSettings.setExchangeRate(centEquiv)
        AppSettings.setExchangeRateExpirationTime(expirationTimeSeconds)
    }
    
    func setConversionRate(receipt:Proto_TransactionReceipt) {
        let rate = receipt.exchangeRate.currentRate
        setConversionRate(centEquiv: rate.centEquiv, expirationTimeSeconds: rate.expirationTime.seconds)
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
