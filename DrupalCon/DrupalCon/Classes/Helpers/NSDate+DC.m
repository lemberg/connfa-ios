//
//  The MIT License (MIT)
//  Copyright (c) 2014 Lemberg Solutions Limited
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//   The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

static NSString * kDCEventDateFormat = @"dd-MM-yyyy";
static NSString * kDCEventViewOutputFormat = @"EEEE dd ";
static NSString * kDCSpeakerEventCellFormat = @"dd LLLL";

#define T_ZERO [NSTimeZone timeZoneForSecondsFromGMT:0]

#import "NSDate+DC.h"

@implementation NSDate (DC)

+ (NSString*)currentUnixTimeString
{
    NSDate * now  = [NSDate date];
    NSTimeInterval interval = [now timeIntervalSince1970];
    return [NSString stringWithFormat:@"%f",interval];
}

+ (NSDate*)fabricateWithEventString:(NSString*)string
{
    NSDate * result = [[NSDate eventDateFormatter] dateFromString:string];
    if (!result) {
        NSLog(@"WRONG! date parse");
    }
    return result;
}

+ (BOOL)dc_isDateInToday:(NSDate *)date
{
    NSDateComponents *otherDay = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
    if([today day] == [otherDay day] &&
       [today month] == [otherDay month] &&
       [today year] == [otherDay year] &&
       [today era] == [otherDay era]) {
        return YES;
    } else
        return NO;
}

- (NSString*)pageViewDateString
{
    NSDateFormatter *outPutDateFormat = [[NSDateFormatter alloc] init];
    [outPutDateFormat setDateFormat:kDCEventViewOutputFormat];
    [outPutDateFormat setTimeZone:T_ZERO];
    NSString *theDate = [[outPutDateFormat stringFromDate:self] uppercaseString];
    return theDate;
}

+ (NSString *)hourFormatForDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mm aaa"];
    NSString *dateDisplay = [dateFormatter stringFromDate:date];
    return  dateDisplay;
}

#pragma mark - private

+ (NSDateFormatter*)eventDateFormatter
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:T_ZERO];
    [dateFormat setDateFormat:kDCEventDateFormat];
    return dateFormat;
}

@end
