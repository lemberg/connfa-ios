/**********************************************************************************
 *                                                                           
 *  The MIT License (MIT)
 *  Copyright (c) 2015 Lemberg Solutions Limited
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to
 *  deal in the Software without restriction, including without limitation the 
 *  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 *  sell copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *   The above copyright notice and this permission notice shall be included in
 *   all  copies or substantial portions of the Software.
 *
 *   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 *  FROM,  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
 *  IN THE SOFTWARE.
 *
 *                                                                           
 *****************************************************************************/



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
