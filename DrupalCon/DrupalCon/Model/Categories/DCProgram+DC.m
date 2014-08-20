//
//  DCProgram+DC.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/20/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCProgram+DC.h"
#import "DCEvent+DC.h"
#import "DCMainProxy.h"

@implementation DCProgram (DC)

+ (void)parceFromJSONData:(NSData *)jsonData
{
    NSError * err = nil;
    NSDictionary * eventItems = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:kNilOptions
                                                                  error:&err];
    if (err)
    {
        NSLog(@"WRONG! json");
        return;
    }
    
    for (NSDictionary * day in eventItems[kDCEvent_days_key])
    {
        NSDate * date = day[kDCEvent_date_key];
        for (NSDictionary * event in day[kDCEvent_events_key])
        {
            DCProgram * programInstance = [[DCMainProxy sharedProxy] createProgramItem];
            programInstance.date = date;
            programInstance.name = event[kDCEvent_name_key];
            programInstance.favorite = @NO;
            programInstance.place = @"n/a";
//            [programInstance addTracksObject:]
            
        }
    }
}

@end
