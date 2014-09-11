//
//  DCProgram+DC.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/20/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCProgram+DC.h"
#import "DCEvent+DC.h"
#import "NSDate+DC.h"
#import "DCMainProxy.h"
#import "NSDictionary+DC.h"

const NSString * kDCProgram_programEvents_key = @"programEvents";

@implementation DCProgram (DC)

+ (void)parseFromJSONData:(NSData *)jsonData
{
    NSError * err = nil;
    NSDictionary * eventItems = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:kNilOptions
                                                                  error:&err];
    eventItems = [eventItems dictionaryByReplacingNullsWithStrings];
    if (err)
    {
        NSLog(@"WRONG! json");
        @throw [NSException exceptionWithName:INVALID_JSON_EXCEPTION reason:@"Problem in json structure" userInfo:nil];
        return;
    }
    
    for (NSDictionary * day in eventItems[kDCEvent_days_key])
    {
        NSDate * date = [NSDate fabricateWithEventString:day[kDCEvent_date_key]];
        for (NSDictionary * event in day[kDCProgram_programEvents_key])
        {
            DCProgram * programInstance = [[DCMainProxy sharedProxy] createProgramItem];
            [DCProgram parseEventFromDictionaty:event toObject:programInstance forDate:date];
        }
    }
}


@end
