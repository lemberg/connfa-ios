
#import "NSCalendar+DC.h"

@implementation NSCalendar (DC)

+ (NSCalendar*)currentGregorianCalendar {
  NSCalendar* gregorian =
      [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
  gregorian.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];

  return gregorian;
}

@end
