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

class FeeCalc {
//    static func getFeeSch() -> [Proto_HederaFunctionality:Proto_FeeData] {
//        
//        var feeSch:Proto_FeeSchedule
//        if let data = AppSettings.getFeeSchedule(), let schedule = try? Proto_CurrentAndNextFeeSchedule(serializedData: data) {
//            feeSch = schedule.currentFeeSchedule
//        } else {
//            let data = try! Data.init(contentsOf: Bundle.main.url(forResource: feeScheduleFile, withExtension: "")!)
//            feeSch = try! Proto_FeeSchedule(serializedData: data)
//        }
//        
//        var map = [Proto_HederaFunctionality:Proto_FeeData]()
//        for item in feeSch.transactionFeeSchedule {
//            map[item.hederaFunctionality] = item.feeData
//        }
//        return map
//    }
//    
//    static func feeForTransfer(_ txn:Proto_Transaction) -> UInt64 {
//        let feeData = getFeeSch()[Proto_HederaFunctionality.cryptoTransfer]!
//        let crBuilder = CryptoFeeBuilder.init()
//        let feeMatrics = crBuilder.getCryptoTransferTxFeeMatrics(txn)
//        let fee = FeeComponentBuilder.init().getTotalFeeforRequest(feeCoefficients: feeData, componentMetrics: feeMatrics)
//        return UInt64(fee)
//    }
//    
//    static func feeForGetBalance() -> UInt64 {
//        let feeData = getFeeSch()[Proto_HederaFunctionality.cryptoGetAccountBalance]!
//        let crBuilder = CryptoFeeBuilder.init()
//        let feeMatrics = crBuilder.getBalanceQueryFeeMatrics()
//        let fee = FeeComponentBuilder.init().getTotalFeeforRequest(feeCoefficients: feeData, componentMetrics: feeMatrics)
//        return UInt64(fee)
//    }
//    
//    static func feeForgetAccountRecordCost() -> UInt64 {
//        let feeData = getFeeSch()[Proto_HederaFunctionality.cryptoGetAccountRecords]!
//        let crBuilder = CryptoFeeBuilder.init()
//        let feeMatrics = crBuilder.getCostTransactionRecordQueryFeeMatrics()
//        let fee = FeeComponentBuilder.init().getTotalFeeforRequest(feeCoefficients: feeData, componentMetrics: feeMatrics)
//        return UInt64(fee)
//    }
}
