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

extension HGCPublickKeyAddress {
    func protoKey() -> Proto_Key {
        var key = Proto_Key.init()
        switch self.type {
        case .ECDSA:
            key.ecdsa384 = self.publicKeyData
        case .ED25519:
            key.ed25519 = self.publicKeyData
        case .RSA:
            key.rsa3072 = self.publicKeyData
        }
        return key
    }
}
