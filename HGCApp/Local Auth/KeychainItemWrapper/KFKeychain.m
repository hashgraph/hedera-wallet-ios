#import "KFKeychain.h"

@implementation KFKeychain

+ (BOOL)checkOSStatus:(OSStatus)status {
    return status == noErr;
}

+ (NSMutableDictionary *)keychainQueryForKey:(NSString *)key accessibilityType:(CFStringRef)accessibilityType {
    return [@{(__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword,
              (__bridge id)kSecAttrService : key,
              (__bridge id)kSecAttrAccount : key,
              (__bridge id)kSecAttrAccessible :(__bridge id) accessibilityType
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
    
    NSMutableDictionary *keychainQuery = [self keychainQueryForKey:key accessibilityType:accessibilityType];
    
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
    return [KFKeychain deleteObjectForKey:key accessibilityType:kSecAttrAccessibleWhenUnlocked] || [KFKeychain deleteObjectForKey:key accessibilityType:kSecAttrAccessibleAfterFirstUnlock];
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
