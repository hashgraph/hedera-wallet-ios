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
