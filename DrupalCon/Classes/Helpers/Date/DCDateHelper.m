
#import "DCDateHelper.h"
#import "NSDate+DC.h"

@implementation DCDateHelper

+ (NSString*)convertDate:(NSDate*)date toApplicationFormat:(NSString*)format {
  NSDate* eventLocalTime =
      [date dateByAddingTimeInterval:[[DCMainProxy sharedProxy] eventTimeZone]
                                         .secondsFromGMT];
  return [eventLocalTime dateToStringWithFormat:format];
}

+ (NSString*)convertDate:(NSDate*)date toDefaultTimeFormat:(NSString*)format {
  return [date dateToStringWithFormat:format];
}
@end
