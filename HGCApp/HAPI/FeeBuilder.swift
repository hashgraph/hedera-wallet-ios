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

class FeeBuilder {
    let sizeLong:Int64 = 8
    let sizeInt:Int64 = 4
    let sizeBool:Int64 = 4
    let sizeKey:Int64 = 32

//    func getCommonTransactionBodyBytes(_ body:Proto_TransactionBody) -> Int64 {
//        /*
//         * Common fields in all transaction
//         
//         *  TransactionID transactionID
//         AccountID accountID  - 3 * LONG_SIZE bytes
//         Timestamp transactionValidStart - (LONG_SIZE + INT_SIZE) bytes
//         AccountID nodeAccountID  - 3 * LONG_SIZE bytes
//         uint64 transactionFee  - LONG_SIZE bytes
//         Duration transactionValidDuration - (LONG_SIZE + INT_SIZE) bytes
//         bool generateRecord  - BOOL_SIZE bytes
//         string memo  - get memo size from transaction
//         *
//         */
//        
//        var commonBytes:Int64 = 3 * sizeLong + (sizeLong + sizeInt)
//        commonBytes = commonBytes + 3 * sizeLong + sizeLong + (sizeLong + sizeInt) + sizeBool
//        commonBytes = commonBytes + Int64(body.memo.data(using: .utf8)!.count)
//        return commonBytes
//    }
//    
//    func getVPT(_ txn:Proto_Transaction) -> Int {
//        // need to verify recursive depth of signatures
//        var sig = Proto_Signature.init()
//        sig.signatureList = txn.sigs
//        return calculateNoOfSigs(sig: sig, count: 0)
//    }
//    
//    func getAccountKeyStorageSize(key:Proto_Key) -> Int64 {
//        var keyStorageSize:Int64 = 0
//        var countKeyMetatData:[Int64] = [0,0]
//        countKeyMetatData = calculateKeysMetadata(key: key, count: &countKeyMetatData)
//        keyStorageSize = (countKeyMetatData[0] * sizeKey) + (countKeyMetatData[1] * sizeInt);
//        return keyStorageSize
//    }
//    
//    private func calculateKeysMetadata(key:Proto_Key, count:inout [Int64]) -> [Int64] {
//        if !key.keyList.keys.isEmpty {
//            count[1] = count[1] + 1
//            for k in key.keyList.keys {
//                count = calculateKeysMetadata(key: k, count: &count)
//            }
//        } else if key.thresholdKey.hasKeys {
//            count[1] = count[1] + 1
//            for k in key.thresholdKey.keys.keys {
//                count = calculateKeysMetadata(key: k, count: &count)
//            }
//            
//        } else {
//            count[0] = count[0] + 1
//        }
//        
//        return count
//    }
//    
//    private func calculateNoOfSigs(sig:Proto_Signature, count:Int) -> Int {
//        var result = count
//        if (!sig.signatureList.sigs.isEmpty) {
//            for item in sig.signatureList.sigs {
//                result = calculateNoOfSigs(sig: item, count: result)
//            }
//            
//        } else if (!sig.thresholdSignature.sigs.sigs.isEmpty) {
//            for item in sig.thresholdSignature.sigs.sigs {
//                result = calculateNoOfSigs(sig: item, count: result)
//            }
//            
//        } else {
//            result = result + 1;
//        }
//        return result;
//    }
}

class FeeComponentBuilder {
    
//    public func getComponentFee(componentCoefficients:Proto_FeeComponents , componentMetrics:Proto_FeeComponents) -> Int64 {
//        let bytesUsageFee = componentCoefficients.bpt * componentMetrics.bpt
//        let verificationFee = componentCoefficients.vpt * componentMetrics.vpt
//        let ramStorageFee = componentCoefficients.rbs * componentMetrics.rbs
//        let storageFee = componentCoefficients.sbs * componentMetrics.sbs
//        let evmGasFee = componentCoefficients.gas * componentMetrics.gas
//        let txValueFee = (componentCoefficients.tv * componentMetrics.tv) / 1000
//        let bytesResponseFee = componentCoefficients.bpr * componentMetrics.bpr
//        let storageBytesResponseFee = componentCoefficients.sbpr * componentMetrics.sbpr
//
//        var totalComponentFee = componentCoefficients.constant +
//            (bytesUsageFee + verificationFee + ramStorageFee + storageFee + evmGasFee + txValueFee + bytesResponseFee +  storageBytesResponseFee)
//
//        if(totalComponentFee < componentCoefficients.min) {
//            totalComponentFee = componentCoefficients.min
//        } else if(totalComponentFee > componentCoefficients.max) {
//            totalComponentFee = componentCoefficients.max
//        }
//        return totalComponentFee
//    }
//
//    func getTotalFeeforRequest(feeCoefficients:Proto_FeeData, componentMetrics:Proto_FeeComponents) -> Int64 {
//        // get Node Fee
//        let nodeFee = getComponentFee(componentCoefficients: feeCoefficients.nodedata, componentMetrics: componentMetrics)
//
//        // get Network fee
//        let  networkFee =  getComponentFee(componentCoefficients: feeCoefficients.networkdata, componentMetrics: componentMetrics)
//        //System.out.println("The networkFee Fee is "+networkFee);
//        // get Service Fee
//        let  serviceFee =  getComponentFee(componentCoefficients: feeCoefficients.servicedata, componentMetrics: componentMetrics)
//        //System.out.println("The serviceFee Fee is "+serviceFee);
//
//        let totalFee = nodeFee + networkFee + serviceFee
//        return totalFee
//    }
}
