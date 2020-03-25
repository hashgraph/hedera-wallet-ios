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
import GRPC

protocol HAPIRPCProtocol {
    var cryptoClient: Proto_CryptoServiceClient { get }
    var fileClient: Proto_FileServiceClient { get }
    var timeout: GRPCTimeout { get set }
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
    var timeout: GRPCTimeout
    private var currentNodeIndex:Int = 0
    
    init(nodes:[HGCNodeVO]) {
        self.nodes = nodes
        do {
        timeout = try GRPCTimeout.seconds(15)
        }
        catch {
            fatalError("Can't make timeout of 15 seconds???")
        }
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

    var cryptoClient: Proto_CryptoServiceClient {
        let target = ConnectionTarget.hostAndPort(node.host, Int(node.port))
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        let config = ClientConnection.Configuration(target: target, eventLoopGroup: group)
        let connection = ClientConnection(configuration: config)
        var callOptions = CallOptions()
        callOptions.timeout = timeout
        let client = Proto_CryptoServiceClient(channel: connection, defaultCallOptions: callOptions)
        return client
    }

    var fileClient: Proto_FileServiceClient {
        let target = ConnectionTarget.hostAndPort(node.host, Int(node.port))
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        let config = ClientConnection.Configuration(target: target, eventLoopGroup: group)
        let connection = ClientConnection(configuration: config)
        var callOptions = CallOptions()
        callOptions.timeout = timeout
        return Proto_FileServiceClient(channel: connection, defaultCallOptions: callOptions)
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
        var e: Error? = nil
        for _ in 1...maxRetryCount {
            do {
                Logger.instance.log(message: " >>> \(node.address())", event: .i)
                return try block()
                
            } catch {
                e = error
                var shouldRetry = false
                if let rpcStatus = error as? GRPCStatusTransformable {
                    switch rpcStatus.makeGRPCStatus().code {
                    case .unavailable:
                        shouldRetry = true
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
