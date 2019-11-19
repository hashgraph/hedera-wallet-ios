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

extension HGCAccountID {
    func protoAccountID() -> Proto_AccountID {
        var acc = Proto_AccountID.init()
        acc.accountNum = accountId
        acc.realmNum = realmId
        acc.shardNum = shardId
        return acc
    }
    
    func protoContractID() -> Proto_ContractID {
        var acc = Proto_ContractID.init()
        acc.contractNum = accountId
        acc.realmNum = realmId
        acc.shardNum = shardId
        return acc
    }
}
