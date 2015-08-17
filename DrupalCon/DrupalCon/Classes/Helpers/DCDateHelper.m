//
//  DCDateHelper.m
//  DrupalCon
//
//  Created by Olexandr on 7/7/15.
//  Copyright (c) 2015 Lemberg Solution. All rights reserved.
//

#import "DCDateHelper.h"
#import "NSDate+DC.h"

@implementation DCDateHelper

+ (NSString *)convertDate:(NSDate *)date toApplicationFormat:(NSString *)format
{
    NSDate *eventLocalTime = [date dateByAddingTimeInterval:[[DCMainProxy sharedProxy] eventTimeZone].secondsFromGMT];
    return [eventLocalTime dateToStringWithFormat:format];
}

+ (NSString *)convertDate:(NSDate *)date toDefaultTimeFormat:(NSString *)format
{
    return [date dateToStringWithFormat:format];
}
@end
