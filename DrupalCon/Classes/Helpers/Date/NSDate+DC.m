
static NSString* kDCEventDateFormat = @"dd-MM-yyyy";
static NSString* kDCEventViewOutputFormat = @"EEEE dd ";
static NSString* kDCSpeakerEventCellFormat = @"dd LLLL";

#define T_ZERO [NSTimeZone timeZoneForSecondsFromGMT:0]

#import "NSDate+DC.h"
#import "NSCalendar+DC.h"

@implementation NSDate (DC)

+ (NSDate*)fabricateWithEventString:(NSString*)string {
  NSDate* result = [[NSDate eventDateFormatter] dateFromString:string];
  if (!result) {
    NSLog(@"WRONG! date parse");
  }
  return result;
}

+ (BOOL)dc_isDateInToday:(NSDate*)date {
  NSDateComponents* otherDay = [[NSCalendar currentGregorianCalendar]
      components:NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit |
                 NSDayCalendarUnit
        fromDate:date];
  NSDateComponents* today = [[NSCalendar currentGregorianCalendar]
      components:NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit |
                 NSDayCalendarUnit
        fromDate:[NSDate date]];
  today.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
  if ([today day] == [otherDay day] && [today month] == [otherDay month] &&
      [today year] == [otherDay year] && [today era] == [otherDay era]) {
    return YES;
  } else
    return NO;
}


+ (BOOL)is24hourFormat {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setLocale:[NSLocale currentLocale]];
  [formatter setDateStyle:NSDateFormatterNoStyle];
  [formatter setTimeStyle:NSDateFormatterShortStyle];
  NSString *dateString = [formatter stringFromDate:[NSDate date]];
  NSRange amRange = [dateString rangeOfString:[formatter AMSymbol]];
  NSRange pmRange = [dateString rangeOfString:[formatter PMSymbol]];
  BOOL is24h = (amRange.location == NSNotFound && pmRange.location == NSNotFound);
  return is24h;
}

+ (NSDate*)dateFromString:(NSString*)formattedDate
                   format:(NSString*)dateFormat {
  if (![formattedDate isKindOfClass:[NSString class]]) {
    return nil;
  }

  NSDateFormatter* dateFormatter = [NSDateFormatter new];
  [dateFormatter
      setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
  [dateFormatter setDateFormat:dateFormat];

  return [dateFormatter dateFromString:formattedDate];
}

- (NSString*)dateToStringWithFormat:(NSString*)dateFormat {
  NSDateFormatter* dateFormatter = [NSDateFormatter new];
  dateFormatter.timeZone = T_ZERO;
  [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
  [dateFormatter setDateStyle:NSDateFormatterShortStyle];
  [dateFormatter setDateFormat:dateFormat];
  return [dateFormatter stringFromDate:self];
}

+ (float)hoursFromDate:(NSDate*)date {
  NSCalendar* calendar = [NSCalendar currentGregorianCalendar];
  NSDateComponents* components =
      [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit)
                  fromDate:date];
  float hour = (float)[components hour];
  float minute = (float)[components minute];
  return hour + minute / 60.0;
}

+ (float)currentHour {
  NSDate* date = [NSDate date];
  NSCalendar* calendar = [NSCalendar currentGregorianCalendar];
  [calendar setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"]];
  NSDateComponents* components =
      [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit)
                  fromDate:date];
  float hour = (float)[components hour] + (float)[components minute] / 60;
  return hour;
}

#pragma mark - private

+ (NSDateFormatter*)eventDateFormatter {
  NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
  [dateFormat setTimeZone:T_ZERO];
  [dateFormat setDateFormat:kDCEventDateFormat];
  return dateFormat;
}

@end
