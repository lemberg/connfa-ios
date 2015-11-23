
#import "DCTimeRange+DC.h"
#import "NSDate+DC.h"
#import "NSManagedObject+DC.h"

#import "DCMainProxy.h"

@implementation DCTimeRange (DC)

- (NSString*)stringValue {
  return
      [NSString stringWithFormat:@"%@ - %@",
                                 [self.from dateToStringWithFormat:@"h:mm aaa"],
                                 [self.to dateToStringWithFormat:@"h:mm aaa"]];
}

- (void)setFrom:(NSString*)from to:(NSString*)to {
  self.from = [NSDate dateFromString:from format:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
  self.to = [NSDate dateFromString:to format:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
}

- (BOOL)isEqualTo:(DCTimeRange*)timeRange {
  BOOL result = YES;
  if (![timeRange.from isEqualToDate:self.from]) {
    result = NO;
  }

  if (![timeRange.to isEqualToDate:self.to]) {
    result = NO;
  }

  return result;
}
- (NSString*)description {
  return [self stringValue];
}

@end
