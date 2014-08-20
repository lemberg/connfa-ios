//
//  DCDateHelper.m
//  DrupalCon
//
//  Created by Rostyslav Stepanyak on 7/31/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCDateHelper.h"

@implementation DCDateHelper

+ (NSString*) getPageViewDateStringFromString: (NSString*) dateString {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    
    NSDate *date = [dateFormat dateFromString: dateString];
    
    NSDateFormatter *outPutDateFormat = [[NSDateFormatter alloc] init];
    [outPutDateFormat setDateFormat:@"EEEE - dd MMM"];

    NSString *theDate = [outPutDateFormat stringFromDate: date];
    return theDate;
}

@end
