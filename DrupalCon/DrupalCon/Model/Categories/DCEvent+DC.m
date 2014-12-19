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
#import "DCType+DC.h"
#import "DCSpeaker+DC.h"
#import "DCLevel+DC.h"
#import "DCTrack+DC.h"
#import "DCMainProxy+Additions.h"
#import "NSManagedObject+DC.h"

#import "NSString+HTML.h"

const NSString * kDCEventsKey = @"events";
const NSString * kDCEventDaysKey = @"days";
const NSString * kDCEventDateKey = @"date";
const NSString * kDCEventFromKey = @"from";
const NSString * kDCEventToKey = @"to";
const NSString * kDCEventTypeKey = @"type";
const NSString * kDCEventNameKey = @"name";
const NSString * kDCEventSpeakersKey = @"speakers";
const NSString * kDCEventTrackKey = @"track";
const NSString * kDCEventExperienceLevelKey = @"experienceLevel";
const NSString * kDCEventIdKey = @"eventID";
const NSString * kDCEventTextKey = @"text";
const NSString * kDCEventPlaceKey = @"place";

@implementation DCEvent (DC)



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

#pragma mark - Update protocol method
// Overload this method in child objects
+ (void)updateFromDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context;
{}

- (void)updateFromDictionary:(NSDictionary *)eventDict forData:(NSDate *)date
{
    self.date = date;
    self.eventID = eventDict[kDCEventIdKey];
    self.name = eventDict[kDCEventNameKey];
    self.favorite = @NO;
    self.place = [eventDict[kDCEventPlaceKey] kv_decodeHTMLCharacterEntities];
    self.desctiptText = eventDict[kDCEventTextKey]; //kv_decodeHTMLCharacterEntities];
    self.timeRange = [DCTimeRange createManagedObjectInContext:self.managedObjectContext];//(DCTimeRange*)[[DCMainProxy sharedProxy] createObjectOfClass:[DCTimeRange class]];
    [self.timeRange setFrom:eventDict[kDCEventFromKey] to:eventDict[kDCEventToKey]];
    
    [self addTypeForID:[eventDict[kDCEventTypeKey] intValue]];
    [self addSpeakersForIds:eventDict[kDCEventSpeakersKey]];
    [self addLevelForID:[eventDict[kDCEventExperienceLevelKey] intValue]];
    [self addTrackForId:[eventDict[kDCEventTrackKey] intValue]];
}



- (void)addTypeForID:(int)typeID
{
    DCType * type = (DCType*)[[DCMainProxy sharedProxy] objectForID:typeID ofClass:[DCType class] inContext:self.managedObjectContext];
    if (!type)
    {
        type = [DCType createManagedObjectInContext:self.managedObjectContext];//(DCType*)[[DCMainProxy sharedProxy] createObjectOfClass:[DCType class]];
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
        DCSpeaker * speaker = (DCSpeaker*)[[DCMainProxy sharedProxy] objectForID:[speakerIdNum intValue]
                                                                         ofClass:[DCSpeaker class]
                                                                       inContext:self.managedObjectContext];
        if (!speaker)
        {
            speaker = [DCSpeaker createManagedObjectInContext:self.managedObjectContext];
            speaker.speakerId = speakerIdNum;
            speaker.name = @"";
        }
        [speaker addEventsObject:self];
    }
}

- (void)addLevelForID:(int)levelID
{
    DCLevel * level = (DCLevel*)[[DCMainProxy sharedProxy] objectForID:levelID
                                                               ofClass:[DCLevel class]
                                                             inContext:self.managedObjectContext];
    if (!level)
    {
        level = [DCLevel createManagedObjectInContext:self.managedObjectContext];
        level.levelId = @(levelID);
        level.name = @"";
        level.order = @(100);
    }
    [level addEventsObject:self];
}

-(void)addTrackForId:(int)trackId
{
    DCTrack * track = (DCTrack*)[[DCMainProxy sharedProxy] objectForID:trackId
                                                               ofClass:[DCTrack class]
                                                             inContext:self.managedObjectContext];
    if (!track)
    {
        track = [DCTrack createManagedObjectInContext:self.managedObjectContext];
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


+ (NSString*)idKey
{
    return (NSString*)kDCEventIdKey;
}


@end
