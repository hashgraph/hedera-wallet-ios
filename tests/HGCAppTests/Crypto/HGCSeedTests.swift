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
@testable import HGCApp

class HGCSeedTests: HGCAppTests {
    
    // Entropy
    func testSeedCreatedByEntropy() {
        let entropy = "aabbccdd11223344aabbccdd11223344aaaaaaaabbbbcc213344aaaaaaaabbbb".hexadecimal()!
        let seed = HGCSeed.init(entropy: entropy)
        XCTAssertEqual(seed!.toWords().joined(separator: " "), "casual echo flesh tribal run react crunch cure pair sum skip fled castle floor crunch deputy run react castle fled cruise ethnic")
        XCTAssertEqual(seed!.toBIP39Words().joined(separator: " "), "primary taxi dance car case pelican priority kangaroo tackle math mimic matter primary fetch priority jazz slow another spell fetch primary fetch upon hip")
        
        XCTAssertTrue(seed!.entropy.count == 32)
        
        let mnemonic = Mnemonic.init(entropy: entropy)
        let words = mnemonic?.words
        
        let mnemonic1 = Mnemonic.init(words: words)
        let entropy1 = mnemonic1?.entropy
        XCTAssertEqual(entropy.toHexString(), entropy1?.toHexString())
        
    }
    
    func testSeedCreationFailsOnSmallerEntropy() {
        let entropy = "aabbccdd11223344aabbccdd11223344aaaaaaaabbbb".hexadecimal()!
        let seed = HGCSeed.init(entropy: entropy)
        XCTAssertTrue(seed == nil)
    }
    
    func testSeedCreationFailsOnBiggerEntropy() {
        let entropy = "aabbccdd11223344aabbccdd11223344aaaaaaaabbbbcc213344aaaaaaaabbbb2312".hexadecimal()!
        let seed = HGCSeed.init(entropy: entropy)
        XCTAssertTrue(seed == nil)
    }
    
    func testSeedCreationFailsOnEmptyEntropy() {
        let entropy = Data.init()
        let seed = HGCSeed.init(entropy: entropy)
        XCTAssertTrue(seed == nil)
    }
    
    // Words
    func testSeedCreatedByWords() {
        let words = ["casual","echo","flesh","tribal",
                     "run","react","crunch","cure",
                     "pair","sum","skip","fled",
                     "castle","floor","crunch","deputy",
                     "run","react","castle","fled",
                     "cruise","ethnic"]
        let seed = HGCSeed.init(words: words)
        XCTAssertEqual(seed?.entropy.hex, "aabbccdd11223344aabbccdd11223344aaaaaaaabbbbcc213344aaaaaaaabbbb");
        XCTAssert(seed!.entropy.count == 32)
    }
    
    func testSeedCreatedByBip39Words() {
        let words = "primary taxi dance car case pelican priority kangaroo tackle math mimic matter primary fetch priority jazz slow another spell fetch primary fetch upon hip".components(separatedBy: " ")
        let seed = HGCSeed.init(bip39Words: words)
        XCTAssertEqual(seed?.entropy.hex, "aabbccdd11223344aabbccdd11223344aaaaaaaabbbbcc213344aaaaaaaabbbb");
        XCTAssert(seed!.entropy.count == 32)
    }
    
    func testSeedCreationFalisOnInvalidWord() {
        // word "trademill" is not a valid word
        let words = ["casual","echo","flesh","tribal",
                     "trademill","react","crunch","cure",
                     "pair","sum","skip","fled",
                     "castle","floor","crunch","deputy",
                     "run","react","castle","fled",
                     "cruise","ethnic"]
        let seed = HGCSeed.init(words: words)
        XCTAssert(seed == nil)
    }
    
    func testSeedCreationFalisOnInvalidWordSequence() {
        // words are not in valid sequence
        let words = ["casual","echo","flesh","tribal",
                     "run","react","crunch","cure",
                     "pair","sum","skip","fled",
                     "castle","floor","crunch","deputy",
                     "run","react","castle","fled",
                     "cruise","run"]
        let seed = HGCSeed.init(words: words)
        XCTAssert(seed == nil)
    }
    
    func testBip39ComaptibilityWithLedgerWallet() {
        let words = "draft struggle fitness mimic mountain rare lonely grocery topple wreck satoshi kangaroo balcony odor tiger crush bamboo parent monkey afraid elite earn hundred learn"
        let seed = Mnemonic.seed(forWords: words.components(separatedBy: " "), password: "")!
    XCTAssertEqual("60691cded1328c5799e36d72aec3842b5230d376ce9b1177b3dc8c79d2d715b099c486fbf91a93ebadcaf473fafa79d5d694c013bcc561c130c447e3f84659f4",seed.hex)
        let ckd = Ed25519Derivation.init(seed: seed).derived(at: 44).derived(at: 3030).derived(at: 0).derived(at: 0).derived(at: 0)
        let publicKeyHex = HGCEdKeyPair.init(seed: ckd.raw).publicKeyString
        XCTAssertEqual("00516a26d75230616da9b18b27fa4d1ce68ca6dbb6db5ee42dc63f35c977310f", publicKeyHex)
    }
}
