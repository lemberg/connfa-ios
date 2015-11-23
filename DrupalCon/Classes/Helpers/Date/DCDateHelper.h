
#import <Foundation/Foundation.h>

@interface DCDateHelper : NSObject

+ (NSString*)convertDate:(NSDate*)date toApplicationFormat:(NSString*)format;
+ (NSString*)convertDate:(NSDate*)date toDefaultTimeFormat:(NSString*)format;

@end
