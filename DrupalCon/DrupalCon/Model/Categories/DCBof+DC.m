//
//  DCBof+DC.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 9/9/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCBof+DC.h"
#import "DCEvent+DC.h"
#import "NSDate+DC.h"
#import "DCMainProxy.h"
#import "NSDictionary+DC.h"

const NSString * kDCBof_bofEvents_key = @"bofsEvents";

@implementation DCBof (DC)


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
        return;
    }
    
    for (NSDictionary * day in eventItems[kDCEvent_days_key])
    {
        NSDate * date = [NSDate fabricateWithEventString:day[kDCEvent_date_key]];
        for (NSDictionary * event in day[kDCBof_bofEvents_key])
        {
            DCBof * bofInstance = [[DCMainProxy sharedProxy] createBofItem];
            [DCBof parseEventFromDictionaty:event toObject:bofInstance forDate:date];
        }
    }
}

@end
