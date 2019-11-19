#import <Foundation/Foundation.h>

@interface KeychainWrapper : NSObject

+ (BOOL)saveObject:(id)object forKey:(NSString *)key;

+ (id)loadObjectForKey:(NSString *)key;

+ (BOOL)deleteObjectForKey:(NSString *)key;

@end
