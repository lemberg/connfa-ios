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

- (void)addTypeForID:(NSInteger)typeID
{
    DCType * type = [[DCMainProxy sharedProxy] typeForID:typeID];
    if (!type)
    {
        type = [[DCMainProxy sharedProxy] createType];
        type.name = @"noname";
        type.typeID = @(typeID);
    }
    [type addEventsObject:self];
}

- (void)addSpeakersForIds:(NSArray*)speakerIds
{
    for (NSNumber* speakerIdNum in speakerIds)
    {
        DCSpeaker * speaker = [[DCMainProxy sharedProxy] speakerForId:[speakerIdNum integerValue]];
        if (!speaker)
        {
            speaker = [[DCMainProxy sharedProxy] createSpeaker];
            speaker.speakerId = speakerIdNum;
            speaker.name = @"unknown speaker";
        }
        [speaker addEventsObject:self];
    }
}

- (void)addLevelForID:(NSInteger)levelID
{
    DCLevel * level = [[DCMainProxy sharedProxy] levelForId:levelID];
    if (!level)
    {
        level = [[DCMainProxy sharedProxy] createLevel];
        level.levelId = @(levelID);
        level.name = @"unknown";
        level.order = @(100);
    }
    [level addEventsObject:self];
}

-(void)addTrackForId:(NSInteger)trackId
{
    DCTrack * track = [[DCMainProxy sharedProxy] trackForId:trackId];
    if (!track)
    {
        track = [[DCMainProxy sharedProxy] createTrack];
        track.trackId = @(trackId);
        track.name = @"General";
    }
    [track addEventsObject:self];
}



@end
