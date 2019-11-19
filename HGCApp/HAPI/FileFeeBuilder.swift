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

class FileFeeBuilder: FeeBuilder {
////    func  getFileInfoQueryFeeMatrices(keys:Proto_KeyList) -> Proto_FeeComponents {
////        var bpt:Int64 = 0
////        let vpt:Int64 = 0
////        let rbs:Int64 = 0
////        let sbs:Int64 = 0
////        let gas:Int64 = 0
////        let tv:Int64 = 0
////        var bpr:Int64 = 0
////        var sbpr:Int64 = 0
////        
////        /*
////         * FileGetContentsQuery QueryHeader Transaction - CryptoTransfer - (will be taken care in
////         * Transaction processing) ResponseType - INT_SIZE FileID - 3 * LONG_SIZE
////         */
////        
////        bpt = sizeInt + (3 * sizeLong);
////    /*
////     *
////     * Response header NodeTransactionPrecheckCode - 4 bytes ResponseType - 4 bytes
////     *
////     * FileInfo FileID fileID - 3 * LONG_SIZE int64 size - LONG_SIZE Timestamp expirationTime = 3;
////     * // the current time at which this account is set to expire bool deleted = 4; // true if
////     * deleted but not yet expired KeyList keys = 5; // one of these keys must sign in order to
////     * modify or delete the file
////     *
////     */
////        var keySize:Int64 = 0;
////        for key in keys.keys {
////            keySize += getAcc
////        }
////    
////    bpr = INT_SIZE + INT_SIZE + 3 * LONG_SIZE + LONG_SIZE + (LONG_SIZE) + BOOL_SIZE + keySize;
////    
////    sbpr = 3 * LONG_SIZE + LONG_SIZE + (LONG_SIZE) + BOOL_SIZE + keySize;
////    ;
////    
////    FeeComponents feeMatrix = FeeComponents.newBuilder().setBpt(bpt).setVpt(vpt).setRbs(rbs)
////    .setSbs(sbs).setGas(gas).setTv(tv).setBpr(bpr).setSbpr(sbpr).build();
////    
////        var feeMatrix = Proto_FeeComponents.init()
////        feeMatrix.bpt = bpt
////        feeMatrix.vpt = vpt
////        feeMatrix.rbs = rbs
////        feeMatrix.sbs = sbs
////        feeMatrix.gas = gas
////        feeMatrix.tv = tv
////        feeMatrix.tv = tv
////        feeMatrix.bpr = bpr
////        feeMatrix.sbpr = sbpr
////        return feeMatrix
////    
////    }
//    
//    func getFileContentQueryFeeMatrices(_ contentSize:Int64) -> Proto_FeeComponents {
//        var bpt:Int64 = 0
//        let vpt:Int64 = 0
//        let rbs:Int64 = 0
//        let sbs:Int64 = 0
//        let gas:Int64 = 0
//        let tv:Int64 = 0
//        var bpr:Int64 = 0
//        var sbpr:Int64 = 0
//        /*
//         * FileGetContentsQuery QueryHeader Transaction - CryptoTransfer - (will be taken care in
//         * Transaction processing) ResponseType - INT_SIZE FileID - 3 * LONG_SIZE
//         */
//        
//        bpt = sizeInt + (3 * sizeLong);
//        /*
//         *
//         * Response header NodeTransactionPrecheckCode - 4 bytes ResponseType - 4 bytes
//         *
//         * FileContents FileID fileID - 3 * LONG_SIZE bytes content - calculated value (size of the
//         * content)
//         *
//         */
//        
//        bpr = sizeInt + sizeInt + 3 * sizeLong + contentSize;
//        
//        sbpr = 3 * sizeLong + contentSize;
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
}
