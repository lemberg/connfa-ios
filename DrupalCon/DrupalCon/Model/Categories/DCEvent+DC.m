//
//  DCEvent+DC.m
//  DrupalCon
//
//  Created by Volodymyr Hyrka on 8/20/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCEvent+DC.h"
#import "DCTimeRange+DC.h"
#import "DCType+DC.h"
#import "DCSpeaker+DC.h"
#import "DCLevel+DC.h"
#import "DCTrack+DC.h"
#import "DCMainProxy+Additions.h"
#import "NSString+HTML.h"

const NSString * kDCEvent_days_key = @"days";
const NSString * kDCEvent_date_key = @"date";
const NSString * kDCEvent_from_key = @"from";
const NSString * kDCEvent_to_key = @"to";
const NSString * kDCEvent_type_key = @"type";
const NSString * kDCEvent_name_key = @"name";
const NSString * kDCEvent_speakers_key = @"speakers";
const NSString * kDCEvent_track_key = @"track";
const NSString * kDCEvent_experienceLevel_key = @"experienceLevel";
const NSString * kDCEvent_eventId_key = @"eventID";
const NSString * kDCEvent_text_key = @"text";
const NSString * kDCEvent_place_key = @"place";

@implementation DCEvent (DC)


+ (void)parseFromJSONData:(NSData *)jsonData
{

}

- (NSArray*)speakersNames
{
    NSMutableArray * speakerNames = [[NSMutableArray alloc] initWithCapacity:self.speakers.count];
    for (DCSpeaker * speaker in self.speakers)
    {
        [speakerNames addObject:(NSString*)speaker.name];
    }
    return speakerNames;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"%@ (%@ %@)", self.name, self.date, [self.timeRange stringValue]];
}

- (NSInteger)getTypeID
{
    return [self.type.typeID integerValue];
}

+ (void)parseEventFromDictionaty:(NSDictionary *)eventDict toObject:(DCEvent *)object forDate:(NSDate *)date
{
    object.date = date;
    object.eventID = eventDict[kDCEvent_eventId_key];
    object.name = eventDict[kDCEvent_name_key];
    object.favorite = @NO;
    object.place = [eventDict[kDCEvent_place_key] kv_decodeHTMLCharacterEntities];
    object.desctiptText = eventDict[kDCEvent_text_key]; //kv_decodeHTMLCharacterEntities];
    object.timeRange = [[DCMainProxy sharedProxy] createTimeRange];
    [object.timeRange setFrom:eventDict[kDCEvent_from_key] to:eventDict[kDCEvent_to_key]];
    
    [object addTypeForID:[eventDict[kDCEvent_type_key] integerValue]];
    [object addSpeakersForIds:eventDict[kDCEvent_speakers_key]];
    [object addLevelForID:[eventDict[kDCEvent_experienceLevel_key] integerValue]];
    [object addTrackForId:[eventDict[kDCEvent_track_key] integerValue]];
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
            speaker.name = @"";
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
        level.name = @"";
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
        track.name = @"";
    }
    [track addEventsObject:self];
}

@end
