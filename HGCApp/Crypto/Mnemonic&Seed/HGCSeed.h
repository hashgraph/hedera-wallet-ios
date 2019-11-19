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

#import <Foundation/Foundation.h>

@interface HGCSeed : NSObject

@property (nonatomic, readonly) NSData *entropy;

+ (instancetype) seedWithEntropy:(NSData *)entropy; // 32 Bytes
+ (instancetype) seedWithWords:(NSArray<NSString *> *)words; // 22 words
+ (instancetype) seedWithBip39Words:(NSArray<NSString *> *)words; // 24 words


- (NSArray<NSString *> *)toWords;
- (NSArray<NSString *> *)toBIP39Words;

@end
