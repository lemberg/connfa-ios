
#import "NSCalendar+DC.h"

@implementation NSCalendar (DC)

+ (NSCalendar*)currentGregorianCalendar {
  NSCalendar* gregorian =
      [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
  gregorian.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];

  return gregorian;
}

@end
