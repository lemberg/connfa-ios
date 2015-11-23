
#import "DCTime+DC.h"

@implementation DCTime (DC)

- (NSString*)stringValue {
  return
      [NSString stringWithFormat:@"%@:%@%@", self.hour,
                                 ([self.minute integerValue] < 5 ? @"0" : @""),
                                 self.minute];
}

- (void)setTime:(NSString*)time {
  NSArray* components = [time componentsSeparatedByString:@":"];
  if (components.count != 2) {
    NSLog(@"WRONG! time format");
    // FIXME: Set default time for event without time, add 25 to put this event
    // in the end of the list
    self.hour = @(25);
    self.minute = @(0);
    return;
  }

  self.hour = [self numberFromString:components[0]];
  self.minute = [self numberFromString:components[1]];
}

- (NSNumber*)numberFromString:(NSString*)string {
  return [NSNumber numberWithInteger:[string integerValue]];
}

- (BOOL)isTimeValid {
  return ([self.hour integerValue] <= 24);
}
@end
