//
//  NSDate+DC.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/21/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

static NSString * kDCEventDateFormat = @"dd-MM-yyyy";
static NSString * kDCEventViewOutputFormat = @"EEEE - dd MMM";

#import "NSDate+DC.h"

@implementation NSDate (DC)

+ (NSDate*)fabricateWithEventString:(NSString*)string
{
    NSDate * result = [[NSDate eventDateFormatter] dateFromString:string];
    if (!result) {
        NSLog(@"WRONG! date parse");
    }
    return result;
}

- (NSString*)pageViewDateString
{
    NSDateFormatter *outPutDateFormat = [[NSDateFormatter alloc] init];
    [outPutDateFormat setDateFormat:kDCEventViewOutputFormat];
    [outPutDateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSString *theDate = [outPutDateFormat stringFromDate:self];
    return theDate;
}

#pragma mark - private

+ (NSDateFormatter*)eventDateFormatter
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormat setDateFormat:kDCEventDateFormat];
    return dateFormat;
}

@end
