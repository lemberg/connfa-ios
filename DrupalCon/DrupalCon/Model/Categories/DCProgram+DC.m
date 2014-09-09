//
//  DCProgram+DC.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/20/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCProgram+DC.h"
#import "DCEvent+DC.h"
#import "DCType+DC.h"
#import "DCTime+DC.h"
#import "DCTimeRange+DC.h"
#import "NSDate+DC.h"
#import "DCSpeaker+DC.h"
#import "DCLevel+DC.h"
#import "DCTrack+DC.h"
#import "DCMainProxy.h"
#import "NSDictionary+DC.h"

const NSString * kDCProgram_programEvents_key = @"programEvents";

@implementation DCProgram (DC)

+ (void)parceFromJSONData:(NSData *)jsonData
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
        for (NSDictionary * event in day[kDCProgram_programEvents_key])
        {
            DCProgram * programInstance = [[DCMainProxy sharedProxy] createProgramItem];
            programInstance.date = date;
            programInstance.eventID = event[kDCEvent_eventId_key];
            programInstance.name = event[kDCEvent_name_key];
            programInstance.favorite = @NO;
            programInstance.place = event[kDCEvent_place_key];
            programInstance.desctiptText = event[kDCEvent_text_key];
            programInstance.timeRange = [[DCMainProxy sharedProxy] createTimeRange];
            [programInstance.timeRange setFrom:event[kDCEvent_from_key] to:event[kDCEvent_to_key]];
            
            [programInstance addTypeForID:[event[kDCEvent_type_key] integerValue]];
            [programInstance addSpeakersForIds:event[kDCEvent_speakers_key]];
            [programInstance addLevelForID:[event[kDCEvent_experienceLevel_key] integerValue]];
            [programInstance addTrackForId:[event[kDCEvent_track_key] integerValue]];
        }
    }
}


@end
