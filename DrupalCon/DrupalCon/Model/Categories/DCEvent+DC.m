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

#import "DCEvent+DC.h"
#import "DCTimeRange+DC.h"
#import "DCTime+DC.h"
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
        type = [[DCMainProxy sharedProxy] typeForID:0];
//        type = [[DCMainProxy sharedProxy] createType];
//        type.name = @"noname";
//        type.typeID = @(typeID);
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

- (UIImage*)imageForEvent
{
    NSString * icon_name = nil;

    switch ([self.type.typeID integerValue]) {
        case DC_EVENT_24h:
            icon_name = @"program_24_hour";
            break;
            
        case DC_EVENT_GROUP:
            icon_name = @"program_group_photo";
            break;
            
        case DC_EVENT_SPEACH_OF_DAY:
            icon_name = @"program_key_event";
            break;
            
        case DC_EVENT_NONE:
        case DC_EVENT_SPEACH:
            icon_name = @"ic_program_clock";
            break;
            
        case DC_EVENT_WALKING:
            icon_name = @"program_walking_break";
            break;
            
        case DC_EVENT_LUNCH:
            icon_name = @"ic_program_lunch";
            break;
            
        case DC_EVENT_COFEE_BREAK:
            icon_name = @"ic_program_coffe";
            break;
            
        case DC_EVENT_REGISTRATION:
            icon_name = @"program_check_in";
            break;
            
        default:
            break;
    }
    return [UIImage imageNamed:icon_name];
}

- (NSDate *)startDate {
    unsigned unitFlags      = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSCalendar *calendar    = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:unitFlags fromDate:self.date];
    comps.hour              = [self.timeRange.from.hour integerValue];
    comps.minute            = [self.timeRange.from.minute integerValue];
    comps.second            = 00;
    return [calendar dateFromComponents:comps];
}

- (NSDate *)endDate {
    unsigned unitFlags      = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSCalendar *calendar    = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:unitFlags fromDate:self.date];
    comps.hour              = [self.timeRange.to.hour integerValue];
    comps.minute            = [self.timeRange.to.minute integerValue];
    comps.second            = 00;
    return [calendar dateFromComponents:comps];
}

@end
