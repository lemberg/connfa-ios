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

const NSString * kDCEvent_days_key = @"days";
const NSString * kDCEvent_date_key = @"date";
const NSString * kDCEvent_from_key = @"from";
const NSString * kDCEvent_to_key = @"to";
const NSString * kDCEvent_type_key = @"type";
const NSString * kDCEvent_name_key = @"name";
const NSString * kDCEvent_speakers_key = @"speakers";
const NSString * kDCEvent_track_key = @"track";
const NSString * kDCEvent_experienceLevel_key = @"experience_level";
const NSString * kDCEvent_eventId_key = @"event_id";

@implementation DCEvent (DC)


+ (void)parceFromJSONData:(NSData *)jsonData
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

@end
