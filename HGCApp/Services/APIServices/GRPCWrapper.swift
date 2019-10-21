//
//  GRPCWrapper.swift
//  HGCApp
//
//  Created by Surendra on 27/06/19.
//  Copyright © 2019 HGC. All rights reserved.
//

import UIKit
import SwiftGRPC

protocol HAPIRPCProtocol {
    var cryptoClient: Proto_CryptoServiceServiceClient { get }
    var tokenClient: Proto_SmartContractServiceServiceClient { get }
    var fileClient: Proto_FileServiceServiceClient { get }
    var timeout:TimeInterval { get set }
    var node: HGCNodeVO { get }

    func perform(_ param:QueryParams, _ txnBuilder:TransactionBuilder) throws -> (query:Proto_Query, response:Proto_Response)
    
    func perform(_ param:TransactionParams, _ txnBuilder:TransactionBuilder) throws -> (transaction:Proto_Transaction, response:Proto_TransactionResponse)
}

protocol TransactionParams {
    func getPayload(_ txnBuilder:TransactionBuilder) -> Proto_Transaction
    func perform(transaction:Proto_Transaction, rpc:HAPIRPCProtocol) throws -> Proto_TransactionResponse
}

protocol QueryParams {
    func getPayload(_ txnBuilder:TransactionBuilder) -> Proto_Query
    func perform(query:Proto_Query, rpc:HAPIRPCProtocol) throws -> Proto_Response
}

class GRPCWrapper : HAPIRPCProtocol {
    var nodes:[HGCNodeVO]
    var timeout:TimeInterval = 15
    private var currentNodeIndex:Int = 0
    
    init(nodes:[HGCNodeVO]) {
        self.nodes = nodes
        currentNodeIndex = randomIndex
    }
    
    var node: HGCNodeVO {
        return nodes[currentNodeIndex]
    }
    
    private var randomIndex: Int {
        if nodes.count > 0 {
            let index = Int(arc4random_uniform(UInt32(nodes.count)))
            if index >= 0 && index < nodes.count {
                return index
            }
        }
        return 0
    }
    
    private var maxRetryCount:Int {
        return max(min(( nodes.count * 2 ) / 3, 10), 1)
    }
    
    var cryptoClient: Proto_CryptoServiceServiceClient {
        let client = Proto_CryptoServiceServiceClient.init(address: node.address(), secure: false)
        client.timeout = timeout
        return client
    }
    
    var tokenClient: Proto_SmartContractServiceServiceClient {
        return Proto_SmartContractServiceServiceClient.init(address: node.address(), secure: false)
    }
    
    var fileClient: Proto_FileServiceServiceClient {
        return Proto_FileServiceServiceClient.init(address: node.address(), secure: false)
    }
    
    func perform(_ param:QueryParams, _ txnBuilder:TransactionBuilder) throws -> (query:Proto_Query, response:Proto_Response) {
        return try perform {
            txnBuilder.node = node.accountID
            let query = param.getPayload(txnBuilder)
            Logger.instance.log(message: query.toString(), event: .i)
            let res = try param.perform(query:query, rpc: self)
            Logger.instance.log(message: res.textFormatString(), event: .i)
            return (query, res)
        }
    }
    
    func perform(_ param:TransactionParams, _ txnBuilder:TransactionBuilder) throws -> (transaction:Proto_Transaction, response:Proto_TransactionResponse) {
        return try perform {
            txnBuilder.node = node.accountID
            let transaction = param.getPayload(txnBuilder)
            Logger.instance.log(message: transaction.toString(), event: .i)
            let res = try param.perform(transaction:transaction, rpc: self)
            Logger.instance.log(message: res.textFormatString(), event: .i)
            return (transaction, res)
        }
    }
    
     func perform<T>(_ block:(() throws -> T)) throws -> T {
        var e:Error? = nil
        for _ in 1...maxRetryCount {
            do {
                Logger.instance.log(message: " >>> \(node.address())", event: .i)
                return try block()
                
            } catch {
                e = error
                var shouldRetry = false
                if let rpcError = error as? RPCError {
                    switch rpcError {
                    case .callError(let result):
                        switch result.statusCode {
                        case .unavailable:
                            shouldRetry = true
                        default:
                            break
                        }
                    default:
                        break
                    }
                }
                if shouldRetry && nodes.count > 1 {
                    nodes.remove(at: currentNodeIndex)
                    currentNodeIndex = randomIndex
                } else {
                    break
                }
            }
        }
        throw e!
    }
}

extension Proto_Query {
    func toString() -> String {
        var payment = cryptogetAccountBalance.header.payment
        if cryptoGetAccountRecords.hasHeader {
            payment = cryptoGetAccountRecords.header.payment
        } else if fileGetContents.hasHeader {
            payment = fileGetContents.header.payment
        } else if cryptoGetInfo.hasHeader {
            payment = cryptoGetInfo.header.payment
        }
        
        let paymentBody = payment.transactionBody()
        return textFormatString() + "\n" + "paymentBody: " + paymentBody.textFormatString()
    }
}

extension Proto_Transaction {
    func toString() -> String {
        let txnBody = self.transactionBody()
        return textFormatString() + "\n" + "transactionBody: " + txnBody.textFormatString()
    }
}
