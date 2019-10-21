//
//  MockRPC.swift
//  HGCApp
//
//  Created by Surendra on 30/08/19.
//  Copyright © 2019 HGC. All rights reserved.
//

import UIKit
@testable import HGCApp

class MockRPC: HAPIRPCProtocol {
    var queryResponse: Proto_Response?
    var txnResponse: Proto_TransactionResponse?
    var error: Error?
    
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
    
    var timeout: TimeInterval = 0
    
    var node: HGCNodeVO = HGCNodeVO.init(host: "", port: 0, accountID: HGCAccountID.init(shardId: 0, realmId: 0, accountId: 0))
    
    func perform(_ param: QueryParams, _ txnBuilder: TransactionBuilder) throws -> (query: Proto_Query, response: Proto_Response) {
        if let r = queryResponse {
            return (param.getPayload(txnBuilder), r)
        } else if let e = error {
            throw e
        } else {
            throw NSError.init(domain: "", code: 0, userInfo: nil)
        }
    }
    
    func perform(_ param: TransactionParams, _ txnBuilder: TransactionBuilder) throws -> (transaction: Proto_Transaction, response: Proto_TransactionResponse) {
        if let r = txnResponse {
            return (param.getPayload(txnBuilder), r)
        } else if let e = error {
            throw e
        } else {
            throw NSError.init(domain: "", code: 0, userInfo: nil)
        }
    }
    

}
