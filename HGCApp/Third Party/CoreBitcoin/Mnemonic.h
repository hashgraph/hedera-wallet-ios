// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.
//
// Original: https://github.com/oleganza/CoreBitcoin/blob/4d85239705090079a8664afd28d690ccbeb8f929/CoreBitcoin/BTCMnemonic.h
//
//  Modifications Copyright 2019-2020 Hedera Hashgraph LLC
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

#import <Foundation/Foundation.h>

/// Implementation of a BIP 39 mnemonic code for encoding the entropy from which deterministic keys are generated.
@interface Mnemonic : NSObject

/// Raw entropy buffer used as an input.
@property(nonatomic, readonly) NSData *entropy;

/// A list of BIP 39 words composed from the rawEntropy using the specified wordlist.  Within the wallet UI, this list of words is called the recovery phrase.
/// The recovery phrase can be written down by the user and used to recover the seed.
@property(nonatomic, readonly) NSArray<NSString *> *words;

/// Inits mnemonic with a raw entropy buffer.  The `entropy` must be 32 bytes in length (including the checksum).  Returns nil if entropy has incorrect size.
- (id) initWithEntropy:(NSData*)entropy;

/// Inits mnemonic with user's words from the BIP 39 word list.  Returns nil if there are not exactly 24 words, if any of the words are not in the word list, or the
/// checksum is invalid.
- (id) initWithWords:(NSArray<NSString *>*)words;

/// Inits mnemonic with user's words from the BIP 39 word list, and an optional password.  If `password` is nil, it is treated as an empty string.  Returns nil if there are
/// not exactly 24 words, if any of the words are not in the word list, or the checksum is invalid.
+ (NSData*) seedForWords:(NSArray*)words password:(NSString*)password;

@end
