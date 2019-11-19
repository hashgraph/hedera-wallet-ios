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
import SwiftGRPC

class BaseOperation: Operation {
    var errorMessage:String?
    var grpc:HAPIRPCProtocol = GRPCWrapper.init(nodes: APIAddressBookService.defaultAddressBook.getActiveNodes())
    
    public static var operationQueue:OperationQueue = {
        let queue = OperationQueue.init()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    func desc(_ error:Error) -> String {
        if let rpcError = error as? RPCError {
            switch rpcError {
            case .timedOut:
                return NSLocalizedString("Request timedOut", comment: "")
            case .invalidMessageReceived:
                return NSLocalizedString("Invalid message received", comment: "")
            case .callError(let result):
                print(result)
                switch result.statusCode {
                case .unavailable, .unknown, .deadlineExceeded:
                    return "\(NSLocalizedString("Node is not reachable", comment: "")): " + grpc.node.host
                default:
                    return NSLocalizedString("Something went wrong, please try later.", comment: "")
                }
                
            }
        } else if let str = error as? String {
            return str
        }
        return (error as NSError).debugDescription
    }
    
    func getReceipt(acc:HGCAccountID, txnID:Proto_TransactionID, retryCount:Int = 30) throws -> Proto_Response {
        var res:Proto_Response? = nil
        for _ in 1...retryCount {
            sleep(2)
            do {
                let transactionBuilder = TransactionBuilder.init(payerCredentials: nil, payerAccount: acc)
                let param = GetTransactionReceiptParam.init(txnID)
                
                let receiptRes = try grpc.perform(param, transactionBuilder)
                res = receiptRes.response
                if receiptRes.response.transactionGetReceipt.receipt.status != .unknown {
                    break
                }
                
            } catch {
                Logger.instance.log(message: desc(error), event: .e)
                break
            }
        }
        
        if let r = res {
            AppConfigService.defaultService.setConversionRate(receipt: r.transactionGetReceipt.receipt)
            return r
        } else {
            throw "unable to fetch receipt"
        }
    }
}

extension Proto_ResponseCodeEnum {
    func getErrorMessage() -> String {
        var msg:String
        switch self {
        case .ok:
            msg = ""
        case .invalidTransaction:
            msg = NSLocalizedString("invalidTransaction", comment: "")
        case .payerAccountNotFound:
            msg = NSLocalizedString("payerAccountNotFound", comment: "")
        case .invalidNodeAccount:
             msg = NSLocalizedString("invalidNodeAccount", comment: "")
        case .transactionExpired:
            msg = NSLocalizedString("transactionExpired", comment: "")
        case .invalidTransactionStart:
            msg = NSLocalizedString("invalidTransactionStart", comment: "")
        case .invalidTransactionDuration:
            msg = NSLocalizedString("invalidTransactionDuration", comment: "")
        case .invalidSignature:
            msg = NSLocalizedString("invalidSignature", comment: "")
        case .memoTooLong:
            msg = NSLocalizedString("memoTooLong", comment: "")
        case .insufficientTxFee:
            msg = NSLocalizedString("insufficientTxFee", comment: "")
        case .insufficientPayerBalance:
            msg = NSLocalizedString("insufficientPayerBalance", comment: "")
        case .duplicateTransaction:
            msg = NSLocalizedString("duplicateTransaction", comment: "")
        case .busy:
            msg = NSLocalizedString("busy", comment: "")
        case .notSupported:
            msg = NSLocalizedString("notSupported", comment: "")
        case .invalidFileID:
            msg = NSLocalizedString("invalidFileID", comment: "")
        case .invalidAccountID:
            msg = NSLocalizedString("invalidAccountID", comment: "")
        case .invalidContractID:
            msg = NSLocalizedString("invalidContractID", comment: "")
        case .invalidTransactionID:
            msg = NSLocalizedString("invalidTransactionID", comment: "")
        case .receiptNotFound:
            msg = NSLocalizedString("receiptNotFound", comment: "")
        case .recordNotFound:
            msg = NSLocalizedString("recordNotFound", comment: "")
        case .invalidSolidityID:
            msg = NSLocalizedString("invalidSolidityID", comment: "")
        case .unknown:
            msg = NSLocalizedString("unknown", comment: "")
        case .success:
            msg = ""
        case .failInvalid:
            msg = NSLocalizedString("failInvalid", comment: "")
        case .failFee:
            msg = NSLocalizedString("failFee", comment: "")
        case .failBalance:
            msg = NSLocalizedString("failBalance", comment: "")
        case .keyRequired:
            msg = NSLocalizedString("keyRequired", comment: "")
        case .badEncoding:
            msg = NSLocalizedString("badEncoding", comment: "")
        case .insufficientAccountBalance:
            msg = NSLocalizedString("insufficientAccountBalance", comment: "")
        case .UNRECOGNIZED(_):
            msg = "UNRECOGNIZED"
        case .invalidSolidityAddress:
            msg = NSLocalizedString("invalidSolidityAddress", comment: "")
        case .insufficientGas:
            msg = NSLocalizedString("insufficientGas", comment: "")
        case .contractSizeLimitExceeded:
            msg = NSLocalizedString("contractSizeLimitExceeded", comment: "")
        case .localCallModificationException:
            msg = NSLocalizedString("localCallModificationException", comment: "")
        case .contractRevertExecuted:
            msg = NSLocalizedString("contractRevertExecuted", comment: "")
        case .contractExecutionException:
            msg = NSLocalizedString("contractExecutionException", comment: "")
        case .invalidReceivingNodeAccount:
            msg = NSLocalizedString("invalidReceivingNodeAccount", comment: "")
        case .missingQueryHeader:
            msg = NSLocalizedString("missingQueryHeader", comment: "")
        case .accountUpdateFailed:
            msg = NSLocalizedString("accountUpdateFailed", comment: "")
        case .invalidKeyEncoding:
            msg = NSLocalizedString("invalidKeyEncoding", comment: "")
        case .nullSolidityAddress:
            msg = NSLocalizedString("nullSolidityAddress", comment: "")
        case .contractUpdateFailed:
            msg = NSLocalizedString("contractUpdateFailed", comment: "")
        case .invalidQueryHeader:
            msg = NSLocalizedString("invalidQueryHeader", comment: "")
        case .invalidFeeSubmitted:
            msg = NSLocalizedString("invalidFeeSubmitted", comment: "")
        case .invalidPayerSignature:
            msg = NSLocalizedString("invalidPayerSignature", comment: "")
        case .keyNotProvided:
            msg = NSLocalizedString("keyNotProvided", comment: "")
        case .invalidExpirationTime:
            msg = NSLocalizedString("invalidExpirationTime", comment: "")
        case .noWaclKey:
            msg = NSLocalizedString("noWaclKey", comment: "")
        case .fileContentEmpty:
            msg = NSLocalizedString("fileContentEmpty", comment: "")
        case .invalidAccountAmounts:
            msg = NSLocalizedString("invalidAccountAmounts", comment: "")
        case .emptyTransactionBody:
            msg = NSLocalizedString("emptyTransactionBody", comment: "")
        case .invalidTransactionBody:
            msg = NSLocalizedString("invalidTransactionBody", comment: "")
        case .accountRepeatedInAccountAmounts:
            msg = NSLocalizedString("accountRepeatedInAccountAmounts", comment: "")
        default:
            msg = String.init(describing: self)
        }
        return msg
    }
}

extension Error {
    var isRPCError: Bool {
        return ((self as? RPCError) != nil)
    }
}
