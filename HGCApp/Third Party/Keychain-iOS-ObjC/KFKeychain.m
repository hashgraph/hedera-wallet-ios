// Original: https://github.com/Keyflow/Keychain-iOS-ObjC/blob/3f72d5be25d0f650a2fc959d11f2914828feb674/KFKeychain.m
//
// Modified for key accessibility type.
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

#import "KFKeychain.h"

@implementation KFKeychain

+ (BOOL)checkOSStatus:(OSStatus)status {
    return status == noErr;
}

+ (NSMutableDictionary *)keychainQueryForKey:(NSString *)key accessibilityType:(CFStringRef)accessibilityType {
    return [@{(__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword,
              (__bridge id)kSecAttrService : key,
              (__bridge id)kSecAttrAccount : key,
              (__bridge id)kSecAttrAccessible : (__bridge id) accessibilityType
    } mutableCopy];
}

+ (BOOL)saveObject:(id)object forKey:(NSString *)key {
    NSMutableDictionary *keychainQuery = [self keychainQueryForKey:key accessibilityType:kSecAttrAccessibleWhenUnlocked];
    // Deleting previous object with this key, because SecItemUpdate is more complicated.
    [self deleteObjectForKey:key];

    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:object] forKey:(__bridge id)kSecValueData];
    return [self checkOSStatus:SecItemAdd((__bridge CFDictionaryRef)keychainQuery, NULL)];
}

+ (id)loadObjectForKey:(NSString *)key accessibilityType:(CFStringRef)accessibilityType {
    id object = nil;

    NSMutableDictionary *keychainQuery = [self keychainQueryForKey:key accessibilityType:kSecAttrAccessibleWhenUnlocked];

    [keychainQuery setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [keychainQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];

    CFDataRef keyData = NULL;

    if ([self checkOSStatus:SecItemCopyMatching((__bridge CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData)]) {
        @try {
            object = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        }
        @catch (NSException *exception) {
            NSLog(@"Unarchiving for key %@ failed with exception %@", key, exception.name);
            object = nil;
        }
        @finally {}
    }

    if (keyData) {
        CFRelease(keyData);
    }

    return object;
}

+ (BOOL)deleteObjectForKey:(NSString *)key {
    NSMutableDictionary *keychainQuery = [self keychainQueryForKey:key accessibilityType:kSecAttrAccessibleWhenUnlocked];
    return [self checkOSStatus:SecItemDelete((__bridge CFDictionaryRef)keychainQuery)];
}

+ (BOOL)deleteObjectForKey:(NSString *)key accessibilityType:(CFStringRef)accessibilityType{
    NSMutableDictionary *keychainQuery = [self keychainQueryForKey:key accessibilityType:accessibilityType];
    return [self checkOSStatus:SecItemDelete((__bridge CFDictionaryRef)keychainQuery)];
}

+ (id)loadObjectForKey:(NSString *)key {
    id obj = [KFKeychain loadObjectForKey:key accessibilityType:kSecAttrAccessibleWhenUnlocked];
    if (obj) {
        return obj;
    } else {
        obj = [KFKeychain loadObjectForKey:key accessibilityType:kSecAttrAccessibleAfterFirstUnlock];
        if (obj != nil && [KFKeychain saveObject:obj forKey:key]) {
            [KFKeychain deleteObjectForKey:key accessibilityType:kSecAttrAccessibleAfterFirstUnlock];
        }
        return obj;
    }
}

@end
