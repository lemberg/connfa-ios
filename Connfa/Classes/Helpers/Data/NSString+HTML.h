
#import <Foundation/Foundation.h>

@interface NSString (HTML)

- (NSString*)kv_decodeHTMLCharacterEntities;
- (NSString*)kv_encodeHTMLCharacterEntities;
- (NSString*)trimmingWhiteSpace;

@end
