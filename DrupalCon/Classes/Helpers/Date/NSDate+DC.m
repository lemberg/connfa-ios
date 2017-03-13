
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
      components:NSCalendarUnitEra| NSCalendarUnitYear | NSCalendarUnitMonth |
                 NSCalendarUnitDay
        fromDate:date];
  NSDateComponents* today = [[NSCalendar currentGregorianCalendar]
      components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth |
                 NSCalendarUnitDay
        fromDate:[NSDate date]];
  today.timeZone = [DCMainProxy sharedProxy].eventTimeZone;
  if ([today day] == [otherDay day] && [today month] == [otherDay month] &&
      [today year] == [otherDay year] && [today era] == [otherDay era]) {
    return YES;
  } else
    return NO;
}

+ (NSString *)currentDateFormat {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setLocale:[NSLocale currentLocale]];
  [formatter setDateStyle:NSDateFormatterNoStyle];
  [formatter setTimeStyle:NSDateFormatterShortStyle];
  
  return  formatter.dateFormat;
}

+ (BOOL) is24hourFormat {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setLocale:[NSLocale currentLocale]];
  [formatter setDateStyle:NSDateFormatterNoStyle];
  [formatter setTimeStyle:NSDateFormatterShortStyle];
  BOOL is24h = [formatter.dateFormat containsString:@"a"];

  return !is24h;
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
  calendar.timeZone = [DCMainProxy sharedProxy].eventTimeZone;
  NSDateComponents* components =
      [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute)
                  fromDate:date];
  float hour = (float)[components hour];
  float minute = (float)[components minute];
  return hour + minute / 60.0;
}

+ (float)currentHour {
  NSDate* date = [NSDate date];
  NSDate *dateInEventTimeZone = [date dateByAddingTimeInterval:[DCMainProxy sharedProxy].eventTimeZone.secondsFromGMT];
  NSCalendar* calendar = [NSCalendar currentGregorianCalendar];
  [calendar setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"]];
  calendar.timeZone = [DCMainProxy sharedProxy].eventTimeZone;
  NSDateComponents* components =
      [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute)
                  fromDate:dateInEventTimeZone];
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
