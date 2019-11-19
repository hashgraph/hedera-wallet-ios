#import <Foundation/Foundation.h>

@interface Mnemonic : NSObject

@property(nonatomic, readonly) NSData *entropy;
@property(nonatomic, readonly) NSArray<NSString *> *words;


- (id) initWithEntropy:(NSData*)entropy;
- (id) initWithWords:(NSArray<NSString *>*)words;
+ (NSData*) seedForWords:(NSArray*)words password:(NSString*)password;

@end
