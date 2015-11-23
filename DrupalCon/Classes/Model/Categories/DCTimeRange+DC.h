
#import "DCTimeRange.h"

@interface DCTimeRange (DC)

- (void)setFrom:(NSString*)from to:(NSString*)to;
- (BOOL)isEqualTo:(DCTimeRange*)timeRange;

- (NSString*)stringValue;

@end
