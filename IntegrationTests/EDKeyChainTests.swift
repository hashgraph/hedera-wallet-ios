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

import XCTest
@testable import HederaWallet

class EDKeyChainTests: XCTestCase {
    
    var keyChain : EDKeyChain? {
        get {
            let seed = HGCSeed.init(entropy: "aabbccdd11223344aabbccdd11223344aaaaaaaabbbbcc213344aaaaaaaabbbb".hexadecimal()! as Data)
            return EDKeyChain.init(hgcSeed: seed!)
        }
    }
    
    func testKeyChainCreation() {
        XCTAssert(self.keyChain != nil)
    }
    
    func testChileKeyCreation() {
        let key0 = keyChain!.key(at: 0)
        XCTAssert(key0 != nil)
        print(key0!.publicKeyData.hex)
        let key1 = keyChain?.key(at: 1)
        XCTAssert(key1 != nil)
        print(key1!.publicKeyData.hex)
    }
    
}
