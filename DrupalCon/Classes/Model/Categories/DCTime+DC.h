
#import "DCTime.h"

@interface DCTime (DC)

- (void)setTime:(NSString*)time;

- (NSString*)stringValue;
- (BOOL)isTimeValid;
@end
