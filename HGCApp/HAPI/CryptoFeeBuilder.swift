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

class CryptoFeeBuilder: FeeBuilder {
    
//    func getCryptoTransferTxFeeMatrics(_ txn:Proto_Transaction) -> Proto_FeeComponents {
//        var bpt:Int64 = 0
//        var vpt:Int64 = 0
//        let rbs:Int64 = 0
//        let sbs:Int64 = 0
//        let gas:Int64 = 0
//        var tv:Int64 = 0
//        let bpr:Int64 = 0
//        let sbpr:Int64 = 0
//        
//        var txnBodySize:Int64 = 0
//        let body = txn.transactionBody()
//        txnBodySize = getCommonTransactionBodyBytes(body)
//        //bpt - Bytes per Transaction
//        bpt = txnBodySize + getCryptoTransferBodyTxSize(body)
//        
//        //vpt - verifications per transactions
//        vpt = Int64(getVPT(txn))
//        
//        //tv - Transfer Value
//        tv = getTV(body)
//        
//        var feeMatricsForTx = Proto_FeeComponents.init()
//        feeMatricsForTx.bpt = bpt
//        feeMatricsForTx.vpt = vpt
//        feeMatricsForTx.rbs = rbs
//        feeMatricsForTx.sbs = sbs
//        feeMatricsForTx.gas = gas
//        feeMatricsForTx.tv = tv
//        feeMatricsForTx.tv = tv
//        feeMatricsForTx.bpr = bpr
//        feeMatricsForTx.sbpr = sbpr
//        return feeMatricsForTx
//    }
//    
//    func getBalanceQueryFeeMatrics() -> Proto_FeeComponents {
//        // get the Fee Matrics
//        var bpt:Int64 = 0
//        let vpt:Int64 = 0
//        let rbs:Int64 = 0
//        let sbs:Int64 = 0
//        let gas:Int64 = 0
//        let tv:Int64 = 0
//        var bpr:Int64 = 0
//        var sbpr:Int64 = 0
//        
//        /*
//         *  CryptoGetAccountBalanceQuery
//         *          QueryHeader
//         *              Transaction - CryptoTransfer - (will be taken care in Transaction processing)
//         *              ResponseType - INT_SIZE
//         *          AccountID -  3 * LONG_SIZE
//         */
//        
//        bpt = sizeInt + (3 * sizeLong);
//        
//        /*
//         * CryptoGetAccountBalanceResponse
//         * Response header
//         * NodeTransactionPrecheckCode -  4 bytes
//         * ResponseType - 4 bytes
//         * AccountID - 24 bytes (consist of 3 long values)
//         * balance - 8 bytes (1 long value)
//         */
//        
//        bpr = sizeInt + sizeInt + 3 * sizeLong + sizeLong;
//        
//        /*
//         * Account Balance Storage Size
//         *
//         * AccountID - 24 bytes (consist of 3 long values) balance - 8 bytes (1 long
//         * value)
//         */
//        
//        sbpr = 3 * sizeLong + sizeLong;
//        
//        var feeMatrix = Proto_FeeComponents.init()
//        feeMatrix.bpt = bpt
//        feeMatrix.vpt = vpt
//        feeMatrix.rbs = rbs
//        feeMatrix.sbs = sbs
//        feeMatrix.gas = gas
//        feeMatrix.tv = tv
//        feeMatrix.tv = tv
//        feeMatrix.bpr = bpr
//        feeMatrix.sbpr = sbpr
//        return feeMatrix
//    }
//    
//    func  getCostTransactionRecordQueryFeeMatrics() -> Proto_FeeComponents {
//        var bpt:Int64 = 0
//        let vpt:Int64 = 0
//        let rbs:Int64 = 0
//        let sbs:Int64 = 0
//        let gas:Int64 = 0
//        let tv:Int64 = 0
//        var bpr:Int64 = 0
//        let sbpr:Int64 = 0
//        
//        /*
//         *  CostTransactionGetRecordQuery
//         *          QueryHeader
//         *              Transaction - CryptoTransfer - (will be taken care in Transaction processing)
//         *              ResponseType - INT_SIZE
//         *          TransactionID
//         *              AccountID accountID  - 3 * LONG_SIZE bytes
//         Timestamp transactionValidStart - (LONG_SIZE + INT_SIZE) bytes
//         */
//        
//        bpt = sizeInt + (3 * sizeLong) + (sizeLong + sizeInt);
//        
//        /*
//         * Response header
//         * NodeTransactionPrecheckCode -  4 bytes
//         * ResponseType - 4 bytes
//         * uint64 cost - 8 bytes
//         */
//        bpr = sizeInt + sizeInt + sizeLong;
//        
//        
//        var feeMatrix = Proto_FeeComponents.init()
//        feeMatrix.bpt = bpt
//        feeMatrix.vpt = vpt
//        feeMatrix.rbs = rbs
//        feeMatrix.sbs = sbs
//        feeMatrix.gas = gas
//        feeMatrix.tv = tv
//        feeMatrix.tv = tv
//        feeMatrix.bpr = bpr
//        feeMatrix.sbpr = sbpr
//        return feeMatrix
//    }
//    
//    private func getCryptoTransferBodyTxSize(_ body:Proto_TransactionBody) -> Int64 {
//        /*
//         * TransferList transfers
//         repeated AccountAmount
//         AccountID - (3 * LONG_SIZE)
//         sint64 amount - LONG_SIZE
//         */
//        
//        let accountAmountCount:Int64 = Int64(body.cryptoTransfer.transfers.accountAmounts.count);
//        let cryptoTransfertBodySize = ((3 * sizeLong) + sizeLong) * accountAmountCount;
//        return cryptoTransfertBodySize;
//    }
//    
//    private func getTV(_ body:Proto_TransactionBody) -> Int64 {
//        var amount:Int64 = 0
//        for actAmt in body.cryptoTransfer.transfers.accountAmounts {
//            if actAmt.amount > 0 {
//                amount = amount + actAmt.amount
//            }
//        }
//        return Int64(amount/1000)
//    }
    
}
